///|
/// 评审回归：同规模但根下标不同的另一张网的 Topology，必须返回结构化错误，
/// 不能 panic。
///
/// 旧实现只校验 `parent_edge[i] >= m`，挡不住「拓扑来自另一张网」：那张网的
/// 根在别的下标上，于是本网根节点拿到的 parent_edge 是 -1，回代里
/// `i_branch[-1]` 直接越界。文件头的注释恰好承诺的正是「库不该用 panic 报错」。
test "sweep rejects same-shape topology from another network" {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  // netA：根是 1（内部下标 0）
  let net_a = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, @dist.Phasor::uniform(z)),
    ],
    [@dist.DistEdge::make(1, 2, z3)],
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  // netB：同样的规模（2 节点 1 支路），但根是 2（内部下标 1）
  let net_b = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::uniform(z)),
      @dist.DistNode::make(2, @dist.Phasor::zero()),
    ],
    [@dist.DistEdge::make(2, 1, z3)],
    2,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  let topo_a = match @dist.build_topology(net_a) {
    Ok(t) => t
    Err(e) => fail("netA should be valid: " + e.describe())
  }
  match @dist.sweep(net_b, topo_a, 1.0e-9, 100) {
    Ok(_) => fail("topology from another network must be rejected")
    Err(e) =>
      match e {
        @dist.SweepErr::TopologyMismatch => ()
        _ => fail("expected TopologyMismatch")
      }
  }
}

///|
/// 评审回归：tol 必须是正的有限数。
///
/// tol=0 时判据 `max_dv < 0` 永远不成立（报 NotConverged，而实际偏差已经是 0）；
/// tol=+inf 时第一轮就判收敛，返回一个明显没收敛的解。两种都是配置错误。
test "sweep rejects non-positive and infinite tolerance" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail("case should be valid: " + e.describe())
  }
  for bad in [0.0, -1.0e-9, 1.0e309] {
    match @dist.sweep(net, topo, bad, 100) {
      Ok(_) => fail("tol=" + bad.to_string() + " must be rejected")
      Err(e) =>
        match e {
          @dist.SweepErr::InvalidConfig => ()
          _ => fail("expected InvalidConfig for tol=" + bad.to_string())
        }
    }
  }
  // 正常 tol 仍然能解
  match @dist.sweep(net, topo, 1.0e-9, 100) {
    Ok(_) => ()
    Err(_) => fail("valid tol should solve")
  }
}
