# Commit Message 规范

> 阶段 1 占位文件。**阶段 2 会从 wework-opus `CLAUDE.md` § 15.1 抽取并扩充**。

## 当前要点(摘要)

- **必须中文**(主要协作者母语)
- 描述**规格级变化**,不写 "update code" / "fix bug" 这种空话
- 推荐 conventional commits 格式 + 中文描述

## 示例(从 wework-opus 历史)

- `feat(transcoder): fun-asr 热词,文件驱动 + 自动同步 vocabulary`
- `chore(server): 适配 Ubuntu 22.04 VPS — 端口绑 127.0.0.1 + 部署文档`
- `docs(session_context): 截至 2026-05-07 — 模块二完结,模块三待开工`

## TODO(阶段 2 填充)

- type 列表(feat/fix/docs/style/refactor/test/chore/perf)
- scope 命名约定
- breaking change 标注
- 多 commit 规模建议
