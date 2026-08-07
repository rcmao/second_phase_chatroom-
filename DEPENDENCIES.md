# Dependencies

This document summarizes the dependencies for the Chime Chatroom Interruptive Chatbot repository.

## Runtime Requirements

- Python 3.8 or later
- macOS, Linux, or Windows
- At least 2 GB available memory for local development
- Optional OpenAI-compatible API endpoint for LLM-assisted classification and intervention wording

## Web Application Dependencies

The main dependency list is maintained in:

```text
web_app/requirements.txt
```

Core packages include:

```text
Flask
Flask-CORS
Flask-SocketIO
Flask-SQLAlchemy
Flask-Login
Flask-WTF
Werkzeug
python-dotenv
bcrypt
PyJWT
eventlet
requests
aiohttp
pytz
pytest
pytest-asyncio
```

The app uses `requests` for OpenAI-compatible API calls, so installing the official `openai` Python package is not required for the current implementation.

## Install

From the repository root:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r web_app/requirements.txt
```

On Windows:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r web_app\requirements.txt
```

## Configuration

Create a local environment file from the template:

```bash
cp web_app/env.example web_app/.env
```

Typical values:

```bash
SECRET_KEY=your-secret-key
DATABASE_URL=sqlite:///instance/chatbot.db
OPENAI_API_KEY=your-openai-api-key
OPENAI_BASE_URL=https://api.openai.com/v1
LLM_TOXICITY_ENABLED=true
LLM_INTERVENTION_ENABLED=true
```

Local `.env` files, SQLite databases, logs, exported chat records, and participant data should not be committed.

## Quick Checks

```bash
python -c "import flask, flask_socketio, sqlalchemy, requests; print('dependencies ok')"
python -c "import requests; print('api client available')"
```

## Notes

- Use a virtual environment for development.
- Keep dependency changes in `web_app/requirements.txt`.
- Do not commit local runtime artifacts.
