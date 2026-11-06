# moon-power-flow

纯 MoonBit 编写的小型交流网络潮流数值内核，首发算法为高斯-赛德尔（Gauss-Seidel，GS）。
定位是教材级、可单测、可对照手算的求解器内核：只做复数四则、三角函数与迭代数值计算，
不绑定电力软件，不使用 C FFI，不依赖外部原生库。

> 边界声明：本仓库首发只覆盖「1 个 Slack + 若干 PQ」的小网络；牛顿法、PV 节点、
> 对地充电导纳等内容只写在「计划中」一节，不作为已实现能力对外描述。

## 快速开始

本机工具链：moon 0.1.20261012（moonc v0.10.15）。下列命令在仓库根目录执行，
验证时显式指定后端，避免默认目标在本机环境缺预编译产物时产生歧义。

| 目的 | 命令 |
|---|---|
| 静态检查（native，警告即错误） | `moon check --target native --deny-warn` |
| 运行测试（native） | `moon test --target native` |
| 静态检查（wasm-gc） | `moon check --target wasm-gc --deny-warn` |
| 运行测试（wasm-gc） | `moon test --target wasm-gc` |
| 运行内置算例演示（native） | `moon run examples/demo --target native` |

CI（`.github/workflows/ci.yml`）起步只配置 wasm-gc 的 check 与 test，不宣称覆盖全部后端。

## 包结构

```text
moon-power-flow/
├── model/      母线类型、母线、支路、网络结构；网络一致性校验与结构化错误
├── ybus/       支路串联导纳换算与节点复导纳矩阵 Ybus 组装
├── solver/     GS 迭代求解、收敛判据、迭代上限保护、支路复功率潮流与损耗
├── cases/      内置三节点算例与默认收敛参数
└── examples/demo/  可执行示例：求解并打印迭代次数、电压、相角与支路潮流
```

## 单位、基准值与容差

- 全部电量为标幺值（p.u.）；内置算例基准容量 `S_B = 100 MVA`，电压基准按统一标称值折算。
- 阻抗 `z = r + jx`，导纳 `y = 1/z = (r - jx)/|z|^2`；注入功率约定 `S = P + jQ`，
  负荷以负净注入表示。
- GS 收敛判据：一轮扫描内全部 PQ 节点「复电压新旧差值的模长」最大值小于阈值；
  内置算例默认 `tol = 1e-8` p.u.，默认 `max_iter = 500`。
- 测试容差：Ybus 元素对人手算结果采用绝对容差 `1e-9`；收敛后电压幅值对照独立参考解采用 `1e-6` p.u.。
- 浮点结果在不同后端可能有末位差异，断言一律走容差比较，不做字符串级相等判断。

## 已实现

- `model`
  - `BusType`：Slack、PQ；PV 仅作枚举预留，本轮不实现 PV 求解。
  - `Bus`、`Branch`、`Network` 数据结构与只读访问接口。
  - 网络校验：母线编号唯一、Slack 恰好一个、支路两端点存在、支路串联阻抗非零；
    失败返回 `Result[Network, NetErr]`，不 panic、不用断言中断。
- `ybus`
  - 支路串联导纳 `y = 1/z`。
  - Ybus 对角元为相连支路导纳之和，非对角元为对应支路导纳取负，矩阵对称。
- `solver`
  - GS 平坦启动（PQ 初值 `1.0 + j0`，Slack 取固定电压）。
  - 最大电压偏差阈值收敛；迭代次数达到 `max_iter` 仍未收敛返回结构化 `NotConverged`。
  - 收敛电压下支路两端复功率与串联损耗计算。
- `cases`
  - 一个内置三节点算例：Slack 母线 1，PQ 母线 2、3，三条串联支路，参数与 Ybus 手算测试一致。
- `examples/demo`
  - 打印收敛扫描次数、各母线电压幅值与相角（度）、各支路两端有功/无功与损耗。

## 已验证（本机实测，2026-11-06）

- `moon check --target native --deny-warn`：退出码 0。
- `moon test --target native`：Total 15，passed 15，failed 0。
- `moon check --target wasm-gc --deny-warn`：退出码 0。
- `moon test --target wasm-gc`：Total 15，passed 15，failed 0。
- `moon check --target js --deny-warn` 与 `moon test --target js` 本机亦为 15/15；
  js 未写入 CI 配置，仅作本机可行性记录。
- 内置算例 native 演示：GS 用 8 次扫描收敛；Slack 保持 `1.0∠0°`；
  PQ 母线 2 约 `0.98852∠-0.6882°`，PQ 母线 3 约 `0.98238∠-1.0743°`（p.u.）。
- Ybus 期望值由独立手算给出（三条支路导纳与六个矩阵元素写死在 `ybus/ybus_test.mbt`），
  不由本库运行结果反向填充。
- 收敛电压幅值另用一份独立 Python GS 脚本（纯标准库、不入库）交叉核对，
  与本库输出在 `1e-6` 量级一致；脚本只作参考，不构成运行依赖。

## 计划中（本轮未实现，不计入已交付）

- 牛顿-拉夫逊（NR）求解器与极坐标雅可比矩阵。
- PV 节点：无功限值、越界转 PQ、PV 电压固定逻辑。
- 线路对地充电导纳、π 型等效支路参数扩展。
- 配电网前推回代、环网特殊处理、稀疏矩阵大规模网络、三相不平衡与谐波。
- 状态估计、最优潮流、数据库持久化、GUI、实时仿真与硬件接口。
- 更多教材算例、js 后端 CI 接入、发布 mooncakes 包（本轮不发布）。

## 输入校验与失败路径覆盖

| 失败情形 | 返回结构 | 覆盖位置 |
|---|---|---|
| 缺少 Slack | `Err(NoSlack)` | `model/validate_test.mbt` |
| Slack 多于一个 | `Err(MultipleSlack(n))` | `model/validate_test.mbt` |
| 母线编号重复 | `Err(DuplicateId(id))` | `model/validate_test.mbt` |
| 支路端点不存在 | `Err(UnknownEndpoint(k, id))` | `model/validate_test.mbt` |
| 支路阻抗为零复数 | `Err(ZeroImpedance(k))` | `model/validate_test.mbt` |
| GS 达到迭代上限未收敛 | `Err(NotConverged(iter, last_dV))` | `solver/solver_test.mbt` |

## 已知限制与适用边界

- 只适用于参数温和的小网络；高阻比、接近病态或拓扑复杂的网络可能收敛慢或不收敛，
  此时以结构化失败结果返回，不保证给出可用电压。
- 本轮不含调度端发电机极限与负荷静特性，母线注入功率为给定常数。
- 复数类型为本库在 `model` 内自建的轻量记录，只覆盖求解所需运算，不追求通用数学库完整度。
- 未做稀疏存储，节点数增大后采用稠密 `n×n` 矩阵，不面向大规模系统。

## 查重状态

本轮未执行 `moon search` 联网查重，也未核对第三方模块的能力边界；
「是否与已有 MoonBit 潮流 / 矩阵包重叠」属于未核实结论，提交申报前必须补查并据实写差异；
本 README 不对模块稀缺性或新颖性下结论。

## 许可证

MIT，详见 `LICENSE`。
