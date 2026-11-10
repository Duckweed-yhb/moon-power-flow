///|
/// dist 包单测：拓扑校验、前推回代收敛、平衡退化、3x3 耦合与失败路径。
fn approx_equal(x : Double, y : Double, eps : Double) -> Bool {
  (x - y).abs() < eps
}

///|
let eps = 0.000000001

// ---------- 拓扑 ----------

///|
test "topology: four-node radial case is accepted" {
  let net = @dist.case_four_node()
  match @dist.build_topology(net) {
    Ok(t) => {
      assert_eq(t.order().length(), 4)
      // 根（内部下标 0）永远排第一，且没有父节点
      assert_eq(t.order()[0], 0)
      assert_eq(t.parent()[0], -1)
      // 每个非根节点都有父边
      assert_true(t.parent_edge()[1] >= 0)
      assert_true(t.parent_edge()[2] >= 0)
      assert_true(t.parent_edge()[3] >= 0)
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "topology: a cycle is rejected as not radial" {
  let z = @dist.z3_diag(
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
  )
  let nodes = [
    @dist.DistNode::make(1, @dist.Phasor::zero()),
    @dist.DistNode::make(2, @dist.Phasor::zero()),
    @dist.DistNode::make(3, @dist.Phasor::zero()),
    @dist.DistNode::make(4, @dist.Phasor::zero()),
  ]
  let edges = [
    @dist.DistEdge::make(1, 2, z),
    @dist.DistEdge::make(2, 3, z),
    @dist.DistEdge::make(3, 4, z),
    @dist.DistEdge::make(4, 1, z),
  ]
  let net = @dist.DistNet::make(
    nodes,
    edges,
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  match @dist.build_topology(net) {
    Ok(_) => fail("expected NotRadial for a 4-node / 4-edge cycle")
    Err(@dist.NotRadial) => ()
    Err(e) => fail("expected NotRadial, got " + e.describe())
  }
}

///|
test "topology: disconnected node is rejected" {
  let z = @dist.z3_diag(
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
  )
  let nodes = [
    @dist.DistNode::make(1, @dist.Phasor::zero()),
    @dist.DistNode::make(2, @dist.Phasor::zero()),
    @dist.DistNode::make(3, @dist.Phasor::zero()),
    @dist.DistNode::make(4, @dist.Phasor::zero()),
  ]
  // 三角形 1-2-3 加孤立节点 4：边数 3 = 节点数 4 - 1，但根到不了 4
  let edges = [
    @dist.DistEdge::make(1, 2, z),
    @dist.DistEdge::make(2, 3, z),
    @dist.DistEdge::make(3, 1, z),
  ]
  let net = @dist.DistNet::make(
    nodes,
    edges,
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  match @dist.build_topology(net) {
    Ok(_) => fail("expected Disconnected")
    Err(@dist.Disconnected(4)) => ()
    Err(e) => fail("expected Disconnected(4), got " + e.describe())
  }
}

///|
test "topology: duplicate node id is rejected" {
  let z = @dist.z3_diag(
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
  )
  let nodes = [
    @dist.DistNode::make(1, @dist.Phasor::zero()),
    @dist.DistNode::make(1, @dist.Phasor::zero()),
  ]
  let edges = [@dist.DistEdge::make(1, 1, z)]
  let net = @dist.DistNet::make(
    nodes,
    edges,
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  match @dist.build_topology(net) {
    Ok(_) => fail("expected DuplicateNodeId")
    Err(@dist.DuplicateNodeId(1)) => ()
    Err(e) => fail("expected DuplicateNodeId, got " + e.describe())
  }
}

// ---------- 前推回代 ----------

///|
test "sweep: balanced case collapses to a single three-phase value" {
  let net = @dist.case_balanced()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 0.000000001, 100) {
    Ok(r) => {
      let v = r.voltages()
      // 根电压逐相保持输入值
      assert_true(approx_equal(@model.cx_abs(v[0].a()), 1.0, eps))
      assert_true(approx_equal(@model.cx_abs(v[0].b()), 1.0, eps))
      assert_true(approx_equal(@model.cx_abs(v[0].c()), 1.0, eps))
      // 平衡负荷 + 对角阻抗 + 平衡根电压：每相电压模长应完全相同
      let va = @model.cx_abs(v[1].a())
      let vb = @model.cx_abs(v[1].b())
      let vc = @model.cx_abs(v[1].c())
      assert_true(approx_equal(va, vb, 0.000000001))
      assert_true(approx_equal(vb, vc, 0.000000001))
      assert_true(va < 1.0)
      assert_true(va > 0.9)
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "sweep: unbalanced case converges and the three phases differ" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 0.000000001, 100) {
    Ok(r) => {
      let v = r.voltages()
      let va = @model.cx_abs(v[1].a())
      let vb = @model.cx_abs(v[1].b())
      let vc = @model.cx_abs(v[1].c())
      // 母线 2 三相负荷不同，电压模长必须不同（平衡假设会漏掉这一点）
      assert_true(!approx_equal(va, vb, 0.0001))
      assert_true(!approx_equal(vb, vc, 0.0001))
      assert_true(va < 1.0 && va > 0.9)
      assert_true(vb < 1.0 && vb > 0.9)
      assert_true(vc < 1.0 && vc > 0.9)
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "sweep: coupled impedance makes a untouched phase deviate" {
  let net = @dist.case_coupled()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 0.000000001, 100) {
    Ok(r) => {
      let v = r.voltages()
      // 只有 a 相有负荷，但相间互阻抗会把 b/c 相电压也拉偏
      let va = @model.cx_abs(v[1].a())
      let vb = @model.cx_abs(v[1].b())
      let vc = @model.cx_abs(v[1].c())
      assert_true(va < vb)
      assert_true(va < vc)
      assert_true(!approx_equal(vb, 1.0, 0.0000001))
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "sweep: absurd load hits iteration limit instead of hanging" {
  let z = @dist.z3_diag(
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
  )
  let nodes = [
    @dist.DistNode::make(1, @dist.Phasor::zero()),
    @dist.DistNode::make(2, @dist.Phasor::uniform(@model.cx(50.0, 20.0))),
  ]
  let edges = [@dist.DistEdge::make(1, 2, z)]
  let net = @dist.DistNet::make(
    nodes,
    edges,
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 0.000000001, 20) {
    Ok(_) => fail("expected NotConverged for an absurd load")
    Err(@dist.NotConverged(_, _)) => ()
    Err(e) => fail("expected NotConverged, got " + e.describe())
  }
}

///|
test "sweep: scrambled ids and non-first root are handled by BFS" {
  let net = @dist.case_scrambled_ids()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  // 根是编号 10，但内部下标是 0；3 和 7 的数组顺序也不是拓扑序。
  assert_eq(topo.order()[0], 0)
  assert_eq(topo.parent()[0], -1)
  // 内部下标：10→0、3→1、7→2；7 的父是 10，3 的父是 7
  assert_eq(topo.parent()[2], 0)
  assert_eq(topo.parent()[1], 2)
  match @dist.sweep(net, topo, 0.000000001, 100) {
    Ok(r) => {
      let v = r.voltages()
      let v_root = @model.cx_abs(v[0].a())
      let v_mid = @model.cx_abs(v[2].a())
      let v_leaf = @model.cx_abs(v[1].a())
      assert_true(approx_equal(v_root, 1.0, 0.000000001))
      assert_true(v_mid < v_root)
      assert_true(v_leaf < v_mid)
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "sweep: ten-node chain converges with monotonic voltage drop" {
  let z = @dist.z3_diag(
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
  )
  let s = @model.cx(0.01, 0.003)
  let nodes : Array[@dist.DistNode] = []
  nodes.push(@dist.DistNode::make(0, @dist.Phasor::zero()))
  let mut i = 1
  while i <= 9 {
    nodes.push(@dist.DistNode::make(i, @dist.Phasor::uniform(s)))
    i += 1
  }
  let edges : Array[@dist.DistEdge] = []
  let mut k = 0
  while k < 9 {
    edges.push(@dist.DistEdge::make(k, k + 1, z))
    k += 1
  }
  let net = @dist.DistNet::make(
    nodes,
    edges,
    0,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  assert_eq(topo.order().length(), 10)
  match @dist.sweep(net, topo, 0.0000000001, 200) {
    Ok(r) => {
      let v = r.voltages()
      // 链式网络：深度越深电压越低
      let mut j = 0
      while j < 9 {
        assert_true(@model.cx_abs(v[j + 1].a()) < @model.cx_abs(v[j].a()))
        j += 1
      }
    }
    Err(e) => fail(e.describe())
  }
}
