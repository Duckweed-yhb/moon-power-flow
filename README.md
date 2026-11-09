# moon-power-flow

[English](./README.en.md)

纯 MoonBit 写的**三相不平衡配电网前推回代**潮流内核，面向配电级辐射状网络：
每相独立负荷、支路用 3x3 复阻抗矩阵（保留相间互阻抗），不假设三相平衡。

同仓库保留一个**单相平衡高斯-赛德尔（GS）求解器**作为对照基线，用来展示
「同一组网络参数下，平衡假设会漏掉什么」。两条线各自独立成包、各自有测试。

> 边界声明：三相侧首发只覆盖「单个根（变电站出口）+ 辐射状树形拓扑」，
> 不含环网、四线中性线、负荷静特性与 PV 节点。单相侧只做 1 Slack + 若干 PQ。
> 计划项在「计划中」一节，不写成已实现。

> 已发布：`Duckweed/moon-power-flow@0.1.1`（2026-11-09），`moon add Duckweed/moon-power-flow` 可安装。

## 快速开始

本机工具链：moon 0.1.20261012（moonc v0.10.15）。下列命令在仓库根目录执行，
验证时显式指定后端，避免默认目标在本机环境缺预编译产物时产生歧义。

| 目的 | 命令 |
|---|---|
| 安装到其他 MoonBit 项目 | `moon add Duckweed/moon-power-flow@0.1.0` |
| 静态检查（native，警告即错误） | `moon check --target native --deny-warn` |
| 运行测试（native） | `moon test --target native` |
| 静态检查（wasm-gc） | `moon check --target wasm-gc --deny-warn` |
| 运行测试（wasm-gc） | `moon test --target wasm-gc` |
| 三相配电示例（native） | `moon run examples/dist_demo --target native` |
| 单相平衡示例（native） | `moon run examples/demo --target native` |

CI（`.github/workflows/ci.yml`）起步只配置 wasm-gc 的 check 与 test，
不宣称覆盖全部后端。

## 包结构

```text
moon-power-flow/
├── dist/       三相不平衡配电网：相量、3x3 阻抗矩阵、辐射状拓扑校验、前推回代
├── model/      单相平衡模型：母线、支路、网络；一致性校验与结构化错误
├── ybus/       单相节点复导纳矩阵 Ybus 组装
├── solver/     单相 GS 迭代求解、收敛判据、支路复功率潮流与损耗
├── cases/      单相内置三节点算例与默认收敛参数
├── examples/demo/        单相 GS 示例
└── examples/dist_demo/   三相前推回代示例
```

## 单位、基准值与容差

- 全部电量为标幺值（p.u.）；内置算例基准容量 `S_B = 100 MVA`，
  三相侧基准相电压取 230 V（`S_base = 1.0` 时 1.0 p.u. 电压对应 230 V 相电压）。
- 阻抗 `z = r + jx`，导纳 `y = 1/z`；注入功率约定 `S = P + jQ`。
- 单相 GS：负荷以负净注入表示，节点电流 `I_i = conj(S_i) / conj(V_i)`；
  收敛判据为一轮扫描内全部 PQ 节点复电压最大模差小于阈值。
- 三相前推回代：负荷以「取用为正」填写，回代电流 `I_load = conj(S_load / V)`，
  前推 `V_to = V_from − Z · I_branch`；收敛判据为非根节点三相复电压最大模差。
- 测试容差：Ybus 元素对人手算结果 `1e-9`；三相电压与独立 Python 前推回代对照
  `1e-9`；单相收敛电压锚点 `1e-6`。浮点结果不同后端有末位差异，断言一律走容差。

## 已实现

### 三相不平衡（`dist/`，主线）

- `Phasor`：a/b/c 三相复相量，支持逐相加减、共轭、按相除、最大模长。
- `Z3`：对称 3x3 复阻抗矩阵（三个自阻抗 + 三个互阻抗），矩阵乘相量得到三相压降。
- 辐射状校验（`build_topology`）：编号唯一、根存在、端点存在、边数 = 节点数 − 1、
  根可达全部节点；失败返回结构化 `TopoErr`，不 panic。
- BFS 拓扑序、父边、父节点、子节点表；回代用逆序、前推用正序。
- 前推回代（`sweep`）：平坦启动、三相耦合电压降、收敛判据、迭代上限；
  不收敛返回 `SweepErr::NotConverged`。
- 三个内置算例：四节点不平衡、四节点平衡（三相退化检查）、带互阻抗的两节点。

### 单相平衡（`model/` + `ybus/` + `solver/`，对照）

- 母线类型 Slack / PQ（PV 仅枚举预留）、网络校验与结构化 `NetErr`。
- Ybus 组装：对角元为相连支路导纳之和，非对角元取负。
- GS 迭代、收敛判据、迭代上限、支路复功率与损耗。
- 一个三节点算例与 GS 示例。

## 已验证（本机实测，2026-11-07）

- `moon test --target native` / `wasm-gc` / `js`：**25/25**，三后端一致。
- `moon check --target native --deny-warn`、`--target js --deny-warn`：0 警告。
- 三相示例（`moon run examples/dist_demo --target native`，也跑过 js）：
  四节点不平衡算例 4 次扫描收敛，`max |dV| ≈ 4.6e-10`；
  母线 2 三相电压约 `0.9974 pu @ -0.16°`、`0.9991 pu @ -120.05°`、`0.9985 pu @ 119.91°`
  ——三相不再相等，正是平衡假设会抹掉的部分。
- 独立基准：四节点算例的 24 个电压分量由 `scripts/gen_dist_fixtures.py`
  （Python 独立实现前推回代）算出并写死在 `dist/fixtures_test.mbt`，
  不取自本库输出。
- 单相侧：三节点算例 GS 8 次扫描收敛，Ybus 期望值由手算给出。
- 发布：`Duckweed/moon-power-flow@0.1.0` 已于 2026-11-08 上线 mooncakes（Latest 0.1.0，MIT）；2026-11-08 本地复跑 native / wasm-gc / js 三后端 `moon test` 均 25/25，`--deny-warn` 严格检查通过。

## 计划中（本轮未实现，不计入已交付）

- 四线制中性线、三相四线负荷模型与中性点位移。
- 环网 / 弱环网处理、多根（多电源）配电网。
- 分布式电源（PV 型节点）与无功限值。
- 牛顿-拉夫逊与连续潮流（电压崩溃裕度）。GitHub 参考实现 `Zcxssxx/gridflow`（未发布 mooncakes）覆盖平衡正序 NR，本项目优先做配电侧不平衡差异方向。
- IEEE 123 / 34 节点等标准算例、稀疏存储、大规模网络。
- js 后端 CI 接入（当前 CI 仅 wasm-gc；本地 js 测试已实测通过，尚未接入 CI）。

## 输入校验与失败路径覆盖

| 失败情形 | 返回结构 | 覆盖位置 |
|---|---|---|
| 单相：缺少 Slack | `Err(NoSlack)` | `model/validate_test.mbt` |
| 单相：Slack 多于一个 | `Err(MultipleSlack(n))` | `model/validate_test.mbt` |
| 单相：母线编号重复 | `Err(DuplicateId(id))` | `model/validate_test.mbt` |
| 单相：支路端点不存在 | `Err(UnknownEndpoint(k, id))` | `model/validate_test.mbt` |
| 单相：支路阻抗为零 | `Err(ZeroImpedance(k))` | `model/validate_test.mbt` |
| 单相：GS 不收敛 | `Err(NotConverged(iter, dV))` | `solver/solver_test.mbt` |
| 三相：根不存在 | `Err(RootNotFound)` | `dist/dist_test.mbt` |
| 三相：母线编号重复 | `Err(DuplicateNodeId(id))` | `dist/dist_test.mbt` |
| 三相：有环（边数 ≠ n−1） | `Err(NotRadial)` | `dist/dist_test.mbt` |
| 三相：图不连通 | `Err(Disconnected(id))` | `dist/dist_test.mbt` |
| 三相：前推回代不收敛 | `Err(NotConverged(iter, dV))` | `dist/dist_test.mbt` |

## 已知限制与适用边界

- 三相侧只适用于辐射状树形网络；环网、弱环网需要另行处理，当前直接拒绝。
- 只建模三相三线、恒功率负荷；没有中性线，因此不覆盖单相接地导致的中性点位移。
- 未做稀疏存储，节点数增大后采用稠密矩阵，不面向大规模系统。
- 单相侧只适用于参数温和的小网络；高阻比或接近病态时可能不收敛，返回结构化失败。
- 复数类型为本库自建的轻量记录，只覆盖求解所需运算，不追求通用数学库完整度。

## 查重状态（2026-11-09 实测）

- `moon search loadflow`：无模块。
- `moon search power`：命中 `SupremeHuaji/MoonElec@0.1.0`，电气工程公式库（电路、三相功率、变压器、电机、信号与控制）。它是公式计算集合，不含网络拓扑、Ybus 组装或迭代潮流求解，与本库不重合。
- GitHub 公开仓库 `Zcxssxx/gridflow`（https://github.com/Zcxssxx/gridflow ，Apache-2.0）：MoonBit 写的平衡正序 AC 潮流库，极坐标牛顿-拉夫逊，PQ/PV/slack，MATPOWER case 文件子集，PGLib-OPF 14/30/118 母线验证；该仓库尚未发布到 mooncakes.io（`moon view Zcxssxx/gridflow` 返回 404，`moon search gridflow` 无命中）。它对应**平衡正序**方向，与本库三相不平衡主线不同。
- 差异：本库主线是**三相不平衡配电**（每相独立负荷、3x3 相间耦合阻抗、辐射状前推回代），gridflow 明确不覆盖 unbalanced distribution models；单相 GS 部分只作对照基线，不作为主卖点。

## 许可证

MIT，详见 `LICENSE`。
