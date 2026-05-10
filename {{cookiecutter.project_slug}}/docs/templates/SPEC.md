# <模块名> 规格文档(SPEC)

> 本文件由 AI 在「方案确认阶段」撰写,用户审核通过(明确说"开始写代码")后才进入实现阶段。
> 联调验证阶段以本文件第 9 节「验收标准」为准。
> 详细工作流见 [`docs/workflows/spec-driven.md`](../workflows/spec-driven.md)。
>
> **使用方式**:复制本模板到 `app/modules/<X>/SPEC.md`(或 `docs/specs/<feature>.md`),逐节填写,删除占位说明。

---

## 1. 背景与目标

(为什么做这个模块 / 特性?解决什么业务问题?在系统架构中处于什么位置?)

---

## 2. 输入

### 2.1 订阅事件

| Stream | event_type | 用途 |
|---|---|---|

### 2.2 读取表

| 库 | 表 | 字段 | 用途 |
|---|---|---|---|

### 2.3 外部依赖

(若调用第三方 API / SDK,在此列出:服务名 / endpoint / 鉴权方式 / 限流)

---

## 3. 输出

### 3.1 发布事件

| Stream | event_type | 字段 | 触发条件 | 下游消费方 |
|---|---|---|---|---|

### 3.2 写入表

| 库 | 表 | 字段 | 触发条件 |
|---|---|---|---|

### 3.3 副作用

(若有非幂等的副作用 — 调用外部、发邮件、转账等 — 在此声明)

---

## 4. 文件结构

```
app/modules/<X>/
├── __init__.py
├── __main__.py        # 入口
├── runner.py          # 主循环
└── ...
```

依赖的共享基础设施:

| `app/shared/<X>` | 用途 |
|---|---|

---

## 5. 关键函数签名

```python
def consume_event(event: BaseEvent) -> None:
    """..."""

def call_external(payload: dict) -> dict:
    """..."""
```

---

## 6. 数据库 schema(完整 DDL)

```sql
CREATE TABLE IF NOT EXISTS <table> (
  id BIGSERIAL PRIMARY KEY,
  ...
);
```

(若涉及修改既有表,在此列 ALTER + 影响范围 + 回滚 DDL)

---

## 7. 事件 schema

```python
class XxxAdded(BaseEvent):
    event_type: str = "x.xx.added"
    ...
```

(对应文件:`app/shared/events/<X>_events.py`)

---

## 8. 错误处理与降级

| 异常类型 | 处置动作 | 状态归宿 | 是否 ack |
|---|---|---|---|
| 网络超时 | 重试 N 次 | success / failed | 是 |
| JSON 解析失败 | 落 failed,不重试 | failed | 是 |
| 上游服务 5xx | 退避 1s/2s/4s | success / failed | 是 |

---

## 9. 验收标准

联调期 AI 与用户共同核对(每条要可执行、可观测):

- [ ] 启动容器后日志显示 `XXX`
- [ ] 喂入 N 条样本数据,观察 ...
- [ ] 数据库可以查到 `SELECT ... FROM ... WHERE ...`
- [ ] Redis 中可以看到 `XLEN <stream>` 增加
- [ ] 失败路径触发后 ...
- [ ] 优雅退出:`podman stop` 之后日志末尾出现 ...

---

## 10. 成功条件

正常路径下的预期行为(具体到数据状态):

- 输入 `<样例>` → 输出 `<样例>`
- 数据库中 `<表>.<字段>` 状态变为 `<值>`

---

## 11. 失败条件

已知会失败的输入 / 边界(以及预期处理):

| 输入 | 失败原因 | 预期处理 |
|---|---|---|

---

## 12. 回退策略

失败时下游如何兜底,数据状态怎么收敛:

- 一次性失败:...
- 持续失败:...
- 与人工兜底模块的衔接点:...

---

## 13. 默认值

(对照 [`docs/conventions/coding-style.md`](../conventions/coding-style.md) §"显式 > 隐式":配置项必须显式指定。**默认值要在这里登记,代码里不许偷偷设**)

| 配置项(.env) | 默认 | 没填的行为 |
|---|---|---|
| `XXX_TIMEOUT_SEC` | `30` | 启动时直接抛错并打印缺失变量名 |

---

## 14. 本期不做

(明确划出范围外的事项,避免实现期边界蔓延)

- 不做 X(留给下个迭代)
- 不做 Y(本期 schema 已预留字段,等手续办齐再实现)
- Z 不在本期范围

---

## 附录 A:相关 ADR(可选)

如果实现期遇到非显然决策,链到对应 ADR 文件:

- [`docs/adr/ADR-0001-xxxx.md`](../adr/ADR-0001-xxxx.md):为什么选 X 而不是 Y
