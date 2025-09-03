#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gunicorn WSGI server configuration file for production deployment
"""

import multiprocessing
import os

# Server socket
bind = "0.0.0.0:8090"
backlog = 2048

# Worker processes
workers = 2  # 由于内存限制，减少worker数量
worker_class = "eventlet"  # 支持WebSocket的worker class
worker_connections = 200
timeout = 60
keepalive = 2

# Restart workers after this many requests, to prevent memory leaks
max_requests = 500
max_requests_jitter = 25

# Logging
accesslog = "/root/first_phase_chatroom_v1/web_app/logs/gunicorn_access.log"
errorlog = "/root/first_phase_chatroom_v1/web_app/logs/gunicorn_error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Process naming
proc_name = 'tki_chatroom_app'

# Server mechanics
daemon = False  # 不使用daemon模式，便于systemd管理
pidfile = "/root/first_phase_chatroom_v1/web_app/logs/gunicorn.pid"
user = None
group = None
tmp_upload_dir = None

# SSL (如果需要HTTPS)
# keyfile = "/path/to/ssl/key.pem"
# certfile = "/path/to/ssl/cert.pem"

# Worker performance
preload_app = True  # 预加载应用以提高性能
enable_stdio_inheritance = True

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

# 环境变量
raw_env = [
    'FLASK_ENV=production',
    'SECRET_KEY=your-secret-key-here-change-in-production',
]

def when_ready(server):
    server.log.info("Server is ready. Spawning workers")

def worker_int(worker):
    worker.log.info("worker received INT or QUIT signal")

def pre_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)

def post_worker_init(worker):
    worker.log.info("Worker initialized (pid: %s)", worker.pid)

def worker_abort(worker):
    worker.log.info("Worker aborted (pid: %s)", worker.pid)
