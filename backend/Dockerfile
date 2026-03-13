FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --production

COPY sub-store.min.js ./
COPY .env ./

FROM alpine:3.19

RUN apk add --no-cache \
    curl \
    caddy \
    dcron \
    nodejs \
    npm

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/sub-store.min.js ./
COPY --from=builder /app/.env ./

RUN mkdir -p /etc/caddy && \
    mkdir -p /var/log/caddy

RUN touch /etc/crontabs/root && chmod 0644 /etc/crontabs/root

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443 3000

ENTRYPOINT ["/entrypoint.sh"]

CMD ["node", "sub-store.min.js", "crond", "-f", "-l", "2", "caddy", "run", "--config", "/etc/caddy/Caddyfile"]
