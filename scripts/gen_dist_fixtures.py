#!/usr/bin/env python3
"""为 dist 包的三相不平衡算例生成独立基准。

Python 侧独立实现三相前推回代（BFS），参数与 `dist/cases.mbt` 的
`case_four_node()` 一一对应；不读取、不导入 MoonBit 的输出。

输出为可直接粘进 dist/fixtures_test.mbt 的 MoonBit 断言。
本机沙箱不允许脚本写 03-竞赛 下的文件，所以只打印。
"""

import cmath
import math
import sys

# 与 cases.mbt 完全一致
Z = complex(0.01, 0.02)
LOADS = {
    2: (complex(0.10, 0.03), complex(0.05, 0.02), complex(0.03, 0.01)),
    3: (complex(0.06, 0.02), complex(0.0, 0.0), complex(0.02, 0.005)),
    4: (complex(0.0, 0.0), complex(0.0, 0.0), complex(0.04, 0.015)),
}
ROOT_V = (
    cmath.rect(1.0, 0.0),
    cmath.rect(1.0, -2 * math.pi / 3),
    cmath.rect(1.0, 2 * math.pi / 3),
)
EDGES = [(1, 2), (2, 3), (2, 4)]
TOL = 1e-12
MAX_ITER = 200


def bfs_sweep():
    parent = {1: None}
    children = {1: [], 2: [], 3: [], 4: []}
    order = [1]
    queue = [1]
    while queue:
        u = queue.pop(0)
        for (a, b) in EDGES:
            v = None
            if a == u:
                v = b
            elif b == u:
                v = a
            if v is not None and v not in parent:
                parent[v] = u
                children[u].append(v)
                order.append(v)
                queue.append(v)
    v = {1: ROOT_V, 2: ROOT_V, 3: ROOT_V, 4: ROOT_V}
    i_branch = {e: (0j, 0j, 0j) for e in EDGES}
    edge_of = {}
    for (a, b) in EDGES:
        edge_of[b] = (a, b)
    for it in range(1, MAX_ITER + 1):
        # 回代：叶子到根
        for u in reversed(order):
            if u == 1:
                continue
            vu = v[u]
            s = LOADS[u]
            i_load = tuple((s[k] / vu[k]).conjugate() for k in range(3))
            total = list(i_load)
            for ch in children[u]:
                pe = edge_of[ch]
                total = [total[k] + i_branch[pe][k] for k in range(3)]
            i_branch[edge_of[u]] = tuple(total)
        # 前推：根到叶子
        max_dv = 0.0
        for u in order:
            if u == 1:
                continue
            p = parent[u]
            pe = edge_of[u]
            i = i_branch[pe]
            v_new = tuple(v[p][k] - Z * i[k] for k in range(3))
            dv = max(abs(v_new[k] - v[u][k]) for k in range(3))
            max_dv = max(max_dv, dv)
            v[u] = v_new
        if max_dv < TOL:
            return it, v
    raise RuntimeError("did not converge")


def main():
    it, v = bfs_sweep()
    print("// iters=%d  tol=%g" % (it, TOL))
    lines = []
    for bus in (2, 3, 4):
        idx = {2: 1, 3: 2, 4: 3}[bus]
        for ph, k in (("a", 0), ("b", 1), ("c", 2)):
            z = v[bus][k]
            lines.append(
                "      // bus%d phase %s\n"
                "      assert_true(approx_equal(v[%d].%s.re, %r, 1e-9))\n"
                "      assert_true(approx_equal(v[%d].%s.im, %r, 1e-9))"
                % (bus, ph, idx, ph, z.real, idx, ph, z.imag)
            )
    print("\n".join(lines))
    print("@@@ITERS@@@ %d" % it)


if __name__ == "__main__":
    sys.exit(main())
