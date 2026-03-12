# Sub-Store Docker

使用 Docker 部署 Sub-Store (后端 + 前端)，集成定时任务和 GitHub Gist 备份功能。

参考项目：
https://github.com/SaintWe/Sub-Store-Docker/
参考：
https://hub.docker.com/r/xream/sub-store
https://hub.docker.com/layers/xream/sub-store/latest/images/sha256-60f0a0dcdaee0cb107454d217753e7d8d92f23524310bb2dd5960e7a41cd37b8

## 功能特性

- **前后端整合** - 后端 API + 前端 UI 一站式部署
- **路径密钥认证** - 使用 `SUB_STORE_FRONTEND_BACKEND_PATH` 保护后端
- **定时任务** - 自动同步订阅、刷新远程订阅 (使用 node-cron)
- **GitHub Gist 备份** - 自动备份和恢复配置
- **自动更新** - 每次构建自动获取 GitHub 最新版本
- **数据持久化** - 订阅数据保存在 Docker 卷中

## 版本信息

- 后端: [Sub-Store](https://github.com/sub-store-org/Sub-Store/releases) (自动获取 latest)
- 前端: [Sub-Store-Front-End](https://github.com/sub-store-org/Sub-Store-Front-End/releases) (自动获取 latest)

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/your-repo/Sub-Store-Docker.git
cd Sub-Store-Docker
```

### 2. 配置环境变量

```bash
cp .env.example .env
nano .env
```

必须修改的配置：

```bash
# 必填：设置后端路径密钥
SUB_STORE_FRONTEND_BACKEND_PATH=your-secret-path-here
```

### 3. 启动服务

```bash
docker-compose up -d --build
```

### 4. 访问

- 前端: http://localhost:3000
- 带密钥访问: http://localhost:3000/your-secret-path-here

## 环境变量说明

| 变量 | 必填 | 说明 | 示例 |
|------|------|------|------|
| `SUB_STORE_FRONTEND_BACKEND_PATH` | ✅ | 后端路径密钥 | `/secret123` |
| `SUB_STORE_BACKEND_SYNC_CRON` | - | 同步订阅定时 | `0 */6 * * *` |
| `SUB_STORE_BACKEND_REFRESH_CRON` | - | 刷新订阅定时 | `0 */12 * * *` |
| `GITHUB_USERNAME` | - | GitHub 用户名 | `yourname` |
| `GITHUB_TOKEN` | - | GitHub Token | `ghp_xxx` |
| `SUB_STORE_BACKEND_UPLOAD_CRON` | - | 上传备份定时 | `55 23 * * 6` |
| `SUB_STORE_BACKEND_DOWNLOAD_CRON` | - | 下载恢复定时 | `30 2 * * 0` |
| `SUB_STORE_FRONTEND_BACKEND_URL` | - | 反向代理地址 | `http://localhost:3000` |

## Cron 表达式示例

| 表达式 | 说明 |
|--------|------|
| `0 * * * *` | 每小时 |
| `0 */6 * * *` | 每 6 小时 |
| `0 */12 * * *` | 每 12 小时 |
| `0 0 * * *` | 每天午夜 |
| `0 0 * * 0` | 每周日午夜 |
| `55 23 * * 6` | 每周六 23:55 |

## 使用场景

### 场景一：本地使用

```bash
SUB_STORE_FRONTEND_BACKEND_PATH=mysecret
```

访问: http://localhost:3000/mysecret

### 场景二：定时同步订阅

```bash
SUB_STORE_BACKEND_SYNC_CRON=0 */6 * * *
```

### 场景三：GitHub Gist 备份

```bash
GITHUB_USERNAME=yourname
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
SUB_STORE_BACKEND_UPLOAD_CRON=55 23 * * 6
SUB_STORE_BACKEND_DOWNLOAD_CRON=30 2 * * 0
```

### 场景四：Nginx 反向代理

```bash
SUB_STORE_FRONTEND_BACKEND_PATH=secret123
SUB_STORE_FRONTEND_BACKEND_URL=http://localhost:3000
```

Nginx 配置：

```nginx
location / {
    proxy_pass http://127.0.0.1:3000;
}
```

## 命令

```bash
# 构建并启动
docker-compose up -d --build

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看状态
docker-compose ps
```

## 数据持久化

订阅数据存储在 Docker 卷 `sub-store-data` 中：

```bash
# 查看卷
docker volume ls | grep sub-store

# 备份卷
docker run --rm -v sub-store-data:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz /data

# 恢复卷
docker run --rm -v sub-store-data:/data -v $(pwd):/backup alpine tar xzf /backup/backup.tar.gz -C /
```

## 文档

- [Docker 部署指南](./docs/DOCKER-DEPLOY.md) - 完整 Docker 部署说明
- [认证机制说明](./docs/SUB-STORE-AUTH.md) - 路径密钥认证详解
- [Sub-Store 官方 Wiki](https://github.com/sub-store-org/Sub-Store/wiki)
