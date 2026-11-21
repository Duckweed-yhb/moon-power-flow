///|
/// 变压器组别相移测试：序分量旋转口径、零相移退化、求解层角度平移、
/// 折算后的功率守恒，以及 OLTC 改变比时相移不被抹掉。
///
/// 判据分三类：纯函数层（对称分量分解与旋转）、求解层（副边角度按 θ 平移、
/// 模长与不平衡度只由负荷决定）、守恒律（根注入 = 负荷 + 损耗）。

///|
fn txs_near(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() <= tol
}

///|
fn txs_solve(net : @dist.DistNet) -> @dist.SweepOk raise {
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
fn txs_tx(ratio : Double) -> @dist.TxSpec raise {
  let z = @model.cx(0.02, 0.04)
  let z3 = @dist.z3_diag(z, z, z)
  match @dist.TxSpec::new(ratio, z3) {
    Ok(t) => t
    Err(e) => fail(e)
  }
}

///|
/// 纯函数层：平衡正序集旋转 +30°，各相模长不变、相角整体前移 30°。
test "sequence rotation advances a balanced set by the shift angle" {
  let v = @dist.Phasor::balanced(1.0, 0.0)
  let r = @dist.sequence_rotate(v, 30.0)
  let pi = 3.141592653589793
  assert_true(txs_near(@model.cx_abs(r.a()), 1.0, 1.0e-12))
  assert_true(txs_near(@model.cx_abs(r.b()), 1.0, 1.0e-12))
  assert_true(txs_near(@model.cx_abs(r.c()), 1.0, 1.0e-12))
  assert_true(txs_near(@model.cx_arg(r.a()), pi / 6.0, 1.0e-12))
  assert_true(
    txs_near(@model.cx_arg(r.b()), pi / 6.0 - 2.0 * pi / 3.0, 1.0e-12),
  )
  assert_true(
    txs_near(@model.cx_arg(r.c()), pi / 6.0 + 2.0 * pi / 3.0, 1.0e-12),
  )
}

///|
/// 纯函数层：+θ 再 −θ 必须复原，平衡集与不平衡集都成立。
test "sequence rotation round trip restores the phasor" {
  let bal = @dist.Phasor::balanced(1.0, 0.2)
  let back = @dist.sequence_rotate(@dist.sequence_rotate(bal, 37.0), -37.0)
  assert_true(
    txs_near(@model.cx_abs(@model.cx_sub(back.a(), bal.a())), 0.0, 1.0e-12),
  )
  assert_true(
    txs_near(@model.cx_abs(@model.cx_sub(back.b(), bal.b())), 0.0, 1.0e-12),
  )
  assert_true(
    txs_near(@model.cx_abs(@model.cx_sub(back.c(), bal.c())), 0.0, 1.0e-12),
  )
  // 不平衡集：三相模长不同、b 相再偏 15°。
  let pi = 3.141592653589793
  let un = @dist.phasor(
    @model.cx_polar(1.0, 0.0),
    @model.cx_polar(0.92, -2.0 * pi / 3.0 + 15.0 * pi / 180.0),
    @model.cx_polar(1.05, 2.0 * pi / 3.0 - 5.0 * pi / 180.0),
  )
  let un_back = @dist.sequence_rotate(@dist.sequence_rotate(un, 25.0), -25.0)
  assert_true(
    txs_near(@model.cx_abs(@model.cx_sub(un_back.a(), un.a())), 0.0, 1.0e-12),
  )
  assert_true(
    txs_near(@model.cx_abs(@model.cx_sub(un_back.b(), un.b())), 0.0, 1.0e-12),
  )
  assert_true(
    txs_near(@model.cx_abs(@model.cx_sub(un_back.c(), un.c())), 0.0, 1.0e-12),
  )
}

///|
/// 零相移是恒等算子：无相移变压器与旧版逐位一致（相量逐位相同）。
test "zero shift keeps the transformer solution bit-identical" {
  let base = @dist.case_with_transformer()
  let r1 = txs_solve(base)
  let tx = base.edge_at(0).tx().with_phase_shift(0.0)
  let net2 = @dist.DistNet::make(
    base.nodes(),
    [
      @dist.DistEdge::make_tx(
        base.edge_at(0).from_id(),
        base.edge_at(0).to_id(),
        tx,
      ),
    ],
    base.root_id(),
    base.v_root(),
  )
  let r2 = txs_solve(net2)
  let v1 = r1.voltages()[1]
  let v2 = r2.voltages()[1]
  assert_true(v1.a().re == v2.a().re && v1.a().im == v2.a().im)
  assert_true(v1.b().re == v2.b().re && v1.b().im == v2.b().im)
  assert_true(v1.c().re == v2.c().re && v1.c().im == v2.c().im)
}

///|
/// 求解层：平衡负荷下 ±30° 两台同参数变压器，副边相角差恰好 60°、模长相同。
test "balanced load shifts secondary angles by the group angle" {
  let lead = txs_tx(1.0).with_phase_shift(30.0)
  let lag = txs_tx(1.0).with_phase_shift(-30.0)
  let zero = @dist.Phasor::zero()
  let s = @model.cx(0.10, 0.03)
  let nodes = [
    @dist.DistNode::make(1, zero),
    @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
  ]
  let v_root = @dist.Phasor::balanced(1.0, 0.0)
  let r_lead = txs_solve(
    @dist.DistNet::make(nodes, [@dist.DistEdge::make_tx(1, 2, lead)], 1, v_root),
  )
  let r_lag = txs_solve(
    @dist.DistNet::make(nodes, [@dist.DistEdge::make_tx(1, 2, lag)], 1, v_root),
  )
  let pi = 3.141592653589793
  let d = @model.cx_arg(r_lead.voltages()[1].a()) -
    @model.cx_arg(r_lag.voltages()[1].a())
  assert_true(txs_near(d, pi / 3.0, 1.0e-9))
  assert_true(
    txs_near(
      @model.cx_abs(r_lead.voltages()[1].a()),
      @model.cx_abs(r_lag.voltages()[1].a()),
      1.0e-12,
    ),
  )
}

///|
/// 守恒律：带 +30° 组别相移的变压器馈线，根注入仍等于负荷 + 损耗。
///
/// 这条专门抓「电压折算改了、原边电流折算没跟着改」的漏改：模型里
/// 电压与电流必须用同一个旋转算子，否则功率平衡静默失效、电压却看着正常。
test "phase shifted transformer feeder keeps the power balance" {
  let base = @dist.case_with_transformer()
  let tx = base.edge_at(0).tx().with_phase_shift(30.0)
  let net2 = @dist.DistNet::make(
    base.nodes(),
    [
      @dist.DistEdge::make_tx(
        base.edge_at(0).from_id(),
        base.edge_at(0).to_id(),
        tx,
      ),
    ],
    base.root_id(),
    base.v_root(),
  )
  let r = txs_solve(net2)
  let loss = @dist.total_loss_active(net2, r)
  let load = @dist.load_demand_active(net2)
  let inject = @dist.root_injection_active(net2, r)
  assert_true(loss >= 0.0)
  assert_true(txs_near(inject, load + loss, 1.0e-9))
}

///|
/// OLTC 改变比不能把组别相移抹掉，非有限角度也不能污染参数。
test "with_ratio preserves the group shift and invalid shift is ignored" {
  let tx = txs_tx(1.0).with_phase_shift(15.0)
  let edge = @dist.DistEdge::make_tx(1, 2, tx)
  let tapped = edge.with_ratio(0.98)
  assert_true(txs_near(tapped.tx().phase_shift_deg(), 15.0, 1.0e-12))
  assert_true(txs_near(tapped.tx().ratio(), 0.98, 1.0e-12))
  let big = 1.0e308
  let inf_deg = big * 10.0
  let inf = tx.with_phase_shift(inf_deg)
  assert_true(txs_near(inf.phase_shift_deg(), 15.0, 1.0e-12))
  let nan = tx.with_phase_shift(inf_deg - inf_deg)
  assert_true(txs_near(nan.phase_shift_deg(), 15.0, 1.0e-12))
}
