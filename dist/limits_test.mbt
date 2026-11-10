///|
/// 电压越限检查与收敛轨迹测试。
///
/// 越限判据用「构造已知答案」的方式验证：同一个解分别用宽限值、窄限值、
/// 只卡上界/下界去查，越限条数应当可以手算出来。

///|
test "no violation when limits are wide" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => {
      let vs = @dist.voltage_violations(r, net, 0.5, 1.5)
      assert_eq(vs.length(), 0)
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "narrow lower limit flags every phase below it" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => {
      // 限值卡在 1.0 以上：根母线也是 1.0，严格小于才越限，所以根母线不报；
      // 三条负荷母线的六个下偏相会被查出来。
      let vs = @dist.voltage_violations(r, net, 0.999, 1.5)
      assert_true(vs.length() > 0)
      for v in vs {
        assert_true(v.kind() is @dist.Under)
        assert_true(v.magnitude() < 0.999)
      }
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "narrow upper limit flags over voltage" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => {
      // 上界压到 0.9995：所有高于它的相都要报 Over。
      let vs = @dist.voltage_violations(r, net, 0.0, 0.9995)
      assert_true(vs.length() > 0)
      for v in vs {
        assert_true(v.kind() is @dist.Over)
        assert_true(v.magnitude() > 0.9995)
      }
      // 描述字符串至少能拼出来（不 panic、不为空）。
      assert_true(vs[0].describe().length() > 0)
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "voltage extremes bracket every phase magnitude" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => {
      let extremes = @dist.voltage_extremes(r)
      let (lo, hi) = match extremes {
        Some(pair) => pair
        None => fail("extremes should be Some for a converged solution")
      }
      assert_true(lo <= 1.0)
      assert_true(hi >= 1.0 - 1.0e-12)
      assert_true(hi - lo > 0.0)
      // 任何一条越限记录都落在 [lo, hi] 之内。
      let vs = @dist.voltage_violations(r, net, lo + 1.0e-9, hi - 1.0e-9)
      for v in vs {
        assert_true(v.magnitude() >= lo - 1.0e-12)
        assert_true(v.magnitude() <= hi + 1.0e-12)
      }
    }
    Err(e) => fail(e.describe())
  }
}

///|
test "convergence trace matches iterations and final deviation" {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail(e.describe())
  }
  match @dist.sweep(net, topo, 1.0e-12, 100) {
    Ok(r) => {
      let trace = r.trace()
      assert_eq(trace.length(), r.iter())
      assert_eq(trace[trace.length() - 1], r.max_dv())
      for d in trace {
        assert_true(d >= 0.0)
      }
      // 四节点算例是良态网络：偏差应当单调下降。
      let mut i = 1
      while i < trace.length() {
        assert_true(trace[i] <= trace[i - 1] + 1.0e-18)
        i += 1
      }
    }
    Err(e) => fail(e.describe())
  }
}
