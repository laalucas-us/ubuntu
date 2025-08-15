FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/laalucas/ubuntu"

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

# 安装依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata curl wget vim net-tools iputils-ping telnet iproute2 unzip neofetch ca-certificates && \
    update-ca-certificates && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 创建普通用户 sealos，保证 /etc/passwd 有条目
RUN useradd -m -s /bin/bash sealos && \
    echo "sealos:x:1000:1000:sealos:/home/sealos:/bin/bash" >> /etc/passwd

# 拷贝 ttyd 和启动脚本
COPY ttyd /usr/local/bin/ttyd
COPY start-terminal.sh /usr/local/bin/start-terminal.sh
RUN chmod +x /usr/local/bin/ttyd /usr/local/bin/start-terminal.sh

# 安装 cloudflared
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

WORKDIR /app
# 可选自定义首页
COPY index.html /app/index.html

EXPOSE 7860

CMD ["start-terminal.sh"]