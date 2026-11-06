// examples/demo/main.mbt — 内置三节点算例的 GS 求解演示。
//
// 运行（native）：moon run examples/demo --target native
// 输出：收敛迭代次数、各母线电压幅值与相角（度）、各支路两端有功/无功与损耗，
// 全部功率与电压为标幺值 p.u.，基准容量 100 MVA。

#warnings("-deprecated")
fn run_demo(net : @model.Network) -> Unit {
  let y = @ybus.build_ybus(net)
  let res = @solver.gauss_seidel(net, y, @cases.default_tol(), @cases.default_max_iter())
  match res {
    Err(e) => println(("solver did not converge:", e.describe()))
    Ok(ok) => {
      println("moon-power-flow GS demo, values in p.u., S_B = 100 MVA")
      println(("converged sweeps:", ok.iter()))
      let v = ok.voltages()
      let n = net.bus_count()
      let mut i = 0
      while i < n {
        let b = net.bus_at(i)
        let mag = @model.cx_abs(v[i])
        let deg = @model.cx_arg(v[i]) * 180.0 / @math.PI
        println(("bus", b.bus_id(), b.bus_name(), "|V|", mag, "angle_deg", deg))
        i += 1
      }
      let flows = @solver.all_flows(net, v)
      let mut k = 0
      while k < flows.length() {
        let f = flows[k]
        println(
          (
            "branch",
            f.from_id(),
            "to",
            f.to_id(),
            "P_from",
            f.s_from().re(),
            "Q_from",
            f.s_from().im(),
            "P_to",
            f.s_to().re(),
            "Q_to",
            f.s_to().im(),
            "loss_P",
            f.loss().re(),
            "loss_Q",
            f.loss().im(),
          ),
        )
        k += 1
      }
    }
  }
}

#warnings("-deprecated")
fn main() -> Unit {
  match @cases.case_three_bus() {
    Err(e) => println(("validation failed:", e.describe()))
    Ok(net) => run_demo(net)
  }
}
