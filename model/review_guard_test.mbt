///|
/// 造一个 NaN（inf - inf），不依赖 stdlib 是否提供常量。
fn nan_value() -> Double {
  let big = 1.0e308 * 10.0
  big - big
}

///|
/// 评审回归：ZIP 系数必须先挡非有限值。
///
/// NaN 与任何数比较恒假，`alpha < 0.0` 和 `(sum-1).abs() > 1e-9` 都会放行，
/// 于是构造出一个 alpha=NaN 的「合法」Zip，一路带到求解器才炸。
test "Zip::new rejects NaN coefficients" {
  let nan = nan_value()
  assert_eq(nan != nan, true)
  assert_true(
    match @model.Zip::new(nan, 0.0, 1.0) {
      Err(_) => true
      Ok(_) => false
    },
  )
  assert_true(
    match @model.Zip::new(1.0, nan, 0.0) {
      Err(_) => true
      Ok(_) => false
    },
  )
  assert_true(
    match @model.Zip::new(0.5, 0.5, nan) {
      Err(_) => true
      Ok(_) => false
    },
  )
}

///|
/// 和不为 1、出现负系数仍然要拒（原有行为，顺手一起钉住）。
test "Zip::new rejects bad sums and negatives" {
  assert_true(
    match @model.Zip::new(0.5, 0.4, 0.4) {
      Err(_) => true
      Ok(_) => false
    },
  )
  assert_true(
    match @model.Zip::new(-0.1, 0.6, 0.5) {
      Err(_) => true
      Ok(_) => false
    },
  )
}
