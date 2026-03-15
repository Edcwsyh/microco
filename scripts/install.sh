#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
AGENTS_DIR="${OPENCODE_CONFIG_DIR}/agents"
MICROCO_AGENTS_DIR="${SCRIPT_DIR}/../agents"

echo "Installing microco agents for OpenCode..."

mkdir -p "${AGENTS_DIR}"

convert_agent() {
    local name="$1"
    local description="$2"
    local in_file="${MICROCO_AGENTS_DIR}/${name}/prompt.txt"
    local out_file="${AGENTS_DIR}/microco-${name}.md"
    
    if [[ ! -f "$in_file" ]]; then
        echo "  [SKIP] ${name}/prompt.txt not found"
        return
    fi
    
    cat > "$out_file" << EOF
---
description: ${description}
mode: primary
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
convert_agent "pm" "Project Manager - Task scheduling and information routing"
convert_agent "planner" "Planner - Requirements analysis and documentation"
convert_agent "architect" "Architect - Technical evaluation and architecture design"
convert_agent "coder" "Coder - Code implementation per development plans"
convert_agent "ops" "Ops - Environment setup and scripting"
convert_agent "qa" "QA - Testing and quality assurance"
convert_agent "reviewer" "Code Reviewer - Code quality review and improvement suggestions"

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  Open OpenCode and use @microco-pm to invoke the PM agent"
echo "  Or add agents to your opencode.json:"
echo ""
cat << 'EOF'
{
  "agent": {
    "microco-pm": {
      "mode": "primary",
      "prompt": "{file:~/.config/opencode/agents/microco-pm.md}"
    },
    "microco-planner": {
      "mode": "subagent",
      "prompt": "{file:~/.config/opencode/agents/microco-planner.md}"
    },
    "microco-architect": {
      "mode": "subagent",
      "prompt": "{file:~/.config/opencode/agents/microco-architect.md}"
    },
    "microco-coder": {
      "mode": "subagent",
      "prompt": "{file:~/.config/opencode/agents/microco-coder.md}"
    },
    "microco-ops": {
      "mode": "subagent",
      "prompt": "{file:~/.config/opencode/agents/microco-ops.md}"
    },
    "microco-qa": {
      "mode": "subagent",
      "prompt": "{file:~/.config/opencode/agents/microco-qa.md}"
    }
  }
}
EOF
