# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 与语义化版本。

## [Unreleased]

### Added

- 10 节点链式网络测试：验证拓扑与迭代在较长链上正常，电压沿链单调下降。

### Changed

- 测试数 28 → 29。

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
