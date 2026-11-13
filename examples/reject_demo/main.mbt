///|
/// 拒绝演示：把「不合法输入会怎样」全部跑一遍。
///
/// 这个库最认真写的是输入校验与结构化失败，但它们只在源码和测试里能看见。
/// 评委与使用者看不到「拒绝」，只看得到功能。这个示例把每条拒绝路径打印出来，
/// 每条都只有两种结局：非法的被拒、合法的通过。
///
/// 运行：`moon run examples/reject_demo --target native`
fn chain(n : Int32) -> @dist.DistNet {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let nodes : Array[@dist.DistNode] = []
  let edges : Array[@dist.DistEdge] = []
  let mut i = 1
  while i <= n {
    nodes.push(@dist.DistNode::make(i, @dist.Phasor::uniform(z)))
    if i > 1 {
      edges.push(@dist.DistEdge::make(i - 1, i, z3))
    }
    i = i + 1
  }
  @dist.DistNet::make(nodes, edges, 1, @dist.Phasor::balanced(1.0, 0.0))
}

///|
fn show(label : String, r : Result[@dist.Topology, @dist.TopoErr]) -> Unit {
  match r {
    Ok(_) => println("  " + label + " -> 通过（预期之外）")
    Err(e) => println("  " + label + " -> 拒绝：" + e.describe())
  }
}

///|
fn show_sweep(
  label : String,
  r : Result[@dist.SweepOk, @dist.SweepErr],
) -> Unit {
  match r {
    Ok(_) => println("  " + label + " -> 求解成功（预期之外）")
    Err(e) => println("  " + label + " -> 拒绝：" + e.describe())
  }
}

///|
fn main {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)

  println("== 拓扑校验（build_topology）==")
  // 编号重复
  show(
    "重复母线编号",
    @dist.build_topology(
      @dist.DistNet::make(
        [
          @dist.DistNode::make(1, @dist.Phasor::zero()),
          @dist.DistNode::make(1, @dist.Phasor::zero()),
          @dist.DistNode::make(3, @dist.Phasor::zero()),
        ],
        [@dist.DistEdge::make(1, 3, z3)],
        1,
        @dist.Phasor::balanced(1.0, 0.0),
      ),
    ),
  )
  // 支路端点不存在
  show(
    "支路引用不存在的母线 9",
    @dist.build_topology(
      @dist.DistNet::make(
        [
          @dist.DistNode::make(1, @dist.Phasor::zero()),
          @dist.DistNode::make(2, @dist.Phasor::uniform(z)),
        ],
        [@dist.DistEdge::make(1, 9, z3)],
        1,
        @dist.Phasor::balanced(1.0, 0.0),
      ),
    ),
  )
  // 环网：3 节点 3 支路
  show(
    "环网（3 节点 3 支路）",
    @dist.build_topology(
      @dist.DistNet::make(
        [
          @dist.DistNode::make(1, @dist.Phasor::zero()),
          @dist.DistNode::make(2, @dist.Phasor::uniform(z)),
          @dist.DistNode::make(3, @dist.Phasor::uniform(z)),
        ],
        [
          @dist.DistEdge::make(1, 2, z3),
          @dist.DistEdge::make(2, 3, z3),
          @dist.DistEdge::make(3, 1, z3),
        ],
        1,
        @dist.Phasor::balanced(1.0, 0.0),
      ),
    ),
  )
  // 不连通：边数恰好 n-1，但 3/4 那一段到不了根
  show(
    "不连通（3-4 与根断开）",
    @dist.build_topology(
      @dist.DistNet::make(
        [
          @dist.DistNode::make(1, @dist.Phasor::zero()),
          @dist.DistNode::make(2, @dist.Phasor::uniform(z)),
          @dist.DistNode::make(3, @dist.Phasor::uniform(z)),
          @dist.DistNode::make(4, @dist.Phasor::uniform(z)),
        ],
        [
          @dist.DistEdge::make(1, 2, z3),
          @dist.DistEdge::make(2, 1, z3),
          @dist.DistEdge::make(3, 4, z3),
        ],
        1,
        @dist.Phasor::balanced(1.0, 0.0),
      ),
    ),
  )
  // 根不存在
  let bad_root = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, @dist.Phasor::uniform(z)),
      @dist.DistNode::make(3, @dist.Phasor::uniform(z)),
    ],
    [@dist.DistEdge::make(1, 2, z3), @dist.DistEdge::make(2, 3, z3)],
    99,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  show("根编号 99 不在节点表里", @dist.build_topology(bad_root))

  println("")
  println("== 求解器拒绝（sweep）==")
  let good = chain(3)
  let topo = match @dist.build_topology(good) {
    Ok(t) => t
    Err(e) => {
      println("  基准网络本身非法：" + e.describe())
      return
    }
  }
  let base = match @dist.sweep(good, topo, 1.0e-9, 100) {
    Ok(r) => "收敛，用了 " + r.iter().to_string() + " 次扫描"
    Err(e) => e.describe()
  }
  println("  合法网络（3 节点链式） -> 通过：" + base)
  show_sweep("tol = 0", @dist.sweep(good, topo, 0.0, 100))
  show_sweep("tol = +inf", @dist.sweep(good, topo, 1.0e309, 100))
  show_sweep("迭代上限 = 0", @dist.sweep(good, topo, 1.0e-9, 0))
  // 拓扑来自另一张同规模、同根、但树形不同的网
  let other = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, @dist.Phasor::uniform(z)),
      @dist.DistNode::make(3, @dist.Phasor::uniform(z)),
    ],
    [@dist.DistEdge::make(1, 3, z3), @dist.DistEdge::make(3, 2, z3)],
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  show_sweep(
    "拓扑来自另一张网（同根、不同树）",
    @dist.sweep(other, topo, 1.0e-9, 100),
  )

  println("")
  println("== 模型校验 ==")
  match @model.Zip::new(0.5, 0.4, 0.4) {
    Ok(_) => println("  ZIP 系数和 = 1.3 -> 通过（预期之外）")
    Err(e) => println("  ZIP 系数和 = 1.3 -> 拒绝：" + e)
  }
  match @model.Zip::new(0.5, 0.5, 0.0) {
    Ok(_) => println("  ZIP 系数 (0.5,0.5,0) -> 通过")
    Err(e) => println("  ZIP 系数 (0.5,0.5,0) -> 拒绝：" + e)
  }
}
