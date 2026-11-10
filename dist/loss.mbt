// dist/loss.mbt — 支路损耗与功率平衡。
//
// 配电潮流的用户最终要的是两样东西：电压分布和不平衡度，以及**损耗**。
// 原先前推回代只吐电压与支路电流，损耗得让调用方自己按 Z·I 复算，而且
// 相间互阻抗很容易被漏掉。这里把损耗算成库的一部分，并用功率平衡做验证。
//
// 逐相损耗：S_p = (Z3 · I)_p · conj(I_p)。由于 Z3 保留了相间互阻抗，
// (Z3 · I)_p 已经含其它两相电流的耦合压降；三项实部之和即该支路的有功损耗，
// 恒为非负（R 对称半正定）。

///|
/// 每条支路的三相复功率损耗，顺序与 `DistNet::edge_at` 一致。
///
/// 返回的每个元素是该支路三个相的损耗相量（伏安，标幺）；实部为有功。
pub fn branch_losses(net : DistNet, r : SweepOk) -> Array[Phasor] {
  let cur = r.branch_currents()
  let out : Array[Phasor] = []
  for k in 0..<cur.length() {
    let i = cur[k]
    let drop = net.edge_at(k).z().mul(i)
    out.push(
      phasor(
        @model.cx_mul(drop.a(), @model.cx_conj(i.a())),
        @model.cx_mul(drop.b(), @model.cx_conj(i.b())),
        @model.cx_mul(drop.c(), @model.cx_conj(i.c())),
      ),
    )
  }
  out
}

///|
/// 全网有功损耗（标幺）：所有支路三个相的有功损耗之和。
pub fn total_loss_active(net : DistNet, r : SweepOk) -> Double {
  let mut sum = 0.0
  for l in branch_losses(net, r) {
    sum = sum + l.a().re + l.b().re + l.c().re
  }
  sum
}

///|
/// 负荷总有功需求（标幺）：非根母线的 P 之和，根母线视为电源不参与。
pub fn load_demand_active(net : DistNet) -> Double {
  let root_id = net.root_id()
  let mut sum = 0.0
  for i in 0..<net.node_count() {
    let node = net.node_at(i)
    if node.id() != root_id {
      sum = sum + node.s().a().re + node.s().b().re + node.s().c().re
    }
  }
  sum
}

///|
/// 根母线注入的有功功率（标幺）：根出发的所有支路，逐个相加 V_root·conj(I)。
///
/// 与 `load_demand_active + total_loss_active` 构成功率平衡恒等式，
/// 是检验「损耗算对没有」最硬的一条判据（不依赖任何外部参考数据）。
pub fn root_injection_active(net : DistNet, r : SweepOk) -> Double {
  let root_id = net.root_id()
  let v_root = net.v_root()
  let cur = r.branch_currents()
  let mut sum = 0.0
  for k in 0..<net.edge_count() {
    if net.edge_at(k).from_id() == root_id {
      let i = cur[k]
      let pa = @model.cx_mul(v_root.a(), @model.cx_conj(i.a())).re
      let pb = @model.cx_mul(v_root.b(), @model.cx_conj(i.b())).re
      let pc = @model.cx_mul(v_root.c(), @model.cx_conj(i.c())).re
      sum = sum + pa + pb + pc
    }
  }
  sum
}
