#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 安装模式选择
echo "请选择安装模式："
echo "1) 全局安装 (~/.config/opencode/)"
echo "2) 当前目录安装 (./.opencode/)"
read -p "请输入选项 [1]: " install_mode

case "$install_mode" in
    2)
        OPENCODE_CONFIG_DIR="$(pwd)/.opencode"
        ;;
    *)
        OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
        ;;
esac

echo "安装目录: ${OPENCODE_CONFIG_DIR}"
echo ""

JQ="${SCRIPT_DIR}/jq"
JQ_URL="https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux64"
JQ_SHA256="5942c9b0934e510ee61eb3e30273f1b3fe2590df93933a93d7c58b81d19c8ff5"

if [[ ! -x "$JQ" ]]; then
    echo "Downloading jq..."
    curl -fsSL -o "$JQ" "$JQ_URL"
    echo "${JQ_SHA256}  $JQ" | sha256sum -c - || { rm -f "$JQ"; exit 1; }
    chmod +x "$JQ"
    echo "  [OK] jq installed to ${JQ}"
fi

AGENTS_DIR="${OPENCODE_CONFIG_DIR}/agents"
MICROCO_AGENTS_DIR="${SCRIPT_DIR}/../agents"

echo "Installing microco agents for OpenCode..."

mkdir -p "${AGENTS_DIR}"

convert_agent() {
    local name="$1"
    local description="$2"
    local mode="$3"
    local in_file="${MICROCO_AGENTS_DIR}/${name}/prompt.txt"
    local out_file="${AGENTS_DIR}/microco-${name}.md"
    
    if [[ ! -f "$in_file" ]]; then
        echo "  [SKIP] ${name}/prompt.txt not found"
        return
    fi
    
    cat > "$out_file" << EOF
---
description: ${description}
mode: ${mode}
tools:
  write: true
  edit: true
  bash: true
  read: true
  grep: true
  glob: true
  webfetch: true
  websearch: true
  codesearch: true
---
$(cat "$in_file")
EOF
    echo "  [OK] Created microco-${name}.md"
}

echo ""
echo "Creating agents..."
convert_agent "pm" "Project Manager - Task scheduling and information routing" "primary"
convert_agent "planner" "Planner - Requirements analysis and documentation" "subagent"
convert_agent "architect" "Architect - Technical evaluation and architecture design" "subagent"
convert_agent "coder" "Coder - Code implementation per development plans" "subagent"
convert_agent "ops" "Ops - Environment setup and scripting" "subagent"
convert_agent "qa" "QA - Testing and quality assurance" "subagent"
convert_agent "reviewer" "Code Reviewer - Code quality review and improvement suggestions" "subagent"

echo ""
echo "Creating/updating opencode.json configuration..."

OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_FILE:-${OPENCODE_CONFIG_DIR}/opencode.json}"

MICROCO_AGENTS_CONFIG=$(cat << EOF
{
  "agent": {
    "microco-pm": {
      "mode": "primary",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-pm.md}",
      "permission": {
        "task": {
          "microco-coder": "allow",
          "microco-ops": "allow",
          "microco-qa": "allow",
          "microco-planner": "allow",
          "microco-architect": "allow",
          "microco-reviewer": "allow"
        }
      }
    },
    "microco-planner": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-planner.md}"
    },
    "microco-architect": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-architect.md}"
    },
    "microco-coder": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-coder.md}"
    },
    "microco-ops": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-ops.md}"
    },
    "microco-qa": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-qa.md}"
    },
    "microco-reviewer": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-reviewer.md}"
    }
  }
}
EOF
)

if [[ -f "$OPENCODE_CONFIG_FILE" ]]; then
    backup_file="${OPENCODE_CONFIG_DIR}/opencode.json.bak"
    cp "$OPENCODE_CONFIG_FILE" "$backup_file"
    echo "  [INFO] Backed up to ${backup_file}"

    "$JQ" -s '.[0] * (.[1] | if . == null then {} else . end)' "$OPENCODE_CONFIG_FILE" <<< "$MICROCO_AGENTS_CONFIG" > "${OPENCODE_CONFIG_FILE}.tmp"
    mv "${OPENCODE_CONFIG_FILE}.tmp" "$OPENCODE_CONFIG_FILE"
    echo "  [OK] Merged microco agents config into ${OPENCODE_CONFIG_FILE}"
else
    mkdir -p "$(dirname "$OPENCODE_CONFIG_FILE")"
    echo "$MICROCO_AGENTS_CONFIG" > "$OPENCODE_CONFIG_FILE"
    echo "  [OK] Created ${OPENCODE_CONFIG_FILE}"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  Open OpenCode and use @microco-pm to invoke the PM agent"
echo "  Or add agents to your opencode.json:"
echo ""
cat << EOF
{
  "agent": {
    "microco-pm": {
      "mode": "primary",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-pm.md}"
    },
    "microco-planner": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-planner.md}"
    },
    "microco-architect": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-architect.md}"
    },
    "microco-coder": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-coder.md}"
    },
    "microco-ops": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-ops.md}"
    },
    "microco-qa": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-qa.md}"
    },
    "microco-reviewer": {
      "mode": "subagent",
      "prompt": "{file:${OPENCODE_CONFIG_DIR}/agents/microco-reviewer.md}"
    }
  }
}
EOF
