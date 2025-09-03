#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gunicorn WSGI server configuration file for chatbot virtual environment
Optimized for production deployment with public IP: 39.96.223.133
"""

import multiprocessing
import os

# Server socket
bind = "0.0.0.0:8090"
backlog = 2048

# Worker processes - 适合2核CPU
workers = multiprocessing.cpu_count() * 2 + 1  # 对于2核CPU，这将是5个worker
worker_class = "eventlet"  # 支持WebSocket的worker class
worker_connections = 1000
timeout = 30
keepalive = 2

# Restart workers after this many requests, to prevent memory leaks
max_requests = 1000
max_requests_jitter = 50

# Logging - 使用chatbot环境路径
log_dir = "/root/first_phase_chatroom_v1/web_app/logs"
accesslog = f"{log_dir}/gunicorn_access.log"
errorlog = f"{log_dir}/gunicorn_error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Process naming
proc_name = 'tki_chatroom_chatbot'

# Server mechanics
daemon = False  # 不使用daemon模式，便于systemd管理
pidfile = f"{log_dir}/gunicorn_chatbot.pid"
user = None
group = None
tmp_upload_dir = None

# Worker performance
preload_app = True  # 预加载应用以提高性能
enable_stdio_inheritance = True

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

# 环境变量 - 针对chatbot环境
raw_env = [
    'FLASK_ENV=production',
    'SECRET_KEY=tki-chatbot-production-secret-key-2024',
    'PUBLIC_IP=39.96.223.133',
    'HOST=0.0.0.0',
    'PORT=8090',
    'PYTHONPATH=/root/first_phase_chatroom_v1/web_app:/root/first_phase_chatroom_v1',
]

def when_ready(server):
    server.log.info("🚀 TKI Chatroom Server is ready. Spawning workers")
    server.log.info(f"📍 Public IP: 39.96.223.133:8090")
    server.log.info(f"🐍 Python Environment: chatbot virtual environment")

def worker_int(worker):
    worker.log.info("worker received INT or QUIT signal")

def pre_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_worker_init(worker):
    worker.log.info("✅ Worker initialized (pid: %s)", worker.pid)

def worker_abort(worker):
    worker.log.info("❌ Worker aborted (pid: %s)", worker.pid)
