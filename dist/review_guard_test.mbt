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

///|
/// NaN 不许被当成「已收敛」。
///
/// `NaN > max_dv` 恒为 false，所以收敛判据里 max_dv 会停在 0，第一轮就判定
/// 收敛并返回 Ok + NaN 电压。这不是精度问题，是结果对错问题：调用方拿到的
/// 是「成功」和一个没法用的电压。
test "sweep reports non-finite instead of converging on NaN" {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let nan = 0.0 / 0.0
  let bad = @dist.phasor(
    @model.cx(nan, 0.0),
    @model.cx(nan, 0.0),
    @model.cx(nan, 0.0),
  )
  let net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, bad),
    ],
    [@dist.DistEdge::make(1, 2, z3)],
    1,
    @dist.Phasor::uniform(@model.cx(1.0, 0.0)),
  )
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-9, 50) {
    Ok(r) =>
      fail("NaN load must not converge, got max_dv=" + r.max_dv().to_string())
    Err(e) =>
      match e {
        @dist.SweepErr::NonFinite(_) => ()
        _ => fail("expected NonFinite, got " + e.describe())
      }
  }
}
