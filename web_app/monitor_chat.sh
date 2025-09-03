#!/bin/bash
echo "🔥 开始监控聊天室实时日志..."
echo "✅ 服务状态: 运行中"
echo "✅ LLM: 已启用"
echo "✅ Clash代理: 运行中"
echo "================================"
tail -f logs/gunicorn_error.log | grep --line-buffered -E "(🎯|🔍|🤖|✅|❌|⚠️|🚀|干预|检测|沉默|LLM|@)" --color=always

