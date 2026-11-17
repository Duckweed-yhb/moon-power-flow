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
/// 调档次数用尽时，返回的调压器必须是最后一次真正解过潮流的那个档位。
/// 旧实现最后一次 raise/lower 后直接退出循环，`oltc()` 报的是没解过的新档，
/// `result()` 却是旧档的电压，两者对不上。
test "tap budget exhaustion reports the tap that was solved" {
  let net = heavy_tx_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  // 目标 1.03、死区 ±0.01：0 档 0.98686、升一档约 1.007，都还在带外，
  // 需要第二次调档，正好卡在只给一次机会的边界上。
  let oltc = match @dist.Oltc::new(2, 0, -6, 6, 0.02, 1.03, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  // 只给一次调档机会：允许解两次（升档前后各一次），不能报没解过的新档。
  match @dist.run_oltc(net, topo, oltc, 1.0e-9, 100, 1) {
    Ok(run) => {
      let moves = run.moves()
      assert_eq(moves.length(), 2)
      assert_eq(run.oltc().tap(), moves[1].0)
      assert_true(!run.reached_band())
      match run.stopped() {
        @dist.RaiseTap => ()
        s => fail("expected RaiseTap after the budget ran out, got " + s.describe())
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

///|
/// 逐档扫描的长度与单调性：13 档（-6…6）全部解出，电压随升档单调上升。
test "tap scan covers every tap and voltage rises with the tap" {
  let net = heavy_tx_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -6, 6, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  match
    @dist.scan_taps_zip(
      net,
      topo,
      oltc,
      @model.Zip::constant_power(),
      1.0e-9,
      100,
    ) {
    Ok(rows) => {
      assert_eq(rows.length(), 13)
      assert_eq(rows[0].0, -6)
      assert_eq(rows[12].0, 6)
      let mut i = 1
      while i < rows.length() {
        assert_true(rows[i].1 > rows[i - 1].1)
        i += 1
      }
    }
    Err(e) => fail(e.describe())
  }
}

///|
/// ZIP 的电压修正方向：同档位下，电压低于额定时恒阻抗负荷取用更少、电压更高；
/// 高于额定时反过来取用更多、电压更低。恒功率负荷两头都不动。
test "zip load correction flips sign across nominal voltage" {
  let net = heavy_tx_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -6, 6, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  let cp = @dist.scan_taps_zip(
    net,
    topo,
    oltc,
    @model.Zip::constant_power(),
    1.0e-9,
    100,
  )
  let ci = @dist.scan_taps_zip(
    net,
    topo,
    oltc,
    @model.Zip::constant_impedance(),
    1.0e-9,
    100,
  )
  match (cp, ci) {
    (Ok(by_cp), Ok(by_ci)) => {
      assert_eq(by_cp.length(), by_ci.length())
      // 0 档（下标 6）：恒功率 0.98686，恒阻抗 0.98720
      assert_true(by_ci[6].1 > by_cp[6].1 + 0.000001)
      // 6 档（下标 12）：恒功率 1.10831，恒阻抗 1.10567
      assert_true(by_ci[12].1 < by_cp[12].1 - 0.000001)
    }
    (Err(e), _) => fail("constant power scan failed: " + e.describe())
    (_, Err(e)) => fail("constant impedance scan failed: " + e.describe())
  }
}

///|
/// 恒功率 ZIP 就是旧行为：与 run_oltc 的终档、调档轨迹和终止状态完全一致。
test "oltc zip driver matches the constant power driver" {
  let net = heavy_tx_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -6, 6, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  let plan = match @dist.run_oltc(net, topo, oltc, 1.0e-9, 100, 12) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let zipped_res = @dist.run_oltc_zip(
    net,
    topo,
    oltc,
    @model.Zip::constant_power(),
    1.0e-9,
    100,
    12,
  )
  let zipped = match zipped_res {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  assert_eq(zipped.oltc().tap(), plan.oltc().tap())
  assert_true(zipped.reached_band() == plan.reached_band())
  assert_eq(zipped.moves().length(), plan.moves().length())
  assert_true(zipped.stopped().describe() == plan.stopped().describe())
  let mut i = 0
  while i < plan.moves().length() {
    assert_eq(zipped.moves()[i].0, plan.moves()[i].0)
    assert_true(oltc_near(zipped.moves()[i].1, plan.moves()[i].1, 1.0e-12))
    i += 1
  }
}

///|
/// 混合 ZIP 下闭环仍然能进带，最终电压落在目标死区内。
test "oltc zip driver reaches the band under a mixed zip load" {
  let net = heavy_tx_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -6, 6, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  let mixed = match @model.Zip::new(0.5, 0.2, 0.3) {
    Ok(z) => z
    Err(e) => fail(e)
  }
  match @dist.run_oltc_zip(net, topo, oltc, mixed, 1.0e-9, 100, 12) {
    Ok(run) => {
      assert_true(run.reached_band())
      let last = run.moves()[run.moves().length() - 1].1
      assert_true(oltc_near(last, oltc.target(), oltc.band() + 1.0e-9))
    }
    Err(e) => fail(e.describe())
  }
}

///|
/// 扫描与驱动共用同一套受控支路校验：普通线路与不存在的节点都报 Control。
test "tap scan rejects a plain line and a missing node" {
  let plain = @dist.case_four_node()
  let topo = match @dist.build_topology(plain) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  match
    @dist.scan_taps_zip(
      plain,
      topo,
      oltc,
      @model.Zip::constant_power(),
      1.0e-9,
      100,
    ) {
    Ok(_) => fail("plain line must be rejected by the tap scan")
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
  match
    @dist.scan_taps_zip(
      plain,
      topo,
      missing,
      @model.Zip::constant_power(),
      1.0e-9,
      100,
    ) {
    Ok(_) => fail("missing node must be rejected by the tap scan")
    Err(e) =>
      match e {
        @dist.OltcErr::Control(_) => ()
        _ => fail("expected Control error")
      }
  }
}

///|
/// 不平衡馈线：a 相轻（0.06+j0.02）、b 相重（0.52+j0.17）、c 相居中。
/// 受控母线三相电压因此拉开，a 相高于最低相约 0.02 p.u.。
fn unbalanced_tx_net() -> @dist.DistNet raise {
  let zt = @model.cx(0.03, 0.05)
  let z3 = @dist.z3_diag(zt, zt, zt)
  let tx = match @dist.TxSpec::new(1.0, z3) {
    Ok(t) => t
    Err(e) => fail(e)
  }
  let s = @dist.phasor(
    @model.cx(0.06, 0.02),
    @model.cx(0.52, 0.17),
    @model.cx(0.22, 0.07),
  )
  @dist.DistNet::make(
    [@dist.DistNode::make(1, @dist.Phasor::zero()), @dist.DistNode::make(2, s)],
    [@dist.DistEdge::make_tx(1, 2, tx)],
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
}

///|
/// 受控母线三相电压模长里最小的那一相。
fn min_phase_mag(run : @dist.OltcRun, net : @dist.DistNet) -> Double raise {
  let node = match net.find_index(run.oltc().node_id()) {
    Some(k) => k
    None => fail("controlled node missing from voltages")
  }
  let v = run.result().voltages()[node]
  let mut worst = @model.cx_abs(v.a())
  let vb = @model.cx_abs(v.b())
  let vc = @model.cx_abs(v.c())
  if vb < worst {
    worst = vb
  }
  if vc < worst {
    worst = vc
  }
  worst
}

///|
/// 平衡算例下两种判据读数一致：最差相就是 a 相，读数只差在浮点末位。
test "worst phase criterion matches a phase on a balanced feeder" {
  let net = heavy_tx_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -6, 6, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  let zip = @model.Zip::constant_power()
  let a = match @dist.scan_taps_zip(net, topo, oltc, zip, 1.0e-9, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let w = match
    @dist.scan_taps_zip_worst_phase(net, topo, oltc, zip, 1.0e-9, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  assert_eq(a.length(), w.length())
  for i in 0..<a.length() {
    assert_eq(a[i].0, w[i].0)
    // 三相模长在浮点末位上有差异，取最小值后不是逐位相等
    assert_true(oltc_near(a[i].1, w[i].1, 1.0e-12))
  }
}

///|
/// 不平衡算例：a 相判据在 0 档就停（a 相 0.997 进了 [0.98, 1.00]），
/// 最低相却停在 0.975，仍在带外；最差相判据继续升一档，把最低相抬到
/// 0.996，代价是 a 相被抬到 1.017。
test "worst phase criterion pulls the lowest phase into band" {
  let net = unbalanced_tx_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let oltc = match @dist.Oltc::new(2, 0, -5, 5, 0.02, 0.99, 0.01) {
    Ok(x) => x
    Err(e) => fail(e)
  }
  let zip = @model.Zip::constant_power()
  let by_a = match @dist.run_oltc_zip(net, topo, oltc, zip, 1.0e-9, 100, 10) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let by_w_run = @dist.run_oltc_zip_worst_phase(
    net, topo, oltc, zip, 1.0e-9, 100, 10,
  )
  let by_w = match by_w_run {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  // a 相判据：停 0 档，a 相进带，最低相留在带外
  assert_true(by_a.reached_band())
  assert_eq(by_a.oltc().tap(), 0)
  assert_true(min_phase_mag(by_a, net) < 0.98)
  // 最差相判据：多升一档，最低相进带
  assert_true(by_w.reached_band())
  assert_eq(by_w.oltc().tap(), 1)
  let worst = min_phase_mag(by_w, net)
  assert_true(worst > 0.98 && worst < 1.0)
  // 档位差一档，其余量随之不同
  assert_true(by_w.moves().length() > by_a.moves().length())
}

///|
/// 最差相判据下某相断开同样拒绝：零电压不是「欠压」，按欠压升档会把档位
/// 推到上限。
test "worst phase criterion rejects an open phase" {
  let zt = @model.cx(0.03, 0.05)
  let z3 = @dist.z3_diag(zt, zt, zt)
  let tx = match @dist.TxSpec::new(1.0, z3) {
    Ok(t) => t
    Err(e) => fail(e)
  }
  // b 相断开：a 相电压正常，最差相是 0
  let sw = @dist.Switch::closed().open_phase(1)
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
  let run_r = @dist.run_oltc_zip_worst_phase(
    net,
    topo,
    oltc,
    @model.Zip::constant_power(),
    1.0e-9,
    40,
    10,
  )
  match run_r {
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
