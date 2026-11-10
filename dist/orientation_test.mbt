///|
/// 支路方向的无关性测试。
///
/// 网络的电气结果不应取决于用户怎么填 `from_id/to_id`：阻抗矩阵对称，
/// 电压降与损耗都与之无关。但「根注入」操作用的是 `i_branch` 的
/// 「父→子」语义，早期实现只认 `from_id == root`，把支路写成子→父时
/// 注入会算成 0，而且电压、损耗全都正常——这类静默错误只能靠守恒关系抓出来。

///|
/// 同一个三节点链，两种支路方向。
fn two_orientation_nets() -> (@dist.DistNet, @dist.DistNet) {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let load = @dist.phasor(
    @model.cx(0.1, 0.03),
    @model.cx(0.08, 0.02),
    @model.cx(0.12, 0.04),
  )
  let zero = @dist.Phasor::zero()
  let nodes = [
    @dist.DistNode::make(1, zero),
    @dist.DistNode::make(2, load),
    @dist.DistNode::make(3, load),
  ]
  let v_root = @dist.Phasor::uniform(@model.cx(1.0, 0.0))
  let fwd = @dist.DistNet::make(
    nodes,
    [@dist.DistEdge::make(1, 2, z3), @dist.DistEdge::make(2, 3, z3)],
    1,
    v_root,
  )
  let rev = @dist.DistNet::make(
    nodes,
    [@dist.DistEdge::make(2, 1, z3), @dist.DistEdge::make(3, 2, z3)],
    1,
    v_root,
  )
  (fwd, rev)
}

///|
test "voltage profile and loss do not depend on edge orientation" {
  let (fwd, rev) = two_orientation_nets()
  let tf = match @dist.build_topology(fwd) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let tr = match @dist.build_topology(rev) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let rf = match @dist.sweep(fwd, tf, 1.0e-12, 100) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let rr = match @dist.sweep(rev, tr, 1.0e-12, 100) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let vf = rf.voltages()
  let vr = rr.voltages()
  assert_true((vf[1].max_abs() - vr[1].max_abs()).abs() < 1.0e-12)
  assert_true((vf[2].max_abs() - vr[2].max_abs()).abs() < 1.0e-12)
  let loss_dev = (@dist.total_loss_active(fwd, rf) -
  @dist.total_loss_active(rev, rr)).abs()
  assert_true(loss_dev < 1.0e-15)
}

///|
test "root injection is orientation independent and balances" {
  let (fwd, rev) = two_orientation_nets()
  let tf = match @dist.build_topology(fwd) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let tr = match @dist.build_topology(rev) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let rf = match @dist.sweep(fwd, tf, 1.0e-12, 100) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let rr = match @dist.sweep(rev, tr, 1.0e-12, 100) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let inject_f = @dist.root_injection_active(fwd, rf)
  let inject_r = @dist.root_injection_active(rev, rr)
  // 两种方向算出的注入必须相同，且都等于 负荷 + 损耗。
  assert_true((inject_f - inject_r).abs() < 1.0e-12)
  assert_true(inject_f > 0.0)
  let load = @dist.load_demand_active(fwd)
  let loss = @dist.total_loss_active(fwd, rf)
  assert_true((inject_f - load - loss).abs() < 1.0e-9)
  assert_true((inject_r - load - loss).abs() < 1.0e-9)
}
