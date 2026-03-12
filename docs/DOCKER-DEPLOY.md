# Sub-Store Docker 部署指南

## 镜像信息

- **镜像名称**: `xream/sub-store`
- **最新版本**: `2.21.45`
- **支持架构**: linux/amd64, linux/arm64/v8

### 可用标签

| 标签 | 说明 |
|------|------|
| `latest` | 最新稳定版 |
| `2.21.45` | 指定版本 |
| `http-meta` | 包含 HTTP-META 功能的版本 |

---

## 快速开始

### 1. Docker CLI 启动

```bash
docker run -d \
  --restart=always \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /root/sub-store-data:/opt/app/data \
  -e SUB_STORE_FRONTEND_BACKEND_PATH=/your-secret-path \
  --name sub-store \
  xream/sub-store
```

### 2. Docker Compose 启动

```yaml
version: '3.8'

services:
  sub-store:
    image: xream/sub-store
    container_name: sub-store
    restart: always
    ports:
      - "3000:3000"
      - "3001:3001"
    volumes:
      - ./data:/opt/app/data
    environment:
      - SUB_STORE_FRONTEND_BACKEND_PATH=/your-secret-path
```

---

## 端口说明

| 端口 | 说明 |
|------|------|
| `3000` | 前端 Web UI |
| `3001` | 后端 API |

---

## 环境变量详解

### 基础配置

| 环境变量 | 必填 | 说明 | 默认值 |
|----------|------|------|--------|
| `SUB_STORE_FRONTEND_BACKEND_PATH` | ✅ | 后端路径密钥 (必须以 `/` 开头) | - |
| `SUB_STORE_FRONTEND_PORT` | - | 前端端口 | `3000` |
| `SUB_STORE_BACKEND_API_PORT` | - | 后端 API 端口 | `3000` |
| `SUB_STORE_FRONTEND_HOST` | - | 前端监听地址 | `::` |
| `SUB_STORE_BACKEND_API_HOST` | - | 后端监听地址 | `::` |
| `SUB_STORE_FRONTEND_PATH` | - | 前端静态文件路径 | `/app/frontend/dist` |
| `SUB_STORE_BACKEND_MERGE` | - | 合并前后端到同一端口 | `false` |

### 定时任务

| 环境变量 | 说明 | 示例 |
|----------|------|------|
| `SUB_STORE_BACKEND_SYNC_CRON` | 同步订阅定时任务 (Cron) | `55 23 * * *` |
| `SUB_STORE_BACKEND_UPLOAD_CRON` | 上传备份到 Gist (Cron) | `55 23 * * 6` |
| `SUB_STORE_BACKEND_DOWNLOAD_CRON` | 从 Gist 下载恢复 (Cron) | `30 2 * * 0` |
| `SUB_STORE_PRODUCE_CRON` | 后台处理订阅定时 | `0 */2 * * *,sub,a;0 */3 * * *,col,b` |

### GitHub Gist 备份

| 环境变量 | 说明 |
|----------|------|
| `GITHUB_USERNAME` | GitHub 用户名 |
| `GITHUB_TOKEN` | GitHub Token (需要 Gist 权限) |

**生成 Token**: GitHub -> Settings -> Developer settings -> Personal access tokens -> Tokens (classic) -> 勾选 `gist`

### 推送服务

| 环境变量 | 说明 |
|----------|------|
| `SUB_STORE_PUSH_SERVICE` | 推送通知服务 URL |

**支持的服务**:
- **Telegram**: `telegram://BOT_TOKEN@telegram?chats=CHAT_ID`
- **Bark**: `https://api.day.app/YOUR_KEY/[推送标题]/[推送内容]?group=SubStore`
- **PushPlus**: `http://www.pushplus.plus/send?token=TOKEN&title=[推送标题]&content=[推送内容]`

### 高级配置

| 环境变量 | 说明 | 示例 |
|----------|------|------|
| `SUB_STORE_BACKEND_PREFIX` | 后端添加路径前缀 | `/api` |
| `SUB_STORE_BACKEND_DEFAULT_PROXY` | 默认代理 | `socks5://user:pass@host:port` |
| `SUB_STORE_MAX_HEADER_SIZE` | Header 大小限制 | `32768` |
| `SUB_STORE_BODY_JSON_LIMIT` | JSON Body 大小限制 | `1mb` |
| `SUB_STORE_DATA_URL` | 远程数据文件 URL | Gist Raw 链接 |
| `SUB_STORE_DATA_URL_POST` | 拉取后执行的命令 | `content.settings.gistToken='xxx'` |
| `SUB_STORE_BACKEND_CUSTOM_NAME` | 自定义运行环境名称 | `My Sub-Store` |
| `SUB_STORE_X_POWERED_BY` | 自定义响应头 | `MyServer` |

### MMDB 数据库 (可选)

用于节点测活等脚本功能:

| 环境变量 | 说明 |
|----------|------|
| `SUB_STORE_MMDB_COUNTRY_PATH` | GeoLite2 Country 数据库路径 |
| `SUB_STORE_MMDB_ASN_PATH` | GeoLite2 ASN 数据库路径 |
| `SUB_STORE_MMDB_COUNTRY_URL` | Country 数据库下载链接 |
| `SUB_STORE_MMDB_ASN_URL` | ASN 数据库下载链接 |
| `SUB_STORE_MMDB_CRON` | MMDB 更新定时 |

---

## 部署模式

### 模式一：前后端分离 (默认)

```bash
# 前端: 3000
# 后端: 3001
docker run -d \
  -p 3000:3000 \
  -p 3001:3001 \
  -e SUB_STORE_FRONTEND_BACKEND_PATH=/secret \
  xream/sub-store
```

### 模式二：前后端合并

```bash
# 合并到 3000 端口
docker run -d \
  -p 3000:3000 \
  -e SUB_STORE_FRONTEND_BACKEND_PATH=/secret \
  -e SUB_STORE_BACKEND_MERGE=true \
  xream/sub-store
```

### 模式三：仅本地访问

```bash
# 仅监听 127.0.0.1
docker run -d \
  -p 127.0.0.1:3000:3000 \
  -p 127.0.0.1:3001:3001 \
  -e SUB_STORE_FRONTEND_BACKEND_PATH=/secret \
  xream/sub-store
```

---

## 访问方式

### 本地访问

| 服务 | 地址 |
|------|------|
| 前端 | http://127.0.0.1:3000 |
| 后端 | http://127.0.0.1:3001/你的密钥 |

### 一键配置 URL

```
http://127.0.0.1:3000?api=http://127.0.0.1:3001/your-secret-path
```

### 验证 API

```bash
# 查看版本信息
curl http://127.0.0.1:3001/your-secret-path/api/utils/env
```

---

## 数据持久化

### 备份数据卷

```bash
# 查看卷
docker volume ls | grep sub-store

# 备份
docker run --rm -v sub-store-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/backup.tar.gz /data

# 恢复
docker run --rm -v sub-store-data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/backup.tar.gz -C /
```

---

## 日志查看

```bash
# 查看日志
docker logs -f sub-store

# 带时间戳
docker logs -f -t --tail 100 sub-store
```

---

## 自动更新

### 使用 Watchtower

```yaml
version: '3.8'

services:
  sub-store:
    image: xream/sub-store
    # ... 其他配置

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_NOTIFICATIONS=shoutrrr
      - WATCHTOWER_NOTIFICATION_URL=telegram://BOT_TOKEN@telegram?chats=CHAT_ID
    command: --interval 3600 sub-store
```

---

## HTTP-META 功能

使用带 `http-meta` 标签的镜像:

```bash
docker run -d xream/sub-store:http-meta
```

HTTP-META 用于支持需要本地代理的 Surge/Clash 等客户端脚本。

---

## 常见问题

### Q: 前端无法连接后端

确保使用正确的 API 地址:
```
http://前端地址?api=http://后端地址/你的密钥
```

### Q: 定时任务不执行

检查 Cron 表达式格式是否正确，例如:
```bash
# 每 6 小时
SUB_STORE_BACKEND_SYNC_CRON=0 */6 * * *

# 每天 23:55
SUB_STORE_BACKEND_SYNC_CRON=55 23 * * *
```

### Q: 备份失败

1. 确认 GitHub Token 具有 Gist 权限
2. 检查 Gist 是否达到数量限制
3. 尝试重新生成 Token

---

## 相关链接

- [Sub-Store 官方仓库](https://github.com/sub-store-org/Sub-Store)
- [Sub-Store 前端仓库](https://github.com/sub-store-org/Sub-Store-Front-End)
- [Telegram 群组](https://t.me/zhetengsha)
- [官方教程](https://xream.notion.site/Sub-Store-abe6a96944724dc6a36833d5c9ab7c87)
