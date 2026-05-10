# 提交前自检 SOP

> CLAUDE.md § 9 的展开版。
> 用户说"提交"或"commit"后,AI 必须先做以下检查并回报,**等用户确认再 `git commit`**。

---

## 触发时机

用户原话出现下列任一关键词:
- "提交"
- "commit"
- "可以 commit 了"
- "把改动 commit 一下"

AI 看到这类指令,**不要直接** `git commit`,先做自检。

---

## 3 步检查

### 1. `git status --short`

主动汇报输出。重点确认:

- [ ] 没有未追踪的临时文件(`.swp` / `.bak` / `*.tmp`)
- [ ] 没有缓存目录(`__pycache__` / `node_modules` / `target` / `.build`)
- [ ] 没有日志 / 数据 / 下载产物(`logs/` / `data/` / `*.log`)
- [ ] 没有意外的二进制(`*.so` / `*.dylib` / `*.exe`)

如果 .gitignore 应该挡掉但没挡掉,先补 .gitignore 而不是直接 add。

### 2. `git diff`(含已 stage 和未 stage)

主动汇报本次改动的**文件清单**,并:

- [ ] 主动指出任何看起来"超出 SPEC 范围"的改动
- [ ] 主动指出任何 `print()` / `console.log()` / 调试日志
- [ ] 主动指出任何注释掉的代码块(应该删除而非留)
- [ ] 主动指出任何 `TODO` / `FIXME` / `XXX` 新增

### 3. 自检清单(逐条对照,口头回答)

```
[ ] 只改了本需求 SPEC.md 涉及的文件?
[ ] 没有误改 .session_context.md(除非用户明确要求更新)?
[ ] 没有误改 CLAUDE.md / docs/conventions/ / docs/workflows/(除非用户明确要求)?
[ ] 没有提交 .env / 私钥 / keys/ 下文件?
[ ] 没有提交 logs/ / __pycache__ / data/ 下产物?
[ ] 文档(README / SPEC)与代码状态一致?
[ ] commit message 准备好了?(中文 + 规格级描述)
```

---

## 自检失败时的处理

**任一项不通过 → 不提交,先修正**。

| 问题 | 处理 |
|---|---|
| 有调试 `print()` 残留 | 删除后再提交 |
| 改了无关文件 | `git restore <无关文件>` 还原 |
| .env / 私钥意外 stage | `git restore --staged <文件>` + 补 .gitignore |
| 文档与代码不一致 | 先更新文档,**与代码改动同一 commit** |
| commit message 还没想好 | 跟用户讨论后再写,不抢时间凑数 |

---

## 与 pre-commit hook 工具(可选)的关系

如果项目启用了 [pre-commit](https://pre-commit.com/) 工具:

- 工具自动跑(format / lint / 大小检查),AI **不用手动跑**
- 但**自检清单**还是要走(工具检查的是机械问题,自检看的是语义问题)
- 工具失败 → 修后重试,**不要用** `--no-verify` **绕过**

---

## 多人协作场景的额外检查

如果项目有多人提交(本项目目前单人):

- [ ] commit author 是不是当前你?(`git log -1 --format='%an <%ae>'`)
- [ ] 分支是不是预期分支?(`git branch --show-current`)
- [ ] 提交目标分支保护策略?(主分支不直接 push,走 PR)

---

## 提交后(可选)

- 推到远程:**问一下用户**是否要 `git push`,默认不推
- 推完汇报远程 commit hash + URL(如 GitHub)
- **绝不** `git push --force` 或 `git push -f`,除非用户明确同意且不在主分支上

---

## 反例(AI 容易踩的坑)

| ❌ AI 行为 | 为什么不行 |
|---|---|
| 看到"提交"就 `git add -A && git commit -m "update"` | 跳过自检 + 空话 commit message |
| `git commit --no-verify` 绕过 pre-commit hook | 把质量门关了 |
| 把临时调试代码也 commit 进去说"反正下次再删" | 主分支不应该有"下次再删"的东西 |
| 改了 .session_context.md 但没问用户就提交 | 元文档改动应单独审 |
| 一个 commit 塞 10 个不相关改动 | 回滚噩梦,违反 commit-style 单一职责 |
