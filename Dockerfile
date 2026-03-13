# Stage 1: Build frontend
FROM node:20-alpine AS builder

RUN apk add --no-cache git pnpm

WORKDIR /tmp
RUN git clone --depth 1 https://github.com/sub-store-org/Sub-Store-Front-End.git && \
    cd Sub-Store-Front-End && \
    pnpm install && \
    pnpm build

# Stage 2: Final image
FROM node:20-alpine

WORKDIR /app

# 安装运行时依赖
RUN apk add --no-cache curl unzip caddy dcron

# 从 builder 复制前端
COPY --from=builder /tmp/Sub-Store-Front-End/dist ./frontend

# 下载后端
RUN mkdir -p backend && \
    curl -sL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o backend/sub-store.min.js

# 安装 npm 依赖
WORKDIR /app/backend
COPY backend/package.json ./
RUN npm install --omit=dev

# 安装 supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord

# 复制配置
COPY supervisord.conf /etc/supervisord.conf
COPY Caddyfile /etc/caddy/Caddyfile
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /etc/caddy /var/log/caddy && \
    touch /etc/crontabs/root && chmod 0644 /etc/crontabs/root

ENTRYPOINT ["/entrypoint.sh"]
