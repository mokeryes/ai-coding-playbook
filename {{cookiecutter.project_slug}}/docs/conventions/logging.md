# 日志规范

> 阶段 1 占位文件。**阶段 2 会从 wework-opus `CLAUDE.md` § 8 抽取并扩充**。

## 当前要点(摘要)

- 同时输出到 stdout 和文件
- 文件路径:`./logs/<模块名>.log`,按日期切割
- 关键事件 INFO 级,常规流转 DEBUG 级
- 异常用 `log.exception` 带 traceback

## TODO(阶段 2 填充)

- 日志框架选型(`{{ cookiecutter.primary_language }}` 相关)
- 日志格式(timestamp / level / module / message)
- 敏感信息打码规则
- 集中日志的对接方式(若有)
