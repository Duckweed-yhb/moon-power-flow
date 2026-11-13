///|
/// 内置算例的自洽性检查。
///
/// 算例本身也是代码：如果 `case_balanced` 其实不平衡、`case_four_node` 的
/// 负荷在某次重构里被改成对称的，后面的不平衡度 / 损耗 / 中性点位移测试
/// 就都在「验证一个不存在的场景」。这里把算例的前提断言出来。

///|
test "four node case is actually unbalanced" {
  let net = @dist.case_four_node()
  // 至少一条母线三相负荷不同（否则「三相不平衡」主线没有载体）
  let mut unbalanced_nodes = 0
  let mut i = 1
  while i < net.node_count() {
    let s = net.node_at(i).s()
    let a = @model.cx_abs(s.a())
    let b = @model.cx_abs(s.b())
    let c = @model.cx_abs(s.c())
    if (a - b).abs() > 1.0e-9 || (b - c).abs() > 1.0e-9 {
      unbalanced_nodes += 1
    }
    i += 1
  }
  assert_true(unbalanced_nodes > 0)
  // 根母线不挂负荷
  assert_true(@dist.Phasor::zero().max_abs() == 0.0)
  let root = match net.find_index(net.root_id()) {
    Some(k) => k
    None => fail("root not found")
  }
  assert_true(net.node_at(root).s().max_abs() == 0.0)
}

///|
test "balanced case has equal phase loads" {
  let net = @dist.case_balanced()
  let mut i = 1
  while i < net.node_count() {
    let s = net.node_at(i).s()
    let a = @model.cx_abs(s.a())
    let b = @model.cx_abs(s.b())
    let c = @model.cx_abs(s.c())
    // 三相负荷模长一致（±1e-12），否则「平衡算例」名不副实
    assert_true((a - b).abs() < 1.0e-12)
    assert_true((b - c).abs() < 1.0e-12)
    i += 1
  }
  // 根电压三相幅值相等
  let v = net.v_root()
  assert_true((@model.cx_abs(v.a()) - @model.cx_abs(v.b())).abs() < 1.0e-12)
  assert_true((@model.cx_abs(v.b()) - @model.cx_abs(v.c())).abs() < 1.0e-12)
}

///|
test "every built-in case is radial and converges" {
  let cases = [
    @dist.case_four_node(),
    @dist.case_balanced(),
    @dist.case_coupled(),
    @dist.case_scrambled_ids(),
    @dist.case_with_transformer(),
    @dist.case_with_open_phase(),
  ]
  for net in cases {
    let topo = match @dist.build_topology(net) {
      Ok(t) => t
      Err(e) => fail("case is not radial: " + e.describe())
    }
    match @dist.sweep(net, topo, 1.0e-12, 100) {
      Ok(r) => {
        // 收敛后根电压必须保持给定值（根是固定电压母线）
        let v = r.voltages()
        let root = match net.find_index(net.root_id()) {
          Some(k) => k
          None => fail("root not found")
        }
        assert_true(
          (v[root].max_abs() - net.v_root().max_abs()).abs() < 1.0e-12,
        )
        // 每个母线三相电压都有限
        for p in v {
          assert_true(p.max_abs() > 0.0)
          assert_true(p.max_abs() < 10.0)
        }
      }
      Err(e) => fail("case did not converge: " + e.describe())
    }
  }
}
