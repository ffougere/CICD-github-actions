#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/simple-python-app}"
SERVICE_NAME="${SERVICE_NAME:-simple-python-app}"
APP_PORT="${APP_PORT:-8000}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

sudo mkdir -p "$APP_DIR"
sudo rsync -a --delete \
  --exclude ".git" \
  --exclude ".github" \
  "$GITHUB_WORKSPACE/" "$APP_DIR/"

cd "$APP_DIR"
$PYTHON_BIN -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

deactivate

sudo tee "/etc/systemd/system/${SERVICE_NAME}.service" >/dev/null <<EOF
[Unit]
Description=Simple Python App Service
After=network.target

[Service]
User=$USER
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/.venv/bin"
ExecStart=$APP_DIR/.venv/bin/gunicorn -w 2 -b 0.0.0.0:$APP_PORT wsgi:app
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"

sleep 2
curl -fsS "http://127.0.0.1:${APP_PORT}/health" >/dev/null

echo "Deployment completed successfully"
