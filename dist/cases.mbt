// dist/cases.mbt — 内置算例：小型三相不平衡辐射网。
//
// 全部为标幺值：基准容量 100 kVA、基准相电压 230 V（即 S_base = 1.0 时
// 1.0 p.u. 电压对应 230 V 相电压）。负荷按"取用为正"填写，缺相填 0。

/// 四节点不平衡算例：1 为根，2/3/4 挂不同相位的单相与两相负荷。
///
/// 拓扑：1 → 2 → {3, 4}，三条支路阻抗相同（0.01 + j0.02 p.u.），
/// 但负荷严重不平衡，用来暴露"三相平衡假设"会算错的场景。
pub fn case_four_node() -> DistNet {
  let z = @model.cx(0.01, 0.02)
  let z12 = z3_diag(z, z, z)
  let z23 = z3_diag(z, z, z)
  let z24 = z3_diag(z, z, z)
  let nodes = [
    DistNode::make(1, Phasor::zero()),
    DistNode::make(
      2,
      phasor(
        @model.cx(0.10, 0.03),
        @model.cx(0.05, 0.02),
        @model.cx(0.03, 0.01),
      ),
    ),
    DistNode::make(
      3,
      phasor(@model.cx(0.06, 0.02), @model.cx(0.0, 0.0), @model.cx(0.02, 0.005)),
    ),
    DistNode::make(
      4,
      phasor(@model.cx(0.0, 0.0), @model.cx(0.0, 0.0), @model.cx(0.04, 0.015)),
    ),
  ]
  let edges = [
    DistEdge::make(1, 2, z12),
    DistEdge::make(2, 3, z23),
    DistEdge::make(2, 4, z24),
  ]
  DistNet::make(nodes, edges, 1, Phasor::balanced(1.0, 0.0))
}

/// 平衡算例：同样拓扑与阻抗，但三相负荷完全相同、根电压平衡。
/// 三相电压应退化为同一个数（用于对称性回归）。
pub fn case_balanced() -> DistNet {
  let z = @model.cx(0.01, 0.02)
  let s = @model.cx(0.10, 0.03)
  let nodes = [
    DistNode::make(1, Phasor::zero()),
    DistNode::make(2, Phasor::uniform(s)),
    DistNode::make(3, Phasor::uniform(s)),
    DistNode::make(4, Phasor::uniform(s)),
  ]
  let edges = [
    DistEdge::make(1, 2, z3_diag(z, z, z)),
    DistEdge::make(2, 3, z3_diag(z, z, z)),
    DistEdge::make(2, 4, z3_diag(z, z, z)),
  ]
  DistNet::make(nodes, edges, 1, Phasor::balanced(1.0, 0.0))
}

/// 带相间互阻抗的算例：三相自阻抗不同、且存在 ab/ac/bc 互阻抗。
/// 用来确认 3x3 矩阵不是只用了对角。
pub fn case_coupled() -> DistNet {
  let zaa = @model.cx(0.02, 0.04)
  let zbb = @model.cx(0.02, 0.04)
  let zcc = @model.cx(0.02, 0.04)
  let m = @model.cx(0.005, 0.01)
  let z = z3_symmetric(zaa, zbb, zcc, m, m, m)
  let nodes = [
    DistNode::make(1, Phasor::zero()),
    DistNode::make(
      2,
      phasor(@model.cx(0.08, 0.02), @model.cx(0.0, 0.0), @model.cx(0.0, 0.0)),
    ),
  ]
  let edges = [DistEdge::make(1, 2, z)]
  DistNet::make(nodes, edges, 1, Phasor::balanced(1.0, 0.0))
}
