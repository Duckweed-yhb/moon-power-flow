///|
test "probe upstream open phase remains dead downstream" {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let zero = @dist.Phasor::zero()
  let s = @dist.phasor(
    @model.cx(0.01, 0.0),
    @model.cx(0.01, 0.0),
    @model.cx(0.01, 0.0),
  )
  let net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, zero),
      @dist.DistNode::make(2, zero),
      @dist.DistNode::make(3, s),
    ],
    [
      @dist.DistEdge::make(1, 2, z3).with_switch(
        @dist.Switch::closed().open_phase(1),
      ),
      @dist.DistEdge::make(2, 3, z3),
    ],
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  let t = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let r = match @dist.sweep(net, t, 1.0e-9, 100) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  assert_eq(@model.cx_abs(r.voltages()[2].b()), 0.0)
  assert_eq(@model.cx_abs(r.branch_currents()[1].b()), 0.0)
  assert_true(@model.cx_abs(r.voltages()[2].a()) > 0.9)
  assert_true(@model.cx_abs(r.voltages()[2].c()) > 0.9)
  assert_true(
    (@dist.root_injection_active(net, r) -
    @dist.total_loss_active(net, r) -
    0.02).abs() <
    1.0e-8,
  )
  let zip = match @model.Zip::new(0.5, 0.2, 0.3) {
    Ok(z) => z
    Err(e) => fail(e)
  }
  let zr = match @dist.sweep_zip(net, t, zip, 1.0e-9, 100) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  assert_eq(@model.cx_abs(zr.voltages()[2].b()), 0.0)
  assert_eq(@model.cx_abs(zr.branch_currents()[1].b()), 0.0)
}
