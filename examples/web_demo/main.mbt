///|
/// examples/web_demo — 浏览器演示的数据侧。
///
/// 四个面板：四节点算例的三相电压幅值与不平衡度、缺相支路下的三相电压、
/// 负荷倍率网格、分接头网格。每一条都走 dist/ 里的 build_topology + sweep，
/// 页面只负责画，不重写公式。
///
/// 后两个面板是参数网格：构建时把每一档都算完，页面滑块只切档。
/// 输出协议：`META {...}` 一行放求解口径，`DATA {...}` 每行一个面板。

///|
fn jnum(x : Double) -> String {
  let q = (x * 10000.0).round()
  let v = q / 10000.0
  if v == 0.0 {
    "0"
  } else {
    v.to_string()
  }
}

///|
fn jarr(xs : Array[Double]) -> String {
  let mut s = "["
  let mut i = 0
  while i < xs.length() {
    if i > 0 {
      s = s + ","
    }
    s = s + jnum(xs[i])
    i = i + 1
  }
  s + "]"
}

///|
/// 把若干行（每行已经拼成 `[...]`）串成一个二维 JSON 数组。
fn jrows(rows : Array[String]) -> String {
  let mut s = "["
  let mut i = 0
  while i < rows.length() {
    if i > 0 {
      s = s + ","
    }
    s = s + rows[i]
    i = i + 1
  }
  s + "]"
}

///|
/// 把一个解的逐母线三相幅值摊平成三条数组，顺便给出不平衡度。
fn phase_columns(r : @dist.SweepOk) -> (String, String, String, String, Int32) {
  let vs = r.voltages()
  let va : Array[Double] = []
  let vb : Array[Double] = []
  let vc : Array[Double] = []
  let vuf : Array[Double] = []
  let mut i = 0
  while i < vs.length() {
    va.push(@model.cx_abs(vs[i].a()))
    vb.push(@model.cx_abs(vs[i].b()))
    vc.push(@model.cx_abs(vs[i].c()))
    vuf.push(@dist.voltage_unbalance_percent(vs[i]))
    i = i + 1
  }
  (jarr(va), jarr(vb), jarr(vc), jarr(vuf), r.iter())
}

///|
/// 只留 a 相与不平衡度两列，给参数网格用。
fn va_vuf_columns(r : @dist.SweepOk) -> (String, String, Int32) {
  let vs = r.voltages()
  let va : Array[Double] = []
  let vuf : Array[Double] = []
  let mut i = 0
  while i < vs.length() {
    va.push(@model.cx_abs(vs[i].a()))
    vuf.push(@dist.voltage_unbalance_percent(vs[i]))
    i = i + 1
  }
  (jarr(va), jarr(vuf), r.iter())
}

///|
/// 按倍率缩放所有非根节点的注入功率，重建一个网。
/// 根节点是电压源，缩放它会改掉边界条件，所以跳过。
fn with_load_scale(base : @dist.DistNet, k : Double) -> @dist.DistNet {
  let nodes : Array[@dist.DistNode] = []
  for n in base.nodes() {
    if n.id() == base.root_id() {
      nodes.push(n)
    } else {
      nodes.push(@dist.DistNode::make(n.id(), n.s().scale(k)))
    }
  }
  let edges : Array[@dist.DistEdge] = []
  let mut i = 0
  while i < base.edge_count() {
    edges.push(base.edge_at(i))
    i = i + 1
  }
  @dist.DistNet::make(nodes, edges, base.root_id(), base.v_root())
}

///|
/// 四节点算例：一条馈线上两个负荷，三相负荷不对称。
fn panel_four() -> String {
  let net = @dist.case_four_node()
  match @dist.build_topology(net) {
    Err(e) => "ERR " + e.describe()
    Ok(topo) =>
      match @dist.sweep(net, topo, 0.000000001, 100) {
        Err(e) => "ERR " + e.describe()
        Ok(r) => {
          let (va, vb, vc, vuf, iter) = phase_columns(r)
          "DATA {\"panel\":\"four\",\"va\":" +
          va +
          ",\"vb\":" +
          vb +
          ",\"vc\":" +
          vc +
          ",\"vuf\":" +
          vuf +
          ",\"iter\":" +
          iter.to_string() +
          "}"
        }
      }
  }
}

///|
/// 缺相支路：某条支路的 a 相断开，下游该相电压为零，另外两相按平衡关系重算。
fn panel_open() -> String {
  let net = @dist.case_with_open_phase()
  match @dist.build_topology(net) {
    Err(e) => "ERR " + e.describe()
    Ok(topo) =>
      match @dist.sweep(net, topo, 0.000000001, 100) {
        Err(e) => "ERR " + e.describe()
        Ok(r) => {
          let (va, vb, vc, vuf, iter) = phase_columns(r)
          "DATA {\"panel\":\"open\",\"va\":" +
          va +
          ",\"vb\":" +
          vb +
          ",\"vc\":" +
          vc +
          ",\"vuf\":" +
          vuf +
          ",\"iter\":" +
          iter.to_string() +
          "}"
        }
      }
  }
}

///|
/// 负荷倍率网格：四节点算例的注入功率按 0.5 / 1.0 / 1.5 / 2.0 / 2.5 倍缩放，
/// 每档重建一次网（DistNode::make + Phasor::scale），再跑一遍 sweep。
fn panel_load_grid() -> String {
  let base = @dist.case_four_node()
  let ks : Array[Double] = [0.5, 1.0, 1.5, 2.0, 2.5]
  let va_rows : Array[String] = []
  let vuf_rows : Array[String] = []
  let iters : Array[Double] = []
  for k in ks {
    let net = with_load_scale(base, k)
    let topo = match @dist.build_topology(net) {
      Err(e) => return "ERR " + e.describe()
      Ok(t) => t
    }
    match @dist.sweep(net, topo, 0.000000001, 100) {
      Err(e) => return "ERR " + e.describe()
      Ok(r) => {
        let (va, vuf, iter) = va_vuf_columns(r)
        va_rows.push(va)
        vuf_rows.push(vuf)
        iters.push(iter.to_double())
      }
    }
  }
  "DATA {\"panel\":\"load\",\"k\":" +
  jarr(ks) +
  ",\"va\":" +
  jrows(va_rows) +
  ",\"vuf\":" +
  jrows(vuf_rows) +
  ",\"iter\":" +
  jarr(iters) +
  "}"
}

///|
/// 分接头网格：1 -变压器-> 2，档位 −4..+4，步进 1.25%。
/// 每档换一个变比重建网，记录各母线 a 相电压、不平衡度与迭代数。
fn panel_tap_grid() -> String {
  let base = @dist.case_with_transformer()
  let topo = match @dist.build_topology(base) {
    Err(e) => return "ERR " + e.describe()
    Ok(t) => t
  }
  let tap : Array[Double] = []
  let ratio : Array[Double] = []
  let va_rows : Array[String] = []
  let vuf_rows : Array[String] = []
  let iters : Array[Double] = []
  let mut t = -4
  while t <= 4 {
    let k = 1.0 + t.to_double() * 0.0125
    let edges = [base.edge_at(0).with_ratio(k)]
    let net = @dist.DistNet::make(
      base.nodes(),
      edges,
      base.root_id(),
      base.v_root(),
    )
    match @dist.sweep(net, topo, 0.000000001, 100) {
      Err(e) => return "ERR " + e.describe()
      Ok(r) => {
        let (va, vuf, iter) = va_vuf_columns(r)
        tap.push(t.to_double())
        ratio.push(k)
        va_rows.push(va)
        vuf_rows.push(vuf)
        iters.push(iter.to_double())
      }
    }
    t = t + 1
  }
  "DATA {\"panel\":\"tap\",\"tap\":" +
  jarr(tap) +
  ",\"ratio\":" +
  jarr(ratio) +
  ",\"va\":" +
  jrows(va_rows) +
  ",\"vuf\":" +
  jrows(vuf_rows) +
  ",\"iter\":" +
  jarr(iters) +
  "}"
}

///|
fn main {
  println(
    "META {\"tol\":0.000000001,\"max_iter\":100,\"grid_load\":5,\"grid_tap\":9,\"tap_step\":0.0125}",
  )
  println(panel_four())
  println(panel_open())
  println(panel_load_grid())
  println(panel_tap_grid())
}
