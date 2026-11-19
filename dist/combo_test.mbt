///|
/// 组合算例的回归：变压器在网中间、OLTC 调档、下游缺相支路同时存在。
///
/// 三项能力原先各自只在两节点小网里验证过，这里锁住它们在同一条馈线上的交互：
/// 调档改变的是变压器变比，缺相只影响它下游那一相的回路，两者不能互相掩盖。

///|
fn combo_topology(net : @dist.DistNet) -> @dist.Topology raise {
  match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
}

///|
test "tx + oltc + open phase in one feeder" {
  let net = @dist.case_tx_oltc_open()
  let topo = combo_topology(net)
  let oltc = match @dist.Oltc::new(3, 0, -8, 8, 0.0125, 0.97, 0.005) {
    Ok(o) => o
    Err(e) => fail(e)
  }
  let run = match @dist.run_oltc(net, topo, oltc, 1.0e-12, 200, 20) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  // 目标母线进入死区，且档位确实动过（初始电压不在带内）。
  assert_true(run.reached_band())
  let v3 = @model.cx_abs(run.result().voltages()[2].a())
  assert_true(v3 >= 0.97 - 0.005 - 1.0e-9)
  assert_true(v3 <= 0.97 + 0.005 + 1.0e-9)
  // Nodal KCL/Newton reference from scripts/check_combo_reference.py.
  let expected = [
    (0, 0.994550680039),
    (-1, 0.982026510842),
    (-2, 0.969501119553),
  ]
  let moves = run.moves()
  assert_eq(moves.length(), expected.length())
  for i in 0..<moves.length() {
    assert_eq(moves[i].0, expected[i].0)
    assert_true((moves[i].1 - expected[i].1).abs() < 1.0e-9)
  }
  assert_eq(run.oltc().tap(), -2)
  // 缺相支路（3 → 4）的 b 相电流为零，下游 b 相电压为零；a/c 两相照常有值。
  let cur = run.result().branch_currents()[2]
  assert_true(@model.cx_abs(cur.b()) == 0.0)
  let result = run.result()
  let terminal = result.supplied_phases(3).unwrap()
  assert_true(terminal.a() && !terminal.b() && terminal.c())
  assert_true(result.supplied_phases(2).unwrap().b())
  assert_true(result.supplied_phases(-1) is None)
  assert_true(result.supplied_phases(4) is None)
  let v4 = result.voltages()[3]
  assert_true(@model.cx_abs(v4.b()) == 0.0)
  let v3_phases = result.voltages()[2]
  assert_true((@model.cx_abs(v3_phases.b()) - 0.972874982425).abs() < 1.0e-9)
  assert_true((@model.cx_abs(v3_phases.c()) - 0.970608525242).abs() < 1.0e-9)
  assert_true((@model.cx_abs(v4.a()) - 0.968674851934).abs() < 1.0e-9)
  assert_true((@model.cx_abs(v4.c()) - 0.969948443167).abs() < 1.0e-9)
  assert_true(@model.cx_abs(v4.c()) > 0.0)
}

///|
/// 同一张网、同一组负荷，把缺相合上后 b 相重新有电流，OLTC 仍能调进死区。
/// 用来确认缺相的零电流不是「恰好算成 0」，而是开关状态决定的。
test "closing the open phase restores the b-phase current" {
  let net = @dist.case_tx_oltc_open()
  let topo = combo_topology(net)
  let oltc = match @dist.Oltc::new(3, 0, -8, 8, 0.0125, 0.97, 0.005) {
    Ok(o) => o
    Err(e) => fail(e)
  }
  let run = match @dist.run_oltc(net, topo, oltc, 1.0e-12, 200, 20) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let edge = net.edge_at(2).with_switch(@dist.Switch::closed())
  let edges : Array[@dist.DistEdge] = []
  for k in 0..<net.edge_count() {
    edges.push(if k == 2 { edge } else { net.edge_at(k) })
  }
  let closed_net = @dist.DistNet::make(
    net.nodes(),
    edges,
    net.root_id(),
    net.v_root(),
  )
  let closed_run = match
    @dist.run_oltc(closed_net, topo, oltc, 1.0e-12, 200, 20) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  assert_true(closed_run.reached_band())
  let i_b = @model.cx_abs(closed_run.result().branch_currents()[2].b())
  assert_true(i_b > 0.0)
  assert_true(i_b > @model.cx_abs(run.result().branch_currents()[2].b()))
}

///|
test "remote sensing raises tap to compensate for the downstream line drop" {
  let net = @dist.case_tx_oltc_open()
  let topo = combo_topology(net)
  let at_transformer = @dist.Oltc::new(3, 0, -8, 8, 0.0125, 1.0006, 0.0064).unwrap()
  let remote = at_transformer.with_sensing_bus(4)
  let zip = @model.Zip::constant_power()
  let at_tx = match
    @dist.run_oltc_zip(net, topo, at_transformer, zip, 1.0e-12, 100, 10) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let at_end = match
    @dist.run_oltc_zip(net, topo, remote, zip, 1.0e-12, 100, 10) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  assert_eq(at_tx.oltc().tap(), 0)
  assert_eq(at_end.oltc().tap(), 1)
  assert_true(at_end.reached_band())
  assert_eq(at_end.oltc().sensing_bus(), 4)
  let rows = match @dist.scan_taps_zip(net, topo, remote, zip, 1.0e-12, 100) {
    Ok(rows) => rows
    Err(e) => fail(e.describe())
  }
  for (tap, voltage) in at_end.moves() {
    assert_true((voltage - rows[tap + 8].1).abs() < 1.0e-10)
  }
  // Independent nodal reference at +1 tap, including the isolated phase.
  let v4 = at_end.result().voltages()[3]
  let endpoint = @model.cx_abs(v4.a())
  assert_true((endpoint - 1.006278310612).abs() < 1.0e-9)
  assert_eq(@model.cx_abs(v4.b()), 0.0)
  assert_true((@model.cx_abs(v4.c()) - 1.007530631601).abs() < 1.0e-9)
  assert_true((endpoint - at_end.moves()[1].1).abs() < 1.0e-10)
  assert_true(
    @dist.run_oltc(
      net,
      topo,
      at_transformer.with_sensing_bus(2),
      1.0e-12,
      100,
      10,
    )
    is Err(@dist.OltcErr::Control(_)),
  )
  assert_true(
    @dist.scan_taps_zip(
      net,
      topo,
      at_transformer.with_sensing_bus(99),
      zip,
      1.0e-12,
      100,
    )
    is Err(@dist.OltcErr::Control(_)),
  )
}

///|
test "a narrow deadband reports repeated reversal only after returning to a tap" {
  let net = @dist.case_tx_oltc_open()
  let topo = combo_topology(net)
  let oltc = @dist.Oltc::new(3, 0, -8, 8, 0.0125, 0.988, 0.001).unwrap()
  for budget in [0, 1, 2, 3] {
    let run = match @dist.run_oltc(net, topo, oltc, 1.0e-12, 100, budget) {
      Ok(r) => r
      Err(e) => fail(e.describe())
    }
    assert_false(run.reached_band())
    assert_eq(run.tap_hunting(), budget >= 2)
  }
}

///|
test "worst supplied phase can regulate an incomplete remote bus" {
  let net = @dist.case_tx_oltc_open()
  let topo = combo_topology(net)
  let oltc = @dist.Oltc::new(3, 0, -8, 8, 0.0125, 1.0006, 0.0064)
    .unwrap()
    .with_sensing_bus(4)
  let zip = @model.Zip::constant_power()
  assert_true(
    @dist.run_oltc_zip_worst_phase(net, topo, oltc, zip, 1.0e-12, 100, 8)
    is Err(_),
  )
  let run = match
    @dist.run_oltc_zip_worst_phase(
      net,
      topo,
      oltc,
      zip,
      1.0e-12,
      100,
      8,
      supplied_only=true,
    ) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let rows = match
    @dist.scan_taps_zip_worst_phase(
      net,
      topo,
      oltc,
      zip,
      1.0e-12,
      100,
      supplied_only=true,
    ) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  assert_true(run.reached_band())
  assert_eq(run.oltc().tap(), 1)
  assert_true((rows[9].1 - 1.006278310612).abs() < 1.0e-9)
  assert_eq(run.moves()[1].1, rows[9].1)
}
