#!/bin/bash
# TKI Smart Chatroom - Quick Production Start Script

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/root/first_phase_chatroom_v1/web_app"
LOG_DIR="$PROJECT_DIR/logs"

echo -e "${BLUE}🚀 TKI智能聊天机器人 - 生产模式启动${NC}"
echo "=================================================="

# 切换到项目目录
cd "$PROJECT_DIR"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 检查依赖
echo -e "${BLUE}📦 检查依赖...${NC}"
if ! command -v gunicorn &> /dev/null; then
    echo -e "${YELLOW}⚠️ 安装Gunicorn...${NC}"
    /root/anaconda3/bin/pip install gunicorn eventlet
fi

# 设置环境变量
export FLASK_ENV=production
export SECRET_KEY=${SECRET_KEY:-"your-secret-key-here-change-in-production"}
export PYTHONPATH="$PROJECT_DIR:$(dirname $PROJECT_DIR)"

echo -e "${BLUE}🌐 启动配置:${NC}"
echo "  - 主机: 0.0.0.0"
echo "  - 端口: 8090"
echo "  - 工作目录: $PROJECT_DIR"
echo "  - 日志目录: $LOG_DIR"

# 选择启动方式
echo ""
echo -e "${YELLOW}请选择启动方式:${NC}"
echo "1. 使用Gunicorn (推荐生产环境)"
echo "2. 使用原生Flask (开发测试)"
echo "3. 后台运行Gunicorn"
echo "4. 查看运行状态"
echo "5. 停止服务"

read -p "请输入选择 (1-5): " choice

case $choice in
    1)
        echo -e "${BLUE}🚀 启动Gunicorn服务器...${NC}"
        /root/anaconda3/bin/gunicorn --config gunicorn.conf.py wsgi:application
        ;;
    2)
        echo -e "${BLUE}🚀 启动Flask开发服务器...${NC}"
        /root/anaconda3/bin/python start_web.py
        ;;
    3)
        echo -e "${BLUE}🚀 后台启动Gunicorn服务器...${NC}"
        nohup /root/anaconda3/bin/gunicorn --config gunicorn.conf.py wsgi:application > "$LOG_DIR/nohup.log" 2>&1 &
        echo $! > "$LOG_DIR/gunicorn.pid"
        echo -e "${GREEN}✅ 服务已在后台启动${NC}"
        echo "  - PID文件: $LOG_DIR/gunicorn.pid"
        echo "  - 日志文件: $LOG_DIR/nohup.log"
        echo "  - 查看日志: tail -f $LOG_DIR/nohup.log"
        echo "  - 停止服务: kill \$(cat $LOG_DIR/gunicorn.pid)"
        ;;
    4)
        echo -e "${BLUE}📊 检查服务状态...${NC}"
        
        # 检查进程
        if pgrep -f "gunicorn.*wsgi:application" > /dev/null; then
            echo -e "${GREEN}✅ Gunicorn进程正在运行${NC}"
            echo "进程信息:"
            pgrep -f "gunicorn.*wsgi:application" | xargs ps -p
        else
            echo -e "${RED}❌ Gunicorn进程未运行${NC}"
        fi
        
        # 检查端口
        if netstat -tlnp 2>/dev/null | grep :8090 > /dev/null; then
            echo -e "${GREEN}✅ 端口8090正在监听${NC}"
            netstat -tlnp | grep :8090
        else
            echo -e "${RED}❌ 端口8090未被监听${NC}"
        fi
        
        # 检查PID文件
        if [ -f "$LOG_DIR/gunicorn.pid" ]; then
            PID=$(cat "$LOG_DIR/gunicorn.pid")
            if kill -0 "$PID" 2>/dev/null; then
                echo -e "${GREEN}✅ PID文件有效: $PID${NC}"
            else
                echo -e "${RED}❌ PID文件无效: $PID${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️ PID文件不存在${NC}"
        fi
        ;;
    5)
        echo -e "${BLUE}🛑 停止服务...${NC}"
        
        # 停止systemd服务
        if systemctl is-active tki-chatroom >/dev/null 2>&1; then
            systemctl stop tki-chatroom
            echo -e "${GREEN}✅ systemd服务已停止${NC}"
        fi
        
        # 停止PID文件中的进程
        if [ -f "$LOG_DIR/gunicorn.pid" ]; then
            PID=$(cat "$LOG_DIR/gunicorn.pid")
            if kill -0 "$PID" 2>/dev/null; then
                kill "$PID"
                echo -e "${GREEN}✅ 进程 $PID 已停止${NC}"
            fi
            rm -f "$LOG_DIR/gunicorn.pid"
        fi
        
        # 强制停止所有相关进程
        pkill -f "gunicorn.*wsgi:application" 2>/dev/null || true
        echo -e "${GREEN}✅ 所有相关进程已停止${NC}"
        ;;
    *)
        echo -e "${RED}❌ 无效选择${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}🌐 访问地址:${NC}"
echo "  - HTTP: http://$(hostname -I | awk '{print $1}'):8090"
echo ""
echo -e "${BLUE}📝 有用命令:${NC}"
echo "  - 查看日志: tail -f $LOG_DIR/gunicorn_error.log"
echo "  - 重新启动: $0"
echo "  - 完整部署: ./deploy_production.sh"
