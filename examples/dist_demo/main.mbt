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
  // 组合算例：变压器在网中间、OLTC 调档、下游还有一条缺相支路。
  // 三项能力原先各自只在两节点小网里出现过，这里放在同一条馈线上跑。
  println("")
  println(
    "== 变压器 + OLTC + 缺相（1 -线路-> 2 -变压器-> 3 -缺相-> 4）==",
  )
  let combo = @dist.case_tx_oltc_open()
  let combo_topo = match @dist.build_topology(combo) {
    Ok(t) => t
    Err(e) => {
      println("topology error: " + e.describe())
      return
    }
  }
  // 步进 1.25%/档，目标 0.97 pu、死区 ±0.005 pu，档位限制 ±8。
  let oltc = match @dist.Oltc::new(3, 0, -8, 8, 0.0125, 0.97, 0.005) {
    Ok(o) => o
    Err(e) => {
      println("oltc error: " + e)
      return
    }
  }
  let run = match
    @dist.run_oltc(combo, combo_topo, oltc, 0.000000001, 100, 20) {
    Ok(r) => r
    Err(e) => {
      println("oltc run error: " + e.describe())
      return
    }
  }
  let mut ti = 0
  let moves = run.moves()
  let mut trace = ""
  while ti < moves.length() {
    if ti > 0 {
      trace = trace + " > "
    }
    let (tap, mag) = moves[ti]
    trace = trace + "tap " + tap.to_string() + ": " + mag.to_string()
    ti += 1
  }
  println("tap trace: " + trace)
  println(
    "final tap=" +
    run.oltc().tap().to_string() +
    " (ratio " +
    run.oltc().ratio().to_string() +
    "), bus3 |a|=" +
    @model.cx_abs(run.result().voltages()[2].a()).to_string() +
    " pu, in band=" +
    run.reached_band().to_string(),
  )
  println(
    "open phase on 3->4: |I_b|=" +
    @model.cx_abs(run.result().branch_currents()[2].b()).to_string() +
    " pu, |V4_b|=" +
    @model.cx_abs(run.result().voltages()[3].b()).to_string() +
    " pu, |V4_a|=" +
    @model.cx_abs(run.result().voltages()[3].a()).to_string() +
    " pu",
  )
  // 负荷静特性：同一个重载网络（1 -> 2 -> 3，每节点 0.30+j0.10 pu），
  // 三种 ZIP 构成下末端电压不同。恒阻抗在电压跌落时少取功率，电压不会一路塌；
  // 恒功率最硬，实际取用的有功也不随电压下降。
  println("")
  println("=== 负荷静特性（重载三节点链，bus3 为末端）===")
  let z = @model.cx(0.02, 0.04)
  let s = @model.cx(0.30, 0.10)
  let heavy = @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
      @dist.DistNode::make(3, @dist.Phasor::uniform(s)),
    ],
    [
      @dist.DistEdge::make(1, 2, @dist.z3_diag(z, z, z)),
      @dist.DistEdge::make(2, 3, @dist.z3_diag(z, z, z)),
    ],
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
  let heavy_topo = match @dist.build_topology(heavy) {
    Ok(t) => t
    Err(e) => {
      println("heavy topology error: " + e.describe())
      return
    }
  }
  let cases : Array[(String, @model.Zip)] = [
    ("恒功率 α=1", @model.Zip::new(1.0, 0.0, 0.0).unwrap()),
    ("恒电流 β=1", @model.Zip::new(0.0, 1.0, 0.0).unwrap()),
    ("恒阻抗 γ=1", @model.Zip::new(0.0, 0.0, 1.0).unwrap()),
    ("5:3:2 混合", @model.Zip::new(0.5, 0.3, 0.2).unwrap()),
  ]
  for item in cases {
    let (label, zip) = item
    match @dist.sweep_zip(heavy, heavy_topo, zip, 0.000000001, 100) {
      Ok(r) => {
        let demand = @dist.load_demand_active_zip(heavy, r, zip)
        println(
          label +
          ": iter=" +
          r.iter().to_string() +
          ", |V3_a|=" +
          @model.cx_abs(r.voltages()[2].a()).to_string() +
          " pu, 实际有功需求=" +
          demand.to_string() +
          " pu",
        )
      }
      Err(e) => println(label + ": " + e.describe())
    }
  }
  // 分接头扫描：同一台 1 -> 2 变压器只改变比，看受控母线电压怎么随档位走。
  // OLTC 那一段给的是「怎么调到目标」，这一段给的是「档位与电压的对应关系」，
  // 两段合起来才是调压能力的完整证据。
  println("")
  println(
    "=== 分接头扫描（1 -变压器-> 2，档位 ±4，步进 1.25%）===",
  )
  let tx_base = @dist.case_with_transformer()
  let tx_topo = match @dist.build_topology(tx_base) {
    Ok(t) => t
    Err(e) => {
      println("tx topology error: " + e.describe())
      return
    }
  }
  let mut tap = -4
  while tap <= 4 {
    let ratio = 1.0 + tap.to_double() * 0.0125
    let edges = [tx_base.edge_at(0).with_ratio(ratio)]
    let net2 = @dist.DistNet::make(
      tx_base.nodes(),
      edges,
      tx_base.root_id(),
      tx_base.v_root(),
    )
    match @dist.sweep(net2, tx_topo, 0.000000001, 100) {
      Ok(r) =>
        println(
          "tap " +
          tap.to_string() +
          " (k=" +
          ratio.to_string() +
          "): |V2_a|=" +
          @model.cx_abs(r.voltages()[1].a()).to_string() +
          " pu, iter=" +
          r.iter().to_string(),
        )
      Err(e) => println("tap " + tap.to_string() + ": " + e.describe())
    }
    tap += 1
  }
}
