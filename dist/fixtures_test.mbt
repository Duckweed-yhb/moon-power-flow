/// 三相不平衡算例的独立基准。
///
/// 期望值由 `scripts/gen_dist_fixtures.py` 里另行实现的前推回代算出
/// （Python 复数、独立写一遍回代/前推），不读取 MoonBit 侧输出。
/// 求解容差取 1e-12、迭代上限 200，保证对照点本身是收敛值。
/// `approx_equal` 复用同包 `dist_test.mbt` 的定义。

test "dist fixtures: four-node unbalanced case (independent Python BFS)" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 0.000000000001, 200) {
    Ok(r) => {
      let v = r.voltages()
      assert_eq(v.length(), 4)
      // bus2 phase a
      assert_true(approx_equal(v[1].a.re, 0.9973838512201859, 0.000000001))
      assert_true(approx_equal(v[1].a.im, -0.00269999999999998, 0.000000001))
      // bus2 phase b
      assert_true(approx_equal(v[1].b.re, -0.5002420940146172, 0.000000001))
      assert_true(approx_equal(v[1].b.im, -0.8648447229179643, 0.000000001))
      // bus2 phase c
      assert_true(approx_equal(v[1].c.re, -0.49794813850366487, 0.000000001))
      assert_true(approx_equal(v[1].c.im, 0.8654714754226924, 0.000000001))
      // bus3 phase a
      assert_true(approx_equal(v[2].a.re, 0.9963765015789868, 0.000000001))
      assert_true(approx_equal(v[2].a.im, -0.003699896032754766, 0.000000001))
      // bus3 phase b
      assert_true(approx_equal(v[2].b.re, -0.5002420940146172, 0.000000001))
      assert_true(approx_equal(v[2].b.im, -0.8648447229179643, 0.000000001))
      // bus3 phase c
      assert_true(approx_equal(v[2].c.re, -0.4974943684635507, 0.000000001))
      assert_true(approx_equal(v[2].c.im, 0.865385673262153, 0.000000001))
      // bus4 phase a
      assert_true(approx_equal(v[3].a.re, 0.9973838512201859, 0.000000001))
      assert_true(approx_equal(v[3].a.im, -0.00269999999999998, 0.000000001))
      // bus4 phase b
      assert_true(approx_equal(v[3].b.re, -0.5002420940146172, 0.000000001))
      assert_true(approx_equal(v[3].b.im, -0.8648447229179643, 0.000000001))
      // bus4 phase c
      assert_true(approx_equal(v[3].c.re, -0.49703381278522096, 0.000000001))
      assert_true(approx_equal(v[3].c.im, 0.8651876650865734, 0.000000001))
    }
    Err(e) => fail(e.describe())
  }
}
