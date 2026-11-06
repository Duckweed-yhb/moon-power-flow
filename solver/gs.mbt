// solver/gs.mbt — 高斯-赛德尔（Gauss-Seidel）PQ 潮流最小求解器。
//
// 适用前提（调用方先用 model.validate 校验网络）：
//   - 恰好一个 Slack，其余为 PQ；PV 不在本轮求解范围；
//   - 网络已组装 Ybus（ybus.build_ybus）；
//   - 全部数值为标幺值 p.u.。
//
// 迭代式（注入功率约定 S = P + jQ，负荷为负注入；节点电流 I = conj(S) / conj(V)）：
//   V_i^(k+1) = ( conj(S_i) / conj(V_i^k) - sum_{j != i} Y_ij V_j ) / Y_ii
// 扫描顺序内 PQ 节点使用本轮已更新的最新电压，即 GS 的逐次替换特征。
// 收敛判据：全部 PQ 节点本次与上次电压复向量最大模差小于 tol。
// 达到 max_iter 仍未收敛返回结构化错误，不 panic。

/// 求解成功结果：迭代次数与各节点最终电压（复数值，p.u.）。
pub struct SolveOk {
  iter : Int
  voltages : Array[@model.Cx]
}

pub fn SolveOk::iter(self : SolveOk) -> Int {
  self.iter
}

pub fn SolveOk::voltages(self : SolveOk) -> Array[@model.Cx] {
  self.voltages
}

/// 求解失败原因。NotConverged 携带达到的迭代次数与最后一轮最大电压偏差。
pub enum SolveErr {
  NotConverged(Int, Double)
}

pub fn SolveErr::describe(self : SolveErr) -> String {
  match self {
    NotConverged(iter, delta) =>
      "did not converge after " + iter.to_string() + " sweeps, last max |dV| = " +
      delta.to_string()
  }
}

/// 从平坦启动（PQ 节点 1.0 + j0，Slack 取固定电压）开始 GS 迭代。
pub fn gauss_seidel(
  net : @model.Network,
  ybus : Array[Array[@model.Cx]],
  tol : Double,
  max_iter : Int,
) -> Result[SolveOk, SolveErr] {
  let n = net.bus_count()
  let slack = match net.slack_index() {
    Some(i) => i
    None => return Err(NotConverged(0, 1.0))
  }
  let v = Array::makei(n, i => {
    if i == slack {
      net.bus_at(i).v_fixed()
    } else {
      @model.cx(1.0, 0.0)
    }
  })
  let mut last_delta = 1.0
  let mut iter = 0
  while iter < max_iter {
    iter += 1
    let mut max_delta = 0.0
    let mut i = 0
    while i < n {
      if i != slack {
        let bus = net.bus_at(i)
        let vi_old = v[i]
        // conj(S_i) = P_i - jQ_i；电流为 I_i = conj(S_i) / conj(V_i^old)。
        let s_conj = @model.cx(bus.p_inj(), -bus.q_inj())
        let mut sum_ykv = @model.cx(0.0, 0.0)
        let mut j = 0
        while j < n {
          if j != i {
            sum_ykv = @model.cx_add(sum_ykv, @model.cx_mul(ybus[i][j], v[j]))
          }
          j += 1
        }
        let numer = @model.cx_sub(@model.cx_div(s_conj, @model.cx_conj(vi_old)), sum_ykv)
        let vi_new = @model.cx_div(numer, ybus[i][i])
        let delta = @model.cx_abs(@model.cx_sub(vi_new, vi_old))
        if delta > max_delta {
          max_delta = delta
        }
        v[i] = vi_new
      }
      i += 1
    }
    last_delta = max_delta
    if max_delta < tol {
      return Ok({ iter: iter, voltages: v })
    }
  }
  Err(NotConverged(max_iter, last_delta))
}
