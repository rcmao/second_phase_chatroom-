# Project Files

This document gives a concise map of the repository. Public documentation follows the Chime/KF1-KF3 terminology used in the paper.

## Repository Overview

```text
second_phase_chatroom-/
├── README.md
├── DEPENDENCIES.md
├── PROJECT_FILES.md
├── config/
├── examples/
├── scripts/
├── src/
└── web_app/
```

## Main Web Application

```text
web_app/app.py
```

Main Flask application. It handles routing, authentication, room management, message storage, WebSocket events, and admin views.

```text
web_app/smart_intervention_engine.py
```

Core Chime intervention engine. It implements the paper-aligned intervention logic:

- KF1 Activation: silent invitation, icebreaker, agenda transition.
- KF2 Safety: toxicity reminder, conflict de-escalation, emergency brake.
- KF3 Structure: turn-taking reminder, topic pullback.

It also handles safety-first priority, cooldowns, detection outputs, template fallback, and optional LLM-generated wording.

```text
web_app/realtime_monitor.py
```

Background monitor for active rooms. It checks room state, silence, lulls, and eligible intervention opportunities.

```text
web_app/templates/
```

HTML templates for chatroom, rooms, dashboard, admin dashboard, profile, and error pages.

```text
web_app/static/
```

Static frontend assets.

```text
web_app/requirements.txt
```

Python dependencies for the web application.

```text
web_app/env.example
```

Example environment configuration. Copy this to `.env` locally. Do not commit real `.env` files.

## Supporting Directories

```text
src/
```

Experimental core modules and utilities retained from earlier development. The public paper-aligned runtime is represented primarily by `web_app/app.py`, `web_app/smart_intervention_engine.py`, and `web_app/realtime_monitor.py`.

```text
config/
```

Configuration templates and settings examples.

```text
scripts/
```

Utility and deployment scripts.

```text
examples/
```

Small usage examples.

```text
@analysis/
```

Analysis scaffold and non-sensitive aggregate outputs. Raw chat records and participant-level exported records should not be committed.

## Files That Should Stay Local

The repository should not include:

- `.env` files or local environment backups.
- SQLite runtime databases.
- Chat logs or exported chat histories.
- Interview transcripts.
- Participant records.
- Runtime logs or PID files.

These are excluded by `.gitignore` where possible.
