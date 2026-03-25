#!/bin/bash
set -e

CUDA_VERSION="cu121"  # cu118, cu124, etc.

command -v uv &>/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh

[ ! -f pyproject.toml ] && cat > pyproject.toml <<EOF
[project]
name = "project"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = ["torch", "transformers", "datasets", "accelerate", "tqdm", "anthropic"]

[tool.uv.sources]
torch = [{ index = "pytorch-cuda" }]

[[tool.uv.index]]
name = "pytorch-cuda"
url = "https://download.pytorch.org/whl/${CUDA_VERSION}"
explicit = true
EOF

uv sync
