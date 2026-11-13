///|
/// 变压器支路测试：变比、漏阻抗压降、与普通线路的对照、功率平衡。
///
/// 判据分两类：结构性对照（同拓扑同负荷，变比 / 阻抗不同时电压怎么变），
/// 守恒律（根注入 = 负荷 + 损耗，变比折算后的原边电流也要对上）。

///|
fn tx_near(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() <= tol
}

///|
fn tx_solve(net : @dist.DistNet) -> @dist.SweepOk raise {
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
}

///|
/// k=1 的变压器与同漏阻抗的普通线路应当逐位一致：变比不偏移时，
/// 模型退化成一条带该阻抗的线路。
test "transformer at unity ratio matches a plain line with same impedance" {
  let zt = @model.cx(0.02, 0.04)
  let z3 = @dist.z3_diag(zt, zt, zt)
  let s = @model.cx(0.10, 0.03)
  let zero = @dist.Phasor::zero()
  let v_root = @dist.Phasor::balanced(1.0, 0.0)
  let tx = match @dist.TxSpec::new(1.0, z3) {
    Ok(t) => t
    Err(e) => fail(e)
  }
  let tx_net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, zero),
      @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
    ],
    [@dist.DistEdge::make_tx(1, 2, tx)],
    1,
    v_root,
  )
  let line_net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, zero),
      @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
    ],
    [@dist.DistEdge::make(1, 2, z3)],
    1,
    v_root,
  )
  let rt = tx_solve(tx_net)
  let rl = tx_solve(line_net)
  let vt = rt.voltages()[1]
  let vl = rl.voltages()[1]
  assert_true(tx_near(@model.cx_abs(vt.a()), @model.cx_abs(vl.a()), 1.0e-12))
  assert_true(tx_near(@model.cx_abs(vt.b()), @model.cx_abs(vl.b()), 1.0e-12))
  assert_true(tx_near(@model.cx_abs(vt.c()), @model.cx_abs(vl.c()), 1.0e-12))
}

///|
/// 变比 k>1 抬高副边电压：同一台变压器、同一负荷，只改变比，
/// 副边 a 相模长应当随 k 增大而抬高。
test "higher off-nominal ratio raises the secondary voltage" {
  let base = @dist.case_with_transformer()
  let r1 = tx_solve(base)
  let edge = base.edge_at(0)
  let net2 = @dist.DistNet::make(
    base.nodes(),
    [edge.with_ratio(1.05)],
    base.root_id(),
    base.v_root(),
  )
  let r2 = tx_solve(net2)
  let v1 = @model.cx_abs(r1.voltages()[1].a())
  let v2 = @model.cx_abs(r2.voltages()[1].a())
  assert_true(v2 > v1)
  // 两种变比下电压都仍在合理区间。
  assert_true(v1 > 0.9 && v1 < 1.05)
  assert_true(v2 > 0.9 && v2 < 1.08)
}

///|
/// 变压器网络仍满足功率平衡：原边电流按 k 折算后，根注入 = 负荷 + 损耗。
test "transformer feeder keeps the active power balance" {
  let net = @dist.case_with_transformer()
  let r = tx_solve(net)
  let loss = @dist.total_loss_active(net, r)
  let load = @dist.load_demand_active(net)
  let inject = @dist.root_injection_active(net, r)
  assert_true(loss >= 0.0)
  assert_true(tx_near(inject, load + loss, 1.0e-9))
}

///|
/// 漏阻抗产生压降：同变比下，漏阻抗越大副边电压越低。
test "larger leakage impedance lowers the secondary voltage" {
  let s = @model.cx(0.10, 0.03)
  let zero = @dist.Phasor::zero()
  let v_root = @dist.Phasor::balanced(1.0, 0.0)
  let small_z = @model.cx(0.01, 0.02)
  let big_z = @model.cx(0.05, 0.08)
  let small_tx = match
    @dist.TxSpec::new(1.0, @dist.z3_diag(small_z, small_z, small_z)) {
    Ok(t) => t
    Err(e) => fail(e)
  }
  let big_tx = match
    @dist.TxSpec::new(1.0, @dist.z3_diag(big_z, big_z, big_z)) {
    Ok(t) => t
    Err(e) => fail(e)
  }
  let small_net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, zero),
      @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
    ],
    [@dist.DistEdge::make_tx(1, 2, small_tx)],
    1,
    v_root,
  )
  let big_net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, zero),
      @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
    ],
    [@dist.DistEdge::make_tx(1, 2, big_tx)],
    1,
    v_root,
  )
  let v_small = @model.cx_abs(tx_solve(small_net).voltages()[1].a())
  let v_big = @model.cx_abs(tx_solve(big_net).voltages()[1].a())
  assert_true(v_big < v_small)
}

///|
/// 非法变压器参数必须被构造层拒掉：非正变比、漏阻抗全零。
test "invalid transformer spec is rejected" {
  let z = @model.cx(0.02, 0.04)
  let z3 = @dist.z3_diag(z, z, z)
  match @dist.TxSpec::new(0.0, z3) {
    Ok(_) => fail("zero ratio must be rejected")
    Err(e) => assert_true(e.contains("positive"))
  }
  match @dist.TxSpec::new(-1.0, z3) {
    Ok(_) => fail("negative ratio must be rejected")
    Err(e) => assert_true(e.contains("positive"))
  }
  let zero = @model.cx(0.0, 0.0)
  let z0 = @dist.z3_diag(zero, zero, zero)
  match @dist.TxSpec::new(1.0, z0) {
    Ok(_) => fail("all-zero leakage must be rejected")
    Err(e) => assert_true(e.contains("leakage"))
  }
}
