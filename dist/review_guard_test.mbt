///|
/// 评审加固：错配的拓扑不许 panic，要让调用方拿到结构化错误。
///
/// 之前的 `sweep` 直接按 `parent_edge[u]` 索引 `i_branch`：传进别处的拓扑
/// 就是数组越界，进程直接挂掉，调用方连 catch 的机会都没有。

///|
test "sweep rejects topology from a different network" {
  let small = @dist.case_coupled()
  let big = @dist.case_four_node()
  let topo_small = match @dist.build_topology(small) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  // 用小网络的拓扑去解大网络：节点数对不上，必须返回结构化错误。
  match @dist.sweep(big, topo_small, 1.0e-9, 50) {
    Ok(_) => fail("mismatched topology should not solve")
    Err(e) =>
      match e {
        @dist.SweepErr::TopologyMismatch => ()
        _ => fail("expected TopologyMismatch, got " + e.describe())
      }
  }
}

///|
test "sweep still solves when the topology matches" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => assert_true(r.iter() > 0)
    Err(e) => fail(e.describe())
  }
}
