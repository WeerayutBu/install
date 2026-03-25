# Common Commands

## Quick Install
```bash
curl -fsSL https://raw.githubusercontent.com/WeerayutBu/install/main/install.sh | sh
```

Sets up: Python (uv), PyTorch, Anthropic SDK, Claude Code config.

---

## Python Environment

#### uv (recommended)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh

uv sync                   # install/update from pyproject.toml
uv add <package>          # add a dependency
uv run <command>          # run inside the project env
uvx <tool>                # run a one-off tool (ruff, black, pytest)
```

#### venv
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

#### Migrate venv → uv
```bash
# old env
python -m pip freeze > requirements.txt

# new env
uv venv
uv pip sync requirements.txt
```

---

## Environment Variables
Add to `~/.bashrc`:
```bash
export TMPDIR=your_storage/tmp
export PIP_CACHE_DIR=your_storage/pip-cache
export HF_HOME=your_storage/hf-cache
export TRANSFORMERS_CACHE=your_storage/hf-cache
```

---

## SSH

#### Install & start
```bash
# Ubuntu/Debian
apt install openssh-server

# CentOS/Amazon Linux
sudo yum -y install openssh-server openssh-clients

service ssh start
service ssh status
```

#### Configure (`/etc/ssh/sshd_config`)
```
PubkeyAuthentication yes
PermitRootLogin yes
```
```bash
service ssh restart
```

#### Copy public key
```bash
cat ~/.ssh/id_rsa.pub | ssh user@host 'cat >> ~/.ssh/authorized_keys'
```

---

## AWS EC2

#### Connect
```bash
ssh -i "aws.pem" ec2-user@xxx.compute-1.amazonaws.com
```

#### Python setup
```bash
sudo dnf install -y python3 python3-pip python3-virtualenv
python3 -m venv /tmp/env
python3 -m pip install --upgrade pip setuptools wheel
```

#### Startup (`~/.bashrc`)
```bash
echo 'alias python=python3' >> ~/.bashrc
echo 'source /tmp/env/bin/activate' >> ~/.bashrc
source ~/.bashrc
```
