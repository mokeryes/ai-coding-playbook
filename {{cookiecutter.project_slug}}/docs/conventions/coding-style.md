# 编码风格(强制约束)

> CLAUDE.md § 5 的展开版。每条规则给出"为什么"和典型场景。
> 与具体语言({{ cookiecutter.primary_language }})无关的部分在前,语言相关补充在末尾。

---

## 总原则

```
清晰 > 优雅 > 抽象
显式 > 隐式
同步 > 异步
少即是多
```

每条原则都不是"宁可"而是"强制"。当你想偏离时,在 SPEC.md 写明"为什么这里破例",由用户决定。

---

## 1. 清晰 > 优雅(禁止过度抽象)

**规则**:不用装饰器魔法、元类、复杂泛型、难以静态追踪的反射机制。

**为什么**:本项目主要由 1-2 人维护,大量代码由 AI 生成 / 修改。代码必须 grep 友好 — 任何变量、函数、类的定义点都应一次搜索定位,不要藏在多层间接里。

**反例**:动态用 `__getattr__` 拼接方法名 / 用元类自动注册子类 / 抽象一个"通用字段处理器"覆盖所有 schema。

**正例**:每个模块按需写明确的函数,重复就重复,等到第三处雷同再考虑抽象。

---

## 2. 显式 > 隐式(配置必须显式)

**规则**:配置项缺失 → 抛错并告知缺哪个 key,**不偷偷使用默认值**。

**为什么**:隐式默认值是事故温床。一旦默认值与实际期望不符,bug 难以定位 — 代码看起来对、行为却出错。

**反例**:`timeout = config.get('TIMEOUT', 30)`(默默用 30 秒)。

**正例**:`timeout = config['TIMEOUT']`(KeyError 时报错明确)。

如果某项**真的**有合理默认值,在 SPEC.md § 13 默认值章节明确登记,不在代码里偷偷设。

---

## 3. 同步 > 异步(默认同步)

**规则**:除非明确需要并发(I/O 密集 + 单进程吞吐瓶颈),否则用同步代码。

**为什么**:async / coroutine / actor 这类并发原语会指数级放大调试复杂度(死锁、竞态、错误传播、栈追踪丢失)。日常业务场景同步轮询就够。

**反例**:为了"看起来现代"把每个 I/O 都包成 async,结果错误处理散落在跨多个 await 点的 `try/except` 里。

**正例**:单进程 + 同步循环 + 阻塞 I/O。如果真要并发,用 process pool / thread pool,而不是 async。

---

## 4. 少即是多(行数硬限制)

**规则**:
- 文件 ≤ 200 行
- 函数 ≤ 50 行
- 超过就拆,不接受"特例"

**为什么**:行数是认知复杂度的代理。超过 200 行的文件几乎一定混入了多个职责;超过 50 行的函数几乎一定可以拆。

**反例**:一个 500 行的 `runner.py` 既做配置加载又做 SDK 调用又做数据库写入又做事件发布。

**正例**:
```
runner.py        # 主循环
filter.py        # 消息分类
persistence.py   # 落库 / 上传
publisher.py     # 事件发布
```
每个 50-150 行,单一职责。

---

## 5. 日志先行

**规则**:每个**模块入口** / **关键决策点** / **外部调用前后**必须有日志。

**为什么**:出问题时,没日志就只能猜。容器化部署后,日志是唯一可观测面。

详见 [`logging.md`](logging.md)。

---

## 6. 代码注释为中文

**规则**:代码内注释、文档字符串(docstring)、log 措辞、用户可见的报错文案 — **全部中文**。

**为什么**:本项目主要协作者母语为中文。中文注释更直接,沟通成本更低。

**反例**:
```python
# Calculate the moving average
def moving_avg(values): ...
```

**正例**:
```python
# 计算滑动平均值,窗口大小由调用方指定
def moving_avg(values): ...
```

---

## 7. 变量名 / 函数名 / 文件名为英文

**规则**:**所有标识符全英文**(变量、函数、类、方法、模块、文件夹、文件名)。

**为什么**:中文标识符在工具链上会触发编码 / 路径 / git 体验问题(终端显示、IDE 跳转、grep 匹配、CI 日志)。

**反例**:`def 计算平均值(values): ...`(Python 3 技术上支持,但工具链脆弱)。

**正例**:`def moving_avg(values): ...` + 中文注释解释作用。

---

## 语言相关补充({{ cookiecutter.primary_language }})

> 各项目根据 `primary_language` 自行扩展。例:
>
> - **Python**:`from __future__ import annotations` 强制延迟求值;`mypy --strict` 全开;不用 `*args / **kwargs` 收兜底
> - **Swift**:统一 `Result<T, Error>` 处理可恢复失败;`fatalError` 仅用于不可达分支;`@MainActor` 显式标注 UI 边界
> - **TypeScript**:`tsconfig.json` strict mode 全开;视 `any` 为错误;Zod 校验外部输入
> - **Go**:`errors.Is / errors.As` 处理 wrapped errors;`golangci-lint` 全开
> - **Rust**:`#![warn(clippy::all)]` 默认开;不用 `unwrap()` 在生产路径

---

## 命名约定补充

| 范畴 | 风格 | 示例 |
|---|---|---|
| 文件 / 文件夹 | snake_case | `meta_collector/` `runner.py` |
| 类型 / 类 / Enum | PascalCase | `MetaEvent` `MsgType` |
| 函数 / 变量 | snake_case(Python/Rust) / camelCase(TS/Swift) | `parse_xml` / `parseXML` |
| 常量 | UPPER_SNAKE_CASE | `MAX_BATCH_SIZE` |

具体语言可覆盖以上,但**全项目内统一**,不混搭。
