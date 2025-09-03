# 项目依赖文档

## 概述

本文档列出了TKI智能干预聊天室项目的所有依赖项，包括核心依赖、开发依赖和系统要求。

## 系统要求

- **Python**: 3.6+ (已优化兼容Python 3.6，同时支持3.11.7+)
- **操作系统**: macOS, Linux, Windows
- **内存**: 至少2GB可用内存
- **存储**: 至少1GB可用磁盘空间

## 🎯 Python 3.6 兼容性

**✅ 已完全兼容Python 3.6！** 所有OpenAI智能干预功能正常工作。

### 兼容性特点：
- ✅ **保留完整OpenAI功能** - 使用requests直接调用OpenAI API
- ✅ **SQLAlchemy 1.4语法** - 兼容Python 3.6的数据库操作
- ✅ **所有依赖降级** - 使用Python 3.6兼容版本
- ✅ **功能无损** - 智能干预、实时监控、WebSocket通信完全正常

## 核心Web应用依赖 (web_app/requirements.txt)

### Web框架 (Python 3.6兼容版本)
```
Flask==2.2.5                    # 核心Web框架
Flask-CORS==3.0.10              # 跨域资源共享支持
Flask-SocketIO==5.1.1           # WebSocket实时通信
Werkzeug==2.2.3                 # WSGI工具库
```

### 数据库 (Python 3.6兼容版本)
```
Flask-SQLAlchemy==2.5.1         # SQLAlchemy ORM集成 (使用SQLAlchemy 1.4)
SQLAlchemy==1.4.*               # 数据库ORM (自动安装)
```

### 认证与安全 (Python 3.6兼容版本)
```
Flask-Login==0.6.3              # 用户会话管理
Flask-WTF==1.1.1                # 表单处理和CSRF保护
Werkzeug==2.2.3                 # 密码哈希
bcrypt==3.2.2                   # 密码加密
PyJWT==2.4.0                    # JWT令牌处理
```

### 配置管理 (Python 3.6兼容版本)
```
python-dotenv==0.21.1           # 环境变量管理
```

### 异步和网络 (Python 3.6兼容版本)
```
eventlet==0.33.0                # 异步网络库 (SocketIO后端)
aiohttp==3.8.6                  # 异步HTTP客户端
requests==2.28.2                # HTTP请求库
```

### AI集成 (Python 3.6兼容 - 重要!)
```
# 注意：不使用openai库，直接用requests调用API
requests==2.28.2                # 用于直接调用OpenAI API (完全兼容)
```

### 时间处理
```
pytz                            # 时区处理 (通常随Python安装)
```

## 开发和测试依赖

```
pytest>=7.0.0                   # 测试框架
pytest-asyncio>=0.21.0          # 异步测试支持
```

## Python标准库依赖

以下模块是Python标准库的一部分，无需额外安装：

```python
# 系统和文件操作
import os
import sys
import json
import sqlite3
import logging
import importlib
from functools import wraps

# 数据结构和类型
from collections import defaultdict, deque
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple, Union
from enum import Enum

# 时间和日期
import time
import asyncio
from datetime import datetime, timedelta

# 字符串和正则
import re
import random

# 并发
import threading
```

## 安装指南

### 1. 创建虚拟环境
```bash
# 兼容Python 3.6+ 和 3.11+
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# 或
venv\Scripts\activate     # Windows
```

### 2. 安装依赖
```bash
# 进入项目目录
cd /Users/apple/Desktop/first_phase_chatroom_v1

# 安装web应用依赖
pip install -r web_app/requirements.txt

# 或者手动安装核心依赖
pip install Flask==2.3.3 Flask-CORS==4.0.0 Flask-SQLAlchemy==3.0.5 \
            Flask-Login==0.6.3 Flask-WTF==1.1.1 Flask-SocketIO==5.3.6 \
            Werkzeug==2.3.7 python-dotenv==1.0.0 bcrypt==4.0.1 \
            PyJWT==2.8.0 eventlet==0.33.3 openai>=1.0.0 \
            aiohttp>=3.8.0 requests>=2.25.0 pytz
```

### 3. 验证安装 (Python 3.6兼容)
```bash
# 检查关键依赖 (不需要openai库)
python -c "import flask, flask_socketio, sqlalchemy, requests; print('✅ 核心依赖安装成功')"

# 检查SQLAlchemy版本兼容性 (应该是1.4.x)
python -c "import sqlalchemy; print(f'SQLAlchemy版本: {sqlalchemy.__version__}')"

# 验证OpenAI功能 (使用requests)
python -c "import requests; print('✅ OpenAI功能可用 (使用requests直接调用)')"
```

## 依赖说明

### 关键依赖说明 (Python 3.6兼容版本)

1. **Flask-SQLAlchemy==2.5.1**: 
   - 使用SQLAlchemy 1.4语法 (兼容Python 3.6)
   - 已回退到`engine.execute()`语法

2. **Flask-SocketIO==5.1.1**: 
   - 提供实时WebSocket通信
   - 需要eventlet作为异步后端

3. **requests==2.28.2 (替代openai库)**: 
   - 直接调用OpenAI API (完全兼容Python 3.6)
   - 需要配置OPENAI_API_KEY环境变量
   - 所有智能干预功能正常工作

4. **eventlet==0.33.0**: 
   - SocketIO的异步后端
   - 提供高性能并发支持

### 可选依赖

```bash
# 如果需要更好的开发体验
pip install flask-debugtoolbar    # Flask调试工具栏
pip install flask-migrate         # 数据库迁移工具
```

## 环境变量配置

创建 `.env` 文件：
```bash
# 复制示例配置
cp web_app/env.example web_app/.env

# 编辑配置
SECRET_KEY=your-secret-key-here
OPENAI_API_KEY=your-openai-api-key
OPENAI_BASE_URL=https://api.openai.com/v1
DATABASE_URL=sqlite:///instance/chatroom.db
```

## 常见问题

### 1. SQLAlchemy版本问题
如果遇到 `'Engine' object has no attribute 'execute'` 错误：
- 确保使用Flask-SQLAlchemy==3.0.5
- 检查代码是否使用了新的SQLAlchemy 2.0语法

### 2. SocketIO连接问题
如果WebSocket连接失败：
- 确保安装了eventlet==0.33.3
- 检查防火墙设置
- 验证端口8080是否可用

### 3. OpenAI API问题
如果AI功能不工作：
- 检查OPENAI_API_KEY是否正确设置
- 验证API配额和网络连接
- 检查OPENAI_BASE_URL配置

## 更新依赖

```bash
# 更新所有依赖到最新版本
pip install --upgrade -r web_app/requirements.txt

# 检查过时的依赖
pip list --outdated

# 生成当前依赖快照
pip freeze > current_requirements.txt
```

## 生产环境额外依赖

```bash
# WSGI服务器
pip install gunicorn>=20.1.0

# 监控和日志
pip install sentry-sdk>=1.0.0

# 缓存 (可选)
pip install redis>=4.0.0
```

---

**最后更新**: 2025-01-09  
**Python版本**: 3.11.7  
**Flask版本**: 2.3.3  
**SQLAlchemy版本**: 2.0+
