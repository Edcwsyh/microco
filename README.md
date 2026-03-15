# microco 🤖

由6个专职AI Agent组成的微型软件开发团队，模拟公司协作流程，实现项目自动化开发。

## 团队成员

| Agent | 角色 | 职责 |
|-------|------|------|
| microco-pm | PM | 任务调度、进度追踪、信息中转 |
| microco-planner | 策划 | 需求分析、策划文档输出 |
| microco-architect | 主程 | 技术评估、架构设计、开发计划拆分 |
| microco-coder | 程序 | 按开发计划编写代码 |
| microco-ops | 运维 | 环境配置、脚本编写 |
| microco-reviewer | Reviewer | 代码审查、质量评估、问题反馈 |
| microco-qa | QA | 编写测试用例、验收代码质量 |

## 协作流程

```
用户 → PM → 策划 → [用户审核] → 主程 → [用户审核] → 运维+主程(并行) → 程序 → Reviewer → QA → 交付
```

## 使用方法

各 agent 的 system prompt 存放在 `agents/` 目录下：

```
agents/
├── pm/prompt.txt          # PM agent
├── planner/prompt.txt     # 策划 agent
├── architect/prompt.txt  # 主程 agent
├── coder/prompt.txt       # 程序 agent
├── reviewer/prompt.txt    # Reviewer agent
├── ops/prompt.txt         # 运维 agent
└── qa/prompt.txt          # QA agent
```

### 接入方式

将对应 agent 的 `prompt.txt` 内容配置到你的 AI agent 框架中（如 OpenCode、Claude Code、Coze 等）。

### 目录规范

项目开发过程中会创建以下目录：

```
project_root/
├── progress/
│   └── progress_log.md    # PM 维护的进度文档
├── docs/
│   ├── plan_doc.md        # 策划文档
│   ├── arch_overview.md   # 开发概要
│   └── review_notes.md    # Code Review 记录
├── plans/
│   └── plan_<module>.md   # 细化开发计划书
├── scripts/
│   └── setup_env.sh       # 环境配置脚本
├── tests/
│   ├── test_cases_*.md    # 测试用例
│   └── bug_report_*.md   # 缺陷报告
└── src/                   # 项目代码
```

## 设计原则

- **职责严格隔离**：每个 Agent 只能做规定范围内的事
- **信息必经 PM**：任何 Agent 间的信息流转必须通过 PM 中转
- **文档驱动**：所有工作产出均以磁盘文档为载体
- **用户审核节点**：策划文档、开发概要均需用户确认后才能进入下一阶段

## License

MIT
