# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 与语义化版本。

## [Unreleased]

### Added

- `examples/reject_demo`：把每条拒绝路径打印出来——重复母线编号、未知端点、环网、不连通、
  根不存在、`tol=0`/`+inf`、迭代上限为 0、拓扑来自另一张网、ZIP 系数和不为 1。
  校验逻辑一直存在，但只在测试与源码里能看见；这个示例让「拒绝」也变成可演示的证据。
- `DELIVERY.md`：申报书（29 测试 / 三后端 / 0.1.3）与现状（74 测试 / 四后端 / 0.2.0）的
  对照，以及申报书「明确不做」里已经做了的两项（中性点位移、ZIP 静特性）的边界说明。
- `dist` 变压器支路：`TxSpec` 非额定变比 + 归算副边漏阻抗；k=1 退化成普通线路；原边电流按 k 折算，复功率守恒，损耗按副边漏阻抗算。
- `dist` OLTC 分接头调压：整数档位与上下限、每档步进、目标电压 + 死区；`run_oltc` 闭环调档入带，控制输入错误返回结构化 `OltcErr::Control`。
- `dist` 逐相投切 / 缺相支路：`Switch` 标记断开相，断开相电流置零、下游该相电压为零，平衡按导通相成立。
- 新增变压器、缺相两个内置算例；新增 `tx_test` / `oltc_test` / `open_test` 对照测试。2026-11-13 四后端 `moon test` 89/89，`--deny-warn` 0 警告。

### Added

- `dist` 组合算例 `case_tx_oltc_open`：线路 → 变压器 → 缺相线路，节点 3 作 OLTC 受控母线。
  变压器、调档、缺相原先各自只在两节点小网里验证过，这张网把它们放在同一条馈线上，
  并用 `dist/combo_test.mbt` 锁两条性质 - 调档能进带，且缺相零电流是开关状态决定的
  （合上后 b 相电流重新出现）。`dist_demo` 后半段打印这条算例的调档轨迹与断开相读数。
- 测试数 92 → 94。
- `examples/dist_demo` 末尾补负荷静特性对比：重载三节点链上同一组负荷换四种 ZIP 构成
  （恒功率 / 恒电流 / 恒阻抗 / 5:3:2 混合），打印末端 `|V3_a|` 与实际取用有功。
  实测 0.96877 / 0.96965 / 0.97046 / 0.96939 p.u.，有功 1.8 / 1.7544 / 1.7123 / 1.7681 p.u.。
  ZIP 一直在库里（`model/zip.mbt` + `dist/zip.mbt`），但示例之前只用恒功率算例，
  审阅时看不出负荷模型确实参与求解；这条把差别摆到输出里。

### Changed

- `run_oltc` 在受控母线 a 相电压为 0 时直接返回 `OltcErr::Control`，不再继续调档。a 相被
  变压器支路断开（缺相）时这一相没有可读电压，旧实现会把它当成欠压、一路升档到上限，
  产出一条看起来正常的调档轨迹。**这是行为变更**：同一张网里受控 a 相断开，以前返回
  `Ok` 且 `tap` 顶到上限，现在返回 `Err`。补一条回归锁住「报错而不是跑满调档次数」。

### Fixed

- 变压器不在根边上时，回代累加漏了原边折算：变压器支路存的是副边侧电流 `I_sec`，
  父节点在原边，累加子支路电流时要按 `I_pri = k·I_sec` 折回。漏掉这一步时上游线路
  电流少一个 `k` 倍，电压迭代照样收敛、损耗照样非负，但根注入与「负荷 + 损耗」对不上
  （`k = 1.05` 时差几个百分点），功率平衡自检才会暴露。已补折算，并加一条
  「线路 → 变压器 → 负荷」的守恒回归（原有变压器用例都挂在根边上，覆盖不到这条路径）。
- 文档的基准容量与源码自相矛盾：README 写 `S_B = 100 MVA`，三相内置算例的注释写 100 kVA。库里没有 Ω→p.u. 折算函数，用户只能照文档算，两种读法的 `Z_B` 差 1000 倍——按 MVA 折算会把真实阻抗算小 1000 倍，压降、损耗、VUF 一起变成 0，而收敛、功率平衡、越限检查全部通过。现在 README（中英）写清两侧各自的基准、两者不共用，并给出折算公式。
- `sweep` 的拓扑守卫只查 `parent_edge >= m`，挡不住「同规模但根下标不同的另一张网的 Topology」：本网根节点拿到的 `parent_edge` 是 -1，回代里 `i_branch[-1]` 直接 panic——而这正是文件头注释承诺「库不该用 panic 报错」要防的那类错。现在逐节点校验「-1 只允许出现在本网根上」。
- 顺着上一条：同规模、同根、但父子关系不同的拓扑仍能通过（根下标一样，只查范围查不出来），回代会沿错误的边累加电流，电压与损耗都错而功率平衡自检照样成立（两边用的是同一份错）。现在逐节点校验父边确实连接 `parent[u]` 与 `u` 的母线编号。
- `tol` 没有校验：`tol = 0` 时判据 `max_dv < 0` 永远不成立（报 `NotConverged`，而实际偏差已经是 0）；`tol = +inf` 时第一轮就判收敛，返回一个明显没收敛的解。`dist/sweep` 与 `solver/gauss_seidel` 现在都拒非正、非有限的 tol（`InvalidConfig`）。
- `Zip::new` 放行 NaN：NaN 与任何数比较恒假，`alpha < 0.0` 与 `(sum-1).abs() > 1e-9` 两条检查都失效，于是构造出一个 `alpha = NaN` 的「合法」Zip，一路带到求解器才炸。现在先挡非有限值。
- 逐相损耗的语义补文档：`(Z·I)_p·conj(I_p)` 的三项之和才是该支路有功损耗（恒非负），**单项可以是负数**——相间互阻抗把耦合功率记到了某一相上，总功率对、分相不对。分相线损考核不能直接拿这三个数。
- `load_demand_active` 补文档：根母线（Slack）上填的负荷不计入，它的电流不经过馈线、求解器也不注入，所以「根注入 = 非根需求 + 损耗」仍然成立，自检看不出异常。
- `SweepErr::describe` / `SolveErr::describe` 的 `InvalidConfig` 仍只写「max_iter must be > 0」：本轮把 tol 也归进同一变体后，`tol=0` 的报错会指向错误的参数。现在两个参数都写进去。
- `solver/flow` 按端点编号查内部下标，查不到时原先回退下标 0，会静默接到首条母线；与 `ybus.bus_index` 的 abort 口径不一致。合法网络端点由 `validate` 规则 3 保证存在，查不到说明 model 层有 bug，现在直接 abort，不再静默错接。

## [0.2.0] - 2026-11-11

### Added

- `dist/zip_test.mbt` 补失败分支：ZIP 路径遇 NaN 负荷同样返回 `NonFinite`、迭代上限过小返回 `NotConverged(1)`、`max_iter=0` 返回 `InvalidConfig`；另断言 α=1 时 `load_demand_active_zip` 与 `load_demand_active` 相等。

### Changed

- 测试数 70 → 73。

### Added

- `model/zip.mbt`：ZIP 负荷系数与缩放规则提到共享的 model 包，三相与单相求解器共用。
- `solver/gauss_seidel_zip`：单相侧也支持负荷静特性（按节点电压缩放净注入）。α=1 时与 `gauss_seidel` 同解，交通测试逐位比对；恒阻抗负荷在电压低于 1 p.u. 时取用更少，求解出的母线电压高于恒功率情形。

### Changed

- **API 变更**：`Zip` 类型从 `@dist.Zip` 移到 `@model.Zip`（`dist/zip.mbt` 里的三相缩放函数改为接受 `@model.Zip`）。0.1.x 允许破坏性变更，下一次发布需在版本说明里点出。
- 测试数 68 → 70。

### Added

- `dist/neutral_voltages_per_edge`：逐支路给定中性导体阻抗。真机上各段导线截面不同，统一阻抗只是特例（`neutral_voltages` 现在就是「全相同」的包装）。阻抗数组长度与支路数不符时返回空数组——同样是「数据无效」而不是「不漂」。
- 3 条测试：逐支路全相同与统一版本逐位一致、两段阻抗下末端位移等于逐段压降之和（定义式）、长度不匹配返回空。

### Changed

- 测试数 65 → 68。

### Added

- `dist/cases_invariant_test.mbt`：内置算例的自洽性断言。四个算例必须都能过拓扑校验并收敛、根电压保持给定值、收敛后电压有限；`case_four_node` 必须真的三相不平衡、`case_balanced` 必须三相负荷模长一致。算例本身也是代码——它们悄悄变对称之后，不平衡度/损耗/中性点位移的测试就都在验证一个不存在的场景。

### Changed

- 测试数 62 → 65。

## [0.1.12] - 2026-11-11

### Added

- `dist/zip.mbt`：负荷静特性 ZIP。`S(V) = S0·(α + β·|V| + γ·|V|²)`，逐相按各自电压模长缩放；`Zip::new` 校验非负且和为 1；`sweep_zip` 与 `sweep` 并存（α=1 时同解）；`load_demand_active_zip` 统计按最终电压缩放后的实际取用，功率平衡恒等式照旧成立。
- 5 条测试：α=1 与旧 sweep 同解、γ=1 功率平衡、混合系数平衡、非法系数拒绝、缩放系数在 |V|=1 处为 1。

### Changed

- 测试数 57 → 62。
- `sweep` 内部改为带可选 ZIP 参数的主体函数，对外签名不变。

### Added

- `scripts/check-release.ps1` + CI 的 `release-meta` job：校验 `moon.mod` 的 version、CHANGELOG 最新版本段标题、README 里所有 `<模块>@x.y.z` 与 `Latest x.y.z` 三处一致，并拒绝重复的版本段。发布时漏改任何一处都不会报错，只会让文档慢慢变成谎话；现在它们对不上就红。

## [0.1.11] - 2026-11-11

### Changed

- `run_oltc` 在受控母线 a 相电压为 0 时直接返回 `OltcErr::Control`，不再继续调档。a 相被
  变压器支路断开（缺相）时这一相没有可读电压，旧实现会把它当成欠压、一路升档到上限，
  产出一条看起来正常的调档轨迹。**这是行为变更**：同一张网里受控 a 相断开，以前返回
  `Ok` 且 `tap` 顶到上限，现在返回 `Err`。补一条回归锁住「报错而不是跑满调档次数」。

### Fixed

- `dist/neutral_voltages` 对错配输入（拓扑或支路电流不是这张网的）返回空数组，而不是按错误下标取数；「没有漂移」和「数据无效」不再混成一个零数组。
- `dist/neutral_voltages` 遍历时跳过父边下标非法的节点：拓扑被外部构造得不完整时宁可少算一个节点，也不越界 panic。

### Changed

- 新测试里的同包名改为显式限定（`@dist.`），此前会让 CI 的 `check --deny-warn` 变红。
- 测试数 56 → 57。

## [0.1.10] - 2026-11-11

### Added

- `dist/neutral.mbt`：中性点位移（四线制一阶近似）。中性导体与相导体同拓扑，支路中性电流取三相电流之和的相反数，逐支路中性阻抗由调用方给定；`neutral_voltages` 给逐节点中性点电压，`phase_to_neutral` 给负荷端「相对中性点」的相电压。补 4 条测试（平衡不漂、单相负荷的位移方向与解析式、定义式逐相比对、零中性阻抗不漂）。

### Changed

- 测试数 52 → 56。
- `examples/dist_demo` 打印中性点位移与相对中性点的三相电压幅值。

## [0.1.9] - 2026-11-10

### Changed

- `run_oltc` 在受控母线 a 相电压为 0 时直接返回 `OltcErr::Control`，不再继续调档。a 相被
  变压器支路断开（缺相）时这一相没有可读电压，旧实现会把它当成欠压、一路升档到上限，
  产出一条看起来正常的调档轨迹。**这是行为变更**：同一张网里受控 a 相断开，以前返回
  `Ok` 且 `tap` 顶到上限，现在返回 `Err`。补一条回归锁住「报错而不是跑满调档次数」。

### Fixed

- `ybus/bus_index` 查不到端点时不再静默返回 0：`Network` 只能由 `model.validate` 构造，端点必然存在；查不到说明 model 层有 bug，此时立刻失败比把非法支路静默接到母线 0 上好。
- `sweep` / `gauss_seidel` 的 `max_iter <= 0` 现在返回新增的 `InvalidConfig`，此前返回 `NotConverged(0, 1.0)`，那个 1.0 是初始化占位值、不是真实偏差。
- `gauss_seidel` 缺 Slack 时返回 `NoSlack`（此前借用 `NotConverged(0, 1.0)`）。
- `voltage_violations` 对非有限电压单独报 `ViolationKind::NonFinite`：NaN 与上下限比较恒为 false，旧实现会把它当成合格电压。
- `voltage_extremes` 改为返回 `(Double, Double)?`：空数组或存在非有限值时返回 `None`，不再返回 `(1e9, -1e9)` 这种会被下游当真值使用的哨兵。

### Changed

- 测试数 50 → 52。

## [0.1.8] - 2026-11-10

### Changed

- `run_oltc` 在受控母线 a 相电压为 0 时直接返回 `OltcErr::Control`，不再继续调档。a 相被
  变压器支路断开（缺相）时这一相没有可读电压，旧实现会把它当成欠压、一路升档到上限，
  产出一条看起来正常的调档轨迹。**这是行为变更**：同一张网里受控 a 相断开，以前返回
  `Ok` 且 `tap` 顶到上限，现在返回 `Err`。补一条回归锁住「报错而不是跑满调档次数」。

### Fixed

- NaN 不再被当成「已收敛」：`sweep` 与 `solver.gauss_seidel` 的收敛判据都靠 `dv > max`，而 `NaN > x` 恒为 false，于是 NaN 那轮的 max 停在 0、**第一轮就判收敛并返回 Ok + NaN 电压**。现在逐轮检查偏差是否为 NaN，命中即返回新增的 `SweepErr::NonFinite(iter)` / `SolveErr::NonFinite(iter)`。补两条回归测试（NaN 负荷 / NaN 注入）。

### Changed

- 测试数 48 → 50。

## [0.1.7] - 2026-11-11

### Changed

- `run_oltc` 在受控母线 a 相电压为 0 时直接返回 `OltcErr::Control`，不再继续调档。a 相被
  变压器支路断开（缺相）时这一相没有可读电压，旧实现会把它当成欠压、一路升档到上限，
  产出一条看起来正常的调档轨迹。**这是行为变更**：同一张网里受控 a 相断开，以前返回
  `Ok` 且 `tap` 顶到上限，现在返回 `Err`。补一条回归锁住「报错而不是跑满调档次数」。

### Fixed

- `root_injection_active` 与支路存储方向无关：`i_branch` 的语义是「BFS 父→子」，早期实现只匹配 `from_id == root`，把支路写成子→父的网络会算出注入 0——电压与损耗都正常，只有功率平衡静默失效。现在按「任一端是根」匹配，并补方向无关性回归测试。
- `sweep` 对错配拓扑不再越界 panic：拓扑数组长度或 `parent_edge` 下标与网络不符时返回新增的 `SweepErr::TopologyMismatch`。库不该用 panic 报错。
- `voltage_violations` 在电压数组与母线表长度不一致时只比对能对上的部分，不越界。

### Changed

- 测试数 44 → 48。
## [0.1.6] - 2026-11-10

### Added

- `dist/limits.mbt`：电压越限检查。`voltage_violations(r, net, vmin, vmax)` 返回逐（母线, 相）的越限记录（含方向与实测值），限值为闭区间，恰好贴限不算越限；`voltage_extremes(r)` 给全网三相电压幅值的最值。库内不写死任何规程限值。
- `SweepOk::trace()`：每轮收敛偏差轨迹（长度 = 迭代次数，末项 = `max_dv`）。不收敛时用来看是振荡还是单调逼近——只看最后一次偏差区分不出来。
- `examples/dist_demo` 打印越限条数与收敛轨迹。

### Changed

- 测试数 39 → 44。
## [0.1.5] - 2026-11-10

### Added

- `dist/loss.mbt`：支路损耗与功率平衡。`branch_losses` 给每条支路三相复功率损耗
  （`S_p = (Z3·I)_p · conj(I_p)`，含相间互阻抗耦合），`total_loss_active` 给全网有功损耗，
  `load_demand_active` 与 `root_injection_active` 供守恒律校验。
- 4 条测试用「根注入 = 负荷需求 + 损耗」做判据（平衡算例、不平衡四节点、带互阻抗两节点、
  逐支路有功非负）：漏算相间互阻抗时这条立刻失衡。

### Changed

- 测试数 35 → 39。

## [0.1.4] - 2026-11-10

### Added

- 10 节点链式网络测试：验证拓扑与迭代在较长链上正常，电压沿链单调下降。
- `dist/unbalance.mbt`：对称分量（Fortescue）与三相电压不平衡度。
  `symmetrical_components(Phasor) -> Seq` 给出零序 / 正序 / 负序，
  `voltage_unbalance_percent(Phasor)` 按 `|V2|/|V1| × 100%` 给出 VUF，
  `unbalance_profile(Array[Phasor])` 按母线顺序批量算。
  正序模长小于 1e-12 p.u. 时返回 0（此时比值没有定义，浮点残差会放大到 1e17 量级）。
- `examples/dist_demo` 每条母线打印 VUF：根母线 ≈ 1.2e-14%，母线 2/3/4 ≈ 0.076% / 0.119% / 0.075%，
  让「平衡假设会抹掉什么」在同一张输出里可对比。
- 6 条单测覆盖：平衡正序（负序为零）、纯负序（正序为零）、单相有压（VUF = 100%）、
  一相跌落（手算 VUF = 20%）、三相相等（纯零序）、profile 顺序。

### Changed

- 测试数 29 → 35。
- 测试数 28 → 29：新增 10 节点链式网络测试（见上）。
- CI 从「只跑 wasm-gc」扩成矩阵：`wasm-gc` / `js` / `native` 三个目标各自 `check --deny-warn` + `build` + `test`，另加一个 job 把 `examples/dist_demo` 与 `examples/demo` 用 native 真跑一遍。求解器不含 C FFI，三目标数值行为一致（浮点末位差异已由容差断言吸收）。
- README 订正：删掉「js 后端 CI 尚未接入」这条计划项（已接入）；本机验证口径改为「2026-11-10 复跑 native / wasm-gc 29/29，js 因本机没有可用 node 交给 CI」。

## [0.1.3] - 2026-11-10

### Added

- `dist/case_scrambled_ids`：编号乱序、根不在首位的算例，验证拓扑与求解按 BFS 走而不是依赖数组顺序；测试数 27 → 28。

### Changed

- `moon fmt` 全仓格式化；CI 增加 `moon fmt --check` 步骤。

## [0.1.2] - 2026-11-09

### Added

- `dist/closed_form_test.mbt`：两节点纯电阻负荷的二次方程闭式解基准（`V2² − V1·V2 + R·P = 0`），与迭代实现构成两条独立路径；另有零负荷电压恒等测试。

### Changed

- 测试数 25 → 27；`moon fmt` 全仓格式化；CI 增加 `moon fmt --check`。

## [0.1.1] - 2026-11-09

### Added

- `dist/` 三相不平衡配电网前推回代：三相相量、3×3 相间耦合阻抗矩阵、辐射状拓扑校验（编号唯一、根存在、边数 = 节点数 − 1、根可达）、BFS 序与父子表。
- 三个内置算例与 `examples/dist_demo`；`scripts/gen_dist_fixtures.py` 用 Python 独立实现前推回代，产出 18 个电压分量基准。

### Changed

- `moon.mod` 描述从单相 GS 改为三相不平衡主线；keywords 同步；CI 补 `moon build` 步骤。

## [0.1.0] - 2026-11-08

### Added

- 首次发布：单相平衡高斯-赛德尔潮流、Ybus 组装、三节点算例、`examples/demo`。
