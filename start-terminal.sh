#!/bin/bash
set -e

# 如果 HF_USER_PASSWORD 为空，使用默认密码
USER_PASSWORD="${HF_USER_PASSWORD:-Sealos123}"

# 如果 HF_CLOUDFLARE_TOKEN 为空，跳过启动 Cloudflare Tunnel
CLOUDFLARE_TOKEN="$HF_CLOUDFLARE_TOKEN"

echo "[INFO] Using ttyd password: $USER_PASSWORD"

# 启动 ttyd（HF 需要 --base-path / 避免 WebSocket 断开）
if [ -f "/app/index.html" ]; then
    /usr/local/bin/ttyd \
        --base-path / \
        -p 7860 \
        --index /app/index.html \
        --credential "admin:$USER_PASSWORD" \
        bash &
else
    /usr/local/bin/ttyd \
        --base-path / \
        -p 7860 \
        --credential "admin:$USER_PASSWORD" \
        bash &
fi

# 启动 Cloudflare Tunnel（仅当 TOKEN 存在）
if [ -n "$CLOUDFLARE_TOKEN" ]; then
    echo "[INFO] Starting Cloudflare Tunnel..."
    cloudflared tunnel run --token "$CLOUDFLARE_TOKEN" &
else
    echo "[INFO] HF_CLOUDFLARE_TOKEN not set. Skipping Cloudflare Tunnel."
fi

# 阻塞，保持前台运行
wait
