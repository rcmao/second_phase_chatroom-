# TKI智能聊天机器人 - 生产环境部署指南

## 🚀 快速部署

### 方式一：自动部署（推荐）
```bash
cd /root/first_phase_chatroom_v1/web_app
chmod +x deploy_production.sh
./deploy_production.sh
```

### 方式二：手动启动
```bash
cd /root/first_phase_chatroom_v1/web_app
chmod +x start_production.sh
./start_production.sh
```

### 方式三：直接使用Gunicorn
```bash
cd /root/first_phase_chatroom_v1/web_app
/root/anaconda3/bin/gunicorn --config gunicorn.conf.py wsgi:application
```

## 📋 部署组件

### 1. 应用服务器
- **Gunicorn**: WSGI服务器，支持多进程
- **配置文件**: `gunicorn.conf.py`
- **入口文件**: `wsgi.py`
- **端口**: 8090
- **主机**: 0.0.0.0

### 2. 反向代理
- **Nginx**: 反向代理和负载均衡
- **配置文件**: `nginx-tki-chatroom.conf`
- **端口**: 80 (HTTP)

### 3. 系统服务
- **systemd**: 系统级服务管理
- **服务文件**: `tki-chatroom.service`
- **服务名**: `tki-chatroom`

## 🔧 配置说明

### Gunicorn配置 (`gunicorn.conf.py`)
```python
# 主要配置项
bind = "0.0.0.0:8090"           # 绑定地址和端口
workers = 5                      # worker进程数 (CPU核心数 * 2 + 1)
worker_class = "eventlet"        # 支持WebSocket的worker类型
worker_connections = 1000        # 每个worker的连接数
timeout = 30                     # 请求超时时间
max_requests = 1000             # worker重启前处理的最大请求数
```

### systemd服务配置
```ini
[Unit]
Description=TKI Smart Chatroom Application
After=network.target

[Service]
Type=notify
User=root
WorkingDirectory=/root/first_phase_chatroom_v1/web_app
ExecStart=/root/anaconda3/bin/gunicorn --config gunicorn.conf.py wsgi:application
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

## 🔄 服务管理命令

### systemd命令
```bash
# 启动服务
systemctl start tki-chatroom

# 停止服务
systemctl stop tki-chatroom

# 重启服务
systemctl restart tki-chatroom

# 查看状态
systemctl status tki-chatroom

# 开机自启
systemctl enable tki-chatroom

# 查看日志
journalctl -u tki-chatroom -f
```

### 直接管理
```bash
# 查看进程
ps aux | grep gunicorn

# 查看端口
netstat -tlnp | grep :8090

# 停止所有相关进程
pkill -f "gunicorn.*wsgi:application"
```

## 📊 监控和日志

### 日志文件位置
```
/root/first_phase_chatroom_v1/web_app/logs/
├── gunicorn_access.log     # 访问日志
├── gunicorn_error.log      # 错误日志
├── gunicorn.pid           # 进程ID文件
└── nohup.log              # 后台运行日志
```

### 查看日志
```bash
# 实时查看错误日志
tail -f logs/gunicorn_error.log

# 实时查看访问日志
tail -f logs/gunicorn_access.log

# 查看systemd日志
journalctl -u tki-chatroom -f

# 查看Nginx日志
tail -f /var/log/nginx/tki-chatroom-access.log
tail -f /var/log/nginx/tki-chatroom-error.log
```

## 🌐 访问地址

### 主要访问方式
- **通过Nginx (推荐)**: http://your-server-ip:80
- **直接访问应用**: http://your-server-ip:8090

### 管理界面
- **聊天室**: http://your-server-ip/rooms
- **管理面板**: http://your-server-ip/admin

### 默认管理员账户
- **用户名**: admin
- **密码**: admin123
- **⚠️ 请立即修改默认密码**

## 🔒 安全配置

### 1. 防火墙设置
```bash
# Ubuntu/Debian
sudo ufw allow 80/tcp
sudo ufw allow 8090/tcp
sudo ufw enable

# CentOS/RHEL
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=8090/tcp
firewall-cmd --reload
```

### 2. SSL/HTTPS配置
1. 获取SSL证书（Let's Encrypt推荐）
2. 修改Nginx配置文件启用HTTPS
3. 设置HTTP重定向到HTTPS

### 3. 安全建议
- 修改默认管理员密码
- 设置强密码策略
- 定期备份数据库
- 监控异常访问
- 定期更新依赖包

## 🔧 性能优化

### 1. Gunicorn优化
- 根据CPU核心数调整worker数量
- 使用`eventlet`支持WebSocket
- 设置合适的超时时间
- 启用预加载应用

### 2. Nginx优化
- 启用Gzip压缩
- 设置静态文件缓存
- 配置连接池
- 使用HTTP/2

### 3. 系统优化
- 增加文件描述符限制
- 调整TCP参数
- 配置系统级监控

## 🚨 故障排除

### 常见问题

#### 1. 服务无法启动
```bash
# 检查端口占用
netstat -tlnp | grep :8090

# 查看错误日志
journalctl -u tki-chatroom --no-pager

# 检查配置文件语法
/root/anaconda3/bin/gunicorn --config gunicorn.conf.py --check-config wsgi:application
```

#### 2. WebSocket连接失败
- 检查Nginx配置中的WebSocket代理设置
- 确认防火墙允许相关端口
- 查看浏览器控制台错误信息

#### 3. 性能问题
- 增加worker进程数
- 检查数据库连接
- 监控内存和CPU使用率

### 调试模式
如需临时启用调试模式：
```bash
# 停止生产服务
systemctl stop tki-chatroom

# 启动调试模式
cd /root/first_phase_chatroom_v1/web_app
FLASK_ENV=development python start_web.py
```

## 📞 技术支持

如遇到部署问题，请检查：
1. 系统日志：`journalctl -u tki-chatroom`
2. 应用日志：`logs/gunicorn_error.log`
3. Nginx日志：`/var/log/nginx/error.log`
4. 系统资源：`htop` 或 `top`

---

**祝部署顺利！** 🎉
