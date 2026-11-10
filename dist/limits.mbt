// dist/limits.mbt — 电压越限检查。
//
// 潮流算完最常问的两个问题：哪条母线电压不合格、越了多少。以前调用方要自己
// 遍历结果逐相比对，还得记住「根母线电压是给定的」这个前提。这里给一个
// 明确口径：**所有母线都查，包括根母线**（根电压通常 1.0 p.u.，落在限值内，
// 不会误报）；限值由调用方给，库里不写死任何规程值。

///|
/// 越限方向。`NonFinite` 表示该相电压不是有限值（NaN/Inf）——
/// 这不是"没越限"，是数据本身坏了，必须报出来而不是静默跳过：
/// `m < vmin` / `m > vmax` 对 NaN 恒为 false，旧实现会把它当成合格。
pub enum ViolationKind {
  Under
  Over
  NonFinite
}

///|
pub fn ViolationKind::describe(self : ViolationKind) -> String {
  match self {
    Under => "under"
    Over => "over"
    NonFinite => "non-finite"
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
///
/// 前提：`r` 与 `net` 来自同一次求解（电压数组与母线表一一对应）。
/// 两者长度不一致时只比较能对上的部分，不越界 panic——错配的输入属于
/// 调用方 bug，库的职责是别崩在半路。
pub fn voltage_violations(
  r : SweepOk,
  net : DistNet,
  vmin : Double,
  vmax : Double,
) -> Array[Violation] {
  let out : Array[Violation] = []
  let v = r.voltages()
  let pairs = if v.length() < net.node_count() {
    v.length()
  } else {
    net.node_count()
  }
  let mut i = 0
  while i < pairs {
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
      if m != m || m.abs() > 1.0e308 {
        // 非有限值单独报一类：NaN 与上下限比较恒为 false，旧实现会把它当合格。
        out.push({ node_id: id, phase: ph, magnitude: m, kind: NonFinite, })
      } else if m < vmin {
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
/// 三相电压幅值的全网最值：`Some((最小, 最大))`；没有任何可用电压
/// （空数组，或存在 NaN 这种非有限值）时返回 `None`。
///
/// 不用 (1e9, −1e9) 之类的哨兵值：那种返回值会被下游当成真实电压
/// 参与报表，错得没有痕迹。返回 `None` 至少让调用方必须显式处理。
pub fn voltage_extremes(r : SweepOk) -> (Double, Double)? {
  let v = r.voltages()
  let mut lo = 0.0
  let mut hi = 0.0
  let mut seen = false
  for p in v {
    let mags = [
      @model.cx_abs(p.a()),
      @model.cx_abs(p.b()),
      @model.cx_abs(p.c()),
    ]
    for m in mags {
      if m != m || m.abs() > 1.0e308 {
        return None
      }
      if !seen {
        lo = m
        hi = m
        seen = true
      } else {
        if m < lo {
          lo = m
        }
        if m > hi {
          hi = m
        }
      }
    }
  }
  if !seen {
    return None
  }
  Some((lo, hi))
}
