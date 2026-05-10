---
name: spec-driven-agentic-coding
description: 适用于任何编程任务的 Spec-Driven Agentic Coding 工作流。先对齐需求并写规格文档,再等待明确实现指令,由 AI agent 实现代码、同步补测试、运行验证,最后在人类确认后 Git 提交。
---

# Spec-Driven Agentic Coding

此 skill 适用于任何语言、框架、仓库规模的编程任务。

核心思想:

```
先定规格,再写代码;
边写边测,提交留痕;
AI 执行,人来把关。
```

> 本 skill 与项目 [`docs/workflows/spec-driven.md`](../../../docs/workflows/spec-driven.md) 同源。
> skill 是 AI 启动时的"短指令版";docs 是详细操作手册版。两者保持一致,如有冲突以 docs 为准。

---

## 总流程

严格按以下顺序执行:

1. 需求对齐
2. 编写或更新规格文档
3. 等待明确实现指令
4. Agentic 实现
5. 同步补测试
6. 验证(AI 自验 + 联调)
7. 人审 diff
8. Git 提交

如果用户没有明确要求跳过某一步,不要擅自改变流程。

---

## 1. 需求对齐

在写代码前,先复述需求并确认理解。

需要明确:

- 用户目标
- 当前问题
- 输入与输出
- CLI / API / UI 行为
- 默认值
- 参数命名
- 成功条件
- 失败条件
- 回退策略
- 数据保存位置
- 向后兼容性
- 安全 / 隐私 / 权限边界
- 验收标准

如果需求有歧义,先问问题。**不要在需求仍不明确时写代码**。

---

## 2. 规格文档

需求确认后,先修改 / 创建 Markdown 规格文档。优先使用项目已有文档:

```
app/modules/<X>/SPEC.md
docs/specs/<feature>.md
README.md
docs/*.md
```

文档中应包含:

- 背景和目标
- 新增 / 变更的行为
- 命令示例
- 参数说明
- 状态流转
- 错误处理
- 回退策略
- 数据结构 / 保存路径
- 测试要求
- 验收标准

文档写完后,先向用户总结变更,并**等待明确实现指令**。

模板见 [`docs/templates/SPEC.md`](../../../docs/templates/SPEC.md)。

---

## 3. 等待实现指令

只有用户明确说类似下面的话,才开始写代码:

```
开始写代码
实现
继续实现
go ahead
write code
开干
```

如果用户只是说"分析一下"、"先对齐"、"先改文档",**不要写代码**。

---

## 4. Agentic 实现

开始实现后:

- 先读代码,再改代码
- 优先遵循现有项目结构
- 保持改动聚焦在规格文档确认的范围内
- 不做无关重构
- 不擅自引入新依赖
- 不擅自改变 CLI / API / UI 行为
- 不删除用户已有改动
- 遇到冲突时先说明,再继续

适合拆分时,可以按层推进:

```
解析层 → 状态模型 → 核心逻辑 → UI/CLI → 持久化 → 测试
```

---

## 5. 测试要求

实现代码时**应当**同步新增 / 更新测试。

优先测试**纯逻辑**:

- 参数解析
- URL / 路径解析
- 状态机
- 回退策略
- 错误分类
- 数据序列化
- profile / config 保存读取
- 边界条件
- 格式化函数

建议结构:

```
tests/
  test_resolver.py
  test_models.py
  test_utils.py
  test_state_machine.py
```

不要把以下内容强行写成脆弱单元测试:

- 真实网络请求
- 真实浏览器操作
- 真实文件下载
- 真实外部命令
- 时间敏感 UI 渲染

对于这类内容,应拆出纯逻辑测试,并在 SPEC.md § 9 验收标准中说明哪些需要集成测试或人工验证。

如果没有测试框架,优先使用项目语言的常规测试框架;如果无法安装依赖,说明原因。

---

## 6. 验证

### 6.1 AI 自验(代码生成完毕,交付前)

跑适合当前项目语言的检查命令(见 CLAUDE.md § 7.1):

```bash
# 通用例子,具体看项目
python3 -m py_compile <changed.py>     # Python
swift build                            # Swift
npx tsc --noEmit                       # TypeScript
go build ./...                         # Go
cargo check                            # Rust
```

如果某些验证无法运行,需要说明:
- 为什么无法运行
- 哪些验证已完成
- 用户后续应运行什么命令

### 6.2 联调验证(用户参与)

按 SPEC.md § 9 验收标准逐项核对。

---

## 7. 人审 Diff

提交前必须检查:

```bash
git status --short
git diff
```

确认:

- 只改了本需求相关文件
- 没有误改生成文件
- 没有误删用户文件
- 没有提交临时文件、缓存、日志或下载产物
- 文档、代码、测试一致

如果发现无关改动,**不要擅自回退用户改动**;先判断是否自己产生。
自己产生的临时文件应清理。
用户已有改动不要动。

详细见 [`docs/workflows/pre-commit-checklist.md`](../../../docs/workflows/pre-commit-checklist.md)。

---

## 8. Git 提交

只有用户明确要求或确认后才提交。

提交前:

```bash
git status --short
git diff
```

提交:

```bash
git add <specific files>
git commit -m "<中文 conventional commits 描述>"
```

提交信息应描述**规格级变化**,而不是泛泛写 "update code"。

好例子:

```
feat(cache): 改事件驱动失效 + 配置文件可热更
chore(deploy): 适配 Ubuntu 22.04 — 端口绑 127.0.0.1 + 部署文档
docs(session_context): 截至 2026-XX-XX — Auth 模块完结,API 模块待开工
```

不要提交:

- 未确认的实验代码
- 失败的中间状态
- 无关格式化
- 下载产物
- 缓存文件

详细见 [`docs/conventions/commit-style.md`](../../../docs/conventions/commit-style.md)。

---

## 9. 回滚规则

如果用户要求回退到某个 commit,严格按 [`docs/workflows/rollback-sop.md`](../../../docs/workflows/rollback-sop.md) 5 步流程:

1. 先确认目标 commit 存在
2. 检查当前工作区状态
3. 说明将要执行的操作(粒度到具体命令)
4. 执行用户明确要求的 Git 操作
5. 再确认 `HEAD` 和工作区状态

```bash
git rev-parse --verify <commit>
git status --short
git reset --hard <commit>            # 仅在用户批准后
git rev-parse --short HEAD
git status --short
```

---

## 10. 最终回复格式

最终回复应简洁,按 [`docs/workflows/task-report-format.md`](../../../docs/workflows/task-report-format.md) 6 项汇报:

- 完成了什么
- 修改了哪些文件
- 新增了哪些测试
- 跑了哪些验证
- 哪些内容未验证
- 用户下一步可执行什么命令

不写长篇解释,除非用户要求。

---

## 11. 进度可视化(SPEC-driven 流程内)

**触发**:`.session_context.md` 的 `## 当前阶段(SPEC-driven)` 段中 `active_spec` 非 null。
**动作**:每次 AI 回答**末尾**追加进度块。**不在 SPEC 流程内**(active_spec=null,如闲聊 / 答疑) → **不加**。

格式:

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

状态符号:🟢 完成 / 🟡 进行中 / ⚪ 待 / 🔴 紧急停下 / 🔵 回滚中 / 🟣 重试。

阶段过渡时 AI 主动更新 `.session_context.md` 状态字段(active_spec / major / sub / flag / retry_count)。
用户可手改作为修正。详见 [`docs/workflows/spec-driven.md`](../../../docs/workflows/spec-driven.md) §"进度可视化"。

---

## 行为约束

- 用户要求"先对齐需求"时,**不写代码**
- 用户要求"先改 `.md`"时,**只改 Markdown**
- 用户明确"开始写代码"后,才实现
- 实现时**必须考虑测试**
- 提交 Git 前**必须等待用户确认**
- **不擅自回退用户改动**
- 不把 TUI / GUI / 网络 / 外部命令测试伪装成稳定单元测试
