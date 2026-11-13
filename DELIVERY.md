# 交付说明（DELIVERY）

这份文件回答一件事：**报名时申报书说的，和仓库现在的实际状态，差在哪。**

申报书是报名存档，不随实现更新；README 和 CHANGELOG 记录实现本身。三者容易出现
三个不同的数字，验收时对方按哪份对都对不上。这里把差异一次写清，包括
「申报书说明确不做、后来做了」的那两项。

- 申报书：`12-知识库/03-竞赛/01-MoonBit黑客松/2026-11/moon-power-flow-申报书.md`
- 本文件对应提交：以仓库 HEAD 为准，最后核对时间见文末

## 一、申报 vs 现在

| 项 | 申报书 | 现在 |
|---|---|---|
| 版本 | 0.1.3 | **0.2.0**（mooncakes 最新） |
| 单测 | 29 | **74**（四个后端各 74） |
| 后端覆盖 | wasm-gc / native / js 三后端 | **wasm / wasm-gc / js / native 四后端** |
| commits | 29 | 58 |
| 包 | `dist/` `model/` `ybus/` `solver/` `cases/` | 同左（包结构未变，包内新增模块） |
| 示例 | `examples/demo`、`examples/dist_demo` | 增加 **`examples/scale_demo`**、**`examples/reject_demo`** |
| CI | check/build/test（wasm-gc）+ native/js 本地实测 | 三目标矩阵 `check --deny-warn` + build + test，三个示例真跑，发布元数据校验 |

## 二、申报之后新增了什么

1. **对称分量与电压不平衡度**（`dist/unbalance.mbt`）：`symmetrical_components`、
   `voltage_unbalance_percent`（`|V2|/|V1|×100`）、`unbalance_profile`。
2. **支路损耗与功率平衡**（`dist/loss.mbt`）：逐支路复功率损耗、全网有功损耗、
   负荷需求与根注入；根注入按「任一端是根」匹配，与支路存储方向无关。
3. **电压越限检查**（`dist/limits.mbt`）：`voltage_violations`、`voltage_extremes`。
4. **中性点位移**（`dist/neutral.mbt`）：给定统一或逐支路的中性导体阻抗，算中性点
   位移与相—中性点电压。**这是一阶后处理近似**，不参与潮流迭代。
5. **ZIP 负荷静特性**（`model/zip.mbt` + `dist/zip.mbt` + 单相 `solver` ZLS-ZIP）。
6. **收敛轨迹与结构化失败**：`SweepOk::trace()`、`SweepErr` 的 `NonFinite` /
   `InvalidConfig` / `TopologyMismatch`，以及 `tol`、`ZIP` 系数的入口校验。
7. **规模实测**：5000 节点链式馈线 5 次扫描收敛，端到端 1.16 s（`examples/scale_demo`）。

## 三、与申报书「明确不做」对不上的两处（主动说明）

申报书第 36 行原文：「明确不做：环网与弱环网（拓扑校验直接拒绝）、**三相四线制与中性线**、
PV 节点与无功限值、…」；同段第 3 条还提到不含「负荷静特性」。现在的实际状态：

| 申报书 | 现状 | 边界说明 |
|---|---|---|
| 不做三相四线制与中性线 | `dist/neutral.mbt` 算**中性点位移** | 只解一个后处理量：给定中性导体阻抗求 `V_n` 与相—中性点电压；不把中性线放进潮流方程，不是完整四线制模型 |
| 不含负荷静特性 | `model/zip.mbt` 支持 ZIP（恒功率/恒电流/恒阻抗） | 只有这三项静特性，不含负荷时变曲线、不含温控/电压调节类负荷模型 |

这两项都是「做了申报说没做的子集」。判断是：它们是求解器的自然延伸、且都有测试与文档，
属于加分而不是方向漂移；但**必须写在这里**，否则对照表读起来像承诺不符。

## 四、验证证据（可复现）

```bash
moon check --deny-warn --target native     # 四个目标逐个跑，下同
moon test --target native                  # 74/74
moon run examples/dist_demo --target native    # 四节点不平衡算例
moon run examples/scale_demo --target native   # 4 → 5000 节点
moon run examples/reject_demo --target native  # 每条拒绝路径
```

- 期望值**不取自本库输出**：`scripts/gen_dist_fixtures.py` 用 Python 复数独立实现一遍
  前推回代，把四节点算例 18 个电压分量写死在 `dist/fixtures_test.mbt`，容差 1e-9。
- 规模：5000 节点 5 次扫描收敛（判据 1e-9），实测 1.16 s；三相侧是线性的，
  真正瓶颈在单相侧的稠密 Ybus（O(n²)）。

## 五、发布状态

- mooncakes：`Duckweed/moon-power-flow@0.2.0`（Latest；`Zip` 从 `@dist.Zip` 移到
  `@model.Zip`，是 0.x 允许的破坏性变更）。
- GitHub tag 只到 **v0.1.3**，落后 11 个已发布版本。**以 mooncakes 上的版本为准**。

## 六、当前边界（不做的事）

环网 / 弱环网、多根配电网、PV 节点与无功限值、完整三相四线模型、IEEE 标准算例、
稀疏存储与大规模网络、最优潮流 / 短路 / 动态稳定 / 状态估计。
