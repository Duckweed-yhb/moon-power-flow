///|
/// OLTC 测试：参数校验、档位—变比—状态映射、上下限钳位、闭环调档前后对照。

///|
fn oltc_near(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() <= tol
}

///|
/// 构造一台重负荷变压器馈线：1 → 2 为变压器，节点 2 挂较重的平衡三相负荷。
fn heavy_tx_net() -> @dist.DistNet raise {
  let zt = @model.cx(0.03, 0.05)
  let z3 = @dist.z3_diag(zt, zt, zt)
  let tx = match @dist.TxSpec::new(1.0, z3) {
    Ok(t) => t
    Err(e) => fail(e)
  }
  let s = @model.cx(0.28, 0.09)
  @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
    ],
    [@dist.DistEdge::make_tx(1, 2, tx)],
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
}

///|
test "oltc rejects invalid configuration" {
  // 下限大于上限
  match @dist.Oltc::new(2, 0, 5, -5, 0.02, 0.99, 0.01) {
    Ok(_) => fail("min > max must be rejected")
    Err(e) => assert_true(e.contains("tap_min"))
  }
  // 初始档位越界
  match @dist.Oltc::new(2, 6, -5, 5, 0.02, 0.99, 0.01) {
    Ok(_) => fail("tap out of range must be rejected")
    Err(e) => assert_true(e.contains("within"))
  }
  // 步进非正
  match @dist.Oltc::new(2, 0, -5, 5, 0.0, 0.99, 0.01) {
    Ok(_) => fail("zero step must be rejected")
    Err(e) => assert_true(e.contains("step"))
  }
  // 目标电压非正
  match @dist.Oltc::new(2, 0, -5, 5, 0.02, 0.0, 0.01) {
    Ok(_) => fail("zero target must be rejected")
    Err(e) => assert_true(e.contains("target"))
  }
  // 死区为负
  match @dist.Oltc::new(2, 0, -5, 5, 0.02, 0.99, -0.01) {
    Ok(_) => fail("negative band must be rejected")
    Err(e) => assert_true(e.contains("band"))
  }
}

///|
test "tap maps to off-nominal ratio" {
  let o = match @dist.Oltc::new(2, 0, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  assert_true(oltc_near(o.ratio(), 1.0, 1.0e-12))
  let up = o.raise_tap()
  assert_true(oltc_near(up.ratio(), 1.02, 1.0e-12))
  let down = o.lower_tap()
  assert_true(oltc_near(down.ratio(), 0.98, 1.0e-12))
}

///|
test "status distinguishes raise lower in-band and limits" {
  let o = match @dist.Oltc::new(2, 0, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  // 偏低 → 升档
  match o.status(0.96) {
    @dist.RaiseTap => ()
    s => fail("expected RaiseTap, got " + s.describe())
  }
  // 偏高 → 降档
  match o.status(1.02) {
    @dist.LowerTap => ()
    s => fail("expected LowerTap, got " + s.describe())
  }
  // 死区内 → 满足目标
  match o.status(0.99) {
    @dist.InBand => ()
    s => fail("expected InBand, got " + s.describe())
  }
  // 已经顶到上限仍想升 → AtUpperLimit
  let top = match @dist.Oltc::new(2, 5, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  match top.status(0.96) {
    @dist.AtUpperLimit => ()
    s => fail("expected AtUpperLimit, got " + s.describe())
  }
  // 已经压到下限仍想降 → AtLowerLimit
  let bot = match @dist.Oltc::new(2, -5, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  match bot.status(1.02) {
    @dist.AtLowerLimit => ()
    s => fail("expected AtLowerLimit, got " + s.describe())
  }
}

///|
test "tap movement is clamped to the limits" {
  let top = match @dist.Oltc::new(2, 5, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  assert_eq(top.raise_tap().tap(), 5)
  let bot = match @dist.Oltc::new(2, -5, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  assert_eq(bot.lower_tap().tap(), -5)
}

///|
/// 闭环调档：每步都按受控相电压判断；最终档位的电压离目标不比初始更远。
test "oltc driver closes the loop without worsening the target" {
  let net = heavy_tx_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -6, 6, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  match @dist.run_oltc(net, topo, oltc, 1.0e-12, 100, 12) {
    Ok(run) => {
      assert_true(run.moves().length() >= 1)
      let first = run.moves()[0].1
      let last = run.moves()[run.moves().length() - 1].1
      // 受控相电压有限且在合理区间。
      assert_true(first > 0.0 && first < 1.1)
      assert_true(last > 0.0 && last < 1.1)
      // 调档后不应比初始更偏离目标（闭环方向正确）。
      assert_true((last - 0.99).abs() <= (first - 0.99).abs() + 1.0e-12)
      // 终止状态属于三类之一：入带、顶上限、压下限。
      match run.stopped() {
        @dist.InBand => ()
        @dist.AtUpperLimit => ()
        @dist.AtLowerLimit => ()
        s => fail("unexpected stop state " + s.describe())
      }
      // 若入带，最终电压落在目标死区内。
      if run.reached_band() {
        assert_true((last - 0.99).abs() <= 0.01 + 1.0e-9)
      }
    }
    Err(e) => fail(e.describe())
  }
}

///|
/// 受控支路不是变压器 / 受控节点不存在：控制层结构化报错，不 panic。
test "oltc rejects a plain-line feeder and a missing node" {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let plain = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, @dist.Phasor::uniform(@model.cx(0.1, 0.03))),
    ],
    [@dist.DistEdge::make(1, 2, z3)],
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  let topo = match @dist.build_topology(plain) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  match @dist.run_oltc(plain, topo, oltc, 1.0e-12, 100, 5) {
    Ok(_) => fail("plain line must be rejected by OLTC driver")
    Err(e) =>
      match e {
        @dist.OltcErr::Control(_) => ()
        _ => fail("expected Control error")
      }
  }
  let missing = match @dist.Oltc::new(99, 0, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  match @dist.run_oltc(plain, topo, missing, 1.0e-12, 100, 5) {
    Ok(_) => fail("missing node must be rejected")
    Err(e) =>
      match e {
        @dist.OltcErr::Control(_) => ()
        _ => fail("expected Control error")
      }
  }
}

///|
/// 受控母线的 a 相被变压器支路断开时，该相电压为 0。调档控制律按 a 相判断，
/// 这一拍没有任何可读的电压，继续按「欠压」升档只会把档位推到上限，
/// 所以驱动层必须直接报错，而不是跑满 `max_moves`。
test "oltc reports an open controlled phase instead of moving taps" {
  let zt = @model.cx(0.03, 0.05)
  let z3 = @dist.z3_diag(zt, zt, zt)
  let tx = match @dist.TxSpec::new(1.0, z3) {
    Ok(t) => t
    Err(e) => fail(e)
  }
  let sw = @dist.Switch::closed().open_phase(0)
  let edge = @dist.DistEdge::make_tx(1, 2, tx).with_switch(sw)
  let s = @model.cx(0.28, 0.09)
  let net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
    ],
    [edge],
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -6, 6, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  match @dist.run_oltc(net, topo, oltc, 1.0e-9, 40, 10) {
    Ok(run) =>
      fail(
        "open phase must not produce a tap plan, got " +
        run.moves().length().to_string() +
        " moves",
      )
    Err(e) =>
      match e {
        @dist.Control(msg) => assert_true(msg.contains("phase"))
        @dist.Sweep(_) => fail("expected a control error, got a sweep error")
      }
  }
}
