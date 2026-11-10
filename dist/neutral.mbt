// dist/neutral.mbt — 中性点位移（四线制近似）。
//
// 三分支模型算出来的是「相对根中性点」的相电压。真实四线制里中性导体也有
// 阻抗，中性点会随不平衡电流漂移，负荷端的**相电压相对中性点**因此变化：
// 重载相下沉最明显，另外两相也会跟着偏移，这正是单相接地/单相负荷场景里
// 最常被忽略的一段。README 的已知限制里写着「没有中性线，不覆盖中性点位移」，这里补上
// 一个明确口径的近似：
//
//   1. 中性导体与相导体同拓扑（每条支路一根中性线）；
//   2. 支路中性电流取该支路三相电流之和的相反数：I_n = −(I_a + I_b + I_c)；
//   3. 中性导体阻抗逐支路相同，由调用方给定（真机上是分段参数，这里不假装
//      知道长度）；
//   4. 根中性点为参考零电位。
//
// 只做线性后处理，不改求解器：相电流仍按原前推回代结果取。严格地说中性点
// 位移会轻微改变负荷功率分配（恒功率负荷），但配电网里中性阻抗远小于相阻抗，
// 一阶近似足够回答「会不会漂、漂多少」。

///|
/// 逐节点中性点电压（相对根中性点，标幺）。顺序与 `DistNet::node_at` 一致。
///
/// `z_neutral` 是每条支路的中性导体阻抗（三相共用一个值）。
/// 返回空数组表示输入对不上（拓扑/电流不是这一网的结果）。返回零数组不行：
/// 「没有漂移」和「数据无效」是两件事，混在一起会被下游当成正常结果。
pub fn neutral_voltages(
  net : DistNet,
  topo : Topology,
  r : SweepOk,
  z_neutral : @model.Cx,
) -> Array[@model.Cx] {
  let n = net.node_count()
  let zero = @model.cx(0.0, 0.0)
  let out : Array[@model.Cx] = []
  // 拓扑与电流必须来自同一张网：长度对不上就返回空，不越界 panic，
  // 也不假装「中性点不漂」。
  if topo.parent().length() != n ||
    topo.parent_edge().length() != n ||
    r.branch_currents().length() != net.edge_count() {
    return out
  }
  for _ in 0..<n {
    out.push(zero)
  }
  let root = match net.find_index(net.root_id()) {
    Some(k) => k
    None => return out
  }
  let order = topo.order()
  let parent = topo.parent()
  let parent_edge = topo.parent_edge()
  let currents = r.branch_currents()
  for u in order {
    if u != root {
      let pu = parent[u]
      let pe = parent_edge[u]
      // 防御：拓扑若被外部构造得不完整，宁可跳过这个节点也不越界 panic。
      if pu < 0 || pe < 0 || pe >= currents.length() {
        continue
      }
      let i = currents[pe]
      // 中性电流 = 该支路三相电流之和取反。
      let i_n = @model.cx_neg(@model.cx_add(@model.cx_add(i.a(), i.b()), i.c()))
      let drop = @model.cx_mul(z_neutral, i_n)
      out[u] = @model.cx_sub(out[pu], drop)
    }
  }
  out
}

///|
/// 相电压（相对根中性点）减去中性点电压，得到负荷端**相对中性点**的相电压。
///
/// 两者长度取较小值比较，避免错配输入越界；正常调用来自同一次求解。
pub fn phase_to_neutral(
  r : SweepOk,
  neutral : Array[@model.Cx],
) -> Array[Phasor] {
  let v = r.voltages()
  let pairs = if v.length() < neutral.length() {
    v.length()
  } else {
    neutral.length()
  }
  let out : Array[Phasor] = []
  let mut i = 0
  while i < pairs {
    let vn = neutral[i]
    out.push(
      phasor(
        @model.cx_sub(v[i].a(), vn),
        @model.cx_sub(v[i].b(), vn),
        @model.cx_sub(v[i].c(), vn),
      ),
    )
    i += 1
  }
  out
}
