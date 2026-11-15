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
   - **Event Types:** `tournament`, `league`, `drop_in` (top-level filter allowing players to isolate or view all). Multi-week leagues store `start_date`, `end_date`, and `day_of_week` (e.g., `"Tuesdays"`) to present cleanly without duplicating event entries.
   - **Surfaces:** `indoor`, `beach`, `grass`
   - **Formats:** `coed_6s`, `mens`, `womens`, `R4s`, `R2s`
   - **Registration Statuses:** `upcoming`, `open`, `waitlist`, `sold_out` (avoid live spot counts that go stale).
   - **Organizer Filter:** Support filtering events by organizer name/entity.
   - **Post-MVP Player Profiles:** Keep player `skill_level` mutable (organizers frequently re-tier players), and model post-event difficulty feedback as `harder`, `as_expected`, or `easier`.
2. **Event-to-Division Data Model (1-to-Many):**
   - Model `Event` (the overarching tournament, league, or drop-in: title, event type, organizer, date/recurrence, venue, registration link, registration_opens_at, registration_status, poster) separately from `EventDivision` (display_label, skill_score, format, price). A single weekend tournament offering multiple tiers (e.g., Men's Open, Co-Ed AA, Co-Ed B) MUST be stored as one event with multiple divisions, avoiding duplicate map pins and calendar spam.
3. **Timezone & Localization:**
   - Use the IANA timezone name `America/Vancouver` as the default configuration constant (never hardcode `"PDT"` or `"PST"`), handling daylight saving time transitions automatically and simplifying future multi-city expansion.
4. **Moderation State Machine:** All public submissions and AI poster extractions MUST enter PostgreSQL with `status = 'pending'`. Never write directly to `published` without admin Auth0 RBAC verification.
5. **Venue Normalization & Pre-Seeding:**
   - Never auto-create rows in the `Venue` table from scraped or AI-extracted text. Match against existing canonical Vancouver venue IDs or flag as unverified for admin geocoding.
   - Pre-seed the `Venue` lookup table upfront with 15–20 major Metro Vancouver gyms and beach courts (e.g., Kitsilano Beach, Spanish Banks, UBC War Memorial / SRC, Richmond Olympic Oval, Bonsor, Creekside, Pinetree, Harry Jerome) with verified latitude/longitude.
6. **Nullable AI Fields:** Keep `price`, `end_time`, `registration_opens_at`, and `registration_deadline` nullable in Pydantic/Zod schemas so Gemini does not hallucinate missing poster details.
7. **Media Storage:** Never persist expiring social media CDN URLs; upload poster bytes to object storage (Cloudflare R2/S3) or pass directly in memory.
8. **UI, Styling & Mobile-First Conventions:**
   - **Mobile-First UX:** Layouts, filter bars, event cards, and `.ics` export buttons must be optimized for mobile screens (majority traffic arrives via Instagram, WhatsApp, Discord links).
   - **Default Landing View:** Default to **List View** for fast mobile scrolling, with a sticky top bar to switch seamlessly between `List | Calendar | Map`.
   - **Theme & Color Vibe:** Light-mode-first athletic/editorial aesthetic with high-contrast white and slate cards ensuring poster art and court badges pop (no theme switcher for MVP).
   - **Accent Color & Visual Badges:** Color-coded pills for fast visual scanning:
     - *Surface:* `Indoor` (blue), `Beach` (amber/sand), `Grass` (green)
     - *Registration Status:* `Open` (emerald), `Opening Soon` (sky), `Waitlist` (yellow), `Sold Out` (muted gray)
   - **Component Library:** Tailwind CSS + **shadcn/ui** and **Lucide icons** for consistent buttons, modals, filter chips, and admin review drawers without custom CSS overhead.

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