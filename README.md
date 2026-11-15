# vballHub

A centralized database for local recreational volleyball tournaments, leagues and drop ins in Vancouver. Users can browse synchronized list, calendar, and venue map views—and export individual events to their calendar—while organizers submit events for admin review.

## Key Features
- **Multi-View Discovery:** Browse and filter events by surface (indoor/beach/grass), format (coed 6s/mens/womens/R4s/R2s), and registration status—with full organizer division labels displayed—across synchronized list, calendar grid, and interactive map views.
- **One-Click Calendar Export:** Download an `.ics` file for any specific tournament or league you decide to join.
- **AI-Assisted Poster Extraction:** Python FastAPI service using the Gemini multimodal API + Pydantic validation to parse uploaded tournament poster images into structured event fields.
- **Human-in-the-Loop Moderation:** Public organizer submission form routed into an Auth0 RBAC-protected admin review queue before publishing.

## Tech Stack
- **Frontend:** Next.js (App Router), TypeScript, Tailwind CSS, Leaflet / MapLibre
- **Backend / Ingestion:** Python 3.12+, FastAPI, Pydantic v2, Playwright
- **AI Extraction:** Google Gemini Vision/Text API (`google-genai`)
- **Database:** PostgreSQL (Neon / Supabase) + PostGIS, Prisma / Drizzle
- **Auth & Automation:** Auth0 (RBAC), GitHub Actions CI/CD & Cron, Docker

## Repository Structure
```text
├── apps/web/          # Next.js frontend, public UI, .ics export, Auth0 admin queue
├── services/ingest/   # Python FastAPI poster OCR extraction & scheduled scrapers
├── docker-compose.yml # Local multi-service development environment
└── AGENTS.md          # Architectural rules and context for AI coding agents
```
## Roadmap (Post-MVP)
- **Player Profiles & Post-Event Difficulty Feedback:** Optional player accounts to log attended tournaments/leagues, maintain a mutable self-declared skill level (adjustable as players improve or get moved between divisions by organizers), and rate past events as harder, same level, or easier than expected.
- **Verified Attendance Sync & Player Discovery:** Automatically sync verified tournament participation to player profiles and enable opt-in player/sub discovery by normalized skill tier and format.
- **Discord Notifications:** Webhook alerts for newly approved tournaments matching specific skill tiers or formats.
- **Automated Ingestion:** Scheduled scrapers for local league websites and Instagram posts
