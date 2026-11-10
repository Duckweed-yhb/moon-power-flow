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
