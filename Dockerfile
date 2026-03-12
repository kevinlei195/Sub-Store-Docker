FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache curl unzip

# 下载最新后端版本
RUN mkdir -p /app/backend /app/frontend && \
    curl -sL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o /app/backend/sub-store.min.js && \
    curl -sL https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip -o /tmp/dist.zip && \
    unzip -q /tmp/dist.zip -d /app/frontend/ && \
    rm /tmp/dist.zip

WORKDIR /app/backend
COPY backend/package.json ./
RUN npm install --omit=dev

EXPOSE 3000

# 直接运行后端，启用合并模式（前后端合一）
CMD ["node", "sub-store.min.js"]
