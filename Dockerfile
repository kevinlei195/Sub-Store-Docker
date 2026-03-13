FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache curl unzip caddy dcron

# 下载最新后端版本
RUN mkdir -p /app/backend /app/frontend && \
    curl -sL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o /app/backend/sub-store.min.js && \
    curl -sL https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip -o /tmp/dist.zip && \
    unzip -q /tmp/dist.zip -d /app/frontend/ && \
    rm /tmp/dist.zip

WORKDIR /app/backend
COPY backend/package.json ./
RUN npm install --omit=dev

# supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
COPY supervisord.conf /etc/supervisord.conf

# Caddy
COPY Caddyfile /etc/caddy/Caddyfile
RUN mkdir -p /etc/caddy /var/log/caddy

# Cron
RUN touch /etc/crontabs/root && chmod 0644 /etc/crontabs/root

ENTRYPOINT ["/entrypoint.sh"]
