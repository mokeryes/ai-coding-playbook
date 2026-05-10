#!/usr/bin/env bash
# 收尾脚本:cruft create / cookiecutter 跑完后,在生成的项目里运行一次。
#
# 为什么需要本脚本?
#   cookiecutter 的 post_gen hook 跑完之后,cruft 才写 .cruft.json,
#   所以 hook 内的 commit 没法把 .cruft.json 包含进去。本脚本作为接力,
#   做 git init(若未做) + git add -A + first commit,一并把 .cruft.json 入库。
#
# 用法(cd 到生成的项目根目录后):
#   ./scripts/finish_setup.sh
#
# 完成使命后,本脚本可以删除:
#   rm scripts/finish_setup.sh && rmdir scripts 2>/dev/null

set -euo pipefail

# 切到项目根(scripts/ 上一级)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# 1. 验证 .cruft.json 存在(本脚本只在 cruft create 后跑有意义)
if [ ! -f .cruft.json ]; then
  echo "ERROR: .cruft.json 不存在,本脚本应在 'cruft create' 之后运行。"
  echo "  cruft create https://github.com/mokeryes/ai-coding-playbook"
  exit 1
fi

# 2. git init(幂等)
if [ ! -d .git ]; then
  git init --quiet
  echo "[finish_setup] git init"
fi

# 3. stage 所有
git add -A

# 4. 检查是否真有内容可 commit(支持反复跑)
if git rev-parse --verify HEAD >/dev/null 2>&1 && git diff --cached --quiet; then
  echo "[finish_setup] 工作区已干净,无需 commit。本脚本已完成使命,可删除。"
  exit 0
fi

# 5. 从 .cruft.json 提取模板信息作 commit message
TEMPLATE=$(python3 -c "import json; print(json.load(open('.cruft.json'))['template'])")
COMMIT_HASH=$(python3 -c "import json; print(json.load(open('.cruft.json'))['commit'][:7])")

# 6. first commit
git commit --quiet -m "chore: bootstrap from ${TEMPLATE} (commit ${COMMIT_HASH})

通过 cruft create / cookiecutter 生成,模板锁定 commit ${COMMIT_HASH}。

下一步:
- 填充 CLAUDE.md § 1 项目背景 / § 2 系统架构 / § 3 技术栈
- 完成本脚本使命后可删除:rm scripts/finish_setup.sh && rmdir scripts"

echo "[finish_setup] ✅ first commit 已建:"
git log --oneline -1
