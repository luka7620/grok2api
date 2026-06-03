# Nginx 部署说明

本文档给出在 Linux 服务器上使用 Docker Compose 运行 Grok2API，并使用 Nginx 反向代理到域名的部署方式。

## 1. 准备目录

```bash
mkdir -p /opt/grok2api
cd /opt/grok2api
curl -fsSL https://raw.githubusercontent.com/luka7620/grok2api/main/deploy/docker-deploy.sh \
  | IMAGE_NAME=luka762/grok2api IMAGE_TAG=latest APP_PORT=127.0.0.1:8000 bash
```

如果你直接使用仓库里的 `docker-compose.yml`，建议把 `.env` 中的端口改成只监听本机：

```env
HOST_PORT=127.0.0.1:8000
```

这样应用不会直接暴露到公网，公网入口只经过 Nginx。

## 2. 启动应用

```bash
docker compose pull
docker compose up -d
docker compose ps
curl http://127.0.0.1:8000/health
```

健康检查应返回：

```json
{"status":"ok"}
```

## 3. 配置 Nginx

把仓库中的 `deploy/nginx.grok2api.conf` 复制到服务器 Nginx 配置目录，并替换域名：

```bash
cp deploy/nginx.grok2api.conf /etc/nginx/conf.d/grok2api.conf
sed -i 's/example.com/your-domain.com/g' /etc/nginx/conf.d/grok2api.conf
nginx -t
systemctl reload nginx
```

如果使用 Debian/Ubuntu 的 `sites-available` 风格，也可以放到 `/etc/nginx/sites-available/grok2api` 并软链到 `sites-enabled`。

## 4. 配置 HTTPS

使用 Certbot 申请证书：

```bash
apt update
apt install -y certbot python3-certbot-nginx
certbot --nginx -d your-domain.com
```

证书生成后，确认 Nginx 配置中 443 server 块已启用，并重新加载：

```bash
nginx -t
systemctl reload nginx
```

## 5. 设置应用公网地址

首次启动后进入后台：

```text
https://your-domain.com/admin/login
```

默认后台密码来自 `app.app_key`，默认值是 `grok2api`。进入后台后至少修改：

- `app.app_key`：后台密码
- `app.api_key`：API 调用密钥
- `app.app_url`：设置为 `https://your-domain.com`

`app.app_url` 必须设置为公网 HTTPS 地址，否则本地代理的图片和视频链接可能无法正常访问。

## 6. 常用检查命令

```bash
docker compose logs -f
curl https://your-domain.com/health
curl https://your-domain.com/v1/models -H "Authorization: Bearer <你的 app.api_key>"
```

如果流式响应、后台批量任务或 WebUI 生成图像异常，优先确认 Nginx 配置里保留了这些设置：

```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $connection_upgrade;
proxy_buffering off;
proxy_read_timeout 3600s;
```
