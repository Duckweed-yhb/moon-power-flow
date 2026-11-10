// model/types.mbt — 母线、支路、网络的数据结构。
//
// 全部数值为标幺值（p.u.），基准容量与基准电压由算例侧约定，见 cases 包与 README。
// 母线数组下标（0 起）即网络内部索引；Bus.id 为外部编号，校验保证唯一。

///|
/// 母线类型。PV 仅作枚举预留，本轮不实现 PV 无功越界与 PV 求解逻辑。
#warnings("-unused_constructor")
pub enum BusType {
  Slack
  PQ
  PV
}

///|
pub extend BusType with Eq::{equal, not_equal}

///|
pub impl Eq for BusType with fn equal(self : BusType, other : BusType) -> Bool {
  match self {
    Slack => other is Slack
    PQ => other is PQ
    PV => other is PV
  }
}

///|
/// 母线。p_inj / q_inj 为净注入功率（发电减负荷，负荷为负）；
/// v_fixed 仅 Slack 使用，存放固定电压（复数值，p.u.）。
pub struct Bus {
  id : Int32
  name : String
  kind : BusType
  p_inj : Double
  q_inj : Double
  v_fixed : Cx
}

///|
/// 构造 Slack 母线，给定固定电压。
pub fn Bus::make_slack(id : Int32, name : String, v_fixed : Cx) -> Bus {
  { id, name, kind: Slack, p_inj: 0.0, q_inj: 0.0, v_fixed, }
}

///|
/// 构造 PQ 母线，给定净注入有功、无功（p.u.）。
pub fn Bus::make_pq(
  id : Int32,
  name : String,
  p_inj : Double,
  q_inj : Double,
) -> Bus {
  { id, name, kind: PQ, p_inj, q_inj, v_fixed: cx(0.0, 0.0), }
}

///|
pub fn Bus::bus_id(self : Bus) -> Int32 {
  self.id
}

///|
pub fn Bus::bus_name(self : Bus) -> String {
  self.name
}

///|
pub fn Bus::kind(self : Bus) -> BusType {
  self.kind
}

///|
pub fn Bus::p_inj(self : Bus) -> Double {
  self.p_inj
}

///|
pub fn Bus::q_inj(self : Bus) -> Double {
  self.q_inj
}

///|
pub fn Bus::v_fixed(self : Bus) -> Cx {
  self.v_fixed
}

///|
/// 线路支路。from_id / to_id 引用母线外部编号；z 为串联复阻抗（p.u.）。
/// 对地充电导纳本轮不启用，列入后续扩展。
pub struct Branch {
  from_id : Int32
  to_id : Int32
  z : Cx
}

///|
pub fn Branch::make(from_id : Int32, to_id : Int32, z : Cx) -> Branch {
  { from_id, to_id, z, }
}

///|
pub fn Branch::from_id(self : Branch) -> Int32 {
  self.from_id
}

///|
pub fn Branch::to_id(self : Branch) -> Int32 {
  self.to_id
}

///|
pub fn Branch::impedance(self : Branch) -> Cx {
  self.z
}

///|
/// 网络：母线表 + 支路表。合法网络只能由 validate 通过后构造。
pub struct Network {
  buses : Array[Bus]
  branches : Array[Branch]
}

///|
/// 仅供本包 validate 在全部规则通过后调用，外部不直接构造未校验网络。
fn Network::make_raw(buses : Array[Bus], branches : Array[Branch]) -> Network {
  { buses, branches, }
}

///|
pub fn Network::bus_count(self : Network) -> Int32 {
  self.buses.length()
}

///|
pub fn Network::branch_count(self : Network) -> Int32 {
  self.branches.length()
}

///|
/// 按下标取母线；下标由本包与求解器内部保证在合法范围。
pub fn Network::bus_at(self : Network, i : Int32) -> Bus {
  self.buses[i]
}

///|
pub fn Network::branch_at(self : Network, k : Int32) -> Branch {
  self.branches[k]
}

///|
/// 按外部编号查找母线，找不到返回 None。
pub fn Network::find_bus(self : Network, id : Int32) -> Bus? {
  let n = self.buses.length()
  let mut i = 0
  while i < n {
    let b = self.buses[i]
    if b.id == id {
      return Some(b)
    }
    i += 1
  }
  None
}

///|
/// Slack 母线内部下标；合法网络恰好一个 Slack，故返回 Option 以保持类型安全。
pub fn Network::slack_index(self : Network) -> Int32? {
  let n = self.buses.length()
  let mut i = 0
  while i < n {
    if self.buses[i].kind == Slack {
      return Some(i)
    }
    i += 1
  }
  None
}
