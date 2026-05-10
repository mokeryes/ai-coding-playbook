# 提交前自检 SOP

> 阶段 1 占位文件。**阶段 2 会从 wework-opus `CLAUDE.md` § 15 抽取并扩充**。

## 触发时机

用户说"提交"或"commit"后,AI **不要直接** `git commit`,先做以下检查并回报。

## 检查步骤(摘要)

1. **`git status --short`** — 确认无未追踪的临时文件 / 缓存 / 日志
2. **`git diff`** — 主动汇报改动范围 + 指出"超出方案"的改动 + 指出 `print()` 调试代码
3. **自检清单**:
   - [ ] 只改了本需求 SPEC 涉及的文件
   - [ ] 没有误改 `.session_context.md` / `CLAUDE.md`
   - [ ] 没有提交 `.env` / 私钥 / `keys/`
   - [ ] 没有提交 `logs/` / `__pycache__` / `data/`
   - [ ] 文档(README/SPEC)与代码一致

## TODO(阶段 2 填充)

- 自检失败时的处理流程
- 与 pre-commit hook 工具(若启用)的关系
- 多人协作场景下的额外检查
