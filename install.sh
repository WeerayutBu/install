#!/bin/bash
set -e

PYTHON_VERSION="3.11"
CUDA_VERSION="cu121"  # Change to cu118, cu124, etc. as needed

echo "==> Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

echo "==> Creating virtual environment..."
uv venv .venv --python ${PYTHON_VERSION}
source .venv/bin/activate

echo "==> Installing PyTorch (CUDA ${CUDA_VERSION})..."
uv pip install torch --index-url https://download.pytorch.org/whl/${CUDA_VERSION}

echo "==> Installing core packages..."
uv pip install transformers datasets accelerate tqdm

echo ""
echo "Done! Activate with: source .venv/bin/activate"
echo "Verify GPU: python -c \"import torch; print(torch.cuda.is_available())\""
