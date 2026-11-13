///|
/// 缺相 / 断线支路测试：断开相电流置零、下游该相电压为零，其余两相照常供负荷。

///|
fn open_near(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() <= tol
}

///|
fn open_solve(net : @dist.DistNet) -> @dist.SweepOk raise {
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
test "open phase carries zero current and a dead downstream phase" {
  let net = @dist.case_with_open_phase()
  let r = open_solve(net)
  let i = r.branch_currents()[0]
  let v = r.voltages()[1]
  // b 相断开：支路 b 相电流为零，下游 b 相电压为零。
  assert_true(@model.cx_abs(i.b()) == 0.0)
  assert_true(@model.cx_abs(v.b()) == 0.0)
  // a/c 两相仍在供负荷：电流非零、电压有限且低于 1 p.u.。
  assert_true(@model.cx_abs(i.a()) > 0.0)
  assert_true(@model.cx_abs(i.c()) > 0.0)
  assert_true(@model.cx_abs(v.a()) > 0.0 && @model.cx_abs(v.a()) < 1.0)
  assert_true(@model.cx_abs(v.c()) > 0.0 && @model.cx_abs(v.c()) < 1.0)
}

///|
test "closed switch is identical to a plain edge" {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let s = @dist.phasor(
    @model.cx(0.08, 0.02),
    @model.cx(0.06, 0.02),
    @model.cx(0.08, 0.02),
  )
  let zero = @dist.Phasor::zero()
  let v_root = @dist.Phasor::balanced(1.0, 0.0)
  let with_switch = @dist.DistNet::make(
    [@dist.DistNode::make(1, zero), @dist.DistNode::make(2, s)],
    [@dist.DistEdge::make(1, 2, z3).with_switch(@dist.Switch::closed())],
    1,
    v_root,
  )
  let plain = @dist.DistNet::make(
    [@dist.DistNode::make(1, zero), @dist.DistNode::make(2, s)],
    [@dist.DistEdge::make(1, 2, z3)],
    1,
    v_root,
  )
  let a = open_solve(with_switch).voltages()[1]
  let b = open_solve(plain).voltages()[1]
  assert_true(open_near(@model.cx_abs(a.a()), @model.cx_abs(b.a()), 1.0e-12))
  assert_true(open_near(@model.cx_abs(a.b()), @model.cx_abs(b.b()), 1.0e-12))
  assert_true(open_near(@model.cx_abs(a.c()), @model.cx_abs(b.c()), 1.0e-12))
}

///|
test "open_phase flips only the requested phase" {
  let closed = @dist.Switch::closed()
  assert_true(closed.a() && closed.b() && closed.c())
  let open_b = closed.open_phase(1)
  assert_true(open_b.a() && !open_b.b() && open_b.c())
  let open_c = closed.open_phase(2)
  assert_true(open_c.a() && open_c.b() && !open_c.c())
}

///|
/// 缺相馈线仍能算损耗与功率平衡：断开相不消耗、不传导，平衡按导通相成立。
test "open-phase feeder keeps power balance on the closed phases" {
  let net = @dist.case_with_open_phase()
  let r = open_solve(net)
  let loss = @dist.total_loss_active(net, r)
  // b 相断开后不供电，平衡只按导通的 a/c 两相负荷算。
  let s = net.node_at(1).s()
  let served = s.a().re + s.c().re
  let inject = @dist.root_injection_active(net, r)
  assert_true(loss >= 0.0)
  assert_true(open_near(inject, served + loss, 1.0e-9))
}
