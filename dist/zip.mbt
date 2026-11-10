// dist/zip.mbt — 三相侧 ZIP 负荷：按相电压逐相缩放。
//
// 系数与缩放规则本身在 `model/zip.mbt`（与单相求解器共用），这里只放
// 「三相相量怎么缩放」和「回代阶段的负荷电流怎么算」。

///|
/// 按 ZIP 模型缩放三相负荷功率（逐相用各自的电压模长）。
///
/// 三相不平衡网里每相电压本来就不同，所以缩放必须逐相做，不能拿一个
/// 平均电压去乘三相。
pub fn zip_adjust_load(s : Phasor, v : Phasor, zip : @model.Zip) -> Phasor {
  let fa = zip.scale_at(@model.cx_abs(v.a()))
  let fb = zip.scale_at(@model.cx_abs(v.b()))
  let fc = zip.scale_at(@model.cx_abs(v.c()))
  phasor(
    @model.cx_scale(s.a(), fa),
    @model.cx_scale(s.b(), fb),
    @model.cx_scale(s.c(), fc),
  )
}

///|
/// 收敛后按 ZIP 模型算出的负荷总有功需求（标幺，根母线不计）。
///
/// 与 `load_demand_active` 的区别：后者用节点上写死的 S0，这里是按最终
/// 电压缩放后的实际取用。功率平衡要配它才对得上。
pub fn load_demand_active_zip(
  net : DistNet,
  r : SweepOk,
  zip : @model.Zip,
) -> Double {
  let root_id = net.root_id()
  let v = r.voltages()
  let mut sum = 0.0
  let mut i = 0
  while i < net.node_count() && i < v.length() {
    let node = net.node_at(i)
    if node.id() != root_id {
      let s_eff = zip_adjust_load(node.s(), v[i], zip)
      sum = sum + s_eff.a().re + s_eff.b().re + s_eff.c().re
    }
    i += 1
  }
  sum
}

///|
/// 回代阶段用的负荷电流：I = conj(S_eff / V)。`zip` 为 None 时是恒功率。
fn load_current(s : Phasor, v : Phasor, zip : @model.Zip?) -> Phasor {
  match zip {
    None => s.map_div(v).conj()
    Some(z) => zip_adjust_load(s, v, z).map_div(v).conj()
  }
}
