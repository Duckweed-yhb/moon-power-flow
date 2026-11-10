// dist/limits.mbt — 电压越限检查。
//
// 潮流算完最常问的两个问题：哪条母线电压不合格、越了多少。以前调用方要自己
// 遍历结果逐相比对，还得记住「根母线电压是给定的」这个前提。这里给一个
// 明确口径：**所有母线都查，包括根母线**（根电压通常 1.0 p.u.，落在限值内，
// 不会误报）；限值由调用方给，库里不写死任何规程值。

///|
/// 越限方向。
pub enum ViolationKind {
  Under
  Over
}

///|
pub fn ViolationKind::describe(self : ViolationKind) -> String {
  match self {
    Under => "under"
    Over => "over"
  }
}

///|
/// 一条电压越限记录：哪条母线、哪一相、实际电压、越限方向。
pub struct Violation {
  node_id : Int32
  phase : Int32
  magnitude : Double
  kind : ViolationKind
}

///|
pub fn Violation::node_id(self : Violation) -> Int32 {
  self.node_id
}

///|
/// 相号：0 = a，1 = b，2 = c。
pub fn Violation::phase(self : Violation) -> Int32 {
  self.phase
}

///|
pub fn Violation::magnitude(self : Violation) -> Double {
  self.magnitude
}

///|
pub fn Violation::kind(self : Violation) -> ViolationKind {
  self.kind
}

///|
pub fn Violation::describe(self : Violation) -> String {
  let ph = match self.phase {
    0 => "a"
    1 => "b"
    _ => "c"
  }
  self.node_id.to_string() +
  "@" +
  ph +
  " " +
  self.magnitude.to_string() +
  " pu (" +
  self.kind.describe() +
  ")"
}

///|
/// 找出所有越限的（母线, 相）。限值为闭区间 `[vmin, vmax]`：
/// 恰好等于限值不算越限（工程上通常允许贴着限值运行）。
pub fn voltage_violations(
  r : SweepOk,
  net : DistNet,
  vmin : Double,
  vmax : Double,
) -> Array[Violation] {
  let out : Array[Violation] = []
  let v = r.voltages()
  let mut i = 0
  while i < v.length() {
    let p = v[i]
    let id = net.node_at(i).id()
    let mags = [
      @model.cx_abs(p.a()),
      @model.cx_abs(p.b()),
      @model.cx_abs(p.c()),
    ]
    let mut ph = 0
    while ph < 3 {
      let m = mags[ph]
      if m < vmin {
        out.push({ node_id: id, phase: ph, magnitude: m, kind: Under, })
      } else if m > vmax {
        out.push({ node_id: id, phase: ph, magnitude: m, kind: Over, })
      }
      ph += 1
    }
    i += 1
  }
  out
}

///|
/// 三相电压幅值的全网最值：返回 (最小, 最大)。做报表时省得再扫一遍。
pub fn voltage_extremes(r : SweepOk) -> (Double, Double) {
  let v = r.voltages()
  let mut lo = 1.0e9
  let mut hi = -1.0e9
  for p in v {
    let mags = [
      @model.cx_abs(p.a()),
      @model.cx_abs(p.b()),
      @model.cx_abs(p.c()),
    ]
    for m in mags {
      if m < lo {
        lo = m
      }
      if m > hi {
        hi = m
      }
    }
  }
  (lo, hi)
}
