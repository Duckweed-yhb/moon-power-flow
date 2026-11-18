///|
/// 变压器馈线上的有载调压，对比三种负荷静特性下的调压结果。
///
/// 算例：母线 1 为平衡根母线，支路 1 → 2 是一台变压器（漏阻抗 0.03 + j0.05），
/// 母线 2 挂 0.28 + j0.09 的三相平衡负荷。调压器目标 0.99 pu、死区 ±0.01，
/// 每档 2%、档位 −6…+6。负荷分别按恒功率、混合（α=0.5 β=0.2 γ=0.3）、
/// 恒阻抗三种静特性算，各打印一条「档位 → 受控相电压」曲线和闭环结果。

///|
/// 构造算例：一台变压器喂一个平衡三相负荷。
fn tx_feeder() -> @dist.DistNet raise {
  let zt = @model.cx(0.03, 0.05)
  let z3 = @dist.z3_diag(zt, zt, zt)
  let tx = match @dist.TxSpec::new(1.0, z3) {
    Ok(t) => t
    Err(e) => fail(e)
  }
  let s = @model.cx(0.28, 0.09)
  @dist.DistNet::make(
    [
      @dist.DistNode::make(1, @dist.Phasor::zero()),
      @dist.DistNode::make(2, @dist.Phasor::uniform(s)),
    ],
    [@dist.DistEdge::make_tx(1, 2, tx)],
    1,
    @dist.Phasor::balanced(1.0, 0.0),
  )
}

///|
/// 打印一种负荷静特性下的扫描曲线与闭环结果。
fn report(
  label : String,
  net : @dist.DistNet,
  topo : @dist.Topology,
  zip : @model.Zip,
) -> Unit raise {
  println("=== " + label + " ===")
  match @dist.scan_taps_zip(net, topo, oltc(), zip, 1.0e-9, 100) {
    Ok(rows) =>
      for row in rows {
        println(
          "  tap " + row.0.to_string() + " -> " + row.1.to_string() + " pu",
        )
      }
    Err(e) => fail(e.describe())
  }
  match @dist.run_oltc_zip(net, topo, oltc(), zip, 1.0e-9, 100, 12) {
    Ok(run) => {
      let moves = run.moves()
      let last = if moves.length() > 0 {
        moves[moves.length() - 1].1
      } else {
        0.0
      }
      println(
        "  闭环：终档 " +
        run.oltc().tap().to_string() +
        "，受控相电压 " +
        last.to_string() +
        " pu，进带 " +
        run.reached_band().to_string() +
        "，调档步数 " +
        (moves.length() - 1).to_string() +
        "，终止于 " +
        run.stopped().describe(),
      )
    }
    Err(e) => fail(e.describe())
  }
}

///|
/// 调压器：受控母线 2，初始 0 档，档位 −6…+6，每档 2%，目标 0.99 pu，死区 ±0.01。
fn oltc() -> @dist.Oltc raise {
  match @dist.Oltc::new(2, 0, -6, 6, 0.02, 0.99, 0.01) {
    Ok(o) => o
    Err(e) => fail(e)
  }
}

///|
fn main raise {
  let net = tx_feeder()
  let topo = match @dist.build_topology(net) {
    Ok(t) => t
    Err(e) => fail("topology error: " + e.describe())
  }
  report("恒功率 (α=1)", net, topo, @model.Zip::constant_power())
  let mixed = match @model.Zip::new(0.5, 0.2, 0.3) {
    Ok(z) => z
    Err(e) => fail(e)
  }
  report("混合 (α=0.5 β=0.2 γ=0.3)", net, topo, mixed)
  report("恒阻抗 (γ=1)", net, topo, @model.Zip::constant_impedance())
}
