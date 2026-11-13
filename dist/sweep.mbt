// dist/sweep.mbt — 三相不平衡辐射网的前推回代（Backward/Forward Sweep）。
//
// 适用前提（调用方先 build_topology 校验）：网络是一棵树，根为变电站出口，
// 全部数值为标幺值。
//
// 每轮迭代：
//   1. 回代（叶子 → 根）：节点负荷电流 I_load = conj(S_load / V)，与所有子支路
//      电流相加，得到该节点上游支路的电流；
//   2. 前推（根 → 叶子）：V_to = V_from − Z_branch · I_branch，Z 为 3x3 复阻抗矩阵，
//      保留相间互阻抗，因此三相电压降会互相耦合；
//   3. 收敛判据：全部非根节点本轮与上轮复电压的最大模差小于 tol。
//
// 恒定功率负荷 + 三相耦合阻抗下，前推回代是配电系统常用解法；它不要求
// 雅可比矩阵，也不假设三相平衡。

///|
/// 求解成功：迭代次数、各母线三相电压、各支路三相电流、最后偏差，以及
/// 每轮的收敛偏差轨迹。
pub struct SweepOk {
  iter : Int32
  voltages : Array[Phasor]
  branch_currents : Array[Phasor]
  max_dv : Double
  trace : Array[Double]
}

///|
pub fn SweepOk::iter(self : SweepOk) -> Int32 {
  self.iter
}

///|
pub fn SweepOk::voltages(self : SweepOk) -> Array[Phasor] {
  self.voltages
}

///|
pub fn SweepOk::branch_currents(self : SweepOk) -> Array[Phasor] {
  self.branch_currents
}

///|
pub fn SweepOk::max_dv(self : SweepOk) -> Double {
  self.max_dv
}

///|
/// 每轮的收敛偏差（长度等于迭代次数，最后一个元素等于 `max_dv`）。
///
/// 不收敛时要判断「是振荡还是单调逼近」：只看最后一次偏差没法区分，
/// 轨迹能看出形状。前推回代在病态网络里通常是前后两轮来回摆。
pub fn SweepOk::trace(self : SweepOk) -> Array[Double] {
  self.trace
}

///|
/// 求解失败：拓扑非法、拓扑与网络不匹配、出现非有限值，或达到迭代上限仍未收敛。
pub enum SweepErr {
  Topology(TopoErr)
  /// 传入的 `Topology` 不是由同一个 `DistNet` 生成的（节点数/支路下标对不上）。
  /// 这类错以前会直接在 `i_branch[parent_edge[u]]` 处以数组越界 panic 掉。
  TopologyMismatch
  /// 迭代过程中出现 NaN（负荷/阻抗里有非有限值，或电压被除到 0）。
  ///
  /// 必须单独报错：NaN 参与比较恒为 false，收敛判据 `dv > max_dv` 会一路
  /// 保持 `max_dv = 0`，第一轮就被判成「已收敛」，然后带着 NaN 电压返回 Ok。
  NonFinite(Int32)
  /// 迭代上限 <= 0：没有可执行的迭代，参数本身是错的。
  /// 以前返回 `NotConverged(0, 1.0)`，那个 1.0 是初始化占位值，不是真实偏差。
  InvalidConfig
  NotConverged(Int32, Double)
}

///|
pub fn SweepErr::describe(self : SweepErr) -> String {
  match self {
    Topology(e) => "topology: " + e.describe()
    TopologyMismatch =>
      "topology does not match this network (build_topology on the same net)"
    NonFinite(iter) =>
      "non-finite value at sweep " +
      iter.to_string() +
      " (NaN in load, impedance or voltage)"
    InvalidConfig =>
      "invalid config: max_iter must be > 0 and tol must be a positive finite number"
    NotConverged(iter, dv) =>
      "did not converge after " +
      iter.to_string() +
      " sweeps, last max |dV| = " +
      dv.to_string()
  }
}

///|
/// 前推回代求解（恒功率负荷）。`topo` 必须由同一 `net` 通过 `build_topology` 得到。
pub fn sweep(
  net : DistNet,
  topo : Topology,
  tol : Double,
  max_iter : Int32,
) -> Result[SweepOk, SweepErr] {
  sweep_with_zip(net, topo, None, tol, max_iter)
}

///|
/// 前推回代求解（ZIP 负荷静特性）。`zip` 按母线电压模长缩放负荷功率，
/// 其余与 `sweep` 完全一致；`Zip::constant_power()` 时与 `sweep` 同解。
pub fn sweep_zip(
  net : DistNet,
  topo : Topology,
  zip : @model.Zip,
  tol : Double,
  max_iter : Int32,
) -> Result[SweepOk, SweepErr] {
  sweep_with_zip(net, topo, Some(zip), tol, max_iter)
}

///|
/// 求解主体：`zip` 为 None 表示恒功率负荷（旧行为）。
fn sweep_with_zip(
  net : DistNet,
  topo : Topology,
  zip : @model.Zip?,
  tol : Double,
  max_iter : Int32,
) -> Result[SweepOk, SweepErr] {
  let n = net.node_count()
  let m = net.edge_count()
  if max_iter <= 0 {
    return Err(SweepErr::InvalidConfig)
  }
  // tol 必须是正的有限数：tol=0 时判据 `max_dv < 0` 永远不成立（必报
  // NotConverged 而实际偏差已是 0），tol=+inf 则第一轮就判收敛、返回一个
  // 明显没收敛的解。两种都是配置错误，不是计算结果。
  if !(tol > 0.0) || tol > 1.0e308 {
    return Err(SweepErr::InvalidConfig)
  }
  // 拓扑必须是同一次 build_topology 的产物：数组长度与支路下标都要落在范围内，
  // 否则下面的 i_branch[parent_edge[u]] 会越界 panic（库不该用 panic 报错）。
  if topo.parent_edge().length() != n || topo.parent().length() != n {
    return Err(SweepErr::TopologyMismatch)
  }
  let root = match net.find_index(net.root_id()) {
    Some(k) => k
    None => return Err(SweepErr::Topology(RootNotFound))
  }
  // 只有根节点的父边是 -1，其余必须落在 [0, m)，而且该父边必须真的连接
  // 「父节点 → 本节点」。只查下标范围挡不住「同规模、同根、不同树」的另一张网
  // （根下标相同、父子关系不同），那种情况下回代会沿错误的边累加电流，
  // 算出来的电压与损耗都是错的，但所有自检照样通过。
  for u in 0..<n {
    let pe = topo.parent_edge()[u]
    if pe == -1 {
      if u != root {
        return Err(SweepErr::TopologyMismatch)
      }
    } else if pe < 0 || pe >= m {
      return Err(SweepErr::TopologyMismatch)
    } else {
      let pu = topo.parent()[u]
      if pu < 0 || pu >= n {
        return Err(SweepErr::TopologyMismatch)
      }
      let e = net.edge_at(pe)
      let uid = net.node_at(u).id()
      let pid = net.node_at(pu).id()
      let connected = (e.from_id() == pid && e.to_id() == uid) ||
        (e.from_id() == uid && e.to_id() == pid)
      if !connected {
        return Err(SweepErr::TopologyMismatch)
      }
    }
  }
  // 平坦启动：全部母线取根电压。
  let v_root = net.v_root()
  let v : Array[Phasor] = []
  for _ in 0..<n {
    v.push(v_root)
  }
  let i_branch : Array[Phasor] = []
  for _ in 0..<m {
    i_branch.push(Phasor::zero())
  }
  let order = topo.order()
  let rev = topo.reverse_order()
  let parent_edge = topo.parent_edge()
  let parent = topo.parent()
  let children = topo.children()
  let mut iter = 0
  let mut last_dv = 1.0
  let trace : Array[Double] = []
  while iter < max_iter {
    iter += 1
    // 1. 回代：叶子到根
    for u in rev {
      if u != root {
        let i_load = load_current(net.node_at(u).s(), v[u], zip)
        let mut total = i_load
        for ch in children[u] {
          total = total.add(i_branch[parent_edge[ch]])
        }
        // 断开相不参与回路：该相支路电流置零。
        let pe = parent_edge[u]
        total = total.apply_switch(net.edge_at(pe).sw())
        i_branch[pe] = total
      }
    }
    // 2. 前推：根到叶子，同时统计收敛偏差
    let mut max_dv = 0.0
    let mut seen_nan = false
    for u in order {
      if u != root {
        let pe = parent_edge[u]
        let e = net.edge_at(pe)
        // 变压器支路：副边电压基准 = 变比 k × 原边电压，漏阻抗归算到副边；
        // 普通线路：基准就是父节点电压，压降用线路 3x3 阻抗。
        let tx = e.tx()
        let (z, base) = if tx.enabled() {
          (tx.z(), v[parent[u]].scale(tx.ratio()))
        } else {
          (e.z(), v[parent[u]])
        }
        let drop = z.mul(i_branch[pe])
        let v_new = base.sub(drop).apply_switch(e.sw())
        let dv = v_new.sub(v[u]).max_abs()
        // NaN 必须先抓：`NaN > max_dv` 恒为 false，否则这一轮的 max_dv 会停在 0，
        // 下一行就把「全是 NaN」判成收敛。
        if dv != dv {
          seen_nan = true
        }
        if dv > max_dv {
          max_dv = dv
        }
        v[u] = v_new
      }
    }
    if seen_nan {
      return Err(SweepErr::NonFinite(iter))
    }
    last_dv = max_dv
    trace.push(max_dv)
    if max_dv < tol {
      return Ok({ iter, voltages: v, branch_currents: i_branch, max_dv, trace, })
    }
  }
  Err(SweepErr::NotConverged(max_iter, last_dv))
}
