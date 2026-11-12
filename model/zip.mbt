// model/zip.mbt — 负荷静特性（ZIP 模型），三相与单相求解器共用。
//
// 真实负荷介于恒功率、恒电流、恒阻抗之间，母线电压越低，恒阻抗负荷取用的
// 功率越小。ZIP 模型把它写成一个二次多项式：
//
//   S(V) = S0 · (α + β·|V| + γ·|V|²)， α + β + γ = 1
//
// α 对应恒功率、β 恒电流、γ 恒阻抗，全部为标幺。这里只放「系数与缩放」这一
// 层，与具体求解器无关：三相侧逐相缩放（`dist/zip.mbt`），单相侧按节点电压
// 缩放（`solver/gs.mbt`）。

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
  // 先挡非有限值：NaN 与任何数比较恒假，`alpha < 0.0` 与 `(sum-1).abs() > 1e-9`
  // 都会放行，于是构造出一个 alpha=NaN 的合法 Zip，一直到求解器里才炸。
  if alpha != alpha || beta != beta || gamma != gamma {
    return Err("ZIP coefficients must be finite")
  }
  if alpha < 0.0 || beta < 0.0 || gamma < 0.0 {
    return Err("ZIP coefficients must be non-negative")
  }
  if alpha > 1.0e308 || beta > 1.0e308 || gamma > 1.0e308 {
    return Err("ZIP coefficients must be finite")
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
/// 纯恒功率（与恒定 S 的求解等价）。
pub fn Zip::constant_power() -> Zip {
  { alpha: 1.0, beta: 0.0, gamma: 0.0, }
}

///|
/// 纯恒阻抗（负荷等值为导纳）。
pub fn Zip::constant_impedance() -> Zip {
  { alpha: 0.0, beta: 0.0, gamma: 1.0, }
}

///|
/// 给定电压模长，返回该类负荷的功率缩放系数 α + β·|V| + γ·|V|²。
pub fn Zip::scale_at(self : Zip, v_mag : Double) -> Double {
  self.alpha + self.beta * v_mag + self.gamma * v_mag * v_mag
}
