# Sub-Store Docker 部署

基于 [Sub-Store](https://github.com/sub-store/Sub-Store) 的 Docker 镜像，支持 Caddy 反向代理和定时任务。

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
git clone <your-repo>
cd express-sub-store
```

### 2. 配置环境变量

创建 `.env` 文件：

```bash
cp backend/.env.example backend/.env
```

编辑 `backend/.env`：

```env
API_TOKEN=your_secure_api_token
DOWNLOAD_TOKEN=your_secure_download_token
```

### 3. 启动服务

```bash
# 使用 Docker Compose
docker-compose up -d

# 或使用 Docker
docker build -t sub-store ./backend
docker run -d \
  -p 3000:3000 \
  -p 80:80 \
  -e API_TOKEN=your_token \
  -e DOWNLOAD_TOKEN=your_token \
  -v /path/to/frontend:/git/public:ro \
  --name sub-store \
  sub-store
```

## 配置说明

### 环境变量

| 变量 | 必填 | 说明 |
|------|------|------|
| `API_TOKEN` | 是 | API 认证 Token |
| `DOWNLOAD_TOKEN` | 是 | 下载认证 Token |

### 端口映射

| 端口 | 服务 |
|------|------|
| 3000 | Node.js 后端 (原始) |
| 80 | Caddy 反向代理 |

### 路由规则

- `/api/*` - 需要 `Authorization: Bearer <token>` 头部
- `/download/*` - 需要 `?d_token=<token>` 查询参数
- 其他路径 - 静态文件服务 (需要挂载前端到 `/git/public`)

### 定时任务

内置 Crontab 任务：

| 时间 | 任务 |
|------|------|
| `0 */6 * * *` | `/api/sync/artifacts` (每6小时) |
| `0 */12 * * *` | `/api/utils/refresh` (每12小时) |

## 前端部署

### 方式一：本地静态文件

1. 下载 Sub-Store 前端静态文件
2. 挂载到容器 `/git/public` 目录：

```bash
# Docker Compose
FRONTEND_PATH=/path/to/your/frontend docker-compose up -d

# 或 Docker
-v /path/to/frontend:/git/public:ro
```

### 方式二：远程前端

直接使用官方前端：https://sub-store.vercel.app

配置后端地址：`https://sub-store.vercel.app?api=http://your-server:80`

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

## 目录结构

```
.
├── backend/
│   ├── Dockerfile          # Docker 构建文件
│   ├── Caddyfile          # Caddy 配置
│   ├── .env               # 环境变量
│   ├── package.json       # Node 依赖
│   └── sub-store.min.js   # 应用代码
├── compose.yml            # Docker Compose 配置
├── data/                  # 数据目录 (运行时创建)
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

## 故障排查

### 查看日志

```bash
docker-compose logs sub-store
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

## License

MIT
