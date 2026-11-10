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

///|
/// 求解成功结果：迭代次数与各节点最终电压（复数值，p.u.）。
pub struct SolveOk {
  iter : Int32
  voltages : Array[@model.Cx]
}

///|
pub fn SolveOk::iter(self : SolveOk) -> Int32 {
  self.iter
}

///|
pub fn SolveOk::voltages(self : SolveOk) -> Array[@model.Cx] {
  self.voltages
}

///|
/// 求解失败原因。NotConverged 携带达到的迭代次数与最后一轮最大电压偏差；
/// NonFinite 表示迭代中出现 NaN（负荷为非有限值，或电压被除到 0）；
/// NoSlack / InvalidConfig 表示输入本身不可解。
pub enum SolveErr {
  NoSlack
  InvalidConfig
  NonFinite(Int32)
  NotConverged(Int32, Double)
}

///|
pub fn SolveErr::describe(self : SolveErr) -> String {
  match self {
    NoSlack => "no slack bus found (network must be validated first)"
    InvalidConfig => "max_iter must be > 0"
    NonFinite(iter) =>
      "non-finite value at sweep " +
      iter.to_string() +
      " (NaN in injection or voltage)"
    NotConverged(iter, delta) =>
      "did not converge after " +
      iter.to_string() +
      " sweeps, last max |dV| = " +
      delta.to_string()
  }
}

///|
/// 从平坦启动（PQ 节点 1.0 + j0，Slack 取固定电压）开始 GS 迭代。
pub fn gauss_seidel(
  net : @model.Network,
  ybus : Array[Array[@model.Cx]],
  tol : Double,
  max_iter : Int32,
) -> Result[SolveOk, SolveErr] {
  gauss_seidel_with_zip(net, ybus, None, tol, max_iter)
}

///|
/// 带 ZIP 负荷静特性的 GS 求解：每轮按节点当前电压模长缩放净注入。
///
/// 语义与三相侧一致：`S(V) = S0·(α + β|V| + γ|V|²)`。α=1 时与 `gauss_seidel`
/// 完全同解。单相侧只做 1 Slack + 若干 PQ，缩放对象是节点净注入（负荷为负）。
pub fn gauss_seidel_zip(
  net : @model.Network,
  ybus : Array[Array[@model.Cx]],
  zip : @model.Zip,
  tol : Double,
  max_iter : Int32,
) -> Result[SolveOk, SolveErr] {
  gauss_seidel_with_zip(net, ybus, Some(zip), tol, max_iter)
}

///|
/// 求解主体：`zip` 为 None 表示恒功率注入（旧行为）。
fn gauss_seidel_with_zip(
  net : @model.Network,
  ybus : Array[Array[@model.Cx]],
  zip : @model.Zip?,
  tol : Double,
  max_iter : Int32,
) -> Result[SolveOk, SolveErr] {
  let n = net.bus_count()
  if max_iter <= 0 {
    return Err(InvalidConfig)
  }
  let slack = match net.slack_index() {
    Some(i) => i
    None => return Err(NoSlack)
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
    let mut seen_nan = false
    let mut i = 0
    while i < n {
      if i != slack {
        let bus = net.bus_at(i)
        let vi_old = v[i]
        // conj(S_i) = P_i - jQ_i；电流为 I_i = conj(S_i) / conj(V_i^old)。
        // ZIP：按节点当前电压模长缩放净注入
        let f = match zip {
          None => 1.0
          Some(z) => z.scale_at(@model.cx_abs(vi_old))
        }
        let s_conj = @model.cx(bus.p_inj() * f, -bus.q_inj() * f)
        let mut sum_ykv = @model.cx(0.0, 0.0)
        let mut j = 0
        while j < n {
          if j != i {
            sum_ykv = @model.cx_add(sum_ykv, @model.cx_mul(ybus[i][j], v[j]))
          }
          j += 1
        }
        let numer = @model.cx_sub(
          @model.cx_div(s_conj, @model.cx_conj(vi_old)),
          sum_ykv,
        )
        let vi_new = @model.cx_div(numer, ybus[i][i])
        let delta = @model.cx_abs(@model.cx_sub(vi_new, vi_old))
        // NaN 必须先抓：`NaN > max_delta` 恒为 false，否则本轮 max_delta 停在 0，
        // 收敛判据会把「全是 NaN」当成收敛，返回 Ok + NaN 电压。
        if delta != delta {
          seen_nan = true
        }
        if delta > max_delta {
          max_delta = delta
        }
        v[i] = vi_new
      }
      i += 1
    }
    if seen_nan {
      return Err(NonFinite(iter))
    }
    last_delta = max_delta
    if max_delta < tol {
      return Ok({ iter, voltages: v, })
    }
  }
  Err(NotConverged(max_iter, last_delta))
}
