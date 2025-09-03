#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
WSGI entry point for production deployment
"""

import os
import sys
from datetime import datetime

# 添加项目路径
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

# 设置生产环境变量
os.environ.setdefault('FLASK_ENV', 'production')
if not os.environ.get('SECRET_KEY'):
    os.environ['SECRET_KEY'] = 'your-secret-key-here-change-in-production'

try:
    from app import app, db, User, Room, RoomMembership, socketio
    from werkzeug.security import generate_password_hash

    def create_default_data():
        """创建默认数据"""
        with app.app_context():
            # 创建数据库表
            db.create_all()
            
            # 创建默认管理员用户（如果不存在）
            admin_user = User.query.filter_by(username='admin').first()
            if not admin_user:
                admin_user = User(
                    username='admin',
                    email='admin@tki.com',
                    password_hash=generate_password_hash('admin123'),
                    role='admin',
                    gender='unknown'
                )
                db.session.add(admin_user)
                print("✅ 创建默认管理员用户: admin/admin123")
                
                try:
                    db.session.commit()
                    print("✅ 默认数据创建完成")
                except Exception as e:
                    print(f"❌ 创建默认数据失败: {e}")
                    db.session.rollback()

    # 初始化应用
    create_default_data()
    
    # 启动实时监控系统
    try:
        from realtime_monitor import RealtimeMonitor
        realtime_monitor = RealtimeMonitor()
        realtime_monitor.start_monitoring()
        print("🚀 实时监控系统已启动")
    except Exception as e:
        print(f"⚠️ 实时监控系统启动失败: {e}")

    # WSGI应用对象
    application = app
    
    print(f"🚀 TKI智能聊天机器人生产环境已启动 - {datetime.now()}")
    print(f"📍 服务地址: 0.0.0.0:8090")

except Exception as e:
    print(f"❌ 应用初始化失败: {e}")
    import traceback
    traceback.print_exc()
    raise

if __name__ == "__main__":
    # 开发模式直接运行
    socketio.run(app, debug=False, host='0.0.0.0', port=8090)
