#!/bin/bash

echo "🔄 开始重启 Chatbot 服务..."

# 进入项目目录
cd /root/first_phase_chatroom_v1

# 查找并停止现有的gunicorn进程
echo "🛑 停止现有进程..."
pkill -f "gunicorn.*app:app" 2>/dev/null || echo "  没有找到运行中的gunicorn进程"

# 等待进程完全停止
sleep 3

# 确认进程已停止
RUNNING=$(ps aux | grep "gunicorn.*app:app" | grep -v grep | wc -l)
if [ $RUNNING -gt 0 ]; then
    echo "⚠️  进程仍在运行，强制终止..."
    pkill -9 -f "gunicorn.*app:app"
    sleep 2
fi

echo "✅ 进程已停止"

# 激活虚拟环境
echo "🔧 激活虚拟环境..."
source chatbot/bin/activate

# 设置环境变量
export PYTHONPATH="$PWD:$PWD/web_app:$PWD/src"
export OPENAI_API_KEY="sk-KCBDPG5Lv8hTCrArnkFSXY77wdJbLGzk0gkisq8T8IbjvfJb"
export OPENAI_BASE_URL="https://api2.aigcbest.top/v1"
export OPENAI_API_BASE="https://api2.aigcbest.top/v1"

# 创建日志目录（如果不存在）
mkdir -p web_app/logs

echo "🚀 启动新的 Chatbot 服务..."

# 启动服务（后台运行）
cd web_app
nohup gunicorn --config gunicorn.conf.py app:app > ../server.log 2>&1 &

# 等待服务启动
sleep 5

# 检查服务状态
PID=$(ps aux | grep "gunicorn.*app:app" | grep -v grep | head -1 | awk '{print $2}')
if [ -n "$PID" ]; then
    echo "✅ Chatbot 服务已成功启动!"
    echo "📊 进程ID: $PID"
    echo "🌐 服务地址: http://localhost:8090"
    echo "📝 日志文件: /root/first_phase_chatroom_v1/server.log"
    
    # 显示端口监听状态
    echo "🔍 端口监听状态:"
    netstat -tlnp | grep :8090 || echo "  端口8090未在监听"
    
    echo ""
    echo "🎉 重启完成! 新的配置已生效:"
    echo "  - 活跃讨论窗口: 120s -> 60s"
    echo "  - 消息频率阈值: 1.5 -> 0.5 条/分钟"
    echo "  - 各种冷却时间已调整"
    echo "  - 沉默检测优化: 按时长排序"
    echo "  - 用户提醒冷却: 60s"
else
    echo "❌ 服务启动失败!"
    echo "📝 请查看日志: tail -f /root/first_phase_chatroom_v1/server.log"
    exit 1
fi
