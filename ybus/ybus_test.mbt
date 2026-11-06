// ybus/ybus_test.mbt — Ybus 手算对照测试。
//
// 手算网络（标幺值 p.u.，基准容量 S_B = 100 MVA，电压基准按各段标称值折算；
// 本测试只验证导纳矩阵的代数结果，不依赖潮流求解器输出）：
//
//   Slack  1，固定电压 1.0∠0；PQ 2、PQ 3。
//   支路 1-2：z = 0.02 + j0.06  -> y = 5.00 - j15.00
//   支路 2-3：z = 0.08 + j0.24  -> y = 1.25 - j3.75
//   支路 1-3：z = 0.06 + j0.18  -> y = 5/3 - j5.00
//
// 期望矩阵（G + jB，容差 1e-9）：
//   Y11 = 20/3 - j20        Y22 = 6.25 - j18.75
//   Y33 = 35/12 - j8.75
//   Y12=Y21 = -5 + j15      Y13=Y31 = -5/3 + j5
//   Y23=Y32 = -1.25 + j3.75

fn close(a : @model.Cx, b : @model.Cx, tol : Double) -> Bool {
  (a.re() - b.re()).abs() < tol && (a.im() - b.im()).abs() < tol
}

fn sample_network() -> @model.Network raise {
  let slack = @model.Bus::make_slack(1, "slack", @model.cx(1.0, 0.0))
  let pq2 = @model.Bus::make_pq(2, "pq2", -0.20, -0.10)
  let pq3 = @model.Bus::make_pq(3, "pq3", -0.15, -0.075)
  let buses = Array::makei(0, _ => @model.Bus::make_slack(0, "", @model.cx(0.0, 0.0)))
  buses.push(slack)
  buses.push(pq2)
  buses.push(pq3)
  let branches = Array::makei(0, _ => @model.Branch::make(0, 0, @model.cx(1.0, 0.0)))
  branches.push(@model.Branch::make(1, 2, @model.cx(0.02, 0.06)))
  branches.push(@model.Branch::make(2, 3, @model.cx(0.08, 0.24)))
  branches.push(@model.Branch::make(1, 3, @model.cx(0.06, 0.18)))
  match @model.validate(buses, branches) {
    Ok(net) => net
    Err(e) => @test.fail("sample network should validate: " + e.describe())
  }
}

test "branch admittance equals reciprocal hand calculation" {
  let tol = 1.0e-9
  let y12 = @ybus.branch_admittance(@model.cx(0.02, 0.06))
  @test.assert_eq(close(y12, @model.cx(5.0, -15.0), tol), true)
  let y23 = @ybus.branch_admittance(@model.cx(0.08, 0.24))
  @test.assert_eq(close(y23, @model.cx(1.25, -3.75), tol), true)
  let y13 = @ybus.branch_admittance(@model.cx(0.06, 0.18))
  @test.assert_eq(close(y13, @model.cx(5.0 / 3.0, -5.0), tol), true)
}

test "Ybus diagonal terms match hand calculation" {
  let tol = 1.0e-9
  let net = sample_network()
  let y = @ybus.build_ybus(net)
  @test.assert_eq(close(y[0][0], @model.cx(20.0 / 3.0, -20.0), tol), true)
  @test.assert_eq(close(y[1][1], @model.cx(6.25, -18.75), tol), true)
  @test.assert_eq(close(y[2][2], @model.cx(35.0 / 12.0, -8.75), tol), true)
}

test "Ybus off-diagonal terms match hand calculation and symmetry" {
  let tol = 1.0e-9
  let net = sample_network()
  let y = @ybus.build_ybus(net)
  @test.assert_eq(close(y[0][1], @model.cx(-5.0, 15.0), tol), true)
  @test.assert_eq(close(y[1][0], y[0][1], tol), true)
  @test.assert_eq(close(y[0][2], @model.cx(-5.0 / 3.0, 5.0), tol), true)
  @test.assert_eq(close(y[2][0], y[0][2], tol), true)
  @test.assert_eq(close(y[1][2], @model.cx(-1.25, 3.75), tol), true)
  @test.assert_eq(close(y[2][1], y[1][2], tol), true)
}
