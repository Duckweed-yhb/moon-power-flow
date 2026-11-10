// dist/zip.mbt — 负荷静特性（ZIP 模型）。
//
// 前推回代默认按恒功率负荷（S 与电压无关）迭代。真实配电负荷介于
// 恒功率、恒电流、恒阻抗之间，母线电压越低，恒阻抗负荷取用的功率越小。
// ZIP 模型把它写成一个二次多项式：
//
//   S(V) = S0 · (α + β·|V| + γ·|V|²)， α + β + γ = 1
//
// α 对应恒功率（P、Q 不随电压变）、β 恒电流、γ 恒阻抗。全部为标幺，
// |V| 取相电压模长，逐相独立缩放（三相不平衡网里每相电压本来就不同）。
//
// 这条以前在 README 的「计划中」里挂着，现在按最小可验证的形式落地：
// 不改 `sweep` 的行为，另开 `sweep_zip` 入口。

///|
/// ZIP 负荷系数：恒功率 / 恒电流 / 恒阻抗三者的占比，和为 1。
pub struct Zip {
  alpha : Double
  beta : Double
  gamma : Double
}

///|
/// 构造 ZIP 系数。三者必须非负、且和与 1 的偏差小于 1e-9；
/// 不满足返回 Err——和不为 1 时负荷功率会凭空放大或缩小。
pub fn Zip::new(
  alpha : Double,
  beta : Double,
  gamma : Double,
) -> Result[Zip, String] {
  if alpha < 0.0 || beta < 0.0 || gamma < 0.0 {
    return Err("ZIP coefficients must be non-negative")
  }
  let sum = alpha + beta + gamma
  if (sum - 1.0).abs() > 1.0e-9 {
    return Err("ZIP coefficients must sum to 1, got " + sum.to_string())
  }
  Ok({ alpha, beta, gamma, })
}

///|
pub fn Zip::alpha(self : Zip) -> Double {
  self.alpha
}

///|
pub fn Zip::beta(self : Zip) -> Double {
  self.beta
}

///|
pub fn Zip::gamma(self : Zip) -> Double {
  self.gamma
}

///|
/// 纯恒功率（与 `sweep` 等价）。
pub fn Zip::constant_power() -> Zip {
  { alpha: 1.0, beta: 0.0, gamma: 0.0, }
}

///|
/// 纯恒阻抗（负荷等值为导纳）。
pub fn Zip::constant_impedance() -> Zip {
  { alpha: 0.0, beta: 0.0, gamma: 1.0, }
}

///|
/// 给定相电压模长，返回该类负荷的功率缩放系数 α + β·|V| + γ·|V|²。
pub fn Zip::scale_at(self : Zip, v_mag : Double) -> Double {
  self.alpha + self.beta * v_mag + self.gamma * v_mag * v_mag
}

///|
/// 按 ZIP 模型缩放三相负荷功率（逐相用各自的电压模长）。
pub fn zip_adjust_load(s : Phasor, v : Phasor, zip : Zip) -> Phasor {
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
pub fn load_demand_active_zip(net : DistNet, r : SweepOk, zip : Zip) -> Double {
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
fn load_current(s : Phasor, v : Phasor, zip : Zip?) -> Phasor {
  match zip {
    None => s.map_div(v).conj()
    Some(z) => zip_adjust_load(s, v, z).map_div(v).conj()
  }
}
