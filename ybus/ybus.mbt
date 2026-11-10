// ybus/ybus.mbt — 节点复导纳矩阵（Ybus）组装。
//
// 约定（标幺值 p.u.，与 model 包一致）：
//   - 支路串联阻抗 z = r + jx，串联导纳 y = 1/z = (r - jx) / |z|^2；
//   - 对角元 Y_ii 等于与节点 i 相连全部支路导纳之和；
//   - 非对角元 Y_ij = Y_ji = -y_ij（i 与 j 直接相连时）；
//   - 本轮不启用对地充电导纳 shunt，列入后续扩展。
//
// 输入网络必须先通过 model.validate；阻抗为零的支路不会到达本包。

///|
/// 由串联复阻抗求串联复导纳 y = 1/z。
pub fn branch_admittance(z : @model.Cx) -> @model.Cx {
  let den = z.re() * z.re() + z.im() * z.im()
  @model.cx(z.re() / den, -z.im() / den)
}

///|
fn bus_index(net : @model.Network, id : Int32) -> Int32 {
  let n = net.bus_count()
  let mut i = 0
  while i < n {
    if net.bus_at(i).bus_id() == id {
      return i
    }
    i += 1
  }
  // 校验已保证端点存在，理论上不会走到这里；兜底返回 0 而非 panic。
  0
}

///|
/// 组装 n×n 复导纳矩阵，行、列下标与 Network.bus_at 的内部下标一致。
pub fn build_ybus(net : @model.Network) -> Array[Array[@model.Cx]] {
  let n = net.bus_count()
  let mat : Array[Array[@model.Cx]] = Array::makei(n, _ => {
    Array::makei(n, _ => @model.cx(0.0, 0.0))
  })
  let b = net.branch_count()
  let mut k = 0
  while k < b {
    let br = net.branch_at(k)
    let a = bus_index(net, br.from_id())
    let c = bus_index(net, br.to_id())
    let y = branch_admittance(br.impedance())
    mat[a][a] = @model.cx_add(mat[a][a], y)
    mat[c][c] = @model.cx_add(mat[c][c], y)
    mat[a][c] = @model.cx_sub(mat[a][c], y)
    mat[c][a] = @model.cx_sub(mat[c][a], y)
    k += 1
  }
  mat
}

///|
/// 读取矩阵元素（只读访问，便于测试与 demo 使用）。
pub fn ybus_get(
  mat : Array[Array[@model.Cx]],
  i : Int32,
  j : Int32,
) -> @model.Cx {
  mat[i][j]
}
