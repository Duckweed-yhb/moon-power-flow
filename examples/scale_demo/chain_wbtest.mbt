///|
test "all chain sizes have identical total impedance and nominal demand" {
  let unit = @dist.Phasor::uniform(@model.cx(1.0, 0.0))
  for n in [2, 4, 50, 5000] {
    let net = build_chain(n)
    assert_eq(net.edge_count(), n - 1)
    let mut impedance = @model.cx(0.0, 0.0)
    for i in 0..<net.edge_count() {
      impedance = @model.cx_add(impedance, net.edge_at(i).z().mul(unit).a())
    }
    assert_true((impedance.re() - 0.02).abs() < 1.0e-12)
    assert_true((impedance.im() - 0.04).abs() < 1.0e-12)
    assert_true((@dist.load_demand_active(net) - 0.9).abs() < 1.0e-12)
  }
}
