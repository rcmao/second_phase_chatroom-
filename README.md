# Chime Chatroom Interruptive Chatbot

This repository contains a Flask and WebSocket-based chatroom system with an AI-assisted intervention engine for moderating and guiding football discussion tasks. The system was designed for controlled group-chat studies in which an automated moderator can detect silence, conflict, topic drift, and sustained floor dominance, then generate lightweight interventions.

## Key Features

### Smart Intervention Engine

- Toxicity detection: identifies potentially offensive content in Chinese football discussions using a hybrid keyword and LLM-based workflow.
- Keyword matching: supports local detection rules with mild, moderate, and severe categories.
- Conflict escalation detection: monitors rapid exchanges and repeated hostile turns.
- Topic drift detection: checks whether discussion is moving away from the football task.
- Structured intervention generation: produces brief prompts for silence invitations, agenda transitions, structure guidance, and conflict interruption.

### Real-Time Monitoring

- Periodic scanning: scans active rooms at a configurable interval.
- Silence monitoring: detects individual silence and group-level lulls.
- Intervention cooldowns: prevents repeated or overly frequent prompts.
- Room state tracking: monitors active rooms, message counts, and recent intervention history.
- Admin feedback: records intervention actions and runtime status for administrators.

### Web Chatroom

- Multi-room chat interface.
- Role-based user and admin views.
- WebSocket message delivery.
- Optional LLM-powered moderation and message generation.
- Configurable intervention style and detection thresholds.

## System Overview

```text
SmartInterventionEngine
├── Detection
│   ├── LLM toxicity detection
│   ├── Keyword matching
│   ├── Conflict escalation detection
│   └── Topic drift detection
├── Intervention generation
│   ├── Silence invitation
│   ├── Agenda transition
│   ├── Structure guidance
│   └── Topic pullback
├── Governance control
│   ├── Progressive warning stages
│   ├── User behavior tracking
│   ├── Throttling and deduplication
│   └── Cooldown management
└── LLM integration
    ├── Message generation
    ├── Tone cleanup
    └── Fallback templates

RealtimeMonitor
├── Monitoring loop
│   ├── Scheduled scans
│   ├── Room state checks
│   └── Intervention triggers
├── State management
│   ├── Active room management
│   ├── Cooldown control
│   └── Error handling
└── Reporting
    ├── Intervention statistics
    ├── Status summaries
    └── Admin notifications
```

## Data Flow

1. A user message is received by the chatroom.
2. The intervention engine analyzes the message and recent room context.
3. The engine decides whether an intervention is needed.
4. If triggered, the system generates or selects an intervention message.
5. The message is stored and broadcast to the room through WebSocket.
6. The monitor updates room-level state and intervention statistics.

## Getting Started

### Requirements

- Python 3.8 or later
- Flask
- Flask-SocketIO
- Flask-SQLAlchemy
- Optional OpenAI-compatible API endpoint for LLM-based detection and intervention generation

Install dependencies:

```bash
pip install -r web_app/requirements.txt
```

### Configuration

Copy the example environment file and fill in local values:

```bash
cp web_app/env.example web_app/.env
```

Common configuration options include:

```bash
OPENAI_API_KEY=your_openai_api_key
OPENAI_BASE_URL=https://api.openai.com/v1
LLM_TOXICITY_ENABLED=true
LLM_INTERVENTION_ENABLED=true
LLM_TOXICITY_MODEL=gpt-4o-mini
LLM_MESSAGE_MODEL=gpt-4o-mini
GLOBAL_COOLDOWN=30
FOOTBALL_ON_TOPIC_RATIO=0.3
INTERVENTION_TONE=warm
```

Do not commit `.env` files, local databases, logs, or exported participant records.

### Run the Web App

From the `web_app` directory:

```bash
cd web_app
python app.py
```

You can also use the included startup scripts when deploying to a server:

```bash
./start_production.sh
```

## Main Configuration Parameters

- `SILENCE_THRESHOLD`: individual silence threshold in seconds.
- `AGENDA_TRANSITION_THRESHOLD`: group-level silence threshold for agenda transitions.
- `GLOBAL_COOLDOWN`: global minimum interval between interventions.
- `GUIDANCE_COOLDOWN`: cooldown for structure-guidance interventions.
- `FOOTBALL_ON_TOPIC_RATIO`: keyword-ratio threshold for football-topic detection.
- `LLM_TOXICITY_ENABLED`: enables LLM-assisted toxicity detection.
- `LLM_INTERVENTION_ENABLED`: enables LLM-generated intervention wording.
- `INTERVENTION_TONE`: sets intervention tone, such as `warm` or `neutral`.

## Intervention Types

### Silence Invitation

Triggered when a participant has been silent beyond the configured threshold. The system invites the participant to share a view without speaking on their behalf.

### Agenda Transition

Triggered when the group conversation stalls. The system proposes a new football-related angle or discussion prompt.

### Structure Guidance

Triggered when one participant sends several consecutive messages or when the conversational floor becomes too concentrated. The system asks the group to return to a more balanced turn structure.

### Conflict Interruption

Triggered when the system detects offensive language, escalating conflict, or a high-risk exchange. The system posts a brief reminder to keep the discussion respectful.

### Topic Pullback

Triggered when the discussion drifts away from the assigned football topic. The system redirects the group toward the task.

## Repository Structure

```text
web_app/                  Main Flask chatroom application
web_app/templates/        HTML templates
web_app/static/           Static assets
web_app/app.py            Main web application
web_app/realtime_monitor.py
web_app/smart_intervention_engine.py
config/                   Example configuration files
src/                      Experimental core modules and utilities
scripts/                  Utility and deployment scripts
examples/                 Basic usage examples
```

## Privacy Notice

This public repository is intended to contain source code and configuration templates only. Participant chat logs, interview transcripts, exported records, local database files, local environment files, and other study data should not be committed to this repository.

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.

## Support

For questions or issues, please open an issue in this repository or contact the project maintainers.
