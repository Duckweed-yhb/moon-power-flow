// solver/solver_test.mbt — GS 收敛性、Slack 固定电压、迭代上限与潮流结构测试。
//
// 收敛电压幅值与独立 Python 参考解（同参数 GS，纯标准库实现，脚本不入库）对照，
// 容差 1e-6 p.u.；迭代次数不写死，只要求落在 [1, max_iter] 且结果在容差内。
// 四类校验失败路径（缺 Slack、母线重号、零阻抗支路、端点不存在）由 model 包测试覆盖，
// 本文件覆盖第四类求解器失败路径：超过迭代上限。

fn solved() -> (@model.Network, @solver.SolveOk) raise {
  let net = match @cases.case_three_bus() {
    Ok(n) => n
    Err(e) => @test.fail("case should validate: " + e.describe())
  }
  let y = @ybus.build_ybus(net)
  let ok = match @solver.gauss_seidel(net, y, @cases.default_tol(), @cases.default_max_iter()) {
    Ok(o) => o
    Err(e) => @test.fail("should converge: " + e.describe())
  }
  (net, ok)
}

test "GS converges on built-in case within tolerance" {
  let (_, ok) = solved()
  @test.assert_eq(ok.iter() > 0 && ok.iter() <= @cases.default_max_iter(), true)
  let v = ok.voltages()
  // 参考：bus2 |V| ≈ 0.9885178743，bus3 |V| ≈ 0.9823811824（p.u.）。
  @test.assert_eq((@model.cx_abs(v[1]) - 0.9885178743).abs() < 1.0e-6, true)
  @test.assert_eq((@model.cx_abs(v[2]) - 0.9823811824).abs() < 1.0e-6, true)
}

test "slack voltage stays fixed at 1.0 angle 0" {
  let (net, ok) = solved()
  let si = match net.slack_index() {
    Some(i) => i
    None => -1
  }
  @test.assert_eq(si >= 0, true)
  let v = ok.voltages()[si]
  @test.assert_eq(@model.cx_abs(v), 1.0)
  @test.assert_eq(@model.cx_arg(v).abs() < 1.0e-12, true)
}

test "PQ voltage magnitudes remain in a sane band" {
  let (_, ok) = solved()
  let v = ok.voltages()
  @test.assert_eq(@model.cx_abs(v[1]) > 0.9 && @model.cx_abs(v[1]) < 1.1, true)
  @test.assert_eq(@model.cx_abs(v[2]) > 0.9 && @model.cx_abs(v[2]) < 1.1, true)
}

test "iteration limit returns structured NotConverged instead of panic" {
  let net = match @cases.case_three_bus() {
    Ok(n) => n
    Err(e) => @test.fail("case should validate: " + e.describe())
  }
  let y = @ybus.build_ybus(net)
  let res = @solver.gauss_seidel(net, y, 1.0e-12, 1)
  let hit = match res {
    Err(NotConverged(1, _)) => true
    _ => false
  }
  @test.assert_eq(hit, true)
}

test "branch flow count matches branch count and active loss is non-negative" {
  let (net, ok) = solved()
  let flows = @solver.all_flows(net, ok.voltages())
  @test.assert_eq(flows.length(), net.branch_count())
  let mut k = 0
  while k < flows.length() {
    // 串联电阻消耗有功，允许极小浮点负值容差。
    @test.assert_eq(flows[k].loss().re() >= -1.0e-12, true)
    k += 1
  }
}
