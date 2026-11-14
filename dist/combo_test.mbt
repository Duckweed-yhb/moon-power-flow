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
  assert_true(run.moves().length() > 1)
  // 缺相支路（3 → 4）的 b 相电流为零，下游 b 相电压为零；a/c 两相照常有值。
  let cur = run.result().branch_currents()[2]
  assert_true(@model.cx_abs(cur.b()) == 0.0)
  let v4 = run.result().voltages()[3]
  assert_true(@model.cx_abs(v4.b()) == 0.0)
  assert_true(@model.cx_abs(v4.a()) > 0.0)
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
  let r = match @dist.sweep(closed_net, topo, 1.0e-12, 200) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let i_b = @model.cx_abs(r.branch_currents()[2].b())
  assert_true(i_b > 0.0)
  assert_true(i_b > @model.cx_abs(run.result().branch_currents()[2].b()))
}
