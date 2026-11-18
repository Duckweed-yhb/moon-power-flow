///|
test "complex magnitude preserves representable norms across scales" {
  for scale in [1.0e-200, 1.0, 1.0e200] {
    assert_true(
      (@model.cx_abs(@model.cx(3.0 * scale, -4.0 * scale)) / scale - 5.0).abs() <
      1.0e-12,
    )
  }
}
