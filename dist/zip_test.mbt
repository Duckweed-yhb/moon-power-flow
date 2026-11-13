///|
/// ZIP 负荷静特性测试。
///
/// 四条判据：
/// 1. `α=1`（纯恒功率）与旧 `sweep` 同解——新入口不能改变既有行为；
/// 2. `γ=1`（纯恒阻抗）仍然收敛，且功率平衡要对**按电压缩放后**的需求成立；
/// 3. 系数和不为 1 / 有负数时构造失败；
/// 4. 同一网络下恒阻抗负荷取用的功率低于恒功率（电压低于 1 p.u. 时）。

///|
fn zip_near(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-9
}

///|
test "constant power ZIP matches the plain sweep" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let plain = match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let zip = @model.Zip::constant_power()
  let zr = match @dist.sweep_zip(net, topo, zip, 1.0e-12, 100) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let a = plain.voltages()
  let b = zr.voltages()
  let mut i = 0
  while i < a.length() {
    assert_true((a[i].max_abs() - b[i].max_abs()).abs() < 1.0e-15)
    i += 1
  }
}

///|
test "constant impedance ZIP keeps the power balance" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let zip = @model.Zip::constant_impedance()
  let r = match @dist.sweep_zip(net, topo, zip, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  // 恒阻抗负荷的取用要按最终电压缩放后统计，才能和根注入对上。
  let demand = @dist.load_demand_active_zip(net, r, zip)
  let loss = @dist.total_loss_active(net, r)
  let inject = @dist.root_injection_active(net, r)
  assert_true(zip_near(inject, demand + loss))
  assert_true(demand > 0.0)
  // 电压低于 1 p.u. 时，恒阻抗负荷取用少于额定 0.3 p.u.
  assert_true(demand < 0.3)
}

///|
test "mixed ZIP converges and balances" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let zip = match @model.Zip::new(0.5, 0.3, 0.2) {
    Ok(z) => z
    Err(e) => fail(e)
  }
  let r = match @dist.sweep_zip(net, topo, zip, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let demand = @dist.load_demand_active_zip(net, r, zip)
  let loss = @dist.total_loss_active(net, r)
  let inject = @dist.root_injection_active(net, r)
  assert_true(zip_near(inject, demand + loss))
}

///|
test "invalid ZIP coefficients are rejected" {
  // 和不为 1
  match @model.Zip::new(0.5, 0.6, 0.0) {
    Ok(_) => fail("sum != 1 should be rejected")
    Err(e) => assert_true(e.contains("sum to 1"))
  }
  // 负数
  match @model.Zip::new(1.2, -0.1, -0.1) {
    Ok(_) => fail("negative coefficient should be rejected")
    Err(e) => assert_true(e.contains("non-negative"))
  }
  // 合法值
  match @model.Zip::new(1.0, 0.0, 0.0) {
    Ok(z) => assert_true(z.alpha() == 1.0)
    Err(e) => fail(e)
  }
}

///|
test "scale factor reflects the voltage dependence" {
  // |V| = 1 时三种负荷的缩放系数都是 1
  let mixed = match @model.Zip::new(0.5, 0.3, 0.2) {
    Ok(z) => z
    Err(e) => fail(e)
  }
  assert_true(zip_near(mixed.scale_at(1.0), 1.0))
  // |V| = 0.9：恒阻抗项按 0.81 缩，恒电流按 0.9，恒功率不变
  let expected = 0.5 + 0.3 * 0.9 + 0.2 * 0.81
  assert_true(zip_near(mixed.scale_at(0.9), expected))
}

///|
/// ZIP 路径同样要把 NaN 拦成 NonFinite：共享的求解主体不能因为负荷模型
/// 不同就把「全是 NaN」当成收敛。
test "sweep_zip reports non-finite on NaN load" {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let nan = 0.0 / 0.0
  let bad = @dist.phasor(
    @model.cx(nan, 0.0),
    @model.cx(nan, 0.0),
    @model.cx(nan, 0.0),
  )
  let net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, bad),
    ],
    [@dist.DistEdge::make(1, 2, z3)],
    1,
    @dist.Phasor::uniform(@model.cx(1.0, 0.0)),
  )
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let zip = @model.Zip::constant_power()
  match @dist.sweep_zip(net, topo, zip, 1.0e-9, 50) {
    Ok(_) => fail("NaN load must not converge under ZIP")
    Err(e) =>
      match e {
        @dist.SweepErr::NonFinite(_) => ()
        _ => fail("expected NonFinite, got " + e.describe())
      }
  }
}

///|
/// Inf 负荷与 NaN 同口径：迭代中经 Inf/Inf 落到 NaN，必须被 NonFinite 拦住，
/// 不能带着非有限电压返回 Ok。
test "sweep_zip reports non-finite on infinite load" {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let inf = 1.0 / 0.0
  let bad = @dist.phasor(
    @model.cx(inf, 0.0),
    @model.cx(inf, 0.0),
    @model.cx(inf, 0.0),
  )
  let net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, bad),
    ],
    [@dist.DistEdge::make(1, 2, z3)],
    1,
    @dist.Phasor::uniform(@model.cx(1.0, 0.0)),
  )
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let zip = @model.Zip::constant_power()
  match @dist.sweep_zip(net, topo, zip, 1.0e-9, 50) {
    Ok(_) => fail("infinite load must not converge under ZIP")
    Err(e) =>
      match e {
        @dist.SweepErr::NonFinite(_) => ()
        _ => fail("expected NonFinite, got " + e.describe())
      }
  }
}

///|
/// 迭代上限过小：ZIP 路径也要返回 NotConverged，而不是默默返回半成品。
test "sweep_zip reports non convergence with a tiny iteration budget" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let zip = match @model.Zip::new(0.5, 0.3, 0.2) {
    Ok(z) => z
    Err(e) => fail(e)
  }
  match @dist.sweep_zip(net, topo, zip, 1.0e-15, 1) {
    Ok(_) => fail("one iteration cannot reach 1e-15")
    Err(e) =>
      match e {
        @dist.SweepErr::NotConverged(iter, _) => assert_eq(iter, 1)
        _ => fail("expected NotConverged, got " + e.describe())
      }
  }
  // 非法迭代上限仍是 InvalidConfig
  match @dist.sweep_zip(net, topo, zip, 1.0e-9, 0) {
    Ok(_) => fail("max_iter=0 must be rejected")
    Err(e) =>
      match e {
        @dist.SweepErr::InvalidConfig => ()
        _ => fail("expected InvalidConfig, got " + e.describe())
      }
  }
}

///|
/// α=1 时「按最终电压缩放的取用」必须等于「写死的 S0 之和」。
test "constant power ZIP demand equals the plain demand" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let zip = @model.Zip::constant_power()
  let r = match @dist.sweep_zip(net, topo, zip, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let zipped = @dist.load_demand_active_zip(net, r, zip)
  let plain = @dist.load_demand_active(net)
  assert_true((zipped - plain).abs() < 1.0e-12)
}
