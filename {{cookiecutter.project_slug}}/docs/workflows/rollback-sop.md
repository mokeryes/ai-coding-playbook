# 回滚操作 SOP

> CLAUDE.md § 8.1 的展开版。
> 用户要求"回退到某个 commit"或"撤销某次改动"时,AI 必须按本文 SOP 执行。

---

## 总原则

```
回滚是破坏性操作,所有 git 命令必须先解释、再执行、后确认。
绝不直接 git reset --hard。
```

---

## 5 步流程

### 1. 确认目标 commit 存在

```bash
git rev-parse --verify <commit>
```

不存在 → 停下,问用户:你说的 commit 在哪个分支?或者你想回退到的"那次改动"具体是什么?

### 2. 检查当前工作区状态

```bash
git status --short
git log --oneline -10
```

**主动汇报**给用户:
- HEAD 现在在哪
- 工作区有无未提交改动
- 当前 vs 目标 commit 之间隔了几个 commit

### 3. 向用户明确说明操作意图

**不要只说"我来回滚一下"**。粒度到具体命令 + 影响范围:

✅ 好:
> "我要执行 `git reset --hard abc1234`,这会:
> - HEAD 移到 abc1234
> - 当前 HEAD 之上 3 个 commit 被丢弃(d8f4467, 970c4e4, 29274db)
> - 工作区有 2 个未提交文件,会被一并丢弃 ⚠️
>
> 确认执行?(yes / no / 先 stash)"

❌ 不好:
> "我来 reset 一下"

### 4. 执行用户明确批准的操作

- 用户说 yes → 执行
- 用户说 no → 不执行,问替代方案
- 用户提替代 → 重走 step 3 解释新方案,再确认

### 5. 执行后再次确认

```bash
git rev-parse --short HEAD
git status --short
git log --oneline -5
```

把输出贴给用户,确认到达预期状态。

---

## 工作区有未提交改动

step 2 发现工作区脏 → 必问用户:

```
1. 是否需要 git stash 保留?(后续可 git stash pop 取回)
2. 还是直接丢弃?
```

**绝不擅自决定**。AI 一旦 `git reset --hard` 而不问,用户的几小时 / 几天工作可能瞬间消失。

---

## 不同回滚场景的命令选择

| 目标 | 推荐命令 | 影响 |
|---|---|---|
| 撤销最近一次未推送的 commit,保留改动到工作区 | `git reset --soft HEAD~1` | 改动回到 staged |
| 撤销最近一次未推送的 commit,保留改动到工作区(unstaged) | `git reset HEAD~1` | 改动回到 unstaged |
| 撤销最近一次未推送的 commit,丢弃所有改动 | `git reset --hard HEAD~1` ⚠️ | **不可恢复** |
| 撤销已推送的 commit(保留历史) | `git revert <commit>` | 新增反向 commit |
| 还原某个文件到某 commit 的状态 | `git restore --source=<commit> <文件>` | 仅改该文件 |
| 切换分支检查另一版本 | `git checkout <commit>` 进 detached HEAD | 不影响主分支 |

---

## 远程分支回滚的额外注意

### 已推送但**还没人 pull**

可以 `git push --force-with-lease`(比 `--force` 安全,如果远程被别人改过会拒绝)。

### 已推送且**有人 pull 过**

**禁止 force push**。改用 `git revert <commit> && git push` 走反向 commit,保留历史。

### 主分支(main / master)

**绝不在主分支上 force push**。即使是单人项目也不要养成习惯。

---

## 回滚后的元文档更新

回滚成功后,**主动询问用户**是否需要:

- 更新 `.session_context.md` 标注本次回滚原因
- 在受影响 SPEC.md 加 ADR 链接说明"为什么放弃 commit X"
- 关闭 / 修改相关 issue / PR(若有)

不要默默回滚不留痕。

---

## 反例(AI 容易踩的坑)

| ❌ | 为什么不行 |
|---|---|
| 用户一说"撤销" 就 `git reset --hard HEAD~1` | 跳过 step 3 解释,可能丢未提交改动 |
| `git push --force` 推主分支 | 即使是单人项目,毁掉自己的备份 |
| 删 `.git/refs/heads/<branch>` | 不可逆,有人会真这么干 |
| 不回报 `git log` 给用户看就开始操作 | 用户不知道当前在哪 |
| 用 `git checkout -- .` 当撤销工作区改动的常规命令 | 改动直接丢,问都不问 |
