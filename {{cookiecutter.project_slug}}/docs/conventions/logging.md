<!-- =============================================================================
encoding: utf-8 (markdown). this top-of-file ascii comment block exists so that
binaryornot/chardet correctly classifies CJK-heavy markdown as text rather than
binary. without it, cookiecutter rendering + cruft 3-way diffs intermittently
fail on short text files dense with chinese characters. do not remove this
block; if you trim, verify with: python -c "from binaryornot.check import is_binary; print(is_binary(\"<file>\"))"
============================================================================= -->

# 日志规范

> CLAUDE.md § 6 的展开版。
> 本规范不绑定具体日志框架,语言层面用什么由项目 § 5 选,但**行为契约必须满足下列要求**。

---

## 4 条强制规则

### 1. 同时输出到 stdout 和文件

**为什么**:容器场景下 stdout 经 `podman logs` / `docker logs` 实时观察,但容器重启 / OOM 后 stdout 会丢;落文件作为持久化兜底。

**实现要点**:
- stdout handler + file handler 各注册一次,**共用同一个 formatter**(避免格式漂移)
- file handler 用 RotatingFileHandler / TimedRotatingFileHandler(避免日志爆盘)

### 2. 文件路径:`./logs/<模块名>.log`,按日期切割

**为什么**:每个模块独立 log 文件,排查时不必在大杂烩里 grep。

**实现要点**:
- 路径相对于项目根,部署时挂载或软链到容器外卷
- 切割规则:每日切割 + 保留 N 天(N 由项目决定,默认 14)
- 切割后命名:`<模块名>.log.YYYY-MM-DD`

### 3. 关键事件 INFO 级,常规流转 DEBUG 级

**为什么**:生产环境只看 INFO 级避免噪音;debug 期切换 DEBUG 级看完整流转;不要在两者之间反复横跳。

**层级建议**:

| 级别 | 用法 | 例子 |
|---|---|---|
| `DEBUG` | 每条消息 / 每次外部调用细节 | `收到消息 msgid=xxx` |
| `INFO` | 模块启动 / 退出 / 关键决策 | `本轮拉取 32 条,新增 28 / 重复 4` |
| `WARN` | 自愈成功的异常 | `重试 1/3 后成功` |
| `ERROR` | 单条失败但不阻塞流程 | `消息 xxx 解密失败,跳过` |
| `EXCEPTION` | 必须带 traceback | 见 § 4 |

### 4. 异常必须 `log.exception` 带 traceback

**为什么**:`log.error("xxx失败: %s", e)` 只打 e 的字符串表示,丢失栈帧。出问题后回不去现场。

**正例**(Python):
```python
try:
    process(msg)
except Exception:
    logger.exception("处理消息失败 msgid=%s", msg.msgid)
    continue
```

**反例**:
```python
except Exception as e:
    logger.error(f"处理失败: {e}")  # ❌ 没栈帧
```

---

## 日志格式建议

```
2026-05-09 14:23:01.234 [INFO] auth.handler: 处理 32 条登录请求,通过 28 / 拒绝 4
└──── 时间戳 ────────┘ └级别┘ └─── 模块路径 ──┘  └─────── 消息(中文) ─────────┘
```

字段顺序:**时间戳 / 级别 / 模块 / 消息**。时间戳精确到毫秒(便于排序合并多模块日志)。

---

## 各语言推荐选型

| 语言 | 推荐库 | 备注 |
|---|---|---|
| Python | 标准库 `logging` + `RotatingFileHandler` | 不用 loguru / structlog 增加学习成本 |
| Swift | `os.Logger`(iOS 14+) + 自写 file 兜底 | 系统集成最佳 |
| TypeScript | `pino`(性能)/ `winston`(生态) | 浏览器场景用 `console` |
| Go | 标准库 `log/slog`(Go 1.21+) | 比 `log` 强,比 `zap` 简单 |
| Rust | `tracing` + `tracing-subscriber` | 现代标准 |

---

## 敏感信息处理

**绝对不打**:密钥、token、私钥内容、用户密码、完整身份证 / 手机号 / 银行卡。

**可打但需脱敏**:用户 ID(后 4 位)、邮箱(`a***@example.com`)、IP(打到 /24)。

**实现**:
- 写一个共享 `mask.py` / `mask.swift` 工具,所有日志前置过滤
- 不要散落在每个模块自己 `replace`

---

## 集中日志(若启用)

如果项目接入了 ELK / Loki / Datadog / 阿里云 SLS,文件日志和集中日志**同时**输出,**不要**只发集中日志(集中日志服务挂了就两眼黑)。

格式优先 JSON-line(便于结构化查询),但要保证人类阅读时也能看懂(关键字段在前)。
