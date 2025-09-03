#!/bin/bash
# TKI Smart Chatroom - Chatbot Virtual Environment Production Start Script
# 专用于chatbot虚拟环境的生产启动脚本
# 公网IP: 39.96.223.133

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

PROJECT_DIR="/root/first_phase_chatroom_v1/web_app"
VENV_DIR="/root/first_phase_chatroom_v1/chatbot"
LOG_DIR="$PROJECT_DIR/logs"
PUBLIC_IP="39.96.223.133"

echo -e "${PURPLE}🚀 TKI智能聊天机器人 - Chatbot环境生产模式${NC}"
echo -e "${BLUE}🌐 公网IP: $PUBLIC_IP:8090${NC}"
echo "=================================================="

# 检查是否在项目目录
if [ "$(pwd)" != "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}📁 切换到项目目录...${NC}"
    cd "$PROJECT_DIR"
fi

# 检查chatbot虚拟环境
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${RED}❌ chatbot虚拟环境不存在: $VENV_DIR${NC}"
    exit 1
fi

# 激活虚拟环境
echo -e "${BLUE}🐍 激活chatbot虚拟环境...${NC}"
source "$VENV_DIR/bin/activate"

# 验证环境
echo -e "${BLUE}✅ 环境验证:${NC}"
echo "  - Python: $(which python)"
echo "  - Gunicorn: $(which gunicorn 2>/dev/null || echo '未安装')"
echo "  - 工作目录: $(pwd)"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 检查依赖
echo -e "${BLUE}📦 检查依赖...${NC}"
if ! command -v gunicorn &> /dev/null; then
    echo -e "${YELLOW}⚠️ 安装Gunicorn...${NC}"
    pip install -i https://pypi.org/simple/ gunicorn
fi

# 设置环境变量
export FLASK_ENV=production
export SECRET_KEY="tki-chatbot-production-secret-key-2024"
export PUBLIC_IP="$PUBLIC_IP"
export PYTHONPATH="$PROJECT_DIR:$(dirname $PROJECT_DIR)"

echo -e "${BLUE}🌐 启动配置:${NC}"
echo "  - 主机: 0.0.0.0"
echo "  - 端口: 8090"
echo "  - 公网IP: $PUBLIC_IP"
echo "  - 虚拟环境: chatbot"
echo "  - 工作目录: $PROJECT_DIR"
echo "  - 日志目录: $LOG_DIR"

# 选择启动方式
echo ""
echo -e "${YELLOW}请选择启动方式:${NC}"
echo "1. 使用Gunicorn前台运行 (推荐生产环境)"
echo "2. 使用原生Flask (开发测试)"
echo "3. 后台运行Gunicorn"
echo "4. 查看运行状态"
echo "5. 停止服务"

read -p "请输入选择 (1-5): " choice

case $choice in
    1)
        echo -e "${BLUE}🚀 启动Gunicorn服务器(前台运行)...${NC}"
        echo -e "${GREEN}访问地址: http://$PUBLIC_IP:8090${NC}"
        gunicorn --config gunicorn_chatbot.conf.py wsgi_chatbot:application
        ;;
    2)
        echo -e "${BLUE}🚀 启动Flask开发服务器...${NC}"
        echo -e "${GREEN}访问地址: http://$PUBLIC_IP:8090${NC}"
        python start_web.py
        ;;
    3)
        echo -e "${BLUE}🚀 后台启动Gunicorn服务器...${NC}"
        nohup gunicorn --config gunicorn_chatbot.conf.py wsgi_chatbot:application > "$LOG_DIR/nohup_chatbot.log" 2>&1 &
        echo $! > "$LOG_DIR/gunicorn_chatbot.pid"
        echo -e "${GREEN}✅ 服务已在后台启动${NC}"
        echo "  - PID文件: $LOG_DIR/gunicorn_chatbot.pid"
        echo "  - 日志文件: $LOG_DIR/nohup_chatbot.log"
        echo "  - 访问地址: http://$PUBLIC_IP:8090"
        echo ""
        echo "管理命令:"
        echo "  - 查看日志: tail -f $LOG_DIR/nohup_chatbot.log"
        echo "  - 停止服务: kill \$(cat $LOG_DIR/gunicorn_chatbot.pid)"
        echo "  - 重新启动: $0"
        ;;
    4)
        echo -e "${BLUE}📊 检查服务状态...${NC}"
        
        # 检查chatbot环境的gunicorn进程
        if pgrep -f "gunicorn.*wsgi_chatbot:application" > /dev/null; then
            echo -e "${GREEN}✅ Gunicorn(chatbot)进程正在运行${NC}"
            echo "进程信息:"
            pgrep -f "gunicorn.*wsgi_chatbot:application" | xargs ps -p
        else
            echo -e "${RED}❌ Gunicorn(chatbot)进程未运行${NC}"
        fi
        
        # 检查端口
        if netstat -tlnp 2>/dev/null | grep :8090 > /dev/null; then
            echo -e "${GREEN}✅ 端口8090正在监听${NC}"
            netstat -tlnp | grep :8090
        else
            echo -e "${RED}❌ 端口8090未被监听${NC}"
        fi
        
        # 检查PID文件
        if [ -f "$LOG_DIR/gunicorn_chatbot.pid" ]; then
            PID=$(cat "$LOG_DIR/gunicorn_chatbot.pid")
            if kill -0 "$PID" 2>/dev/null; then
                echo -e "${GREEN}✅ PID文件有效: $PID${NC}"
            else
                echo -e "${RED}❌ PID文件无效: $PID${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️ chatbot环境PID文件不存在${NC}"
        fi
        
        # 测试HTTP连接
        echo -e "${BLUE}🌐 测试HTTP连接...${NC}"
        if curl -s --connect-timeout 5 "http://localhost:8090" > /dev/null; then
            echo -e "${GREEN}✅ HTTP服务响应正常${NC}"
        else
            echo -e "${RED}❌ HTTP服务无响应${NC}"
        fi
        ;;
    5)
        echo -e "${BLUE}🛑 停止服务...${NC}"
        
        # 停止chatbot环境的gunicorn进程
        if pgrep -f "gunicorn.*wsgi_chatbot:application" > /dev/null; then
            pkill -f "gunicorn.*wsgi_chatbot:application"
            echo -e "${GREEN}✅ Gunicorn(chatbot)进程已停止${NC}"
        fi
        
        # 停止PID文件中的进程
        if [ -f "$LOG_DIR/gunicorn_chatbot.pid" ]; then
            PID=$(cat "$LOG_DIR/gunicorn_chatbot.pid")
            if kill -0 "$PID" 2>/dev/null; then
                kill "$PID"
                echo -e "${GREEN}✅ 进程 $PID 已停止${NC}"
            fi
            rm -f "$LOG_DIR/gunicorn_chatbot.pid"
        fi
        
        # 强制停止所有8090端口的进程
        PORT_PIDS=$(lsof -t -i:8090 2>/dev/null || true)
        if [ -n "$PORT_PIDS" ]; then
            echo "$PORT_PIDS" | xargs kill 2>/dev/null || true
            echo -e "${GREEN}✅ 端口8090已释放${NC}"
        fi
        ;;
    *)
        echo -e "${RED}❌ 无效选择${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}🌐 访问地址:${NC}"
echo "  - 公网访问: http://$PUBLIC_IP:8090"
echo "  - 本地访问: http://localhost:8090"
echo ""
echo -e "${BLUE}📝 有用命令:${NC}"
echo "  - 查看错误日志: tail -f $LOG_DIR/gunicorn_error.log"
echo "  - 查看访问日志: tail -f $LOG_DIR/gunicorn_access.log"
echo "  - 查看启动日志: tail -f $LOG_DIR/nohup_chatbot.log"
echo "  - 重新启动: $0"
echo ""
echo -e "${PURPLE}🔒 安全提醒:${NC}"
echo "  - 默认管理员: admin/admin123"
echo "  - 请立即修改默认密码"
echo "  - 配置防火墙允许8090端口访问"
