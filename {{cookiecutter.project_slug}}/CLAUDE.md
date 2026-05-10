<!-- =============================================================================
encoding: utf-8 (markdown). this top-of-file ascii comment block exists so that
binaryornot/chardet correctly classifies CJK-heavy markdown as text rather than
binary. without it, cookiecutter rendering + cruft 3-way diffs intermittently
fail on short text files dense with chinese characters. do not remove this
block; if you trim, verify with: python -c "from binaryornot.check import is_binary; print(is_binary(\"<file>\"))"
============================================================================= -->

# {{ cookiecutter.project_name }}

> **{{ cookiecutter.project_description }}**
>
> 主要语言:`{{ cookiecutter.primary_language }}` | 技术栈:{{ cookiecutter.tech_stack_summary }} | Owner: {{ cookiecutter.owner }}

本文件是项目宪法,Claude Code / GPT 等 AI 启动会话时自动加载。所有代码生成、修改、审查任务都必须遵守以下约束。

**启动会话时,务必先阅读 `.session_context.md`**,了解上次会话的进度、关键决策和当前待办事项。

---

## 1. 项目背景

> ⏳ TODO(由项目所有者填写):业务背景 / 核心目标 / 关键约束

---

## 2. 系统架构

> ⏳ TODO:模块划分图 / 通信契约 / 关键依赖

---

## 3. 技术栈(不可变更,除非明确批准)

主要语言:**{{ cookiecutter.primary_language }}**
概要:{{ cookiecutter.tech_stack_summary }}

| 维度 | 选择 |
|---|---|
| 语言 | {{ cookiecutter.primary_language }} |
| ⏳ 详细表格 | TODO |

---

## 4. 代码组织(强制结构)

> ⏳ TODO:目录结构图 + 模块边界规则

---

## 5. 编码风格(强制约束)

详细见 [`docs/conventions/coding-style.md`](docs/conventions/coding-style.md)。**核心要点**:

- **清晰 > 优雅**:禁止装饰器魔法、元类、过度抽象、复杂泛型
- **显式 > 隐式**:配置项必须显式指定或抛错,**不允许偷偷使用默认值**
- **同步 > 异步**:除非明确需要并发,否则用同步代码(异步增加调试复杂度)
- **少即是多**:文件 ≤ 200 行,函数 ≤ 50 行,超过就拆
- **日志先行**:每个模块入口、关键决策点、外部调用前后必须有日志
- **代码注释为中文**(主要协作者母语)
- **变量名 / 函数名 / 文件名为英文**(避免编码问题)

---

## 6. 日志规范

详细见 [`docs/conventions/logging.md`](docs/conventions/logging.md)。**核心要点**:

- **同时输出到 stdout 和文件**(容器日志 + 持久化双需求)
- 文件路径:`./logs/<模块名>.log`,按日期切割
- 关键事件单独打 INFO 级,常规流转打 DEBUG 级
- 异常必须 `log.exception` 带 traceback

---

## 7. 协作流程(必须遵守)

详细见 [`docs/workflows/spec-driven.md`](docs/workflows/spec-driven.md)。**核心流程**:

1. **方案确认阶段**:AI 在 `app/modules/<X>/SPEC.md` 写规格 → 用户审核 → 明确"开始写代码"才进入下一阶段
   SPEC.md 必填 13 项:输入 / 输出 / 文件结构 / 关键函数签名 / 数据库 schema / 事件 schema / 错误处理 / **验收标准 / 成功条件 / 失败条件 / 回退策略 / 默认值 / 本期不做**
2. **代码生成阶段**:严格按 SPEC 实现,不擅自越界
3. **AI 自验阶段**:语法 / import / schema 自跑(命令见 § 7.1)
4. **联调验证阶段**:按 SPEC 的"验收标准"逐项核对

SPEC 模板见 [`docs/templates/SPEC.md`](docs/templates/SPEC.md)。

### 7.1 AI 自验命令(语言相关)

{% if cookiecutter.primary_language == 'python' -%}
- 语法检查(必做):`python -m py_compile <改动的 .py 文件>`
- import 检查:`python -c "import <module>"`
- 测试(若有):`python -m pytest tests/`
{%- elif cookiecutter.primary_language == 'swift' -%}
- 编译检查(必做):`swift build` 或 `xcodebuild -scheme <X> build`
- 单元测试:`swift test` 或 `xcodebuild test -scheme <X>`
- SwiftLint(若启用):`swiftlint`
{%- elif cookiecutter.primary_language == 'typescript' -%}
- 类型检查(必做):`npx tsc --noEmit`
- Lint:`npx eslint .`
- 测试:`npm test`
{%- elif cookiecutter.primary_language == 'go' -%}
- 编译检查(必做):`go build ./...`
- Vet:`go vet ./...`
- 测试:`go test ./...`
{%- elif cookiecutter.primary_language == 'rust' -%}
- 编译检查(必做):`cargo check`
- Clippy:`cargo clippy`
- 测试:`cargo test`
{%- else -%}
- ⏳ TODO:填写本项目的语法 / 编译 / 测试命令
{%- endif %}

**未经用户明确批准,不得擅自修改既有模块代码**。

### 7.2 进度可视化

**SPEC-driven 流程内**(`.session_context.md` 的 `current_phase.active_spec` 非 null 时),
AI 每次回答末尾**必须**追加进度块:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 [SPEC: <模块名>]  阶段 <X> / 6  <阶段名>
   🟢方案 → 🟡代码 → ⚪自验 → ⚪联调 → ⚪收尾 → ⚪提交
   └─ 当前阶段:
        ├─ 🟢 <已完成子步骤>
        ├─ 🟡 <进行中子步骤> ← 现在
        └─ ⚪ <待办子步骤>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

状态符号(色块 emoji):
**🟢 完成 / 🟡 进行中 / ⚪ 待 / 🔴 紧急停下 / 🔵 回滚中 / 🟣 重试**

闲聊 / 答疑 / 不在 SPEC 流程时**不加**(看 `.session_context.md` `active_spec` 字段为 null)。

详细见 [`docs/workflows/spec-driven.md`](docs/workflows/spec-driven.md) §"进度可视化"。

---

## 8. 紧急沟通规则

5 类情况**必须停下询问**:

1. **业务逻辑歧义** — 对一个数据应该走哪条分支不确定
2. **跨模块边界争议** — 某个功能放在 A 模块还是 B 模块
3. **性能 / 成本权衡** — 某方案明显更贵但更稳
4. **安全敏感操作** — 密钥处理、权限提升、数据删除
5. **与本文档冲突的需求** — 用户明确要求时

普通实现细节(变量名、内部函数拆分、日志措辞)无需询问,直接做。

详细见 [`docs/workflows/spec-driven.md`](docs/workflows/spec-driven.md) §"紧急沟通规则"。

### 8.1 回滚操作流程

详细见 [`docs/workflows/rollback-sop.md`](docs/workflows/rollback-sop.md)。**5 步**:确认 commit → 查工作区 → 说明操作 → 用户批准 → 执行后再确认。**不要直接** `git reset --hard`。

---

## 9. 提交前自检

详细见 [`docs/workflows/pre-commit-checklist.md`](docs/workflows/pre-commit-checklist.md)。

用户说"提交"或"commit"后,AI 必须先 `git status --short` + `git diff` 自检,等用户确认再 `git commit`。

### 9.1 Commit message 规范

详细见 [`docs/conventions/commit-style.md`](docs/conventions/commit-style.md)。**必须中文** + 描述规格级变化 + 推荐 conventional commits 格式。

---

## 10. 任务收尾汇报格式

详细见 [`docs/workflows/task-report-format.md`](docs/workflows/task-report-format.md)。

每个独立任务交付时按 6 项简洁汇报:完成什么 / 改了哪些文件 / 新增测试 / 自跑验证 / 未验证项 / 下一步命令。

{% if cookiecutter.include_optional_sections == 'yes' -%}
---

## 11. 数据库分层(可选)

> ⏳ TODO:三库分离 / schema 设计(后端服务类项目保留)

## 12. 容器部署(可选)

> ⏳ TODO:容器编排 / 启动脚本

## 13. 运维脚本(可选)

> ⏳ TODO:manage.sh / fresh_pull.sh 等

{%- endif %}

---

## 14. 当前阶段

> ⏳ TODO:本期范围 / 当前进度 / 不做的事

---

## 15. 关键参考资料

> ⏳ TODO:外部 API 文档 / 依赖库链接

---

## 16. 模板版本

本项目从 [`mokeryes/ai-coding-playbook`](https://github.com/mokeryes/ai-coding-playbook) 生成,版本锁在 `.cruft.json`。
跑 `cruft check` 看更新,`cruft update` 应用更新。
