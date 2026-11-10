// cases/case_three_bus.mbt — 内置三节点小网络算例。
//
// 单位：全部为标幺值 p.u.；基准容量 S_B = 100 MVA，电压基准按各段标称电压
// 折算（本算例取统一基准电压，故电压初值与结果直接以 p.u. 给出）。
//
// 结构：1 个 Slack（母线 1，1.0∠0）+ 2 个 PQ（母线 2、母线 3）；
// 三条串联支路，参数与 ybus 手算对照测试一致，便于交叉核对。
// 负荷以负净注入表示：母线 2 为 0.20 + j0.10，母线 3 为 0.15 + j0.075（p.u.）。

///|
/// 算例基准容量（MVA），仅用于把 p.u. 结果换算回有名值。
pub fn base_mva() -> Double {
  100.0
}

///|
/// demo 与测试默认收敛阈值（最大电压复偏差，p.u.）。
pub fn default_tol() -> Double {
  1.0e-8
}

///|
/// 默认最大 GS 扫描次数。
pub fn default_max_iter() -> Int32 {
  500
}

///|
/// 构造并校验三节点算例；校验失败时把结构化错误原样返回。
pub fn case_three_bus() -> Result[@model.Network, @model.NetErr] {
  let slack = @model.Bus::make_slack(1, "slack-1", @model.cx(1.0, 0.0))
  let bus2 = @model.Bus::make_pq(2, "pq-2", -0.20, -0.10)
  let bus3 = @model.Bus::make_pq(3, "pq-3", -0.15, -0.075)
  let buses = Array::makei(0, _ => {
    @model.Bus::make_slack(0, "", @model.cx(0.0, 0.0))
  })
  buses.push(slack)
  buses.push(bus2)
  buses.push(bus3)
  let branches = Array::makei(0, _ => {
    @model.Branch::make(0, 0, @model.cx(1.0, 0.0))
  })
  branches.push(@model.Branch::make(1, 2, @model.cx(0.02, 0.06)))
  branches.push(@model.Branch::make(2, 3, @model.cx(0.08, 0.24)))
  branches.push(@model.Branch::make(1, 3, @model.cx(0.06, 0.18)))
  @model.validate(buses, branches)
}
