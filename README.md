# ai-coding-playbook

> 一根**活动扳手** — AI-assisted coding 的可复用约定 + 工作流模板。新项目 cruft 一键 bootstrap,老项目长期跟随升级。

跨项目复用以下资产(各取所需):

- 📐 **编码约定** — 风格 / 日志 / commit message 规范(中文)
- 🔄 **工作流 SOP** — SPEC-driven 开发 / AI 自验 / 提交前自检 / 回滚 / 任务收尾汇报
- 📋 **模板** — `SPEC.md` / `ADR.md` / `MODULE_README.md`
- 🛠 **AI Skill** — `spec-driven-agentic-coding`(Claude Code 启动注入)
- 🌐 **多语言矩阵** — Python / Swift / TypeScript / Go / Rust(`primary_language` 切自验命令 / `.gitignore`)

---

## 安装

```bash
pip install cookiecutter cruft
```

## 三种使用场景

| 场景 | 命令 |
|---|---|
| **新项目 bootstrap** | `cruft create https://github.com/mokeryes/ai-coding-playbook` |
| **老项目检查更新** | `cruft check`(已接入项目根) |
| **老项目应用更新** | `cruft update`(已接入项目根) |
| **应用更新报 unicode 错时** | `bash <(curl -fsSL https://raw.githubusercontent.com/mokeryes/ai-coding-playbook/main/tools/manual_update.sh)` |

新项目生成后,**第一步**:

```bash
cd <project-name>
./scripts/finish_setup.sh   # git init + first commit(把 .cruft.json 一并入库)
```

---

## 仓库结构

```
ai-coding-playbook/
├── cookiecutter.json                 # 模板变量定义
├── hooks/                            # 生命周期钩子(pre / post gen)
├── tools/                            # 维护工具(manual_update.sh / lint)
├── {{cookiecutter.project_slug}}/    # ★ 模板内容(将复制到新项目)
│   ├── CLAUDE.md                     # AI 会话规则 + 项目宪法
│   ├── README.md                     # 项目 README 占位
│   ├── .session_context.md           # 跨会话进度记录
│   ├── docs/
│   │   ├── conventions/              # 编码风格 / 日志 / commit 规范
│   │   ├── workflows/                # SPEC-driven / 提交自检 / 回滚 / 汇报 SOP
│   │   └── templates/                # SPEC / ADR / Module README 模板
│   ├── .claude/skills/               # spec-driven-agentic-coding skill
│   └── scripts/finish_setup.sh       # bootstrap 收尾脚本
└── .github/workflows/                # 矩阵 CI(5 种语言渲染验证)
```

---

## 设计原则

- **混合层** — `CLAUDE.md` 内联关键规则(AI 必读) + `docs/` 详细 SOP + skill 文件(启动指令)
- **渲染矩阵** — `primary_language` 切 Python / Swift / TypeScript / Go / Rust 命令(如 § 7.1 AI 自验)
- **跟随而不绑死** — `.cruft.json skip` 列表保护项目 fork 文件(`CLAUDE.md` / `README.md` 等)免被覆盖
- **ASCII header 防误判** — CJK 密集 `.md` 文件顶部加 HTML 注释 header,让 `binaryornot` 稳判文本

---

## 已知限制

`cruft update` 在已锁旧 commit 的项目首次升级时,可能报:

```
Unable to interpret changes between current project and cookiecutter template as unicode
```

这是 `binaryornot` 对 CJK 密集 markdown 的偶发误判。本仓库已为受影响文件加 ASCII header 修复,**新项目不会触发**;**已接入项目第一次升级**用 `tools/manual_update.sh` 绕开(直接 rsync latest 模板内容,尊重 `.cruft.json skip` 列表)。

---

## Fork 自定义

想做自己版本的 playbook?

```bash
gh repo fork mokeryes/ai-coding-playbook --clone
# 改 {{cookiecutter.project_slug}}/ 内的内容
# 推自己 GitHub
cruft create https://github.com/<your-account>/ai-coding-playbook
```

变量定义在 `cookiecutter.json`:`primary_language` / `include_skills` / `include_optional_sections` 等。

---

## License

MIT
