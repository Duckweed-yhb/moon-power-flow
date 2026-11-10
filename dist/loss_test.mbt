///|
/// 损耗与功率平衡测试。
///
/// 判据是守恒律而不是参考数据：根注入的有功 = 负荷需求 + 全网有功损耗。
/// 这条恒等式对任何网络都成立，只要损耗算法把相间互阻抗算进去了；
/// 漏掉互阻抗时它会立刻失衡。

///|
/// 相对误差：功率量级约 1 p.u.，用绝对容差足够。
fn near_pu(actual : Double, expected : Double) -> Bool {
  (actual - expected).abs() <= 1.0e-9
}

///|
test "balanced three phase case keeps the power balance" {
  // 三相平衡算例（三相退化检查用）：损耗应当很小但非负，守恒关系仍成立。
  let net = @dist.case_balanced()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => {
      let loss = @dist.total_loss_active(net, r)
      let load = @dist.load_demand_active(net)
      let inject = @dist.root_injection_active(net, r)
      assert_true(loss >= 0.0)
      assert_true(near_pu(inject, load + loss))
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "power balance holds on the unbalanced four node feeder" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => {
      let loss = @dist.total_loss_active(net, r)
      let load = @dist.load_demand_active(net)
      let inject = @dist.root_injection_active(net, r)
      // 不平衡算例必须有非零损耗（否则说明压根没算功率）。
      assert_true(loss > 0.0)
      assert_true(near_pu(inject, load + loss))
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "power balance holds on the mutually coupled two node case" {
  // 带互阻抗的两节点算例：漏掉相间耦合时这条会失衡。
  let net = @dist.case_coupled()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => {
      let loss = @dist.total_loss_active(net, r)
      let load = @dist.load_demand_active(net)
      let inject = @dist.root_injection_active(net, r)
      assert_true(loss > 0.0)
      assert_true(near_pu(inject, load + loss))
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "every branch loss has non negative active part" {
  // R 对称半正定 → 每条支路的有功损耗不可能为负。单相或数值噪声可能让
  // 微小支路出现 −1e−18 量级，容差放到 1e−12。
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => {
      let losses = @dist.branch_losses(net, r)
      assert_eq(losses.length(), net.edge_count())
      for l in losses {
        let active = l.a().re + l.b().re + l.c().re
        assert_true(active >= -1.0e-12)
      }
    }
    Err(e) => fail(e.describe())
  }
}
