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

- ⏳ TODO(阶段 2 从 wework-opus § 7 抽取填充)

---

## 6. 日志规范

详细见 [`docs/conventions/logging.md`](docs/conventions/logging.md)。**核心要点**:

- ⏳ TODO(阶段 2 抽取)

---

## 7. 协作流程(必须遵守)

详细见 [`docs/workflows/spec-driven.md`](docs/workflows/spec-driven.md)。**核心流程**:

1. **方案确认阶段**:写 SPEC.md → 用户审核 → 明确"开始写代码"才进入下一阶段
2. **代码生成阶段**:严格按 SPEC 实现
3. **AI 自验阶段**:语法 / import / schema 自跑(命令视语言而定,见下方)
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

---

## 8. 紧急沟通规则

5 类情况**必须停下询问**:业务歧义 / 跨模块边界 / 性能成本权衡 / 安全敏感操作 / 与本文档冲突。

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

本项目从 [`moker/ai-coding-playbook`](https://github.com/moker/ai-coding-playbook) 生成,版本锁在 `.cruft.json`。
跑 `cruft check` 看更新,`cruft update` 应用更新。
