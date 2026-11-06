// model/validate.mbt — 网络一致性校验。
//
// 规则：
//   1. 母线外部编号唯一；
//   2. Slack 母线恰好一个；
//   3. 每条支路两端点都能在母线表中找到；
//   4. 支路串联阻抗不得为零复数。
//
// 任何一条不满足都返回结构化 Err，不 panic、不抛异常中断；
// 调用方（ybus、solver、cases、demo）只处理 Result。

/// 校验失败原因，变体携带定位信息（母线编号或支路下标）。
pub enum NetErr {
  DuplicateId(Int)
  NoSlack
  MultipleSlack(Int)
  UnknownEndpoint(Int, Int)
  ZeroImpedance(Int)
}

pub fn NetErr::describe(self : NetErr) -> String {
  match self {
    DuplicateId(id) => "duplicate bus id: " + id.to_string()
    NoSlack => "no slack bus found"
    MultipleSlack(count) => "expected exactly one slack bus, got " + count.to_string()
    UnknownEndpoint(branch_index, bus_id) =>
      "branch " + branch_index.to_string() + " references missing bus id " + bus_id.to_string()
    ZeroImpedance(branch_index) =>
      "branch " + branch_index.to_string() + " has zero series impedance"
  }
}

fn has_bus(buses : Array[Bus], id : Int) -> Bool {
  let n = buses.length()
  let mut i = 0
  while i < n {
    if buses[i].id == id {
      return true
    }
    i += 1
  }
  false
}

/// 校验母线表与支路表；通过时返回封装好的 Network，否则返回首个失败原因。
pub fn validate(buses : Array[Bus], branches : Array[Branch]) -> Result[Network, NetErr] {
  // 规则 1：母线编号唯一。
  let n = buses.length()
  let mut i = 0
  while i < n {
    let mut j = i + 1
    while j < n {
      if buses[i].id == buses[j].id {
        return Err(DuplicateId(buses[i].id))
      }
      j += 1
    }
    i += 1
  }

  // 规则 2：Slack 恰好一个。
  let mut slack_count = 0
  i = 0
  while i < n {
    if buses[i].kind == Slack {
      slack_count += 1
    }
    i += 1
  }
  if slack_count == 0 {
    return Err(NoSlack)
  }
  if slack_count > 1 {
    return Err(MultipleSlack(slack_count))
  }

  // 规则 3：支路端点存在。
  let m = branches.length()
  let mut k = 0
  while k < m {
    let br = branches[k]
    if !has_bus(buses, br.from_id) {
      return Err(UnknownEndpoint(k, br.from_id))
    }
    if !has_bus(buses, br.to_id) {
      return Err(UnknownEndpoint(k, br.to_id))
    }
    k += 1
  }

  // 规则 4：阻抗非零（实部、虚部同时为零才判零）。
  k = 0
  while k < m {
    let z = branches[k].z
    if z.re == 0.0 && z.im == 0.0 {
      return Err(ZeroImpedance(k))
    }
    k += 1
  }

  Ok(Network::make_raw(buses, branches))
}
