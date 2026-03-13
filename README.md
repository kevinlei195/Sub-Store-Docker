# Sub-Store Docker 部署

基于 [Sub-Store](https://github.com/sub-store/Sub-Store) 的 Docker 镜像，自动下载最新版本，支持 Caddy 反向代理和定时任务。

## Usage

```
http://localhost:3000/api/utils/env

https://sub-store.vercel.app/subs

http://localhost:3000/download/my?target=JSON
http://localhost/download/my?target=JSON&d_token=mydltoken
```

## 功能特性

- 🚀 Node.js 后端 (端口 3000)
- 🌐 Caddy 反向代理 (端口 80)
- 🔒 API 认证 (Bearer Token)
- 📥 下载认证 (d_token)
- ⏰ 内置定时任务 (每6小时/12小时)
- 📦 Docker Compose 一键部署

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/kevinlei195/Sub-Store-Docker.git
cd Sub-Store-Docker
```

### 2. 配置环境变量

创建 `.env` 文件：

```bash
cp docker-compose.env.example .env
```

编辑 `.env`：

```env
API_TOKEN=your_secure_api_token
DOWNLOAD_TOKEN=your_secure_download_token
```

### 3. 启动服务

```bash
docker-compose up -d
```

## 配置说明

### 环境变量

| 变量 | 必填 | 说明 |
|------|------|------|
| `API_TOKEN` | 是 | API 认证 Token |
| `DOWNLOAD_TOKEN` | 是 | 下载认证 Token |
| `CRON_SYNC_ENABLED` | 否 | 启用同步任务 (默认 true) |
| `CRON_SYNC_INTERVAL` | 否 | 同步间隔小时 (默认 6) |
| `CRON_REFRESH_ENABLED` | 否 | 启用刷新任务 (默认 true) |
| `CRON_REFRESH_INTERVAL` | 否 | 刷新间隔小时 (默认 12) |

### 端口映射

| 端口 | 服务 |
|------|------|
| 3000 | Node.js 后端 (原始) |
| 80 | Caddy 反向代理 |

### 路由规则

| 路径 | 认证方式 | 说明 |
|------|----------|------|
| `/api/*` | `Authorization: Bearer <token>` | API 接口 |
| `/download/*` | `?d_token=<token>` | 下载链接 |
| 其他 | 无 | 静态前端 |

### 定时任务

内置 Crontab 任务：

| 时间 | 任务 |
|------|------|
| `0 */6 * * *` | `/api/sync/artifacts` (每6小时) |
| `0 */12 * * *` | `/api/utils/refresh` (每12小时) |

## 目录结构

```
.
├── Dockerfile              # Docker 构建文件
├── Caddyfile              # Caddy 配置
├── supervisord.conf       # 进程管理配置
├── entrypoint.sh          # 启动脚本
├── compose.yml            # Docker Compose 配置
├── docker-compose.env.example  # 环境变量示例
├── backend/
│   └── package.json       # Node 依赖
└── README.md              # 本文档
```

## 认证示例

### API 请求

```bash
# 带认证的 API 请求
curl -H "Authorization: Bearer your_api_token" http://localhost:80/

# 不带认证 (返回 401)
curl http://localhost:80/api/
```

### 下载请求

```bash
# 带 d_token 的下载
http://localhost:80/download/xxx?d_token=your_download_token
```

## 常用命令

```bash
# 启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止
docker-compose down

# 重启
docker-compose restart

# 重新构建
docker-compose build --no-cache
```

## 使用 GitHub 镜像

如果不想本地构建，可以使用 GitHub Container Registry 的预构建镜像：

```bash
# 复制示例配置
cp docker-compose.example.yml docker-compose.yml
cp docker-compose.env.example .env

# 编辑 .env 填入 token
# 启动
docker-compose up -d
```

## 故障排查

### 查看日志

```bash
docker-compose logs -f
```

### 检查容器状态

```bash
docker-compose ps
```

### 进入容器

```bash
docker-compose exec sub-store sh
```

### 检查 Crontab

```bash
docker-compose exec sub-store crontab -l
```

### 检查进程状态

```bash
docker-compose exec sub-store supervisord ctl status
```

## License

MIT
