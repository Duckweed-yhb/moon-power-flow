// dist/topology.mbt — 辐射状校验与遍历顺序。
//
// 前推回代的正确性依赖两件事：网络是一棵树（唯一路径、无环），以及有一个明确的
// 根（变电站出口）。本包把这两件事变成结构化的校验结果，失败不 panic。

///|
/// 拓扑校验失败原因。
pub enum TopoErr {
  /// 根母线编号在节点表里不存在。
  RootNotFound
  /// 母线外部编号重复。
  DuplicateNodeId(Int32)
  /// 支路端点引用了不存在的母线编号。
  UnknownEndpoint(Int32)
  /// 支路数不等于 节点数 - 1：一定不是树（有环或缺边）。
  NotRadial
  /// 从根出发无法到达该母线。
  Disconnected(Int32)
}

///|
pub fn TopoErr::describe(self : TopoErr) -> String {
  match self {
    RootNotFound => "root bus not found"
    DuplicateNodeId(id) => "duplicate node id " + id.to_string()
    UnknownEndpoint(id) => "branch references unknown node id " + id.to_string()
    NotRadial => "branch count != node count - 1, network is not radial"
    Disconnected(id) => "node " + id.to_string() + " is not reachable from root"
  }
}

///|
/// 校验通过后的拓扑：BFS 序、每节点父边、每节点父节点、每节点子节点。
pub struct Topology {
  order : Array[Int32]
  parent_edge : Array[Int32]
  parent : Array[Int32]
  children : Array[Array[Int32]]
}

///|
/// BFS 访问顺序（根在前，存内部下标）。
pub fn Topology::order(self : Topology) -> Array[Int32] {
  self.order
}

///|
/// 每个节点的父支路下标，根为 -1。
pub fn Topology::parent_edge(self : Topology) -> Array[Int32] {
  self.parent_edge
}

///|
/// 每个节点的父节点内部下标，根为 -1。
pub fn Topology::parent(self : Topology) -> Array[Int32] {
  self.parent
}

///|
/// 每个节点的子节点内部下标。
pub fn Topology::children(self : Topology) -> Array[Array[Int32]] {
  self.children
}

///|
/// 校验网络并生成拓扑。规则：
///   1. 母线编号唯一；
///   2. 根编号存在；
///   3. 支路两端编号都存在；
///   4. 支路数 = 节点数 - 1（树）；
///   5. 从根可达全部节点（连通）。
pub fn build_topology(net : DistNet) -> Result[Topology, TopoErr] {
  let n = net.node_count()
  if n == 0 {
    return Err(RootNotFound)
  }
  // 1. 编号唯一
  let mut i = 0
  while i < n {
    let mut j = i + 1
    while j < n {
      if net.node_at(i).id() == net.node_at(j).id() {
        return Err(DuplicateNodeId(net.node_at(i).id()))
      }
      j += 1
    }
    i += 1
  }
  // 2. 根存在
  let root = match net.find_index(net.root_id()) {
    Some(k) => k
    None => return Err(RootNotFound)
  }
  // 3. 端点存在
  let m = net.edge_count()
  let mut k = 0
  while k < m {
    let e = net.edge_at(k)
    match net.find_index(e.from_id()) {
      Some(_) => ()
      None => return Err(UnknownEndpoint(e.from_id()))
    }
    match net.find_index(e.to_id()) {
      Some(_) => ()
      None => return Err(UnknownEndpoint(e.to_id()))
    }
    k += 1
  }
  // 4. 树的条件
  if m != n - 1 {
    return Err(NotRadial)
  }
  // 邻接表：节点 -> [(邻居, 边下标)]
  let adj : Array[Array[(Int32, Int32)]] = []
  for _ in 0..<n {
    adj.push([])
  }
  let mut e = 0
  while e < m {
    let edge = net.edge_at(e)
    let u = match net.find_index(edge.from_id()) {
      Some(x) => x
      None => return Err(UnknownEndpoint(edge.from_id()))
    }
    let v = match net.find_index(edge.to_id()) {
      Some(x) => x
      None => return Err(UnknownEndpoint(edge.to_id()))
    }
    adj[u].push((v, e))
    adj[v].push((u, e))
    e += 1
  }
  // 5. BFS
  let visited : Array[Bool] = []
  for _ in 0..<n {
    visited.push(false)
  }
  let parent_edge : Array[Int32] = []
  for _ in 0..<n {
    parent_edge.push(-1)
  }
  let parent : Array[Int32] = []
  for _ in 0..<n {
    parent.push(-1)
  }
  let children : Array[Array[Int32]] = []
  for _ in 0..<n {
    children.push([])
  }
  let order : Array[Int32] = []
  let queue : Array[Int32] = []
  queue.push(root)
  visited[root] = true
  let mut head = 0
  while head < queue.length() {
    let u = queue[head]
    head += 1
    order.push(u)
    for pair in adj[u] {
      let (v, ei) = pair
      if !visited[v] {
        visited[v] = true
        parent_edge[v] = ei
        parent[v] = u
        children[u].push(v)
        queue.push(v)
      }
    }
  }
  if order.length() != n {
    let mut miss = 0
    let mut found = false
    while miss < n {
      if !visited[miss] {
        found = true
        break
      }
      miss += 1
    }
    let _ = found
    return Err(Disconnected(net.node_at(miss).id()))
  }
  Ok({ order, parent_edge, parent, children, })
}

///|
/// 反向遍历顺序（叶子到根），用于回代阶段累加支路电流。
pub fn Topology::reverse_order(self : Topology) -> Array[Int32] {
  let out : Array[Int32] = []
  let mut i = self.order.length()
  while i > 0 {
    i -= 1
    out.push(self.order[i])
  }
  out
}
