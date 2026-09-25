# CI/CD for a Simple Python App with GitHub Actions and a Linux Self-Hosted Runner

This project deploys a simple Python app automatically when you push to `main`.

## What is included

- A simple Flask app (`app.py`)
- Tests with `pytest` (`tests/test_app.py`)
- GitHub Actions workflow (`.github/workflows/deploy.yml`)
- Linux deployment script (`scripts/deploy.sh`)
- `systemd` service deployment using Gunicorn

## Runner labels used

The workflow expects this runner label set:

- `self-hosted`
- `linux`
- `x64`
- `python-app`

## 1) Create and register a self-hosted runner (Linux)

In your GitHub repository:

1. Go to **Settings > Actions > Runners**.
2. Click **New self-hosted runner**.
3. Choose **Linux** and **x64**.
4. Run the provided commands on your Linux machine, for example:

```bash
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/latest/download/actions-runner-linux-x64.tar.gz
tar xzf ./actions-runner-linux-x64.tar.gz
./config.sh --url https://github.com/<OWNER>/<REPO> --token <TOKEN> --labels python-app
./run.sh
```

To run it as a service (recommended):

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

## 2) Install required packages on the runner machine

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip rsync curl
```

## 3) Allow passwordless sudo for deployment commands

The deploy script uses `sudo` for `/opt` and `systemd` operations. Add a sudoers rule for your runner user:

```bash
sudo visudo
```

Add a line like this (replace `runneruser`):

```text
runneruser ALL=(ALL) NOPASSWD: /bin/mkdir, /usr/bin/rsync, /usr/bin/tee, /bin/systemctl
```

## 4) Push this project to GitHub

When you push to `main`, the workflow will:

1. Run tests on the self-hosted runner.
2. Deploy app files to `/opt/simple-python-app`.
3. Create/update `simple-python-app.service`.
4. Restart service and verify `/health`.

## 5) Verify deployment

On the runner machine:

```bash
systemctl status simple-python-app
curl http://127.0.0.1:8000/health
```

Expected response:

```json
{"status":"ok"}
```

## Notes

- Change deployment path/port by editing environment values in `.github/workflows/deploy.yml`.
- The app is served by Gunicorn on port `8000`.
- If you want external access, open firewall/security-group port `8000` or place Nginx in front.
