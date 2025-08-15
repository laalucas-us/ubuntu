FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/laalucas-us/ubuntu.git"

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    APP_PORT=7860

# 安装依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata curl vim net-tools iputils-ping unzip ca-certificates bash && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 创建普通用户 sealos
RUN useradd -m -s /bin/bash sealos && \
    echo "sealos:x:1000:1000:sealos:/home/sealos:/bin/bash" >> /etc/passwd

WORKDIR /usr/local/bin

# 下载 ttyd 和启动脚本
RUN curl -L -o ttyd https://github.com/laalucas-us/ubuntu/raw/refs/heads/main/ttyd && \
    curl -L -o start-terminal.sh https://raw.githubusercontent.com/laalucas-us/ubuntu/refs/heads/main/start-terminal.sh && \
    chmod +x ttyd start-terminal.sh

# 设置工作目录
WORKDIR /app
# 下载可选自定义首页
RUN curl -L -o index.html https://raw.githubusercontent.com/laalucas-us/ubuntu/refs/heads/main/index.html

# 暴露 APP_PORT
EXPOSE $APP_PORT

# 安装 cloudflared
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# 默认启动脚本
CMD ["start-terminal.sh"]
