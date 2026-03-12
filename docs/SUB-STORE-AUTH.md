# Sub-Store 认证机制文档

## 项目概述

Sub-Store 是一个高级订阅管理工具，用于订阅格式转换、节点聚合和过滤处理。

- **后端项目**: [sub-store-org/Sub-Store](https://github.com/sub-store-org/Sub-Store)
- **前端项目**: [sub-store-org/Sub-Store-Front-End](https://github.com/sub-store-org/Sub-Store-Front-End)

---

## 认证方式

### 认证类型：路径密钥认证 (Path-based Secret)

Sub-Store 使用的是**基于路径的简单认证**，而非标准 API Token、OAuth 或 JWT。

### 核心配置

| 环境变量 | 说明 | 示例 |
|---------|------|------|
| `SUB_STORE_FRONTEND_BACKEND_PATH` | 后端 API 路径/密钥 | `/2cXaAxRGfddmGz2yx1wA` |
| `SUB_STORE_FRONTEND_BACKEND_URL` | 前端反向代理地址（可选） | `http://localhost:3000` |

### 连接方式

#### 方式一：URL 参数连接（推荐）

```
http://前端地址?api=http://后端地址/你的密钥
```

示例：
```
http://localhost:3001?api=http://localhost:3001/2cXaAxRGfddmGz2yx1wA
```

#### 方式二：直接访问带密钥的路径

```
http://后端地址/你的密钥
```

### Docker 部署示例

```yaml
version: "3.8"
services:
  sub-store:
    image: xream/sub-store:latest
    container_name: sub-store
    restart: always
    volumes:
      - ./data:/app/data
    environment:
      - SUB_STORE_FRONTEND_BACKEND_PATH=/2cXaAxRGfddmGz2yx1wA
      - SUB_STORE_FRONTEND_PORT=3001
    ports:
      - "3001:3001"
```

---

## 前端连接机制

### 连接流程

```
┌─────────────────────────────────────────────────┐
│                 前端 (Vue/Pinia)                │
├─────────────────────────────────────────────────┤
│ 1. 检查 URL 参数 `api=`                        │
│ 2. 解析后端地址 (如有 api 参数)                 │
│ 3. 提取当前 URL 路径第一段作为密钥              │
│ 4. 构建完整 API 请求地址                       │
│ 5. 存储到 localStorage 复用                   │
└─────────────────────────────────────────────────┘
```

### API 请求地址构建

前端会根据配置的密钥构建如下请求：

```
http://后端地址/密钥/api/具体接口
```

例如：
```
http://localhost:3001/2cXaAxRGfddmGz2yx1wA/api/configs
```

---

## 安全评估

### 安全特性

| 特性 | 支持情况 |
|------|---------|
| API Key | ❌ |
| OAuth 2.0 | ❌ |
| JWT Token | ❌ |
| Basic Auth | ❌ |
| 路径密钥 | ✅ |
| Token 过期机制 | ❌ |
| 权限分级 | ❌ |

### 安全建议

1. **仅内网使用**: 不要在公网直接暴露 Sub-Store 端口
2. **使用反向代理**: 通过 Nginx/Caddy 配置 Basic Auth 或 IP 白名单
3. **使用复杂密钥**: 避免使用简单字符串作为后端路径
4. **定期更换密钥**: 定期更新 `SUB_STORE_FRONTEND_BACKEND_PATH`

### 强化安全示例 (Nginx)

```nginx
server {
    listen 443 ssl;
    server_name sub-store.example.com;
    
    # 基础认证
    auth_basic "Sub-Store Admin";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    # IP 白名单 (可选)
    allow 192.168.1.0/24;
    deny all;
    
    location / {
        proxy_pass http://127.0.0.1:3001;
    }
}
```

---

## 部署配置说明

### 环境变量 (.env)

```bash
# ============================================================
# 基础配置
# ============================================================
# 后端路径密钥 (必填)
SUB_STORE_FRONTEND_BACKEND_PATH=/your-secret-path

# ============================================================
# 定时任务配置 (Cron 表达式，为空则不启用)
# ============================================================
# 同步订阅间隔
SUB_STORE_BACKEND_SYNC_CRON=
# 刷新远程订阅间隔
SUB_STORE_BACKEND_REFRESH_CRON=

# ============================================================
# GitHub Gist 备份 (为空则不启用)
# ============================================================
# GitHub 用户名
GITHUB_USERNAME=
# GitHub Token (需要 Gist 权限)
GITHUB_TOKEN=
# 上传备份间隔 (Cron)
SUB_STORE_BACKEND_UPLOAD_CRON=
# 下载恢复间隔 (Cron)
SUB_STORE_BACKEND_DOWNLOAD_CRON=

# ============================================================
# 前端反向代理路径 (可选)
# 前端请求后端 API 时使用的前缀
# ============================================================
SUB_STORE_FRONTEND_BACKEND_URL=
```

### Cron 表达式示例

| 表达式 | 说明 |
|--------|------|
| `0 * * * *` | 每小时 |
| `0 */6 * * *` | 每 6 小时 |
| `0 */12 * * *` | 每 12 小时 |
| `0 0 * * *` | 每天午夜 |
| `0 0 * * 0` | 每周日 |

---

## 相关链接

- [GitHub Wiki - 链接参数说明](https://github.com/sub-store-org/Sub-Store/wiki/%E9%93%BE%E6%8E%A5%E5%8F%82%E6%95%B0%E8%AF%B4%E6%98%8E)
- [Docker 镜像 - xream/sub-store](https://hub.docker.com/r/xream/sub-store)
