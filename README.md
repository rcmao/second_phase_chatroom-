# Chime Chatroom Interruptive Chatbot

This repository contains the source code for Chime, an interruptive chatbot and web-based group chatroom system used to support more balanced participation in controlled football-discussion sessions.

Chime was designed as a rule-governed AI moderator for synchronous text-based group chats. It monitors interactional signals such as silence, safety risks, sustained dominance, and topic drift, then posts brief public interventions that reopen conversational space without speaking on behalf of participants or judging the correctness of their football opinions.

## Intervention Functions

Chime is organized around three intervention functions:

- KF1 Activation: legitimizes entry into the discussion through silent invitations, icebreakers, and agenda transitions.
- KF2 Safety: reduces expressive risk through gentle toxicity reminders, conflict de-escalation, and emergency-brake messages.
- KF3 Structure: creates floor-release moments through turn-taking reminders and football-topic pullbacks.

In the study, the Treatment condition used Chime with KF1-KF3 enabled, while the Control condition used the same chatroom without Chime interventions.

## Core Functions

### KF1 Activation

KF1 targets entry legitimacy. It helps participants enter or re-enter the conversational floor when the discussion has not started, has stalled, or when an individual participant has remained silent for a sustained period.

Implemented message types:

- Silent invitation: a targeted @mention inviting a silent participant to share a view.
- Icebreaker: an opening prompt when no participant has spoken yet.
- Agenda transition: a football-related prompt when the group discussion stalls.

### KF2 Safety

KF2 targets expressive safety. It is used when the system detects potentially hostile, exclusionary, or escalating exchanges. The goal is de-escalation, not punishment.

Implemented message types:

- Gentle toxicity reminder: a brief non-punitive reminder after mild risk.
- Conflict de-escalation: a short message redirecting participants back to football arguments rather than personal attacks.
- Emergency brake: a stronger pause-and-reset message for escalating conflict.

### KF3 Structure

KF3 targets floor release. It interrupts sustained floor occupation and reopens transition points so that other participants can enter the conversation.

Implemented message types:

- Turn-taking reminder: a brief prompt when one participant sends several consecutive messages.
- Topic pullback: a smooth redirect when the conversation drifts away from the football task.

## Intervention Policy

Chime follows a four-stage moderation pipeline:

```text
Module A: Sensing
  Message stream -> interactional signals
  Signals include silence, dominance, toxicity/conflict risk, and topic drift.

Module B: Reasoning
  Signals -> candidate intents
  Candidate intents map to KF1, KF2, or KF3.

Module C: Arbitration
  Candidate intents + current room context -> at most one approved intervention
  Safety-first priority and cooldown rules limit over-interruption.

Module D: Generation
  Approved intent + minimal context -> brief guardrailed Chime message
  Messages are generated from structured templates with fallback wording.
```

Priority order:

```text
KF2 Safety > KF3 Structure > KF1 Activation
```

This means safety-related interventions take precedence when multiple triggers are present. If the discussion is active, Chime favors structure-related intervention over activation prompts; if the discussion is inactive, Chime favors activation.

## Trigger Conditions

The study used task-calibrated thresholds for a 15-minute, three-person football chat:

| Trigger family | Module | Condition |
| --- | --- | --- |
| Individual silence | KF1 | A participant is silent for at least 90 seconds after chat has started. |
| Group silence | KF1 | Icebreaker if no participant has spoken and group silence exceeds 45 seconds. |
| Group lull | KF1 | Agenda transition if an ongoing discussion stalls for at least 60 seconds. |
| Safety risk | KF2 | Toxicity keyword hit or LLM-classified toxicity/conflict escalation. |
| Sustained dominance | KF3 | One participant sends at least 4 consecutive messages. |
| Topic drift | KF3 | Conversation is flagged as no longer mainly football-related. |

Cooldowns and throttles:

- Global cooldown: 30 seconds.
- KF1 per-user cooldown: 120 seconds.
- KF3 shared cooldown: 180 seconds.
- Agenda transition cooldown: 60 seconds.
- Conflict throttle: 30 seconds.

## Web Chatroom

The repository also includes the web chatroom used to deploy Chime in experimental sessions:

- Multi-room text chat interface.
- Participant and administrator views.
- WebSocket-based real-time message delivery.
- Admin controls for rooms and users.
- Optional OpenAI-compatible API integration for classification and message generation.
- Local fallback templates when LLM calls fail.

## Getting Started

### Requirements

- Python 3.8 or later
- Flask
- Flask-SocketIO
- Flask-SQLAlchemy
- Optional OpenAI-compatible API endpoint for LLM-based classification and message generation

Install dependencies:

```bash
pip install -r web_app/requirements.txt
```

### Configuration

Copy the example environment file and fill in local values:

```bash
cp web_app/env.example web_app/.env
```

Common configuration options:

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

Do not commit `.env` files, local databases, logs, exported chat records, interview transcripts, or any participant data.

### Run the Web App

From the `web_app` directory:

```bash
cd web_app
python app.py
```

Production helper scripts are included for server deployment:

```bash
./start_production.sh
```

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
