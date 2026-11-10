///|
/// 对称分量与不平衡度测试。
///
/// 期望值全部来自手算或对称分量的解析性质，不取自本库输出：
/// - 平衡正序 → 负序为零，VUF = 0；
/// - 单相有压（Va=1、Vb=Vc=0）→ V0=V1=V2=1/3，VUF = 100%；
/// - Va=1、Vb=a²、Vc=0.5a 的三相 → V1=2.5/3、|V2|=0.5/3，VUF = 20%；
/// - 零序（三相相等）→ V1=V2=0、V0=1。

///|
/// 双精度比较：浮点末位在不同后端有差异，一律走容差。
fn near(actual : Double, expected : Double, tol : Double) -> Bool {
  (actual - expected).abs() <= tol
}

///|
test "balanced positive sequence has no negative component" {
  let v = @dist.Phasor::balanced(0.98, 0.0)
  let seq = @dist.symmetrical_components(v)
  assert_true(@model.cx_abs(seq.positive()) > 0.97)
  assert_true(@model.cx_abs(seq.positive()) < 0.99)
  assert_true(@model.cx_abs(seq.negative()) < 1.0e-12)
  assert_true(@model.cx_abs(seq.zero()) < 1.0e-12)
  assert_true(near(@dist.voltage_unbalance_percent(v), 0.0, 1.0e-9))
}

///|
test "pure negative sequence kills the positive component" {
  // 负序：相序反过来 Va=1、Vb=∠+120°、Vc=∠−120°。
  let v = @dist.phasor(
    @model.cx(1.0, 0.0),
    @model.cx_polar(1.0, 2.0943951023931953),
    @model.cx_polar(1.0, -2.0943951023931953),
  )
  let seq = @dist.symmetrical_components(v)
  assert_true(@model.cx_abs(seq.positive()) < 1.0e-12)
  assert_true(near(@model.cx_abs(seq.negative()), 1.0, 1.0e-12))
  assert_true(@model.cx_abs(seq.zero()) < 1.0e-12)
  // 正序为零时不平衡度没有定义，约定返回 0 而不是 inf/NaN。
  assert_eq(@dist.voltage_unbalance_percent(v), 0.0)
}

///|
test "single phase energised is 100 percent unbalance" {
  // Va=1、Vb=Vc=0 → V0=V1=V2=1/3，|V2|/|V1| = 1。
  let v = @dist.phasor(
    @model.cx(1.0, 0.0),
    @model.cx(0.0, 0.0),
    @model.cx(0.0, 0.0),
  )
  let seq = @dist.symmetrical_components(v)
  assert_true(near(@model.cx_abs(seq.zero()), 1.0 / 3.0, 1.0e-12))
  assert_true(near(@model.cx_abs(seq.positive()), 1.0 / 3.0, 1.0e-12))
  assert_true(near(@model.cx_abs(seq.negative()), 1.0 / 3.0, 1.0e-12))
  assert_true(near(@dist.voltage_unbalance_percent(v), 100.0, 1.0e-9))
}

///|
test "one sagged phase gives 20 percent unbalance" {
  // Va=1、Vb=a²（即 ∠−120°）、Vc=0.5a（∠+120° 的一半）。
  // 手算：V1 = (1 + a·a² + a²·0.5a)/3 = (1+1+0.5)/3 = 2.5/3；
  //       V2 = (1 + a²·a² + a·0.5a)/3 = (1 + a + 0.5a²)/3 = −0.5a²/3 → |V2| = 0.5/3；
  //       VUF = (0.5/3)/(2.5/3) = 20%。
  let a = @dist.rot_a()
  let v = @dist.phasor(
    @model.cx(1.0, 0.0),
    @model.cx_mul(a, a),
    @model.cx_scale(a, 0.5),
  )
  let seq = @dist.symmetrical_components(v)
  assert_true(near(@model.cx_abs(seq.positive()), 2.5 / 3.0, 1.0e-12))
  assert_true(near(@model.cx_abs(seq.negative()), 0.5 / 3.0, 1.0e-12))
  assert_true(near(@dist.voltage_unbalance_percent(v), 20.0, 1.0e-9))
}

///|
test "equal three phase voltages are pure zero sequence" {
  // 三相相等 → 只有零序，正序与负序都为零。
  let v = @dist.phasor(
    @model.cx(1.0, 0.0),
    @model.cx(1.0, 0.0),
    @model.cx(1.0, 0.0),
  )
  let seq = @dist.symmetrical_components(v)
  assert_true(near(@model.cx_abs(seq.zero()), 1.0, 1.0e-12))
  assert_true(@model.cx_abs(seq.positive()) < 1.0e-12)
  assert_true(@model.cx_abs(seq.negative()) < 1.0e-12)
  assert_eq(@dist.voltage_unbalance_percent(v), 0.0)
}

///|
test "unbalance profile follows bus order" {
  let voltages = [
    @dist.Phasor::balanced(1.0, 0.0),
    @dist.phasor(@model.cx(1.0, 0.0), @model.cx(0.0, 0.0), @model.cx(0.0, 0.0)),
  ]
  let profile = @dist.unbalance_profile(voltages)
  assert_eq(profile.length(), 2)
  assert_true(profile[0] < 1.0e-9)
  assert_true(near(profile[1], 100.0, 1.0e-9))
}
