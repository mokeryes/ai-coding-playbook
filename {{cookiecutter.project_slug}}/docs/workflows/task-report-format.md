# 任务收尾汇报格式

> CLAUDE.md § 10 的展开版。
> 每个独立任务交付时(代码写完、文档改完、配置改完之后),AI 按本格式汇报。

---

## 6 项汇报清单

| # | 项 | 内容 | 例子 |
|---|---|---|---|
| 1 | **完成了什么** | 1-2 句话讲清"做了什么、为什么" | "把 fun-asr 热词改成文件驱动,改 `config/hot_words.txt` 即可生效,无需重启容器。" |
| 2 | **修改了哪些文件** | 列表带相对路径,标注 [新建] / [修改] / [删除] | `app/modules/transcoder/vocabulary.py` [新建] |
| 3 | **新增了哪些测试 / 验证** | 测试文件路径或验证脚本 | "本任务无新增,纯逻辑覆盖在既有 `tests/test_filter.py`" |
| 4 | **AI 自跑了哪些验证** | 跑过的命令 + 结果 | "✅ `python -m py_compile app/...` / ✅ `python -c 'import ...'`" |
| 5 | **哪些内容未验证** | 给出明确命令让用户跑 | "DashScope 实际调用未跑(需要 API key);用户跑 `podman exec moker-transcoder ...` 验证" |
| 6 | **用户下一步建议** | 明确命令 / 明确步骤 | "1. `./manage.sh --rebuild` 让新代码生效 / 2. 看日志验证热词同步" |

无关项可省略(标注"无")。**绝不写长篇解释**,除非用户问"为什么"。

---

## 好示例(模块二 fun-asr 热词改造完成时)

> ### 1. 完成了什么
> fun-asr 热词改成文件驱动 + 自动同步。`config/hot_words.txt` 改完保存即可,下条 voice 转写就生效。
>
> ### 2. 修改的文件
> - `app/modules/transcoder/vocabulary.py` [新建] — VocabularyService 封装
> - `app/modules/transcoder/transcoder.py` [修改] — transcribe 前调用 vocabulary.sync()
> - `config/hot_words.txt` [新建] — 热词清单(文本)
> - `manage.sh` [修改] — 加 hot_words.txt 存在性前置检查 + 挂载
>
> ### 3. 新增测试 / 验证
> 无(纯外部 SDK 调用,留给联调)。
>
> ### 4. AI 自跑的验证
> - ✅ `podman exec moker-transcoder python -m py_compile app/modules/transcoder/vocabulary.py`
> - ✅ `podman exec moker-transcoder python -c "from app.modules.transcoder.vocabulary import VocabularyService"`
>
> ### 5. 未验证
> DashScope `list_vocabularies` / `update_vocabulary` 实际调用未测(需要 API key 在 .env)。需要你跑:
> ```bash
> ./fresh_pull.sh   # 触发一次 voice 转写,看 transcoder 日志
> podman logs moker-transcoder | grep vocabulary
> ```
>
> ### 6. 下一步建议
> 联调通过后,可以提交。建议 commit message:
> `feat(transcoder): fun-asr 热词,文件驱动 + 自动同步 vocabulary`

---

## 反例(AI 容易踩的坑)

### 反例 1:写流水账

❌ 不好:
> "我先读了 transcoder.py,看到现在的代码是这样写的: ... 然后我想到可以这样改:... 接下来我修改了 vocabulary.py 的代码,先加了 list_vocabularies 调用,再加了 sync 函数,最后 ... 一共写了 80 行代码。"

✅ 好:用 6 项格式,直接说**做了什么 / 改了什么 / 哪里没验**,不要复述思考过程。

### 反例 2:省略"未验证"

❌ 不好:跳过 § 5,默认所有都验过了。

✅ 好:即使跑过基础验证,也要明确说"集成 / DB / 外部 SDK 我没跑,需要你 ...";让用户清楚 AI 验证的边界。

### 反例 3:"下一步"模糊

❌ 不好:
> "建议测试一下"

✅ 好:
> "建议跑这条命令验证: `podman exec moker-transcoder python -c 'from x import y; y()'`,看输出是否含 'OK'"

### 反例 4:把 commit 步骤替用户做了

❌ 不好:汇报完 6 项后直接 `git commit`。

✅ 好:在 § 6 写出建议的 commit message,**等用户说"提交"再走 [`pre-commit-checklist.md`](pre-commit-checklist.md)**。

---

## 与 git diff / git status 的关系

§ 2 修改的文件清单可以直接用 `git status --short` + `git diff --stat` 输出,不必手抄。但要**整理成人类可读列表**(不是直接贴 git 输出)。

如果改动**很多**(超过 10 个文件),按目录或职责分组:

```
### 2. 修改的文件
- 模块二实现(5 个):
  - app/modules/transcoder/vocabulary.py [新建]
  - ...
- 配置(2 个):
  - config/hot_words.txt [新建]
  - .env [修改] — 加 VOCAB_PREFIX 变量
- 脚本(1 个):
  - manage.sh [修改]
```

---

## 多任务批量汇报

如果用户一次让你做了多个独立任务(罕见),分别按 6 项格式汇报,用 `### 任务 1` `### 任务 2` 切开,不要混汇报。
