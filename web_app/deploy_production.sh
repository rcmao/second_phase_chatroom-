#!/bin/bash
# TKI Smart Chatroom - Production Deployment Script

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目配置
PROJECT_DIR="/root/first_phase_chatroom_v1/web_app"
SERVICE_NAME="tki-chatroom"
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"

echo -e "${BLUE}🚀 TKI智能聊天机器人 - 生产环境部署脚本${NC}"
echo "=================================================="

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ 请使用root用户运行此脚本${NC}"
    exit 1
fi

# 切换到项目目录
cd "$PROJECT_DIR"

echo -e "${YELLOW}📁 工作目录: $(pwd)${NC}"

# 1. 安装系统依赖
echo -e "${BLUE}📦 检查和安装系统依赖...${NC}"
if command -v apt &> /dev/null; then
    # Ubuntu/Debian
    apt update
    apt install -y python3-pip python3-venv nginx supervisor
elif command -v yum &> /dev/null; then
    # CentOS/RHEL
    yum update -y
    yum install -y python3-pip python3-venv nginx supervisor
else
    echo -e "${YELLOW}⚠️ 无法自动安装依赖，请手动安装 nginx 和 supervisor${NC}"
fi

# 2. 安装Python依赖
echo -e "${BLUE}🐍 安装Python依赖...${NC}"
if [ -f "requirements.txt" ]; then
    /root/anaconda3/bin/pip install -r requirements.txt
    /root/anaconda3/bin/pip install gunicorn eventlet
else
    echo -e "${YELLOW}⚠️ requirements.txt文件不存在，跳过Python依赖安装${NC}"
fi

# 3. 创建必要目录
echo -e "${BLUE}📁 创建必要目录...${NC}"
mkdir -p logs
mkdir -p instance
chown -R root:root .
chmod -R 755 .
chmod 644 *.py

# 4. 配置systemd服务
echo -e "${BLUE}⚙️ 配置systemd服务...${NC}"
if [ -f "tki-chatroom.service" ]; then
    cp tki-chatroom.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable $SERVICE_NAME
    echo -e "${GREEN}✅ systemd服务配置完成${NC}"
else
    echo -e "${RED}❌ tki-chatroom.service文件不存在${NC}"
    exit 1
fi

# 5. 配置Nginx
echo -e "${BLUE}🌐 配置Nginx...${NC}"
if [ -f "nginx-tki-chatroom.conf" ]; then
    # 备份现有配置
    if [ -f "$NGINX_AVAILABLE/tki-chatroom" ]; then
        cp "$NGINX_AVAILABLE/tki-chatroom" "$NGINX_AVAILABLE/tki-chatroom.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # 复制新配置
    cp nginx-tki-chatroom.conf "$NGINX_AVAILABLE/tki-chatroom"
    
    # 创建软链接
    if [ ! -L "$NGINX_ENABLED/tki-chatroom" ]; then
        ln -s "$NGINX_AVAILABLE/tki-chatroom" "$NGINX_ENABLED/tki-chatroom"
    fi
    
    # 测试Nginx配置
    if nginx -t; then
        echo -e "${GREEN}✅ Nginx配置语法检查通过${NC}"
    else
        echo -e "${RED}❌ Nginx配置语法错误${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️ nginx-tki-chatroom.conf文件不存在，跳过Nginx配置${NC}"
fi

# 6. 启动服务
echo -e "${BLUE}🚀 启动服务...${NC}"

# 停止现有服务（如果正在运行）
systemctl stop $SERVICE_NAME 2>/dev/null || true

# 启动应用服务
systemctl start $SERVICE_NAME
sleep 3

# 检查服务状态
if systemctl is-active --quiet $SERVICE_NAME; then
    echo -e "${GREEN}✅ TKI聊天机器人服务启动成功${NC}"
else
    echo -e "${RED}❌ TKI聊天机器人服务启动失败${NC}"
    echo "查看服务日志："
    systemctl status $SERVICE_NAME --no-pager
    exit 1
fi

# 重启Nginx
if systemctl is-active --quiet nginx; then
    systemctl reload nginx
    echo -e "${GREEN}✅ Nginx配置重新加载${NC}"
else
    systemctl start nginx
    echo -e "${GREEN}✅ Nginx服务启动${NC}"
fi

# 7. 显示部署信息
echo ""
echo -e "${GREEN}🎉 部署完成！${NC}"
echo "=================================================="
echo -e "${BLUE}📊 服务状态:${NC}"
echo "  - 应用服务: $(systemctl is-active $SERVICE_NAME)"
echo "  - Nginx服务: $(systemctl is-active nginx)"
echo ""
echo -e "${BLUE}🌐 访问地址:${NC}"
echo "  - HTTP: http://$(hostname -I | awk '{print $1}'):80"
echo "  - 直接访问: http://$(hostname -I | awk '{print $1}'):8090"
echo ""
echo -e "${BLUE}📝 管理命令:${NC}"
echo "  - 查看服务状态: systemctl status $SERVICE_NAME"
echo "  - 重启服务: systemctl restart $SERVICE_NAME"
echo "  - 查看日志: journalctl -u $SERVICE_NAME -f"
echo "  - 查看应用日志: tail -f $PROJECT_DIR/logs/gunicorn_error.log"
echo ""
echo -e "${BLUE}🔧 默认管理员账户:${NC}"
echo "  - 用户名: admin"
echo "  - 密码: admin123"
echo ""
echo -e "${YELLOW}⚠️ 重要提醒:${NC}"
echo "  1. 请立即修改默认管理员密码"
echo "  2. 请配置防火墙规则允许80和8090端口访问"
echo "  3. 建议配置SSL证书启用HTTPS"
echo "  4. 定期备份数据库文件: $PROJECT_DIR/chatbot.db"

# 8. 防火墙配置提醒
echo ""
echo -e "${BLUE}🔥 防火墙配置建议:${NC}"
if command -v ufw &> /dev/null; then
    echo "  Ubuntu/Debian系统:"
    echo "    sudo ufw allow 80/tcp"
    echo "    sudo ufw allow 8090/tcp"
    echo "    sudo ufw enable"
elif command -v firewall-cmd &> /dev/null; then
    echo "  CentOS/RHEL系统:"
    echo "    firewall-cmd --permanent --add-port=80/tcp"
    echo "    firewall-cmd --permanent --add-port=8090/tcp"
    echo "    firewall-cmd --reload"
else
    echo "  请手动配置防火墙允许80和8090端口访问"
fi

echo ""
echo -e "${GREEN}✅ 生产环境部署脚本执行完成！${NC}"
