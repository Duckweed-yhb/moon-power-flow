///|
/// 三相不平衡配电网前推回代示例。
///
/// 跑内置四节点算例：根母线 1 平衡，母线 2/3/4 挂单相或两相负荷，
/// 打印收敛扫描次数、各母线三相电压与支路电流。
fn fmt_cx(c : @model.Cx) -> String {
  let mag = @model.cx_abs(c)
  let deg = @model.cx_arg(c) * 180.0 / 3.141592653589793
  mag.to_string() + " pu @" + deg.to_string() + " deg"
}

///|
fn main {
  let net = @dist.case_four_node()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => {
      println("topology error: " + e.describe())
      return
    }
  }
  match @dist.sweep(net, topo, 0.000000001, 100) {
    Ok(r) => {
      println(
        "converged in " +
        r.iter().to_string() +
        " sweeps, max |dV| = " +
        r.max_dv().to_string(),
      )
      let v = r.voltages()
      let names = ["bus1 (root)", "bus2", "bus3", "bus4"]
      let mut i = 0
      while i < v.length() {
        let p = v[i]
        // 三相不平衡度（对称分量法，|V2|/|V1|）：平衡假设下这一列恒为 0，
        // 它才是「不平衡配电网」和「平衡配电网」真正的数字差别。
        let vuf = @dist.voltage_unbalance_percent(p)
        println(
          names[i] +
          ": a=" +
          fmt_cx(p.a()) +
          "  b=" +
          fmt_cx(p.b()) +
          "  c=" +
          fmt_cx(p.c()) +
          "  VUF=" +
          vuf.to_string() +
          "%",
        )
        i += 1
      }
      let cur = r.branch_currents()
      println(
        "branch 1->2: a=" + fmt_cx(cur[0].a()) + "  b=" + fmt_cx(cur[0].b()),
      )
      println(
        "branch 2->3: a=" + fmt_cx(cur[1].a()) + "  c=" + fmt_cx(cur[1].c()),
      )
      println("branch 2->4: c=" + fmt_cx(cur[2].c()))
      // 电压越限检查：限值只是示例口径，规程由调用方按自己的标准定。
      let (vmin, vmax) = (0.95, 1.05)
      let vs = @dist.voltage_violations(r, net, vmin, vmax)
      println(
        "voltage limits [" +
        vmin.to_string() +
        ", " +
        vmax.to_string() +
        "] pu: " +
        vs.length().to_string() +
        " violation(s)",
      )
      for v in vs {
        println("  " + v.describe())
      }
      // 收敛轨迹：形状比最后一次偏差有用（振荡 / 单调逼近）。
      let mut trace_str = ""
      let mut ti = 0
      let tr = r.trace()
      while ti < tr.length() {
        if ti > 0 {
          trace_str = trace_str + " > "
        }
        trace_str = trace_str + tr[ti].to_string()
        ti += 1
      }
      println("convergence trace: " + trace_str)
      // 中性点位移（四线制一阶近似）：给每条支路一根中性线阻抗，
      // 看负荷端「相对中性点」的相电压怎么变。
      let zn = @model.cx(0.015, 0.008)
      let vn = @dist.neutral_voltages(net, topo, r, zn)
      let vpn = @dist.phase_to_neutral(r, vn)
      println(
        "neutral shift (z_n = 0.015+j0.008 pu), phase-to-neutral magnitudes:",
      )
      let mut bi = 0
      while bi < vpn.length() {
        println(
          "  " +
          names[bi] +
          ": |Vn|=" +
          @model.cx_abs(vn[bi]).to_string() +
          "  |Van|=" +
          @model.cx_abs(vpn[bi].a()).to_string() +
          "  |Vbn|=" +
          @model.cx_abs(vpn[bi].b()).to_string() +
          "  |Vcn|=" +
          @model.cx_abs(vpn[bi].c()).to_string(),
        )
        bi += 1
      }
      // 功率平衡：根注入 = 负荷需求 + 损耗。残差就是「损耗算错没有」的证据。
      let loss = @dist.total_loss_active(net, r)
      let load = @dist.load_demand_active(net)
      let inject = @dist.root_injection_active(net, r)
      println(
        "active power: root injection=" +
        inject.to_string() +
        " pu, load=" +
        load.to_string() +
        " pu, loss=" +
        loss.to_string() +
        " pu, residual=" +
        (inject - load - loss).to_string() +
        " pu",
      )
    }
    Err(e) => println("sweep error: " + e.describe())
  }
}
