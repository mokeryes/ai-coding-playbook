# Commit Message 规范

> CLAUDE.md § 9.1 的展开版。
> 本项目所有 commit 必须遵守。

---

## 3 条铁律

1. **必须中文**(主要协作者母语;团队习惯统一)
2. 描述**规格级变化**,不写 "update code" / "fix bug" 这种空话
3. 推荐 conventional commits 格式 + 中文描述

---

## 格式

```
<type>(<scope>): <中文描述,简洁版>

<空行>

<可选:中文详细说明,讲"为什么"而不是"做了什么">
```

---

## type 列表(必须从此选一)

| type | 用途 | 例子 |
|---|---|---|
| `feat` | 新功能 / 新模块 | `feat(transcoder): fun-asr 热词,文件驱动 + 自动同步 vocabulary` |
| `fix` | bug 修复 | `fix(collector): seq=0 时跳过空批次防止误判退出` |
| `docs` | 仅文档变更 | `docs(session_context): 截至 2026-05-07 — 模块二完结,模块三待开工` |
| `refactor` | 重构(行为不变) | `refactor(events): 拆分 base_event 为独立模块` |
| `chore` | 构建 / 依赖 / 工具链 | `chore(server): 适配 Ubuntu 22.04 VPS — 端口绑 127.0.0.1 + 部署文档` |
| `test` | 仅测试相关 | `test(filter): 补 image / voice 分类边界用例` |
| `perf` | 性能优化(行为不变) | `perf(persistence): media MD5 流式计算避免双拷` |
| `style` | 仅格式化 / 无逻辑 | `style: black 格式化全项目`(很少用) |
| `build` | 仅构建系统变更 | `build(docker): 升级 base 到 ubuntu:24.04` |

---

## scope 命名约定

scope 是**模块名 / 文件域**,不是任意标签:

✅ 好:`feat(transcoder)`、`fix(meta_collector)`、`refactor(events)`、`chore(scripts)`、`docs(claude)`

❌ 不好:`feat(important)`、`fix(urgent)`、`feat(misc)`、`feat(general)`

如果改动**横跨多模块**,用 `feat(core)` / `chore(server)` / `docs(session)` 这种**虚类目**,但最多 1 个 scope,不要 `feat(a, b, c)`。

---

## 描述部分写什么

**写规格级变化**:这个 commit 改变了什么"行为"或"约定",而不是"哪些文件"。

✅ 好:
- `feat(transcoder): fun-asr 热词,文件驱动 + 自动同步 vocabulary`
- `chore(server): 适配 Ubuntu 22.04 VPS — 端口绑 127.0.0.1 + 部署文档`
- `fix(scripts): manage.sh 在 podman 5.x 下 network rm 加 -f`

❌ 不好:
- `update code`
- `fix bug`
- `修改了 transcoder.py 和 vocabulary.py`(写文件名而非语义)
- `feat: improvement`(没说改了什么)

---

## breaking change 标注

行为破坏性变更,在 type 后加 `!`,并在 body 写 `BREAKING CHANGE:` 段:

```
feat(events)!: 重命名 meta.text.added 为 meta.message.added

BREAKING CHANGE:
所有订阅 meta.text.added 的下游模块需要改成 meta.message.added。
迁移脚本:scripts/migrate_event_name.sh
```

---

## 多 commit 规模建议

**一个 commit = 一个完整的、可回滚的"小步"**。

| 改动 | 建议 commit 数 |
|---|---|
| 新模块上线 | 1-3 个(实现 / 文档 / 配置) |
| bug 修复 | 1 个 |
| 重构 | 多个,每个独立可编译 |
| 大特性 | 多个,按子任务切 |

**不要把 10 个不相关改动塞一个 commit**。也**不要把 1 个改动切成 5 个**(回滚噩梦)。

---

## 与 SPEC.md 的对应

理想情况:**一个 SPEC.md 对应 1-3 个 commit**。
- 第 1 个:实现核心逻辑
- 第 2 个:补文档(README / SPEC 完成版 / .session_context 更新)
- 第 3 个(可选):配置 / 部署脚本

提交前对照 SPEC.md 检查:每条**验收标准**都有 commit 对应吗?

---

## 反例集(供 AI 自检)

```
❌ update CLAUDE.md           → ✅ docs(claude): 吸收 spec-driven 工作流 — SPEC 前置 / AI 自验 / 回滚 SOP
❌ fix typo                   → ✅ docs(readme): 修正模块二文件路径错别字
❌ wip                        → 不应该作为 commit 落进 main 分支
❌ Refactor logging           → ✅ refactor(logger): 拆出 mask.py 集中处理脱敏
❌ feat: 新模块                → ✅ feat(business_extractor): 模块三骨架 — DeepSeek 意图判断 + 知识库占位
```
