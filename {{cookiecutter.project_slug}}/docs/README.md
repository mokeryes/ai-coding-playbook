# docs/ — 项目文档目录

| 子目录 | 内容 | 与 CLAUDE.md 关系 |
|---|---|---|
| [`conventions/`](conventions/) | 跨模块编码约定(风格、日志、commit) | CLAUDE.md § 5/6/9.1 引用 |
| [`workflows/`](workflows/) | 工作流 SOP(SPEC 驱动、提交自检、回滚、汇报) | CLAUDE.md § 7/8.1/9/10 引用 |
| [`templates/`](templates/) | 可复用模板(SPEC、ADR、模块 README) | 模块开工时 cp 到 `app/modules/<X>/SPEC.md` |

## 文档分层原则

- **CLAUDE.md** = 规则索引 + 关键约束(AI 启动必读)
- **docs/conventions/ + docs/workflows/** = 详细 SOP(CLAUDE.md 引用,允许扩写)
- **docs/templates/** = 拷贝即用的模板(不是说明,是骨架)
- **app/modules/`<X>`/{SPEC,README,ARCHITECTURE}.md** = 模块自带文档(贴着代码走)
