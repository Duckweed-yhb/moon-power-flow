///|
test "remote tap regulation conserves complex power with mixed ZIP loads" {
  let net = @dist.case_tx_oltc_open()
  let topo = combo_topology(net)
  for n in 0..<40 {
    let target = 0.91 + (n * 31).to_double() / 10000.0
    let oltc = @dist.Oltc::new(3, 0, -8, 8, 0.0125, target, 0.007)
      .unwrap()
      .with_sensing_bus(4)
    let a = (n + 1).to_double() / 100.0
    let zip = @model.Zip::new(a, 0.25, 0.75 - a).unwrap()
    let run = match @dist.run_oltc_zip(net, topo, oltc, zip, 1.0e-12, 200, 20) {
      Ok(r) => r
      Err(e) => fail(e.describe())
    }
    let final_net = run.solved_network()
    let result = run.result()
    let expected = @model.cx_add(
      @dist.total_loss_power(final_net, result),
      @dist.load_demand_power_zip(final_net, result, zip),
    )
    assert_true(
      @model.cx_abs(
        @model.cx_sub(@dist.root_injection_power(final_net, result), expected),
      ) <
      1.0e-8,
    )
    let v = run.result().voltages()[3]
    assert_true(run.reached_band())
    assert_true((@model.cx_abs(v.a()) - target).abs() <= 0.007)
    assert_eq(@model.cx_abs(v.b()), 0.0)
  }
}
