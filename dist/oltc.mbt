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
/// 每档变比步进。
pub fn Oltc::step(self : Oltc) -> Double {
  self.step
}

///|
/// 档位下限。
pub fn Oltc::tap_min(self : Oltc) -> Int32 {
  self.tap_min
}

///|
/// 档位上限。
pub fn Oltc::tap_max(self : Oltc) -> Int32 {
  self.tap_max
}

///|
/// 目标电压。
pub fn Oltc::target(self : Oltc) -> Double {
  self.target
}

///|
/// 目标死区半宽。
pub fn Oltc::band(self : Oltc) -> Double {
  self.band
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
/// 受控母线及其上游支路的下标。节点不存在、没有上游支路或上游不是变压器，
/// 都按控制输入错误返回，不 panic。
fn controlled_indices(
  net : DistNet,
  topo : Topology,
  node_id : Int32,
) -> Result[(Int32, Int32), OltcErr] {
  let node = match net.find_index(node_id) {
    Some(k) => k
    None =>
      return Err(
        Control("controlled node " + node_id.to_string() + " not found"),
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
  Ok((node, pe))
}

///|
/// 逐档扫描：档位从下限走到上限，每档按给定 ZIP 负荷求解一次，返回
/// (档位, 受控母线 a 相电压模长)。用于画调压曲线、检查「电压随档位单调」，
/// 或者先看清 ZIP 负荷下哪一档才进带，再决定闭环从哪起步。
///
/// 与 `run_oltc_zip` 共用同一套受控支路校验；潮流失败透传 `SweepErr`。
pub fn scan_taps_zip(
  net : DistNet,
  topo : Topology,
  oltc : Oltc,
  zip : @model.Zip,
  tol : Double,
  max_iter : Int32,
) -> Result[Array[(Int32, Double)], OltcErr] {
  let (node, pe) = match controlled_indices(net, topo, oltc.node_id()) {
    Ok(x) => x
    Err(e) => return Err(e)
  }
  let edges : Array[DistEdge] = []
  for e in 0..<net.edge_count() {
    edges.push(net.edge_at(e))
  }
  let base = net.edge_at(pe)
  let out : Array[(Int32, Double)] = []
  let mut tap = oltc.tap_min()
  while tap <= oltc.tap_max() {
    let ratio = 1.0 + tap.to_double() * oltc.step()
    edges[pe] = base.with_ratio(ratio)
    let net2 = DistNet::make(net.nodes(), edges, net.root_id(), net.v_root())
    let r = match sweep_zip(net2, topo, zip, tol, max_iter) {
      Ok(x) => x
      Err(e) => return Err(Sweep(e))
    }
    out.push((tap, @model.cx_abs(r.voltages()[node].a())))
    tap += 1
  }
  Ok(out)
}

///|
/// 闭环调档驱动：反复求解 → 读受控母线 a 相电压 → 判断方向 → 调档钳限，
/// 直到进入目标区间、碰到档位上下限或用完调档次数。负荷按恒功率算。
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
  run_oltc_with(net, topo, oltc, None, tol, max_iter, max_moves)
}

///|
/// 与 `run_oltc` 同一套控制律，但每拍按给定 ZIP 静特性缩放负荷。
///
/// 恒功率下电压跌多少负荷就取多少，ZIP 下电压一跌负荷跟着变小、反过来又让
/// 电压没那么跌，所以两种负荷模型最终可能停在不同档位。恒阻抗占比越大，
/// 需要升的档通常越少；`scan_taps_zip` 能把这个差异直接扫出来。
pub fn run_oltc_zip(
  net : DistNet,
  topo : Topology,
  oltc : Oltc,
  zip : @model.Zip,
  tol : Double,
  max_iter : Int32,
  max_moves : Int32,
) -> Result[OltcRun, OltcErr] {
  run_oltc_with(net, topo, oltc, Some(zip), tol, max_iter, max_moves)
}

///|
/// 两种调档驱动的共用主体：`zip` 为 None 时是恒功率负荷（旧行为）。
fn run_oltc_with(
  net : DistNet,
  topo : Topology,
  oltc : Oltc,
  zip : @model.Zip?,
  tol : Double,
  max_iter : Int32,
  max_moves : Int32,
) -> Result[OltcRun, OltcErr] {
  let (node, pe) = match controlled_indices(net, topo, oltc.node_id()) {
    Ok(x) => x
    Err(e) => return Err(e)
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
    let base = net.edge_at(pe)
    edges[pe] = base.with_ratio(cur.ratio())
    let net2 = DistNet::make(net.nodes(), edges, net.root_id(), net.v_root())
    let r = match zip {
      None => sweep(net2, topo, tol, max_iter)
      Some(z) => sweep_zip(net2, topo, z, tol, max_iter)
    }
    let solved = match r {
      Ok(x) => x
      Err(e) => return Err(Sweep(e))
    }
    let mag = @model.cx_abs(solved.voltages()[node].a())
    if !(mag > 0.0) {
      // a 相断开时该相电压为 0，控制律没有可读的量；继续按「欠压」升档
      // 会把档位推到上限，所以这里直接拒绝，不产出调档轨迹。
      return Err(
        Control(
          "controlled a-phase voltage is " +
          mag.to_string() +
          ", tap control is undefined when that phase is open",
        ),
      )
    }
    moves.push((cur.tap(), mag))
    latest = Some(solved)
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
