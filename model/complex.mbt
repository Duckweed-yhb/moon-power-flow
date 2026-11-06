// model/complex.mbt — 轻量二维复数（标幺值 p.u.），仅四则与模、幅角。
//
// 标准库未提供复数类型；这里用两个 Double 分量自建，避免引入外部依赖。
// 约定：re 为实部，im 为虚部；功率注入 S = P + jQ，导纳 Y = G + jB。

/// 复数记录：re 实部，im 虚部。
pub struct Cx {
  re : Double
  im : Double
}

/// 以实部、虚部构造复数。
pub fn cx(re : Double, im : Double) -> Cx {
  { re: re, im: im }
}

pub fn Cx::re(self : Cx) -> Double {
  self.re
}

pub fn Cx::im(self : Cx) -> Double {
  self.im
}

pub fn cx_add(a : Cx, b : Cx) -> Cx {
  cx(a.re + b.re, a.im + b.im)
}

pub fn cx_sub(a : Cx, b : Cx) -> Cx {
  cx(a.re - b.re, a.im - b.im)
}

pub fn cx_neg(a : Cx) -> Cx {
  cx(-a.re, -a.im)
}

pub fn cx_mul(a : Cx, b : Cx) -> Cx {
  cx(
    a.re * b.re - a.im * b.im,
    a.re * b.im + a.im * b.re,
  )
}

/// 复数除法；调用方必须保证 b 非零（支路阻抗在网络校验阶段已排除零点）。
pub fn cx_div(a : Cx, b : Cx) -> Cx {
  let denom = b.re * b.re + b.im * b.im
  cx(
    (a.re * b.re + a.im * b.im) / denom,
    (a.im * b.re - a.re * b.im) / denom,
  )
}

/// 共轭复数。
pub fn cx_conj(a : Cx) -> Cx {
  cx(a.re, -a.im)
}

/// 实数倍乘。
pub fn cx_scale(a : Cx, k : Double) -> Cx {
  cx(a.re * k, a.im * k)
}

/// 模长 |z|。
pub fn cx_abs(a : Cx) -> Double {
  (a.re * a.re + a.im * a.im).sqrt()
}

/// 幅角 arg(z)，单位弧度，范围 (-pi, pi]。
pub fn cx_arg(a : Cx) -> Double {
  @math.atan2(a.im, a.re)
}

/// 由模长、幅角（弧度）构造复数。
pub fn cx_polar(mag : Double, angle : Double) -> Cx {
  cx(mag * @math.cos(angle), mag * @math.sin(angle))
}
