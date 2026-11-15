# AGENTS.md

## Project Overview
**vballHub** is a centralized community directory for recreational volleyball tournaments, leagues, and drop-ins in Vancouver, BC.
- **Frontend (`apps/web`):** Next.js App Router handling public event discovery (synchronized list, calendar, and map views), single-event `.ics` calendar exports, public organizer submissions, and an Auth0-protected `/admin` review queue.
- **Ingestion Service (`services/ingest`):** Python FastAPI microservice handling multimodal tournament poster extraction (Gemini API + Pydantic) and post-MVP scheduled web scrapers.

## Tech Stack
- **Web:** Next.js (App Router), TypeScript (strict), Tailwind CSS, Leaflet/MapLibre, Zod, Prisma/Drizzle
- **Ingest:** Python 3.12+, FastAPI, Pydantic v2, `google-genai`, Pillow, Playwright
- **Database & Infra:** PostgreSQL (Neon/Supabase) + PostGIS, Auth0 (RBAC), Docker, GitHub Actions

## Commands
- **Web Dev:** `cd apps/web && npm run dev`
- **Web Lint & Test:** `cd apps/web && npm run lint && npx vitest run`
- **Database Migrate:** `cd apps/web && npx prisma migrate dev`
- **FastAPI Dev:** `cd services/ingest && uvicorn app.main:app --reload`
- **FastAPI Test:** `cd services/ingest && pytest`
- **Docker:** `docker compose up --build`

## Domain Rules & Invariants
1. **Domain Enums & Skill Normalization:**
   - Store each event division with both the organizer's `display_label` (e.g., `Open`, `AA+`, `A-`, `Upper Intermediate`) and a normalized `skill_score` (`0`–`100` integer derived from the ordered division list on the poster, adjustable in admin review).
   - **Surfaces:** `indoor`, `beach`, `grass`
   - **Formats:** `coed_6s`, `mens`, `womens`, `R4s`, `R2s`
   - **Post-MVP Player Profiles:** Keep player `skill_level` mutable (organizers frequently re-tier players), and model post-event difficulty feedback as `harder`, `as_expected`, or `easier`.
2. **Moderation State Machine:** All public submissions and AI poster extractions MUST enter PostgreSQL with `status = 'pending'`. Never write directly to `published` without admin Auth0 RBAC verification.
3. **Venue Normalization:** Never auto-create rows in the `Venue` table from scraped or AI-extracted text. Match against existing canonical Vancouver venue IDs or flag as unverified for admin geocoding.
4. **Nullable AI Fields:** Keep `price`, `end_time`, and `registration_deadline` nullable in Pydantic/Zod schemas so Gemini does not hallucinate missing poster details.
5. **Media Storage:** Never persist expiring social media CDN URLs; upload poster bytes to object storage (Cloudflare R2/S3) or pass directly in memory.

## Repository Structure
```text
vballhub/
├── .github/
│   └── workflows/
│       └── ci.yml                 # Automated linting & tests on push/PR
├── apps/
│   └── web/                       # Next.js Frontend (deployed to Vercel)
│       ├── prisma/
│       │   └── schema.prisma      # PostgreSQL tables (Venue, Event, Division, Submission)
│       ├── src/
│       │   ├── app/               # Public pages, /admin review queue, /submit form
│       │   ├── components/        # Synchronized List, Calendar, Leaflet/MapLibre Map, Filters
│       │   └── lib/               # Auth0 helpers, Zod schemas, .ics generator, DB client
│       ├── .env.local             # Local secrets (ignored by Git)
│       └── package.json
├── services/
│   └── ingest/                    # Python FastAPI Service (deployed to Render)
│       ├── app/
│       │   ├── main.py            # GET /health and POST /extract/poster endpoints
│       │   ├── schemas.py         # Pydantic models (display_label, skill_score, nullable fields)
│       │   ├── extractor.py       # Gemini Vision multimodal poster parser
│       │   └── scrapers/          # (Post-MVP) Eventbrite, Meetup, organizer scrapers
│       ├── tests/                 # pytest unit & endpoint tests
│       ├── Dockerfile             # Production container build for Render
│       ├── .env                   # Gemini API key (ignored by Git)
│       └── requirements.txt
├── .gitignore                     # Ignores node_modules, .venv, .next, .env*
├── docker-compose.yml             # Local multi-service development environment
├── AGENTS.md                      # Architectural rules and context for AI coding agents
└── README.md                      # Human project & portfolio documentation
```

## Guardrails
- Never read, log, or commit `.env*` files or API secrets.
- Never run destructive database resets (`prisma migrate reset`, `DROP`, `TRUNCATE`) against non-local environments.
- Always validate external inputs at API boundaries using Zod (TypeScript) and Pydantic (Python).