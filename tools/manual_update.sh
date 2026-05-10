#!/usr/bin/env bash
# manual_update.sh — 在已接入 ai-coding-playbook 的项目里,等价于 cruft update。
#
# 为什么需要本脚本?
#   cruft update 内部要用 .cruft.json 的旧 commit 重新渲染 base,如果旧 commit
#   有 binaryornot 误判的文件(短小、CJK 密集),且新 commit 已经修复(加了
#   ASCII header),会因 base/latest binary/text 类型不一致触发:
#     'Unable to interpret changes between current project and cookiecutter
#      template as unicode'
#   本脚本绕过 base 重渲染,直接用最新 playbook 渲染 latest shadow,把变化的
#   文件覆盖到当前项目,然后更新 .cruft.json 指向最新 commit。
#
# 用法(在接入了 playbook 的项目根目录):
#   curl -fsSL https://raw.githubusercontent.com/mokeryes/ai-coding-playbook/main/tools/manual_update.sh | bash
# 或下载后:
#   curl -fsSLO https://raw.githubusercontent.com/mokeryes/ai-coding-playbook/main/tools/manual_update.sh
#   bash manual_update.sh
#   rm manual_update.sh
#
# 行为契约:
#   - 必须在 .cruft.json 所在目录跑(项目根)
#   - 用 .cruft.json 中的 context 渲染最新 shadow
#   - 把 shadow 文件 rsync 到当前目录,但 **尊重 .cruft.json 的 skip 列表**
#   - 更新 .cruft.json 的 commit / _commit 到最新,但保留原 skip 列表
#   - 不触碰 .git
#   - 不自动 commit,留给用户审 + 提交

set -euo pipefail

# ---- 1. 前置检查 -----------------------------------------------------------
if [ ! -f .cruft.json ]; then
  echo "ERROR: 未在当前目录找到 .cruft.json。"
  echo "本脚本必须在已接入 ai-coding-playbook 的项目根目录运行。"
  exit 1
fi

for cmd in cruft python3 rsync; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: 依赖 '$cmd' 未安装。"
    exit 1
  fi
done

# ---- 2. 解析 .cruft.json ---------------------------------------------------
TEMPLATE=$(python3 -c "import json; print(json.load(open('.cruft.json'))['template'])")
PROJECT_SLUG=$(python3 -c "import json; print(json.load(open('.cruft.json'))['context']['cookiecutter']['project_slug'])")

# 提取 context(去掉 _template / _commit 这两个 cruft 内部字段)
CONTEXT_JSON=$(python3 -c "
import json
d = json.load(open('.cruft.json'))
ctx = dict(d['context']['cookiecutter'])
ctx.pop('_template', None)
ctx.pop('_commit', None)
print(json.dumps(ctx, ensure_ascii=False))
")

# 提取 skip 列表(用于 rsync exclude + 保留)
SKIP_LIST=$(python3 -c "
import json
print('\n'.join(json.load(open('.cruft.json')).get('skip', [])))
")

OLD_COMMIT=$(python3 -c "import json; print(json.load(open('.cruft.json'))['commit'][:7])")

# ---- 3. 渲染 latest shadow -------------------------------------------------
SHADOW=$(mktemp -d -t playbook-shadow-XXXXXX)
trap 'rm -rf "$SHADOW"' EXIT

echo "[manual_update] 用 template=$TEMPLATE 渲染最新 shadow..."
cruft create "$TEMPLATE" --no-input --output-dir "$SHADOW" \
  --extra-context "$CONTEXT_JSON" >/dev/null 2>&1 || {
  echo "ERROR: cruft create 失败,可能 template URL 不可达或 cookiecutter.json 变量不兼容。"
  exit 1
}

SHADOW_PROJECT="$SHADOW/$PROJECT_SLUG"
NEW_COMMIT=$(python3 -c "import json; print(json.load(open('$SHADOW_PROJECT/.cruft.json'))['commit'][:7])")

if [ "$OLD_COMMIT" = "${NEW_COMMIT}" ]; then
  echo "[manual_update] 已是最新($OLD_COMMIT),无需同步。"
  exit 0
fi

echo "[manual_update] 升级:$OLD_COMMIT → ${NEW_COMMIT}"

# ---- 4. rsync 覆盖(尊重 skip 列表)----------------------------------------
RSYNC_EXCLUDES=(--exclude=.git --exclude=.cruft.json)
if [ -n "$SKIP_LIST" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] && RSYNC_EXCLUDES+=(--exclude="$f")
  done <<< "$SKIP_LIST"
  echo "[manual_update] skip 保留(不覆盖):$(echo "$SKIP_LIST" | tr '\n' ' ')"
fi

rsync -a "${RSYNC_EXCLUDES[@]}" "$SHADOW_PROJECT/" "./"

# ---- 5. 更新 .cruft.json(保留 skip 列表)----------------------------------
python3 - <<EOF
import json
old = json.load(open('.cruft.json'))
new = json.load(open('$SHADOW_PROJECT/.cruft.json'))
new['skip'] = old.get('skip', [])
with open('.cruft.json', 'w') as f:
    json.dump(new, f, indent=2, ensure_ascii=False)
    f.write('\n')
EOF

# ---- 6. 报告 ---------------------------------------------------------------
echo
echo "[manual_update] ✅ 同步完成,template commit 已切到 ${NEW_COMMIT}。"
echo
echo "下一步:"
echo "  git status                    # 看变化"
echo "  git diff                      # 审改动"
echo "  cruft check                   # 验证 up to date"
echo "  git add . && git commit -m \"chore: 手动等价 cruft update 至 ${NEW_COMMIT}\""
