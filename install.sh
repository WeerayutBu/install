#!/bin/bash
set -e

CUDA_VERSION="cu121"  # options: cu118, cu124, cpu

# ── Python / uv ───────────────────────────────────────────────────────────────
command -v uv &>/dev/null || { curl -LsSf https://astral.sh/uv/install.sh | sh; export PATH="$HOME/.local/bin:$PATH"; }

if [ ! -f pyproject.toml ]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: torch is available on PyPI with native arm64/x86_64 wheels
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
    "python-dotenv",
]
EOF
  else
    # Linux/Windows: install torch from the pytorch CUDA index
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
    "python-dotenv",
]

[tool.uv.sources]
torch = [{ index = "pytorch-cuda" }]

[[tool.uv.index]]
name = "pytorch-cuda"
url = "https://download.pytorch.org/whl/${CUDA_VERSION}"
explicit = true
EOF
  fi
elif [[ "$(uname)" == "Darwin" ]] && grep -q "pytorch-cuda" pyproject.toml; then
  # pyproject.toml exists but has a CUDA torch source — strip it for macOS
  python3 - <<'PYEOF'
import re, pathlib
p = pathlib.Path("pyproject.toml")
txt = p.read_text()
txt = re.sub(r'\[tool\.uv\.sources\]\ntorch\s*=\s*\[.*?\]\n+', '', txt, flags=re.DOTALL)
txt = re.sub(r'\[\[tool\.uv\.index\]\]\nname\s*=\s*"pytorch-cuda".*?(?=\[\[|\Z)', '', txt, flags=re.DOTALL)
p.write_text(txt.strip() + '\n')
PYEOF
fi

uv sync --python 3.11

# ── Node.js ───────────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
if ! command -v node &>/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
else
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

# ── Claude Code ───────────────────────────────────────────────────────────────
command -v claude &>/dev/null || npm install -g @anthropic-ai/claude-code
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

if [ ! -f .env ]; then
  cat > .env <<EOF
# Environment variables
# ANTHROPIC_API_KEY=your_api_key_here
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
