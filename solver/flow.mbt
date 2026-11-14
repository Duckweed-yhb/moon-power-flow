// solver/flow.mbt — 收敛电压下的支路复功率潮流与损耗。
//
// 约定：S_from = V_a * conj(I_ab)，I_ab = y * (V_a - V_b)；
// S_to 同理从 b 端计算；支路复功率损耗 S_loss = S_from + S_to（p.u.）。
// 本轮不含对地充电功率，损耗只来自串联阻抗。

///|
/// 单条支路两端复功率与损耗（复数值，p.u.）。
pub struct BranchFlow {
  from_id : Int32
  to_id : Int32
  s_from : @model.Cx
  s_to : @model.Cx
  loss : @model.Cx
}

///|
pub fn BranchFlow::from_id(self : BranchFlow) -> Int32 {
  self.from_id
}

///|
pub fn BranchFlow::to_id(self : BranchFlow) -> Int32 {
  self.to_id
}

///|
pub fn BranchFlow::s_from(self : BranchFlow) -> @model.Cx {
  self.s_from
}

///|
pub fn BranchFlow::s_to(self : BranchFlow) -> @model.Cx {
  self.s_to
}

///|
pub fn BranchFlow::loss(self : BranchFlow) -> @model.Cx {
  self.loss
}

///|
/// 按外部编号查内部下标。端点存在性由 `model.validate` 规则 3 保证；
/// 查不到说明 model 层有 bug，与 `ybus.bus_index` 口径一致，直接 abort，
/// 不回退下标 0 静默接到首条母线。
fn local_index(net : @model.Network, id : Int32) -> Int32 {
  let n = net.bus_count()
  let mut i = 0
  while i < n {
    if net.bus_at(i).bus_id() == id {
      return i
    }
    i += 1
  }
  abort("flow: bus id " + id.to_string() + " not found in a validated network")
}

///|
/// 计算第 k 条支路的两端潮流与损耗。
pub fn branch_flow(
  net : @model.Network,
  voltages : Array[@model.Cx],
  k : Int32,
) -> BranchFlow {
  let br = net.branch_at(k)
  let a = local_index(net, br.from_id())
  let b = local_index(net, br.to_id())
  let y = @ybus.branch_admittance(br.impedance())
  let va = voltages[a]
  let vb = voltages[b]
  let i_ab = @model.cx_mul(y, @model.cx_sub(va, vb))
  let i_ba = @model.cx_mul(y, @model.cx_sub(vb, va))
  let s_from = @model.cx_mul(va, @model.cx_conj(i_ab))
  let s_to = @model.cx_mul(vb, @model.cx_conj(i_ba))
  let loss = @model.cx_add(s_from, s_to)
  { from_id: br.from_id(), to_id: br.to_id(), s_from, s_to, loss, }
}

///|
/// 汇总全部支路潮流。
pub fn all_flows(
  net : @model.Network,
  voltages : Array[@model.Cx],
) -> Array[BranchFlow] {
  let m = net.branch_count()
  Array::makei(m, k => branch_flow(net, voltages, k))
}
