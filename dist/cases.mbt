// dist/cases.mbt — 内置算例：小型三相不平衡辐射网。
//
// 全部为标幺值：基准容量 100 kVA、基准相电压 230 V（即 S_base = 1.0 时
// 1.0 p.u. 电压对应 230 V 相电压）。负荷按"取用为正"填写，缺相填 0。

///|
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

///|
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

///|
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

///|
/// 带变压器的两节点算例：1 → 2 为一台变比 1.0、漏阻抗 0.02+j0.04 p.u. 的
/// 变压器，节点 2 挂平衡三相负荷。用来和「同拓扑同负荷的普通线路」对照变比
/// 与漏阻抗压降的差别。
pub fn case_with_transformer() -> DistNet {
  let zt = @model.cx(0.02, 0.04)
  let z3 = z3_diag(zt, zt, zt)
  let tx = match TxSpec::new(1.0, z3) {
    Ok(t) => t
    Err(_) => TxSpec::disabled()
  }
  let s = @model.cx(0.10, 0.03)
  let nodes = [
    DistNode::make(1, Phasor::zero()),
    DistNode::make(2, Phasor::uniform(s)),
  ]
  let edges = [DistEdge::make_tx(1, 2, tx)]
  DistNet::make(nodes, edges, 1, Phasor::balanced(1.0, 0.0))
}

///|
/// 带缺相支路的算例：1 → 2 为普通线路，但 b 相断开；节点 2 三相都挂负荷。
/// 断开相支路电流置零、下游该相电压为零，a/c 两相仍正常供负荷。
pub fn case_with_open_phase() -> DistNet {
  let z = @model.cx(0.01, 0.02)
  let z3 = z3_diag(z, z, z)
  let s = phasor(
    @model.cx(0.08, 0.02),
    @model.cx(0.06, 0.02),
    @model.cx(0.08, 0.02),
  )
  let nodes = [DistNode::make(1, Phasor::zero()), DistNode::make(2, s)]
  let closed = Switch::closed().open_phase(1)
  let edges = [DistEdge::make(1, 2, z3).with_switch(closed)]
  DistNet::make(nodes, edges, 1, Phasor::balanced(1.0, 0.0))
}

///|
/// 编号乱序的算例：根是 10，中间节点 7，末端 3，节点表顺序也不是拓扑序。
/// 用来验证拓扑与求解按 BFS 走，而不是依赖编号或数组顺序。
pub fn case_scrambled_ids() -> DistNet {
  let z = @model.cx(0.01, 0.02)
  let nodes = [
    DistNode::make(10, Phasor::zero()),
    DistNode::make(3, Phasor::uniform(@model.cx(0.05, 0.01))),
    DistNode::make(7, Phasor::uniform(@model.cx(0.03, 0.01))),
  ]
  let edges = [
    DistEdge::make(10, 7, z3_diag(z, z, z)),
    DistEdge::make(7, 3, z3_diag(z, z, z)),
  ]
  DistNet::make(nodes, edges, 10, Phasor::balanced(1.0, 0.0))
}
