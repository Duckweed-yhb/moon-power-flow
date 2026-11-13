// dist/oltc.mbt — 有载调压（OLTC）分接头：档位、上下限与调压目标约束。
//
// 这里是控制律层，不另起一套潮流：底层仍是 `sweep` 的前推回代，OLTC 只在每次
// 求解前后做两件事——按当前档位算出变压器变比 k = 1 + tap·step，再按受控母线
// 电压判断该升档、降档还是保持。
//
// 口径（标幺值 p.u.，与全库一致）：
// - 档位 tap 为整数，取值闭合区间 [tap_min, tap_max]；0 档为额定档（k=1）；
// - `step` 为每档变比步进，k = 1 + tap·step；升档提高副边变比，副边电压抬高；
// - 受控母线电压模长落在 [target − band, target + band] 内视为满足目标；
// - 只调一台挂在受控母线上游的变压器支路；相移、无功限值、并联调压不在本轮。

///|
/// 一次调压判断的结果。`AtUpperLimit` / `AtLowerLimit` 表示方向上还想调，
/// 但档位已经顶到上下限。
pub enum OltcStatus {
  InBand
  RaiseTap
  LowerTap
  AtUpperLimit
  AtLowerLimit
}

///|
pub fn OltcStatus::describe(self : OltcStatus) -> String {
  match self {
    InBand => "in target band"
    RaiseTap => "raise tap"
    LowerTap => "lower tap"
    AtUpperLimit => "at upper tap limit"
    AtLowerLimit => "at lower tap limit"
  }
}

///|
/// 驱动层失败：控制输入问题用中文可读描述，潮流失败原样包进 `Sweep`。
pub enum OltcErr {
  Control(String)
  Sweep(SweepErr)
}

///|
pub fn OltcErr::describe(self : OltcErr) -> String {
  match self {
    Control(msg) => msg
    Sweep(e) => "sweep: " + e.describe()
  }
}

///|
/// OLTC 调压器：受控母线编号、当前档位、档位上下限、每档步进、目标电压与死区。
pub struct Oltc {
  node_id : Int32
  tap : Int32
  tap_min : Int32
  tap_max : Int32
  step : Double
  target : Double
  band : Double
}

///|
/// 构造调压器。校验：下限 ≤ 上限、当前档在区间内、步进与目标为正有限数、
/// 死区非负有限数；不满足返回结构化错误，不panic。
pub fn Oltc::new(
  node_id : Int32,
  tap : Int32,
  tap_min : Int32,
  tap_max : Int32,
  step : Double,
  target : Double,
  band : Double,
) -> Result[Oltc, String] {
  if tap_min > tap_max {
    return Err("tap_min must be <= tap_max")
  }
  if tap < tap_min || tap > tap_max {
    return Err("tap must be within [tap_min, tap_max]")
  }
  if step != step || step <= 0.0 || step > 1.0e308 {
    return Err("tap step must be a positive finite number")
  }
  if target != target || target <= 0.0 || target > 1.0e308 {
    return Err("target voltage must be a positive finite number")
  }
  if band != band || band < 0.0 || band > 1.0e308 {
    return Err("band must be a non-negative finite number")
  }
  Ok({ node_id, tap, tap_min, tap_max, step, target, band, })
}

///|
pub fn Oltc::node_id(self : Oltc) -> Int32 {
  self.node_id
}

///|
pub fn Oltc::tap(self : Oltc) -> Int32 {
  self.tap
}

///|
pub fn Oltc::ratio(self : Oltc) -> Double {
  1.0 + self.tap.to_double() * self.step
}

///|
/// 按受控母线某相电压模长判断当前状态。
pub fn Oltc::status(self : Oltc, v_mag : Double) -> OltcStatus {
  if v_mag < self.target - self.band {
    if self.tap >= self.tap_max {
      return AtUpperLimit
    }
    return RaiseTap
  }
  if v_mag > self.target + self.band {
    if self.tap <= self.tap_min {
      return AtLowerLimit
    }
    return LowerTap
  }
  InBand
}

///|
/// 升一档（钳到上限），返回新的调压器。
pub fn Oltc::raise_tap(self : Oltc) -> Oltc {
  let next = if self.tap + 1 > self.tap_max {
    self.tap_max
  } else {
    self.tap + 1
  }
  {
    node_id: self.node_id,
    tap: next,
    tap_min: self.tap_min,
    tap_max: self.tap_max,
    step: self.step,
    target: self.target,
    band: self.band,
  }
}

///|
/// 降一档（钳到下限），返回新的调压器。
pub fn Oltc::lower_tap(self : Oltc) -> Oltc {
  let next = if self.tap - 1 < self.tap_min {
    self.tap_min
  } else {
    self.tap - 1
  }
  {
    node_id: self.node_id,
    tap: next,
    tap_min: self.tap_min,
    tap_max: self.tap_max,
    step: self.step,
    target: self.target,
    band: self.band,
  }
}

///|
/// 一次调档迭代的结果：最终调压器、最后一次潮流解、是否进入目标区间、
/// 每一步（档位, 受控相电压模长）轨迹、最终状态。
pub struct OltcRun {
  oltc : Oltc
  result : SweepOk
  reached_band : Bool
  moves : Array[(Int32, Double)]
  stopped : OltcStatus
}

///|
pub fn OltcRun::oltc(self : OltcRun) -> Oltc {
  self.oltc
}

///|
pub fn OltcRun::result(self : OltcRun) -> SweepOk {
  self.result
}

///|
pub fn OltcRun::reached_band(self : OltcRun) -> Bool {
  self.reached_band
}

///|
pub fn OltcRun::moves(self : OltcRun) -> Array[(Int32, Double)] {
  self.moves
}

///|
pub fn OltcRun::stopped(self : OltcRun) -> OltcStatus {
  self.stopped
}

///|
/// 闭环调档驱动：反复求解 → 读受控母线 a 相电压 → 判断方向 → 调档钳限，
/// 直到进入目标区间、碰到档位上下限或用完调档次数。
///
/// 受控母线必须挂在某条变压器支路上游；拓扑与网络来自同一次 `build_topology`。
/// 控制层输入不合法（节点不存在、支路不是变压器）返回 `Err(String)`；
/// 潮流本身失败透传 `SweepErr`。
pub fn run_oltc(
  net : DistNet,
  topo : Topology,
  oltc : Oltc,
  tol : Double,
  max_iter : Int32,
  max_moves : Int32,
) -> Result[OltcRun, OltcErr] {
  let node = match net.find_index(oltc.node_id()) {
    Some(k) => k
    None =>
      return Err(
        Control("controlled node " + oltc.node_id().to_string() + " not found"),
      )
  }
  let pe = topo.parent_edge()[node]
  if pe < 0 || pe >= net.edge_count() {
    return Err(Control("controlled node has no parent edge"))
  }
  let edge = net.edge_at(pe)
  if !edge.tx().enabled() {
    return Err(Control("controlled edge is not a transformer branch"))
  }
  let edges : Array[DistEdge] = []
  for e in 0..<net.edge_count() {
    edges.push(net.edge_at(e))
  }
  let mut cur = oltc
  let moves : Array[(Int32, Double)] = []
  let mut latest : SweepOk? = None
  let mut reached = false
  let mut status = InBand
  let mut move_no = 0
  while move_no < max_moves {
    edges[pe] = edge.with_ratio(cur.ratio())
    let net2 = DistNet::make(net.nodes(), edges, net.root_id(), net.v_root())
    let r = match sweep(net2, topo, tol, max_iter) {
      Ok(x) => x
      Err(e) => return Err(Sweep(e))
    }
    let mag = @model.cx_abs(r.voltages()[node].a())
    moves.push((cur.tap(), mag))
    latest = Some(r)
    status = cur.status(mag)
    match status {
      InBand => {
        reached = true
        break
      }
      AtUpperLimit => break
      AtLowerLimit => break
      RaiseTap => cur = cur.raise_tap()
      LowerTap => cur = cur.lower_tap()
    }
    move_no += 1
  }
  let result = match latest {
    Some(r) => r
    None => return Err(Control("no sweep produced a result"))
  }
  Ok({ oltc: cur, result, reached_band: reached, moves, stopped: status, })
}
