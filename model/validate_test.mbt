// model/validate_test.mbt — 校验规则与失败路径测试。
//
// 失败用例只断言返回的错误变体，不允许发生 panic；期望值来自规则定义本身，
// 不依赖求解器输出。测试文件内调用本包函数、构造本包类型时加 @model 前缀；
// match 模式中的枚举变体按语言规则保持不限定。

fn empty_buses() -> Array[@model.Bus] {
  Array::makei(0, _ => @model.Bus::make_slack(0, "", @model.cx(0.0, 0.0)))
}

fn empty_branches() -> Array[@model.Branch] {
  Array::makei(0, _ => @model.Branch::make(0, 0, @model.cx(1.0, 0.0)))
}

fn valid_two_bus() -> (Array[@model.Bus], Array[@model.Branch]) {
  let slack = @model.Bus::make_slack(1, "slack", @model.cx(1.0, 0.0))
  let pq = @model.Bus::make_pq(2, "pq", -0.2, -0.1)
  let br = @model.Branch::make(1, 2, @model.cx(0.02, 0.06))
  let buses = empty_buses()
  buses.push(slack)
  buses.push(pq)
  let branches = empty_branches()
  branches.push(br)
  (buses, branches)
}

test "valid two-bus network returns Ok" {
  let (buses, branches) = valid_two_bus()
  let res = @model.validate(buses, branches)
  @test.assert_eq(res is Ok(_), true)
}

test "network without slack returns NoSlack" {
  let buses = empty_buses()
  buses.push(@model.Bus::make_pq(1, "a", -0.2, -0.1))
  buses.push(@model.Bus::make_pq(2, "b", -0.1, -0.05))
  let res = @model.validate(buses, empty_branches())
  let hit = match res {
    Err(NoSlack) => true
    _ => false
  }
  @test.assert_eq(hit, true)
}

test "two slack buses return MultipleSlack" {
  let buses = empty_buses()
  buses.push(@model.Bus::make_slack(1, "s1", @model.cx(1.0, 0.0)))
  buses.push(@model.Bus::make_slack(2, "s2", @model.cx(1.0, 0.0)))
  let res = @model.validate(buses, empty_branches())
  let hit = match res {
    Err(MultipleSlack(2)) => true
    _ => false
  }
  @test.assert_eq(hit, true)
}

test "duplicate bus id returns DuplicateId" {
  let buses = empty_buses()
  buses.push(@model.Bus::make_slack(1, "slack", @model.cx(1.0, 0.0)))
  buses.push(@model.Bus::make_pq(1, "dup", -0.2, -0.1))
  let res = @model.validate(buses, empty_branches())
  let hit = match res {
    Err(DuplicateId(1)) => true
    _ => false
  }
  @test.assert_eq(hit, true)
}

test "branch to missing endpoint returns UnknownEndpoint" {
  let (buses, _) = valid_two_bus()
  let branches = empty_branches()
  branches.push(@model.Branch::make(1, 99, @model.cx(0.02, 0.06)))
  let res = @model.validate(buses, branches)
  let hit = match res {
    Err(UnknownEndpoint(0, 99)) => true
    _ => false
  }
  @test.assert_eq(hit, true)
}

test "zero impedance branch returns ZeroImpedance" {
  let (buses, _) = valid_two_bus()
  let branches = empty_branches()
  branches.push(@model.Branch::make(1, 2, @model.cx(0.0, 0.0)))
  let res = @model.validate(buses, branches)
  let hit = match res {
    Err(ZeroImpedance(0)) => true
    _ => false
  }
  @test.assert_eq(hit, true)
}

test "failure message renders without panic" {
  let (buses, _) = valid_two_bus()
  let branches = empty_branches()
  branches.push(@model.Branch::make(1, 99, @model.cx(0.02, 0.06)))
  let res = @model.validate(buses, branches)
  let msg = match res {
    Err(e) => e.describe()
    Ok(_) => ""
  }
  @test.assert_eq(msg.length() > 0, true)
}
