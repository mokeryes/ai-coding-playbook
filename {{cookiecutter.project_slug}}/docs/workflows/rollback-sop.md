# 回滚操作 SOP

> 阶段 1 占位文件。**阶段 2 会从 wework-opus `CLAUDE.md` § 14.1 抽取并扩充**。

## 触发时机

用户要求"回退到某个 commit"或"撤销某次改动"时。

**绝不直接** `git reset --hard`。

## 5 步流程(摘要)

1. 确认目标 commit 存在:`git rev-parse --verify <commit>`
2. 检查当前工作区状态:`git status --short`
3. 向用户**明确说明**将要执行的操作(粒度到具体命令),等用户批准
4. 执行用户明确批准的 Git 操作
5. 再次确认 HEAD 和工作区状态:
   ```bash
   git rev-parse --short HEAD
   git status --short
   ```

## 工作区有未提交改动时

先问用户:
- 是否需要 `git stash` 保留?
- 还是直接丢弃?

**绝不擅自决定**。

## TODO(阶段 2 填充)

- 不同回滚场景的命令选择(reset / revert / restore / checkout)
- 远程分支回滚的额外注意事项(force push)
- 回滚后 .session_context 的更新指引
