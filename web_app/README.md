# Chime Web Chatroom

This directory contains the Flask web application used to run the Chime chatroom. The app provides synchronous multi-room text chat, participant/admin views, and the runtime integration point for Chime's KF1-KF3 intervention policy.

## Paper-Aligned Functions

- KF1 Activation: silent invitations, icebreakers, and agenda transitions.
- KF2 Safety: gentle toxicity reminders, conflict de-escalation, and emergency-brake messages.
- KF3 Structure: turn-taking reminders and topic pullbacks.

Chime posts brief public messages into the chat stream. It is designed to reshape conversational flow, not to speak on behalf of participants or judge the correctness of their football opinions.

## Web App Features

- Multi-room group chat.
- WebSocket-based real-time message delivery.
- Participant login and administrator dashboard.
- Configurable intervention thresholds and cooldowns.
- Optional OpenAI-compatible API integration for classification and message generation.
- Local fallback templates when LLM calls fail.

## Requirements

- Python 3.8 or later
- Flask
- Flask-SocketIO
- Flask-SQLAlchemy
- eventlet
- requests
- python-dotenv

Install dependencies from this directory or from the repository root:

```bash
pip install -r requirements.txt
```

## Configuration

Copy the example environment file:

```bash
cp env.example .env
```

Common configuration values:

```bash
SECRET_KEY=your-secret-key
DATABASE_URL=sqlite:///instance/chatbot.db
OPENAI_API_KEY=your-openai-api-key
OPENAI_BASE_URL=https://api.openai.com/v1
LLM_TOXICITY_ENABLED=true
LLM_INTERVENTION_ENABLED=true
GLOBAL_COOLDOWN=30
FOOTBALL_ON_TOPIC_RATIO=0.3
INTERVENTION_TONE=warm
```

Do not commit `.env` files, local databases, logs, exported chat records, interview transcripts, or participant data.

## Run Locally

```bash
python app.py
```

Default local pages:

- Main app: `http://localhost:8080`
- Rooms: `http://localhost:8080/rooms`
- Admin dashboard: `http://localhost:8080/admin`

## Main Files

```text
app.py                         Main Flask application
smart_intervention_engine.py   Chime intervention policy and message generation
realtime_monitor.py            Periodic room monitoring
templates/                     HTML templates
static/                        Static assets
requirements.txt               Python dependencies
env.example                    Example local configuration
```

## Privacy

This application may create runtime databases and logs during local use. Those files should remain local and should not be committed to the public repository.
