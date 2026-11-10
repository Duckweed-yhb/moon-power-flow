// solver/solver_test.mbt — GS 收敛性、Slack 固定电压、节点功率平衡、迭代上限与潮流结构测试。
//
// 收敛电压幅值与角度锚点来自独立教材式 GS 参考实现（I = conj(S) / conj(V)，纯标准库脚本，
// 不入库）；功率平衡残差由 Ybus 直接计算 S_calc = V * conj((YV)_i)，不取自求解器输出。
// 四类校验失败路径（缺 Slack、母线重号、零阻抗支路、端点不存在）由 model 包测试覆盖，
// 本文件覆盖求解器失败路径：超过迭代上限。

///|
fn solved() -> (@model.Network, Array[Array[@model.Cx]], @solver.SolveOk) raise {
  let net = match @cases.case_three_bus() {
    Ok(n) => n
    Err(e) => @test.fail("case should validate: " + e.describe())
  }
  let y = @ybus.build_ybus(net)
  let ok = match
    @solver.gauss_seidel(
      net,
      y,
      @cases.default_tol(),
      @cases.default_max_iter(),
    ) {
    Ok(o) => o
    Err(e) => @test.fail("should converge: " + e.describe())
  }
  (net, y, ok)
}

///|
test "GS converges on built-in case within tolerance" {
  let (_, _, ok) = solved()
  @test.assert_eq(ok.iter() > 0 && ok.iter() <= @cases.default_max_iter(), true)
  let v = ok.voltages()
  // 标准递推锚点（tol=1e-8，p.u.）：bus2 0.988193798654∠-0.6704233975°，
  // bus3 0.981741084187∠-1.0395866766°；角度为弧度。
  @test.assert_eq((@model.cx_abs(v[1]) - 0.988193798654).abs() < 1.0e-6, true)
  @test.assert_eq((@model.cx_abs(v[2]) - 0.981741084187).abs() < 1.0e-6, true)
  @test.assert_eq((@model.cx_arg(v[1]) - -0.011701095669).abs() < 1.0e-6, true)
  @test.assert_eq((@model.cx_arg(v[2]) - -0.018144210367).abs() < 1.0e-6, true)
}

///|
test "PQ buses satisfy nodal power balance" {
  let (net, y, ok) = solved()
  let v = ok.voltages()
  let n = net.bus_count()
  let mut i = 0
  while i < n {
    let bus = net.bus_at(i)
    let is_slack = match bus.kind() {
      @model.Slack => true
      _ => false
    }
    if !is_slack {
      let mut iy = @model.cx(0.0, 0.0)
      let mut j = 0
      while j < n {
        iy = @model.cx_add(iy, @model.cx_mul(y[i][j], v[j]))
        j += 1
      }
      // S_calc = V_i * conj(I_i)，I_i = (YV)_i；残差为指定注入与计算注入之差。
      let s_calc = @model.cx_mul(v[i], @model.cx_conj(iy))
      let s_spec = @model.cx(bus.p_inj(), bus.q_inj())
      let residual = @model.cx_abs(@model.cx_sub(s_spec, s_calc))
      @test.assert_eq(residual < 1.0e-6, true)
    }
    i += 1
  }
}

///|
test "slack voltage stays fixed at 1.0 angle 0" {
  let (net, _, ok) = solved()
  let si = match net.slack_index() {
    Some(i) => i
    None => -1
  }
  @test.assert_eq(si >= 0, true)
  let v = ok.voltages()[si]
  @test.assert_eq(@model.cx_abs(v), 1.0)
  @test.assert_eq(@model.cx_arg(v).abs() < 1.0e-12, true)
}

///|
test "PQ voltage magnitudes remain in a sane band" {
  let (_, _, ok) = solved()
  let v = ok.voltages()
  @test.assert_eq(@model.cx_abs(v[1]) > 0.9 && @model.cx_abs(v[1]) < 1.1, true)
  @test.assert_eq(@model.cx_abs(v[2]) > 0.9 && @model.cx_abs(v[2]) < 1.1, true)
}

///|
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

///|
test "branch flow count matches branch count and active loss is non-negative" {
  let (net, _, ok) = solved()
  let flows = @solver.all_flows(net, ok.voltages())
  @test.assert_eq(flows.length(), net.branch_count())
  let mut k = 0
  while k < flows.length() {
    // 串联电阻消耗有功，允许极小浮点负值容差。
    @test.assert_eq(flows[k].loss().re() >= -1.0e-12, true)
    k += 1
  }
}

///|
/// NaN 注入不许被判成收敛（与 dist 侧同一条理由：`NaN > max_delta` 恒 false）。
test "GS reports non-finite instead of converging on NaN injection" {
  let nan = 0.0 / 0.0
  let buses = [
    @model.Bus::make_slack(1, "bus1", @model.cx(1.0, 0.0)),
    @model.Bus::make_pq(2, "bus2", nan, 0.0),
  ]
  let branches = [@model.Branch::make(1, 2, @model.cx(0.01, 0.02))]
  let net = match @model.validate(buses, branches) {
    Ok(n) => n
    Err(e) => @test.fail("should validate: " + e.describe())
  }
  let y = @ybus.build_ybus(net)
  match @solver.gauss_seidel(net, y, 1.0e-8, 50) {
    Ok(ok) =>
      @test.fail(
        "NaN injection must not converge, iter=" + ok.iter().to_string(),
      )
    Err(e) =>
      match e {
        @solver.SolveErr::NonFinite(_) => ()
        _ => @test.fail("expected NonFinite, got " + e.describe())
      }
  }
}

///|
/// 迭代上限为 0：参数错误，不是「不收敛」。
test "GS rejects non positive iteration limit" {
  let net = match @cases.case_three_bus() {
    Ok(n) => n
    Err(e) => @test.fail("case should validate: " + e.describe())
  }
  let y = @ybus.build_ybus(net)
  match @solver.gauss_seidel(net, y, 1.0e-8, 0) {
    Ok(_) => @test.fail("max_iter=0 must not solve")
    Err(e) =>
      match e {
        @solver.SolveErr::InvalidConfig => ()
        _ => @test.fail("expected InvalidConfig, got " + e.describe())
      }
  }
}
