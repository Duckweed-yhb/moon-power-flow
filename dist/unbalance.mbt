// dist/unbalance.mbt — 对称分量与三相电压不平衡度。
//
// 这个库的卖点是「三相不平衡」，但此前只给每相电压，没有回答「到底有多不平衡」。
// 配电侧判断不平衡量的标准做法是对称分量法（Fortescue）：把三相相量拆成正序、
// 负序、零序，再用负序/正序之比表示不平衡度。
//
// 依据：
// - 对称分量定义：a = e^{j120°}，
//   V0 = (Va + Vb + Vc)/3，V1 = (Va + a·Vb + a²·Vc)/3，V2 = (Va + a²·Vb + a·Vc)/3。
// - 电压不平衡度（IEC 61000-4-30 / IEEE 1159 的常用定义）：
//   VUF = |V2| / |V1| × 100%。
//
// 只做计算，不做判断：多少算超限由调用方按自己的规程定。

///|
/// 三相电压的对称分量（Fortescue）。
pub struct Seq {
  /// 零序 V0。
  zero : @model.Cx
  /// 正序 V1（基波正序，正常运行时的主分量）。
  positive : @model.Cx
  /// 负序 V2（不平衡的主要来源）。
  negative : @model.Cx
}

///|
/// 旋转算子 a = e^{j120°} = −1/2 + j√3/2。
pub fn rot_a() -> @model.Cx {
  @model.cx(-0.5, 0.8660254037844386)
}

///|
/// 把三相相量拆成对称分量。
pub fn symmetrical_components(v : Phasor) -> Seq {
  let a = rot_a()
  let a2 = @model.cx_mul(a, a)
  let va = v.a()
  let vb = v.b()
  let vc = v.c()
  let third = 1.0 / 3.0
  let zero = @model.cx_scale(@model.cx_add(@model.cx_add(va, vb), vc), third)
  let positive = @model.cx_scale(
    @model.cx_add(
      @model.cx_add(va, @model.cx_mul(a, vb)),
      @model.cx_mul(a2, vc),
    ),
    third,
  )
  let negative = @model.cx_scale(
    @model.cx_add(
      @model.cx_add(va, @model.cx_mul(a2, vb)),
      @model.cx_mul(a, vc),
    ),
    third,
  )
  { zero, positive, negative, }
}

///|
pub fn Seq::zero(self : Seq) -> @model.Cx {
  self.zero
}

///|
pub fn Seq::positive(self : Seq) -> @model.Cx {
  self.positive
}

///|
pub fn Seq::negative(self : Seq) -> @model.Cx {
  self.negative
}

///|
/// 电压不平衡度 VUF = |V2| / |V1| × 100（%）。
///
/// 正序接近零（三相电压全零、纯负序、纯零序）时「不平衡度」没有定义：
/// 此时浮点残差会让 |V2|/|V1| 放大到 1e17 量级，直接返回 0 比返回 inf/NaN
/// 更适合上游做阈值判断。判据是正序模长小于 1e-12 p.u.，对 1.0 p.u. 的
/// 额定电压而言低于任何有意义的测量分辨率。
pub fn voltage_unbalance_percent(v : Phasor) -> Double {
  let seq = symmetrical_components(v)
  let pos = @model.cx_abs(seq.positive)
  if pos < 1.0e-12 {
    return 0.0
  }
  @model.cx_abs(seq.negative) / pos * 100.0
}

///|
/// 一组母线电压的不平衡度（%），按 `voltages` 的顺序返回。
pub fn unbalance_profile(voltages : Array[Phasor]) -> Array[Double] {
  let out : Array[Double] = []
  for v in voltages {
    out.push(voltage_unbalance_percent(v))
  }
  out
}
