// dist/txshift.mbt — 变压器组别相移：按对称分量逐序旋转。
//
// 口径（与 dist/model.mbt 的 TxSpec 一致）：
//   - `shift_deg` 是副边电压相对原边的超前角，正序 +θ、负序 −θ；
//   - 零序分量不旋转。零序通路（接地方式、绕组接法）本轮不建模，
//     所以含零序的不平衡工况下这个假设只是近似，README 与 CHANGELOG 已写明；
//   - 电压按 +θ 转、电流按 −θ 转（正向旋转的逆），逐序满足
//     V_sec·conj(I_sec) = V_pri·conj(I_pri)；因此三相复功率
//     Σ V·conj(I) 在折算前后守恒，根注入与「负荷 + 损耗」的恒等式不受影响。
//
// 注意不要退化成"逐相乘同一个复因子"：那相当于三相整体转一个角度，
// 正负序同向旋转，组别相位差就不对了（不平衡度也不会按变压器的方式变化）。

///|
/// 把一个三相相量分解成零序、正序、负序三个分量，按 (V0, V1, V2) 返回。
///
/// 约定：a 相为参考，b 相滞后 120°、c 相超前 120° 的平衡集是正序。
pub fn sym_parts(x : Phasor) -> (@model.Cx, @model.Cx, @model.Cx) {
  let seq = symmetrical_components(x)
  (seq.zero(), seq.positive(), seq.negative())
}

///|
/// 组别旋转：正序转 +deg、负序转 −deg、零序不动，再合回三相。
///
/// `deg` 为 0 或非有限值时原样返回（读档与缺省参数都走这条路，不抛错）。
pub fn sequence_rotate(x : Phasor, deg : Double) -> Phasor {
  let degrees = deg % 360.0
  if degrees == 0.0 || degrees.is_nan() {
    return x
  }
  let pi = 3.141592653589793
  let a = @model.cx_polar(1.0, 2.0 * pi / 3.0)
  let a2 = @model.cx_polar(1.0, -2.0 * pi / 3.0)
  let (v0, v1, v2) = sym_parts(x)
  let th = degrees * pi / 180.0
  let p = @model.cx_mul(v1, @model.cx_polar(1.0, th))
  let n = @model.cx_mul(v2, @model.cx_polar(1.0, -th))
  phasor(
    @model.cx_add(@model.cx_add(v0, p), n),
    @model.cx_add(@model.cx_add(v0, @model.cx_mul(a2, p)), @model.cx_mul(a, n)),
    @model.cx_add(@model.cx_add(v0, @model.cx_mul(a, p)), @model.cx_mul(a2, n)),
  )
}

///|
/// 由原边电压求副边电压：先按组别转 +θ，再乘变比 k。
///
/// 与 `tx_primary_current` 配对使用，二者都作用在同一个旋转算子上，
/// 所以 `V_pri·conj(I_pri) = V_sec·conj(I_sec)`。
pub fn tx_secondary_voltage(tx : TxSpec, v_pri : Phasor) -> Phasor {
  sequence_rotate(v_pri, tx.phase_shift_deg()).scale(tx.ratio())
}

///|
/// 由副边电流求原边电流：先按组别转 −θ（正向旋转的逆），再乘变比 k。
///
/// 电压按 +θ 转、电流按 −θ 转是逐序功率守恒的要求：正序上有
/// `V_sec·conj(I_sec) = k·e^{jθ}V_pri·conj(k·e^{-jθ}I_pri) = V_pri·conj(I_pri)`，
/// 负序同理。两边同向旋转会让复功率差一个相角，根注入对不上「负荷 + 损耗」。
pub fn tx_primary_current(tx : TxSpec, i_sec : Phasor) -> Phasor {
  sequence_rotate(i_sec, -tx.phase_shift_deg()).scale(tx.ratio())
}
