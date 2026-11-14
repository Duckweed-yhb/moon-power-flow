///|
/// examples/web_demo — 浏览器演示的数据侧。
///
/// 三个面板：四节点算例的三相电压幅值与不平衡度、缺相支路下的三相电压、
/// 变压器分接头扫描。每一条都走 dist/ 里的 build_topology + sweep，
/// 页面只负责画，不重写公式。
///
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
/// 分接头扫描：1 -变压器-> 2，档位 −4..+4，步进 1.25%，看受控母线电压怎么走。
fn panel_tap() -> String {
  let base = @dist.case_with_transformer()
  let topo = match @dist.build_topology(base) {
    Err(e) => return "ERR " + e.describe()
    Ok(t) => t
  }
  let tap : Array[Double] = []
  let ratio : Array[Double] = []
  let v2 : Array[Double] = []
  let iter : Array[Double] = []
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
        tap.push(t.to_double())
        ratio.push(k)
        v2.push(@model.cx_abs(r.voltages()[1].a()))
        iter.push(r.iter().to_double())
      }
    }
    t = t + 1
  }
  "DATA {\"panel\":\"tap\",\"tap\":" +
  jarr(tap) +
  ",\"ratio\":" +
  jarr(ratio) +
  ",\"v2\":" +
  jarr(v2) +
  ",\"iter\":" +
  jarr(iter) +
  "}"
}

///|
fn main {
  println("META {\"tol\":0.000000001,\"max_iter\":100}")
  println(panel_four())
  println(panel_open())
  println(panel_tap())
}
