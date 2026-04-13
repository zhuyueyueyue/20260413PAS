# pasr

R 语言项目模板（最小可用版），包含：

- 包结构（`DESCRIPTION`、`NAMESPACE`、`R/`）
- 单元测试（`testthat`）
- 基础开发流程说明

## 快速开始

```r
# 安装开发依赖
install.packages(c("devtools", "roxygen2", "testthat", "renv"))

# 在项目根目录执行
devtools::document()   # 生成/更新文档与 NAMESPACE
devtools::test()       # 运行测试
devtools::check()      # 运行检查
```

## 建议工作流

1. 函数写在 `R/` 下（每个函数写 roxygen 注释）
2. 测试写在 `tests/testthat/` 下
3. 新增依赖后执行 `renv::snapshot()` 锁定版本
4. 提交前运行 `devtools::test()` 和 `devtools::check()`
