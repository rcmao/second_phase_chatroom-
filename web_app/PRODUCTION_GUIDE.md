# Chime Chatroom Production Guide

This guide describes a basic production deployment for the Chime web chatroom.

## Deployment Options

### Scripted Start

```bash
cd /path/to/second_phase_chatroom-/web_app
chmod +x start_production.sh
./start_production.sh
```

### Gunicorn

```bash
cd /path/to/second_phase_chatroom-/web_app
gunicorn --config gunicorn.conf.py wsgi:application
```

## Components

- Gunicorn: WSGI server.
- eventlet: WebSocket-compatible worker backend.
- Nginx: optional reverse proxy.
- systemd: optional service manager.
- SQLite or another SQLAlchemy-compatible database.

## Example systemd Unit

```ini
[Unit]
Description=Chime Chatroom Application
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/second_phase_chatroom-/web_app
ExecStart=/usr/bin/gunicorn --config gunicorn.conf.py wsgi:application
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

## Environment

Create a production `.env` from `env.example` and keep it off Git:

```bash
cp env.example .env
```

Set at least:

```bash
SECRET_KEY=replace-this
DATABASE_URL=sqlite:///instance/chatbot.db
OPENAI_API_KEY=your-api-key
OPENAI_BASE_URL=https://api.openai.com/v1
LLM_TOXICITY_ENABLED=true
LLM_INTERVENTION_ENABLED=true
```

## Privacy

Do not deploy with participant data committed to the repository. Keep runtime databases, logs, exported chat histories, interview transcripts, and environment files outside version control.
