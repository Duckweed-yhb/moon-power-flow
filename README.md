# moon-power-flow

[English](./README.en.md)

纯 MoonBit 写的**三相不平衡配电网前推回代**潮流内核，面向配电级辐射状网络：
每相独立负荷、支路用 3x3 复阻抗矩阵（保留相间互阻抗），不假设三相平衡。

同仓库保留一个**单相平衡高斯-赛德尔（GS）求解器**作为对照基线，用来展示
「同一组网络参数下，平衡假设会漏掉什么」。两条线各自独立成包、各自有测试。

> 边界声明：三相侧首发只覆盖「单个根（变电站出口）+ 辐射状树形拓扑」，
> 不含环网、四线中性线、负荷静特性与 PV 节点。单相侧只做 1 Slack + 若干 PQ。
> 计划项在「计划中」一节，不写成已实现。

> 已发布：`Duckweed/moon-power-flow@0.2.0`（2026-11-10），`moon add Duckweed/moon-power-flow` 可安装。

## 快速开始

本机工具链：moon 0.1.20261104（moonc v0.10.20+65efd5b93）。下列命令在仓库根目录执行，
验证时显式指定后端，避免默认目标在本机环境缺预编译产物时产生歧义。

| 目的 | 命令 |
|---|---|
| 安装到其他 MoonBit 项目 | `moon add Duckweed/moon-power-flow@0.2.0` |
| 静态检查（native，警告即错误） | `moon check --target native --deny-warn` |
| 运行测试（native） | `moon test --target native` |
| 静态检查（wasm-gc） | `moon check --target wasm-gc --deny-warn` |
| 运行测试（wasm-gc） | `moon test --target wasm-gc` |
| 三相配电示例（native） | `moon run examples/dist_demo --target native` |
| 单相平衡示例（native） | `moon run examples/demo --target native` |

CI（`.github/workflows/ci.yml`）跑三件事：`moon fmt --check`；`wasm-gc` / `js` / `native` 三个目标各自的
`check --deny-warn` + `build` + `test`；以及两个示例的 `moon run --target native`。

## 包结构

```text
moon-power-flow/
├── dist/       三相不平衡配电网：相量、3x3 阻抗矩阵、辐射状拓扑校验、前推回代（含 ZIP）、对称分量与 VUF、支路损耗、越限检查、中性点位移
├── model/      共享模型：母线、支路、网络、一致性校验、ZIP 负荷系数
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
- 对称分量与三相电压不平衡度（`dist/unbalance.mbt`）：Fortescue 分解出零序 / 正序 / 负序，
  按 `VUF = |V2|/|V1| × 100%` 给出不平衡度。正序接近零（纯负序、纯零序）时返回 0 而不是
  inf/NaN——浮点残差会把比值放大到 1e17 量级，那个数字没有工程意义。示例 `dist_demo`
  每条母线都会打印 VUF。
- 负荷静特性 ZIP（系数在 `model/zip.mbt`，两侧共用）：`S(V) = S0·(α + β·|V| + γ·|V|²)`。三相侧 `sweep_zip` 逐相按各自电压模长缩放，单相侧 `gauss_seidel_zip` 按节点电压缩放净注入；两侧都是 α=1 时与旧求解同解。三相侧另配 `load_demand_active_zip` 统计按最终电压缩放后的实际取用，功率平衡恒等式照旧成立。
- 中性点位移（`dist/neutral.mbt`，四线制一阶近似）：中性导体与相导体同拓扑，支路中性电流取三相电流之和的相反数。`neutral_voltages` 接受统一中性阻抗，`neutral_voltages_per_edge` 接受逐支路阻抗数组（真机上各段导线截面不同）；`phase_to_neutral` 给负荷端「相对中性点」的相电压。示例里四节点算例的中性点漂移约 `0.0017–0.0026 p.u.`，a 相相对中性点压到 `0.994–0.996 p.u.`、b 相被抬到 `1.0006–1.0014 p.u.` —— 这是三相不平衡配电网里最容易被忽略的一段。
- 支路损耗与功率平衡（`dist/loss.mbt`）：逐相 `S_p = (Z3·I)_p · conj(I_p)`，相间互阻抗
  已包含在 `(Z3·I)` 里；`branch_losses` 给每条支路三相损耗，`total_loss_active` 给全网有功
  损耗，`load_demand_active` / `root_injection_active` 供功率平衡校验。验收判据不是参考数据，
  而是守恒律：根注入 = 负荷需求 + 损耗。四节点算例实测 0.30046496 = 0.3 + 0.00046496，
  残差 −6.5e−11 p.u.。

### 单相平衡（`model/` + `ybus/` + `solver/`，对照）

- 母线类型 Slack / PQ（PV 仅枚举预留）、网络校验与结构化 `NetErr`。
- Ybus 组装：对角元为相连支路导纳之和，非对角元取负。
- GS 迭代、收敛判据、迭代上限、支路复功率与损耗。
- 一个三节点算例与 GS 示例。

## 已验证（本机实测，2026-11-11 复跑）

- `moon test`：wasm / wasm-gc / js / native 四个后端均 **73/73**，四后端一致。
- `moon check --deny-warn` 四个后端：0 警告。
- 三相示例（`moon run examples/dist_demo --target native`，也跑过 js）：
  四节点不平衡算例 4 次扫描收敛，`max |dV| ≈ 4.6e-10`；
  母线 2 三相电压约 `0.9974 pu @ -0.16°`、`0.9991 pu @ -120.05°`、`0.9985 pu @ 119.91°`
  ——三相不再相等，正是平衡假设会抹掉的部分。
- 三相不平衡度（同一次示例输出）：根母线 `VUF ≈ 1.2e-14%`（平衡期望值 0），
  负荷母线 2/3/4 分别约 `0.0756%` / `0.1187%` / `0.0745%`。四个数都来自对称分量
  实时计算，没有写死；平衡母线与不平衡母线在同一张输出里就能对比。
- 独立基准：四节点算例的 24 个电压分量由 `scripts/gen_dist_fixtures.py`
  （Python 独立实现前推回代）算出并写死在 `dist/fixtures_test.mbt`，
  不取自本库输出。
- 单相侧：三节点算例 GS 8 次扫描收敛，Ybus 期望值由手算给出。
- 发布：`Duckweed/moon-power-flow@0.2.0` 已于 2026-11-10 上线 mooncakes（Latest 0.2.0，MIT）；本地 2026-11-11 复跑四个后端 `moon test` 均 73/73，四个目标的 `--deny-warn` 严格检查通过。

## 计划中（本轮未实现，不计入已交付）

- 四线制中性线、三相四线负荷模型与中性点位移。
- 环网 / 弱环网处理、多根（多电源）配电网。
- 分布式电源（PV 型节点）与无功限值。
- 牛顿-拉夫逊与连续潮流（电压崩溃裕度）。GitHub 参考实现 `Zcxssxx/gridflow`（未发布 mooncakes）覆盖平衡正序 NR，本项目优先做配电侧不平衡差异方向。
- IEEE 123 / 34 节点等标准算例、稀疏存储、大规模网络。

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
- 中性点位移是**后处理近似**：中性阻抗按逐支路均匀给定，不考虑负荷的恒功率再分配，也不做多条并联中性导体的分流。它回答「会不会漂、漂多少」，不替代完整的四线制潮流。
- 只建模三相三线、恒功率负荷；没有中性线，因此不覆盖单相接地导致的中性点位移。
- 未做稀疏存储，节点数增大后采用稠密矩阵，不面向大规模系统。
- 单相侧只适用于参数温和的小网络；高阻比或接近病态时可能不收敛，返回结构化失败。
- 复数类型为本库自建的轻量记录，只覆盖求解所需运算，不追求通用数学库完整度。
- `VUF` 的「正序接近零」判据是**绝对量** `1e-12 p.u.`：整网电压被压到 1e-6 p.u. 以下时，真实存在的不平衡也会被report 成 0。实际配电网络不会到这个量级，但做极端参数扫描时要留意。

## 查重状态（2026-11-10 实测）

- `moon search loadflow`：无模块。
- `moon search power`：命中 `SupremeHuaji/MoonElec@0.1.0`，电气工程公式库（电路、三相功率、变压器、电机、信号与控制）。它是公式计算集合，不含网络拓扑、Ybus 组装或迭代潮流求解，与本库不重合。
- GitHub 公开仓库 `Zcxssxx/gridflow`（https://github.com/Zcxssxx/gridflow ，Apache-2.0）：MoonBit 写的平衡正序 AC 潮流库，极坐标牛顿-拉夫逊，PQ/PV/slack，MATPOWER case 文件子集，PGLib-OPF 14/30/118 母线验证；该仓库尚未发布到 mooncakes.io（`moon view Zcxssxx/gridflow` 返回 404，`moon search gridflow` 无命中）。它对应**平衡正序**方向，与本库三相不平衡主线不同。
- 差异：本库主线是**三相不平衡配电**（每相独立负荷、3x3 相间耦合阻抗、辐射状前推回代），gridflow 明确不覆盖 unbalanced distribution models；单相 GS 部分只作对照基线，不作为主卖点。

## AI 工具使用说明

开发使用了 AI 编程工具，选题、边界与质量由本人把控。

- AI 辅助：包骨架、测试初稿、文档初稿。
- 人工把控：选题转向（平衡正序 GS → 三相不平衡前推回代）、与 gridflow 的差异判断、拓扑校验规则、Python 独立基准的参数与容差设定。
- AI 生成的测试逐条对照教材公式核过断言，三后端全绿才合并。

## 许可证

MIT，详见 `LICENSE`。来源、参考项目、测试数据与 AI 使用范围见 [`PROVENANCE.md`](PROVENANCE.md)。
