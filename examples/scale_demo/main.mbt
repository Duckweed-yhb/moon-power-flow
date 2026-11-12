///|
/// 规模实测：把一条辐射状馈线拉长到 N 个节点，看求解器在哪里开始变慢。
///
/// 目的不是炫技，是把「能跑多大」变成可复现的数字，而不是一句「面向配电级」。
/// 物理量固定（总阻抗与总负荷不随 N 变），只让节点数增长，这样测的是求解器
/// 的规模行为，不是「网架越难越慢」。
///
/// 运行：`moon run examples/scale_demo --target native`
fn build_chain(n : Int32) -> @dist.DistNet {
  let per_seg = @model.cx(0.02 / n.to_double(), 0.04 / n.to_double())
  let z3 = @dist.z3_diag(per_seg, per_seg, per_seg)
  let per_node = @model.cx(0.3 / (n - 1).to_double(), 0.1 / (n - 1).to_double())
  let nodes : Array[@dist.DistNode] = []
  let edges : Array[@dist.DistEdge] = []
  let mut i = 1
  while i <= n {
    let s = if i == 1 {
      @dist.Phasor::zero()
    } else {
      @dist.Phasor::uniform(per_node)
    }
    nodes.push(@dist.DistNode::make(i, s))
    if i > 1 {
      edges.push(@dist.DistEdge::make(i - 1, i, z3))
    }
    i = i + 1
  }
  @dist.DistNet::make(nodes, edges, 1, @dist.Phasor::balanced(1.0, 0.0))
}

///|
fn min_magnitude(v : Array[@dist.Phasor]) -> Double {
  let mut m = 1.0e9
  for p in v {
    let a = @model.cx_abs(p.a())
    if a < m {
      m = a
    }
  }
  m
}

///|
fn main {
  println("nodes\tsweeps\tmax_dV\t\tloss(pu)\tdemand(pu)\tmin|V|")
  for n in [4, 10, 50, 200, 500, 1000, 2000, 5000] {
    let net = build_chain(n)
    let topo = match @dist.build_topology(net) {
      Ok(t) => t
      Err(e) => {
        println(n.to_string() + "\ttopology error: " + e.describe())
        continue
      }
    }
    match @dist.sweep(net, topo, 1.0e-9, 2000) {
      Ok(r) =>
        println(
          n.to_string() +
          "\t" +
          r.iter().to_string() +
          "\t" +
          r.max_dv().to_string() +
          "\t" +
          @dist.total_loss_active(net, r).to_string() +
          "\t" +
          @dist.load_demand_active(net).to_string() +
          "\t" +
          min_magnitude(r.voltages()).to_string(),
        )
      Err(e) => println(n.to_string() + "\tnot converged: " + e.describe())
    }
  }
}
