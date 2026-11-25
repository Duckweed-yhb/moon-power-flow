# 发布与验证

在 MoonBit 工程中运行 `moon add Duckweed/moon-power-flow@0.2.4` 安装此版本。

## 从源码复现

在仓库根目录运行以下命令。

```sh
moon fmt --check
moon check --target native --deny-warn
moon test --target native
moon run examples/dist_demo --target native
```

示例在三相辐射状馈线上逐档求解电压，输出末端各相的供电状态和功率平衡残差。运行 `moon run examples/oltc_zip_demo --target native` 可比较不同 ZIP 负荷下的调压结果。

[使用说明](README.md) · [版本记录](CHANGELOG.md) · [代码与数据来源](PROVENANCE.md)
