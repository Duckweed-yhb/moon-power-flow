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

/// 求解成功：迭代次数、各母线三相电压、各支路三相电流、最后偏差。
pub struct SweepOk {
  iter : Int
  voltages : Array[Phasor]
  branch_currents : Array[Phasor]
  max_dv : Double
}

pub fn SweepOk::iter(self : SweepOk) -> Int {
  self.iter
}

pub fn SweepOk::voltages(self : SweepOk) -> Array[Phasor] {
  self.voltages
}

pub fn SweepOk::branch_currents(self : SweepOk) -> Array[Phasor] {
  self.branch_currents
}

pub fn SweepOk::max_dv(self : SweepOk) -> Double {
  self.max_dv
}

/// 求解失败：拓扑非法，或达到迭代上限仍未收敛。
pub enum SweepErr {
  Topology(TopoErr)
  NotConverged(Int, Double)
}

pub fn SweepErr::describe(self : SweepErr) -> String {
  match self {
    Topology(e) => "topology: " + e.describe()
    NotConverged(iter, dv) =>
      "did not converge after " + iter.to_string() + " sweeps, last max |dV| = " +
      dv.to_string()
  }
}

/// 前推回代求解。`topo` 必须由同一 `net` 通过 `build_topology` 得到。
pub fn sweep(
  net : DistNet,
  topo : Topology,
  tol : Double,
  max_iter : Int,
) -> Result[SweepOk, SweepErr] {
  let n = net.node_count()
  let m = net.edge_count()
  let root = match net.find_index(net.root_id()) {
    Some(k) => k
    None => return Err(SweepErr::Topology(RootNotFound))
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
  while iter < max_iter {
    iter += 1
    // 1. 回代：叶子到根
    for u in rev {
      if u != root {
        let i_load = net.node_at(u).s().map_div(v[u]).conj()
        let mut total = i_load
        for ch in children[u] {
          total = total.add(i_branch[parent_edge[ch]])
        }
        i_branch[parent_edge[u]] = total
      }
    }
    // 2. 前推：根到叶子，同时统计收敛偏差
    let mut max_dv = 0.0
    for u in order {
      if u != root {
        let pe = parent_edge[u]
        let drop = net.edge_at(pe).z().mul(i_branch[pe])
        let v_new = v[parent[u]].sub(drop)
        let dv = v_new.sub(v[u]).max_abs()
        if dv > max_dv {
          max_dv = dv
        }
        v[u] = v_new
      }
    }
    last_dv = max_dv
    if max_dv < tol {
      return Ok({
        iter: iter,
        voltages: v,
        branch_currents: i_branch,
        max_dv: max_dv,
      })
    }
  }
  Err(SweepErr::NotConverged(max_iter, last_dv))
}
