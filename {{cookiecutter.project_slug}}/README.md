# {{ cookiecutter.project_name }}

{{ cookiecutter.project_description }}

## Tech Stack

- 语言:{{ cookiecutter.primary_language }}
- 概要:{{ cookiecutter.tech_stack_summary }}

## Owner

{{ cookiecutter.owner }} <{{ cookiecutter.owner_email }}>

## Status

🚧 Just bootstrapped from [mokeryes/ai-coding-playbook](https://github.com/mokeryes/ai-coding-playbook).

### Bootstrap 收尾(只做一次)

```bash
cd {{ cookiecutter.project_slug }}
./scripts/finish_setup.sh   # git init + first commit(把 .cruft.json 入库)
```

完成后可删除该脚本:`rm scripts/finish_setup.sh && rmdir scripts`。

## 文档导航

| 入口 | 用途 |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | AI 会话规则 + 项目宪法 |
| [`docs/conventions/`](docs/conventions/) | 编码风格 / 日志 / commit 规范 |
| [`docs/workflows/`](docs/workflows/) | SPEC-driven / 提交自检 / 回滚 / 汇报 SOP |
| [`docs/templates/`](docs/templates/) | SPEC / ADR / 模块 README 模板 |

## Playbook 同步

```bash
cruft check        # 看 playbook 是否有更新
cruft update       # 应用更新(3-way merge)
```
