// dist/model.mbt — 三相不平衡配电网的数据结构（纯计算，标幺值 p.u.）。
//
// 与 model/ 的单相平衡模型并列：model/ 面向输电级正序网络，本包面向配电级
// 辐射状三相网络。约定：
//   - 电压为相对地相电压相量，电流为相电流；
//   - 负荷功率 S = P + jQ，按"取用"为正（与 model/ 的"注入"为正相反），
//     求解器在回代时用 conj(S/V) 得到负荷电流；
//   - 支路用 3x3 复阻抗矩阵描述，保留相间互阻抗，支持三相参数不对称。

///|
/// 三相复相量：a/b/c 三相各自一个复数。
pub struct Phasor {
  a : @model.Cx
  b : @model.Cx
  c : @model.Cx
}

///|
/// 由三个复数构造相量。
pub fn phasor(a : @model.Cx, b : @model.Cx, c : @model.Cx) -> Phasor {
  { a, b, c, }
}

///|
/// 全部为零的相量。
pub fn Phasor::zero() -> Phasor {
  { a: @model.cx(0.0, 0.0), b: @model.cx(0.0, 0.0), c: @model.cx(0.0, 0.0), }
}

///|
/// 三相同一个复数值。
pub fn Phasor::uniform(v : @model.Cx) -> Phasor {
  { a: v, b: v, c: v, }
}

///|
/// 平衡三相：幅值 mag，a 相角 angle（弧度），b/c 依次滞后 120°。
pub fn Phasor::balanced(mag : Double, angle : Double) -> Phasor {
  let pi = 3.141592653589793
  {
    a: @model.cx_polar(mag, angle),
    b: @model.cx_polar(mag, angle - 2.0 * pi / 3.0),
    c: @model.cx_polar(mag, angle + 2.0 * pi / 3.0),
  }
}

///|
pub fn Phasor::a(self : Phasor) -> @model.Cx {
  self.a
}

///|
pub fn Phasor::b(self : Phasor) -> @model.Cx {
  self.b
}

///|
pub fn Phasor::c(self : Phasor) -> @model.Cx {
  self.c
}

///|
pub fn Phasor::add(self : Phasor, other : Phasor) -> Phasor {
  {
    a: @model.cx_add(self.a, other.a),
    b: @model.cx_add(self.b, other.b),
    c: @model.cx_add(self.c, other.c),
  }
}

///|
pub fn Phasor::sub(self : Phasor, other : Phasor) -> Phasor {
  {
    a: @model.cx_sub(self.a, other.a),
    b: @model.cx_sub(self.b, other.b),
    c: @model.cx_sub(self.c, other.c),
  }
}

///|
/// 逐相除以一个复标量（用于 conj(S/V) 之类的逐相运算）。
pub fn Phasor::map_div(self : Phasor, den : Phasor) -> Phasor {
  {
    a: @model.cx_div(self.a, den.a),
    b: @model.cx_div(self.b, den.b),
    c: @model.cx_div(self.c, den.c),
  }
}

///|
/// 逐相共轭。
pub fn Phasor::conj(self : Phasor) -> Phasor {
  {
    a: @model.cx_conj(self.a),
    b: @model.cx_conj(self.b),
    c: @model.cx_conj(self.c),
  }
}

///|
/// 三相中最大的复模长（用于收敛判据）。
pub fn Phasor::max_abs(self : Phasor) -> Double {
  let a = @model.cx_abs(self.a)
  let b = @model.cx_abs(self.b)
  let c = @model.cx_abs(self.c)
  let m = if a > b { a } else { b }
  if c > m {
    c
  } else {
    m
  }
}

///|
/// 对称 3x3 复阻抗矩阵。只存上三角的六个元素，对角为自阻抗，
/// 非对角为相间互阻抗；矩阵按对称处理（Z_ab = Z_ba 等）。
pub struct Z3 {
  aa : @model.Cx
  bb : @model.Cx
  cc : @model.Cx
  ab : @model.Cx
  ac : @model.Cx
  bc : @model.Cx
}

///|
/// 无相间耦合的对角阻抗矩阵。
pub fn z3_diag(za : @model.Cx, zb : @model.Cx, zc : @model.Cx) -> Z3 {
  let zero = @model.cx(0.0, 0.0)
  { aa: za, bb: zb, cc: zc, ab: zero, ac: zero, bc: zero, }
}

///|
/// 完整对称阻抗矩阵：给定三个自阻抗与三个互阻抗。
pub fn z3_symmetric(
  aa : @model.Cx,
  bb : @model.Cx,
  cc : @model.Cx,
  ab : @model.Cx,
  ac : @model.Cx,
  bc : @model.Cx,
) -> Z3 {
  { aa, bb, cc, ab, ac, bc, }
}

///|
/// 对称阻抗矩阵乘三相电流相量，得到三相电压降。
pub fn Z3::mul(self : Z3, i : Phasor) -> Phasor {
  let va = @model.cx_add(
    @model.cx_add(@model.cx_mul(self.aa, i.a), @model.cx_mul(self.ab, i.b)),
    @model.cx_mul(self.ac, i.c),
  )
  let vb = @model.cx_add(
    @model.cx_add(@model.cx_mul(self.ab, i.a), @model.cx_mul(self.bb, i.b)),
    @model.cx_mul(self.bc, i.c),
  )
  let vc = @model.cx_add(
    @model.cx_add(@model.cx_mul(self.ac, i.a), @model.cx_mul(self.bc, i.b)),
    @model.cx_mul(self.cc, i.c),
  )
  { a: va, b: vb, c: vc, }
}

///|
/// 配电母线：外部编号 + 三相负荷复功率（取用为正，缺相填 0）。
pub struct DistNode {
  id : Int32
  s : Phasor
}

///|
pub fn DistNode::make(id : Int32, s : Phasor) -> DistNode {
  { id, s, }
}

///|
pub fn DistNode::id(self : DistNode) -> Int32 {
  self.id
}

///|
pub fn DistNode::s(self : DistNode) -> Phasor {
  self.s
}

///|
/// 配电支路：from → to，3x3 复阻抗矩阵。
pub struct DistEdge {
  from_id : Int32
  to_id : Int32
  z : Z3
}

///|
pub fn DistEdge::make(from_id : Int32, to_id : Int32, z : Z3) -> DistEdge {
  { from_id, to_id, z, }
}

///|
pub fn DistEdge::from_id(self : DistEdge) -> Int32 {
  self.from_id
}

///|
pub fn DistEdge::to_id(self : DistEdge) -> Int32 {
  self.to_id
}

///|
pub fn DistEdge::z(self : DistEdge) -> Z3 {
  self.z
}

///|
/// 三相辐射状配电网络：母线表 + 支路表 + 根母线编号与根三相电压。
pub struct DistNet {
  nodes : Array[DistNode]
  edges : Array[DistEdge]
  root_id : Int32
  v_root : Phasor
}

///|
/// 构造网络。合法性（编号唯一、辐射状、连通、根存在）由 topology 校验，
/// 本构造只负责打包。
pub fn DistNet::make(
  nodes : Array[DistNode],
  edges : Array[DistEdge],
  root_id : Int32,
  v_root : Phasor,
) -> DistNet {
  { nodes, edges, root_id, v_root, }
}

///|
pub fn DistNet::node_count(self : DistNet) -> Int32 {
  self.nodes.length()
}

///|
pub fn DistNet::edge_count(self : DistNet) -> Int32 {
  self.edges.length()
}

///|
pub fn DistNet::node_at(self : DistNet, i : Int32) -> DistNode {
  self.nodes[i]
}

///|
pub fn DistNet::edge_at(self : DistNet, k : Int32) -> DistEdge {
  self.edges[k]
}

///|
pub fn DistNet::root_id(self : DistNet) -> Int32 {
  self.root_id
}

///|
pub fn DistNet::v_root(self : DistNet) -> Phasor {
  self.v_root
}

///|
/// 按外部编号查内部下标，找不到返回 None。
pub fn DistNet::find_index(self : DistNet, id : Int32) -> Int32? {
  let n = self.nodes.length()
  let mut i = 0
  while i < n {
    if self.nodes[i].id == id {
      return Some(i)
    }
    i += 1
  }
  None
}
