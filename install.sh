#!/bin/bash
set -e

CUDA_VERSION="cu121"  # options: cu118, cu124, cpu

# ── Python / uv ───────────────────────────────────────────────────────────────
command -v uv &>/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh

if [ ! -f pyproject.toml ]; then
  cat > pyproject.toml <<EOF
[project]
name = "project"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "torch",
    "transformers",
    "datasets",
    "accelerate",
    "tqdm",
    "anthropic",
]

[tool.uv.sources]
torch = [{ index = "pytorch-cuda" }]

[[tool.uv.index]]
name = "pytorch-cuda"
url = "https://download.pytorch.org/whl/${CUDA_VERSION}"
explicit = true
EOF
fi

uv sync

# ── Claude Code ───────────────────────────────────────────────────────────────
mkdir -p .claude/agents .claude/skills

if [ ! -f .claude/settings.json ]; then
  cat > .claude/settings.json <<EOF
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
EOF
fi

if [ ! -f CLAUDE.md ]; then
  cat > CLAUDE.md <<EOF
# Project

## Setup
\`\`\`bash
uv sync
source .venv/bin/activate
\`\`\`

## Verify GPU
\`\`\`bash
python -c "import torch; print(torch.cuda.is_available())"
\`\`\`
EOF
fi
