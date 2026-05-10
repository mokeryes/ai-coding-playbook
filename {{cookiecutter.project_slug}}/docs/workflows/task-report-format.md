# 任务收尾汇报格式

> CLAUDE.md § 10 的展开版。
> 每个独立任务交付时(代码写完、文档改完、配置改完之后),AI 按本格式汇报。

---

## 6 项汇报清单

| # | 项 | 内容 | 例子 |
|---|---|---|---|
| 1 | **完成了什么** | 1-2 句话讲清"做了什么、为什么" | "把缓存失效改成事件驱动,订阅 `cache.invalidate.requested` 后立即清 Redis,延迟从 0-30s 降到 <100ms。" |
| 2 | **修改了哪些文件** | 列表带相对路径,标注 [新建] / [修改] / [删除] | `app/cache/invalidator.py` [新建] |
| 3 | **新增了哪些测试 / 验证** | 测试文件路径或验证脚本 | "本任务无新增,纯逻辑覆盖在既有 `tests/cache/test_keys.py`" |
| 4 | **AI 自跑了哪些验证** | 跑过的命令 + 结果 | "✅ `python -m py_compile app/...` / ✅ `python -c 'import ...'`" |
| 5 | **哪些内容未验证** | 给出明确命令让用户跑 | "真实 Redis 高 QPS 表现没测;请跑 `docker exec myapp python -m app.cache.benchmark`" |
| 6 | **用户下一步建议** | 明确命令 / 明确步骤 | "1. 部署 staging / 2. 看吞吐 / 3. commit message: `feat(cache): 事件驱动失效`" |

无关项可省略(标注"无")。**绝不写长篇解释**,除非用户问"为什么"。

---

## 好示例(虚构场景:缓存失效器改造完成)

> ### 1. 完成了什么
> 把缓存失效改成事件驱动 + 配置文件可热更。订阅 `cache.invalidate.requested` 事件后立即清 Redis;`config/cache_rules.yaml` 改完 SIGHUP 即生效,无需重启服务。
>
> ### 2. 修改的文件
> - `app/cache/invalidator.py` [新建] — 事件订阅 + Redis 清理
> - `app/api/order_service.py` [修改] — 写订单后发布 `cache.invalidate.requested`
> - `config/cache_rules.yaml` [新建] — key 模式匹配规则
> - `scripts/reload_cache_rules.sh` [新建] — SIGHUP 触发热更
>
> ### 3. 新增测试 / 验证
> - `tests/cache/test_invalidator.py`(纯逻辑:key 模式匹配 + 事件序列化,5 用例)
> - 真实 Redis + 事件总线集成测试留给联调。
>
> ### 4. AI 自跑的验证
> - ✅ `python -m py_compile app/cache/invalidator.py app/api/order_service.py`
> - ✅ `python -c "from app.cache.invalidator import CacheInvalidator; CacheInvalidator()"`
> - ✅ `python -m pytest tests/cache/`(5 passed)
>
> ### 5. 未验证
> 真实 Redis 高 QPS 下吞吐表现 + 多消费者竞争行为。需要你跑:
> ```bash
> docker exec myapp python -m app.cache.invalidator --benchmark
> docker logs myapp | grep invalidator
> ```
>
> ### 6. 下一步建议
> 联调通过后,可以提交。建议 commit message:
> `feat(cache): 改事件驱动失效 + 配置文件可热更`

---

## 反例(AI 容易踩的坑)

### 反例 1:写流水账

❌ 不好:
> "我先读了 `invalidator.py`,看到现在的代码是这样写的: ... 然后我想到可以这样改:... 接下来我修改了 `cache_rules.yaml`,先加了 key 模式,再加了 ... 一共写了 80 行代码。"

✅ 好:用 6 项格式,直接说**做了什么 / 改了什么 / 哪里没验**,不要复述思考过程。

### 反例 2:省略"未验证"

❌ 不好:跳过 § 5,默认所有都验过了。

✅ 好:即使跑过基础验证,也要明确说"集成 / DB / 外部 SDK 我没跑,需要你 ...";让用户清楚 AI 验证的边界。

### 反例 3:"下一步"模糊

❌ 不好:
> "建议测试一下"

✅ 好:
> "建议跑这条命令验证: `docker exec myapp python -c 'from x import y; y()'`,看输出是否含 'OK'"

### 反例 4:把 commit 步骤替用户做了

❌ 不好:汇报完 6 项后直接 `git commit`。

✅ 好:在 § 6 写出建议的 commit message,**等用户说"提交"再走 [`pre-commit-checklist.md`](pre-commit-checklist.md)**。

---

## 与 git diff / git status 的关系

§ 2 修改的文件清单可以直接用 `git status --short` + `git diff --stat` 输出,不必手抄。但要**整理成人类可读列表**(不是直接贴 git 输出)。

如果改动**很多**(超过 10 个文件),按目录或职责分组:

```
### 2. 修改的文件
- 核心实现(5 个):
  - app/cache/invalidator.py [新建]
  - ...
- 配置(2 个):
  - config/cache_rules.yaml [新建]
  - .env [修改] — 加 REDIS_URL 变量
- 脚本(1 个):
  - scripts/reload_cache_rules.sh [新建]
```

---

## 多任务批量汇报

如果用户一次让你做了多个独立任务(罕见),分别按 6 项格式汇报,用 `### 任务 1` `### 任务 2` 切开,不要混汇报。
