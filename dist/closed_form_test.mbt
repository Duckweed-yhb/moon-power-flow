///|
/// 闭式解基准：两节点、纯有功负荷、纯电阻线路。
///
/// 这个场景有解析解，不依赖迭代：设根电压 V1 = 1（每相），线路电阻 R，
/// 负荷每相有功 P（无功为 0）。负荷电流与电压同相，于是
///
///   V2 = V1 - R * (P / V2)
///   V2² - V1·V2 + R·P = 0
///   V2 = (V1 + √(V1² - 4RP)) / 2
///
/// 期望值直接由这个二次方程算出，和本库的迭代实现是两条独立的路径。
test "sweep: two-node resistive load matches quadratic closed form" {
  let r = 0.05
  let p = 0.1
  let z = @dist.z3_diag(@model.cx(r, 0.0), @model.cx(r, 0.0), @model.cx(r, 0.0))
  let s = @model.cx(p, 0.0)
  let nodes = [
    @dist.DistNode::make(1, @dist.Phasor::zero()),
    @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
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
  match @dist.sweep(net, topo, 0.000000000001, 200) {
    Ok(res) => {
      let v = res.voltages()
      // 闭式解：V2 = (1 + sqrt(1 - 4*0.05*0.1)) / 2 = 0.9949747468...
      let disc = 1.0 - 4.0 * r * p
      let expected = (1.0 + disc.sqrt()) / 2.0
      let va = @model.cx_abs(v[1].a())
      assert_true(approx_equal(va, expected, 0.000000001))
      // 平衡负荷下三相退化相同
      assert_true(approx_equal(@model.cx_abs(v[1].b()), va, 0.000000001))
      assert_true(approx_equal(@model.cx_abs(v[1].c()), va, 0.000000001))
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "sweep: no load leaves root voltage untouched" {
  let z = @dist.z3_diag(
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
    @model.cx(0.01, 0.02),
  )
  let nodes = [
    @dist.DistNode::make(1, @dist.Phasor::zero()),
    @dist.DistNode::make(2, @dist.Phasor::zero()),
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
  match @dist.sweep(net, topo, 0.000000000001, 50) {
    Ok(res) => {
      let v = res.voltages()
      assert_true(approx_equal(@model.cx_abs(v[1].a()), 1.0, 0.000000001))
      assert_true(approx_equal(@model.cx_abs(v[1].b()), 1.0, 0.000000001))
      assert_true(approx_equal(@model.cx_abs(v[1].c()), 1.0, 0.000000001))
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "mixed ZIP transformer feeder matches analytic high voltage root" {
  let r = 0.08
  let p = 0.65
  let z = @model.cx(r, 0.0)
  for ratio in [0.9, 1.0, 1.1] {
    let tx = @dist.TxSpec::new(ratio, @dist.z3_diag(z, z, z)).unwrap()
    let net = @dist.DistNet::make(
      [
        @dist.DistNode::make(7, @dist.Phasor::zero()),
        @dist.DistNode::make(15, @dist.Phasor::uniform(@model.cx(p, 0.0))),
      ],
      [@dist.DistEdge::make_tx(7, 15, tx)],
      7,
      @dist.Phasor::balanced(1.0, 0.0),
    )
    let topo = match @dist.build_topology(net) {
      Ok(t) => t
      Err(e) => fail(e.describe())
    }
    for
      (alpha, beta, gamma) in [
        (1.0, 0.0, 0.0),
        (0.0, 1.0, 0.0),
        (0.0, 0.0, 1.0),
        (0.5, 0.2, 0.3),
      ] {
      let zip = @model.Zip::new(alpha, beta, gamma).unwrap()
      let result = match @dist.sweep_zip(net, topo, zip, 1.0e-12, 100) {
        Ok(v) => v
        Err(e) => fail(e.describe())
      }
      // V = ratio - R * P(V)/V. Choose the high-voltage quadratic root.
      let a = 1.0 + r * p * gamma
      let b = ratio - r * p * beta
      let expected = (b + (b * b - 4.0 * a * r * p * alpha).sqrt()) / (2.0 * a)
      let v = result.voltages()[1]
      for phase in [v.a(), v.b(), v.c()] {
        assert_true((@model.cx_abs(phase) - expected).abs() < 1.0e-10)
      }
    }
  }
}
