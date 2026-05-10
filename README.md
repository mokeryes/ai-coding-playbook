# mokeryes/ai-coding-playbook

> Reusable AI-assisted coding playbook — 一根活动扳手,跨项目复用编码约定与工作流。

新项目 bootstrap、老项目同步、SOP 单点维护,统一靠这个仓库。

---

## TL;DR

```bash
pip install cruft
cruft create gh:mokeryes/ai-coding-playbook
```

(本地未推 GitHub 阶段,可用 `cruft create file:///Users/moker/Desktop/ai-coding-playbook`)

---

## 状态

🚧 **阶段 1 / 5**:仓库骨架已建,内容多为 TODO 占位,待阶段 2 从 wework-opus 反向抽取后填充。

| 阶段 | 进度 |
|---|---|
| 1. 仓库骨架 | ✅ 进行中 |
| 2. 通用化抽取 wework-opus 内容 | ⏳ |
| 3. wework-opus 接入 playbook | ⏳ |
| 4. 推 GitHub Public + 实战检验 | ⏳ |

---

## 仓库结构

```
ai-coding-playbook/
├── cookiecutter.json                 # 变量定义(扳手刻度)
├── hooks/                            # cookiecutter 生命周期钩子
├── {{cookiecutter.project_slug}}/    # ★ 模板内容(将复制到新项目)
│   ├── CLAUDE.md                     # 项目宪法(含通用规则 + 项目特定占位)
│   ├── docs/
│   │   ├── conventions/              # 编码风格 / 日志 / commit
│   │   ├── workflows/                # SPEC-driven / 提交自检 / 回滚 / 汇报
│   │   └── templates/                # SPEC / ADR / Module README
│   └── .claude/skills/               # AI agent skill 文件
├── tools/                            # CI / sync 辅助脚本
└── .github/workflows/                # 模板可生成性 CI
```

---

## 三种使用场景

| 场景 | 命令 |
|---|---|
| 新项目 bootstrap | `cruft create https://github.com/mokeryes/ai-coding-playbook` |
| 老项目检查更新 | `cruft check`(项目根目录运行) |
| 老项目应用更新 | `cruft update`(项目根目录运行) |
| 老项目应用更新(`cruft update` 报 unicode 错时) | `bash <(curl -fsSL https://raw.githubusercontent.com/mokeryes/ai-coding-playbook/main/tools/manual_update.sh)` |

> ⚠️ **`cruft update` 报 'Unable to interpret changes ... unicode' 怎么办?**
>
> 这是 binaryornot 对短小 + CJK 密集的 markdown 文件误判的副作用。本仓库
> commit `cfa90e1` 已为受影响文件加了 ASCII header 修复,但**已锁旧 commit
> 的项目首次升级**仍会触发(因为 cruft 内部要重渲染旧 base)。
>
> 解决:用 `tools/manual_update.sh`,它绕过 base 重渲染,直接把最新模板
> 内容 rsync 到当前项目并更新 `.cruft.json`,**尊重 skip 列表 + 不动 .git**。
> 跑完手动 `git diff` 审 + commit。

---

## License

MIT
