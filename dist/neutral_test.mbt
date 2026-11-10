///|
/// 中性点位移测试。
///
/// 判据都是结构性的（不依赖外部参考值）：
/// - 三相平衡 → 中性电流为零 → 中性点不漂、相压不变；
/// - 只有一相带负荷 → 中性点朝该相方向漂、相电压相对中性点比相对地更低；
/// - 相电压相对中性点恒等于 相电压相对地 减 中性点电压（定义式）。

///|
/// 造一个 2 节点网络：母线 2 只挂 a 相负荷。
fn single_phase_load_net() -> @dist.DistNet {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let zero = @dist.Phasor::zero()
  let load = @dist.phasor(
    @model.cx(0.12, 0.04),
    @model.cx(0.0, 0.0),
    @model.cx(0.0, 0.0),
  )
  @dist.DistNet::make(
    [@dist.DistNode::make(1, zero), @dist.DistNode::make(2, load)],
    [@dist.DistEdge::make(1, 2, z3)],
    1,
    @dist.Phasor::uniform(@model.cx(1.0, 0.0)),
  )
}

///|
test "balanced load keeps the neutral point at zero" {
  let net = @dist.case_balanced()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let r = match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let vn = @dist.neutral_voltages(net, topo, r, @model.cx(0.02, 0.01))
  for x in vn {
    assert_true(@model.cx_abs(x) < 1.0e-12)
  }
  // 中性点不漂，相电压相对中性点 = 相对地。
  let vpn = @dist.phase_to_neutral(r, vn)
  let v = r.voltages()
  assert_true((vpn[1].max_abs() - v[1].max_abs()).abs() < 1.0e-12)
}

///|
test "single phase load shifts the neutral point toward that phase" {
  let net = single_phase_load_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let r = match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let zn = @model.cx(0.02, 0.01)
  let vn = @dist.neutral_voltages(net, topo, r, zn)
  // 根中性点是参考零。
  assert_true(@model.cx_abs(vn[0]) == 0.0)
  // 中性电流 = −I_a，位移方向就是 a 相电流经中性阻抗的方向：非零。
  assert_true(@model.cx_abs(vn[1]) > 0.0)
  // 定义式：I_n = −I_a，V_n = −z_n·I_n = z_n·I_a。
  let ia = r.branch_currents()[0].a()
  let expected = @model.cx_mul(zn, ia)
  assert_true(@model.cx_sub(vn[1], expected).re.abs() < 1.0e-12)
  assert_true(@model.cx_sub(vn[1], expected).im.abs() < 1.0e-12)
  // 相对中性点：带负荷的 a 相明显下沉；b/c 相对地电压本来就没有压降，
  // 但减去同一个中性点电压后也不再等于 1.0——三相不平衡度变了。
  let vpn = @dist.phase_to_neutral(r, vn)
  let v = r.voltages()
  assert_true(@model.cx_abs(vpn[1].a()) < @model.cx_abs(v[1].a()))
  assert_true(
    (@model.cx_abs(vpn[1].b()) - @model.cx_abs(v[1].b())).abs() > 1.0e-6,
  )
  assert_true(
    (@model.cx_abs(vpn[1].c()) - @model.cx_abs(v[1].c())).abs() > 1.0e-6,
  )
}

///|
test "phase to neutral is the definitional difference" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let r = match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let vn = @dist.neutral_voltages(net, topo, r, @model.cx(0.015, 0.008))
  let vpn = @dist.phase_to_neutral(r, vn)
  let v = r.voltages()
  assert_eq(vpn.length(), v.length())
  // 逐相逐节点：V_pn = V_p − V_n
  let mut i = 0
  while i < v.length() {
    let va = @model.cx_sub(v[i].a(), vn[i])
    let vb = @model.cx_sub(v[i].b(), vn[i])
    let vc = @model.cx_sub(v[i].c(), vn[i])
    assert_true(@model.cx_sub(vpn[i].a(), va).re.abs() < 1.0e-15)
    assert_true(@model.cx_sub(vpn[i].b(), vb).re.abs() < 1.0e-15)
    assert_true(@model.cx_sub(vpn[i].c(), vc).re.abs() < 1.0e-15)
    i += 1
  }
}

///|
test "zero neutral impedance means no displacement" {
  let net = single_phase_load_net()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let r = match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let vn = @dist.neutral_voltages(net, topo, r, @model.cx(0.0, 0.0))
  for x in vn {
    assert_true(@model.cx_abs(x) == 0.0)
  }
}

///|
/// 拓扑与电流不是这张网的：返回空数组，既不越界，也不假装「不漂」。
test "neutral voltages reject mismatched topology" {
  let small = @dist.case_coupled()
  let big = @dist.case_four_node()
  let topo_small = match @dist.build_topology(small) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let r_big = match
    @dist.sweep(
      big,
      match @dist.build_topology(big) {
        Ok(t) => t
        Err(e) => fail(e.describe())
      },
      1.0e-12,
      100,
    ) {
    Ok(r) => r
    Err(e) => fail(e.describe())
  }
  let vn = @dist.neutral_voltages(big, topo_small, r_big, @model.cx(0.01, 0.0))
  assert_eq(vn.length(), 0)
  // phase_to_neutral 拿到空数组也不越界，直接返回空。
  let vpn = @dist.phase_to_neutral(r_big, vn)
  assert_eq(vpn.length(), 0)
}

///|
/// 逐支路中性阻抗：全相同时必须与统一版本逐位一致。
test "per edge neutral impedance matches the uniform version" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let r = match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let zn = @model.cx(0.015, 0.008)
  let uniform = @dist.neutral_voltages(net, topo, r, zn)
  let per_edge : Array[@model.Cx] = []
  for _ in 0..<net.edge_count() {
    per_edge.push(zn)
  }
  let from_edges = @dist.neutral_voltages_per_edge(net, topo, r, per_edge)
  assert_eq(uniform.length(), from_edges.length())
  let mut i = 0
  while i < uniform.length() {
    assert_true(@model.cx_sub(uniform[i], from_edges[i]).re.abs() < 1.0e-15)
    assert_true(@model.cx_sub(uniform[i], from_edges[i]).im.abs() < 1.0e-15)
    i += 1
  }
}

///|
/// 两段阻抗不同时，末端中性点电压等于逐段压降之和（定义式）。
test "per edge drops accumulate along the path" {
  let z = @model.cx(0.01, 0.02)
  let z3 = @dist.z3_diag(z, z, z)
  let zero = @dist.Phasor::zero()
  let load = @dist.phasor(
    @model.cx(0.1, 0.03),
    @model.cx(0.08, 0.02),
    @model.cx(0.12, 0.04),
  )
  let net = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, zero),
      @dist.DistNode::make(2, load),
      @dist.DistNode::make(3, load),
    ],
    [@dist.DistEdge::make(1, 2, z3), @dist.DistEdge::make(2, 3, z3)],
    1,
    @dist.Phasor::uniform(@model.cx(1.0, 0.0)),
  )
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let r = match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let z1 = @model.cx(0.01, 0.005)
  let z2 = @model.cx(0.02, 0.010)
  let vn = @dist.neutral_voltages_per_edge(net, topo, r, [z1, z2])
  // 逐段中性电流：I_n = −(Ia+Ib+Ic)
  let cur = r.branch_currents()
  let i_n1 = @model.cx_neg(
    @model.cx_add(@model.cx_add(cur[0].a(), cur[0].b()), cur[0].c()),
  )
  let i_n2 = @model.cx_neg(
    @model.cx_add(@model.cx_add(cur[1].a(), cur[1].b()), cur[1].c()),
  )
  let expected = @model.cx_neg(
    @model.cx_add(@model.cx_mul(z1, i_n1), @model.cx_mul(z2, i_n2)),
  )
  assert_true(@model.cx_sub(vn[2], expected).re.abs() < 1.0e-15)
  assert_true(@model.cx_sub(vn[2], expected).im.abs() < 1.0e-15)
}

///|
/// 长度对不上：返回空数组，不越界也不假装不漂。
test "per edge neutral impedance rejects mismatched length" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  let r = match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(x) => x
    Err(e) => fail(e.describe())
  }
  let too_few : Array[@model.Cx] = [@model.cx(0.01, 0.0)]
  assert_eq(@dist.neutral_voltages_per_edge(net, topo, r, too_few).length(), 0)
}
