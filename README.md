# Myafrimall — SecureByPay Technical Assessment

A shipping dashboard built from the [Figma design](https://www.figma.com/design/ABTLIq49zQbsgwMgZSNAEK/Technical-test-_MashonaDev): **Sign up**, **Sign in** and an authenticated **Dashboard** (wallet balance, shipment stats, company-growth chart, recent shipments).

| | URL |
|---|---|
| Live app | https://securebypay-myafrimall.vercel.app |
| API | https://securebypay-api-cw9m.onrender.com/api (health: `/api/health`) |
| Figma | https://www.figma.com/design/ABTLIq49zQbsgwMgZSNAEK/Technical-test-_MashonaDev |

## Stack

| Layer | Tech |
|---|---|
| Frontend (`frontend/`) | Flutter Web 3.x, go_router (route guards), http, flutter_secure_storage, fl_chart, google_fonts (DM Sans / Manrope) |
| Backend (`backend/`) | NestJS 10, TypeORM, PostgreSQL, Passport JWT, bcrypt (`bcryptjs`), class-validator |
| Hosting | Render (API + managed Postgres via `render.yaml`), Vercel (static Flutter build) |

## Repository layout

```
backend/src/
  main.ts                         bootstrap: CORS, /api prefix, validation pipe, error filter
  config/env.validation.ts        fails fast on missing or invalid env vars
  auth/                           controller, service, JWT strategy + guard, DTOs
  users/                          User entity + service
  dashboard/                      Shipment entity, service, controller, query DTOs
  common/                         exception filter, @CurrentUser decorator
  health/                         liveness endpoint
frontend/lib/
  theme/                          design tokens from Figma + ThemeData
  core/                           ApiClient, AuthController, AuthScope, models
  router.dart                     auth-gated routes
  widgets/                        shared inputs and buttons
  features/auth/                  sign in / sign up, shared layout, validators
  features/dashboard/             dashboard widgets + DashboardRepository
render.yaml                       Render Blueprint (API + Postgres)
```

## Local setup

**Prerequisites:** Node 18+, Flutter 3.22+, PostgreSQL 14+ (or Docker).

### Backend

```bash
cd backend
cp .env.example .env            # edit DATABASE_URL / JWT_SECRET
docker run -d --name sbp-pg -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=securebypay -p 5432:5432 postgres:16-alpine
npm install
npm run build && npm start      # http://localhost:3000/api/health
```

Tables are created automatically on start (`synchronize: true`, which is fine for an assessment; use migrations in production).

### Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 8080 --dart-define=API_BASE_URL=http://localhost:3000/api
```

## Environment variables

### `backend/.env` (see `backend/.env.example`)

| Variable | Description |
|---|---|
| `PORT` | HTTP port (default `3000`) |
| `DATABASE_URL` | Postgres connection string |
| `DATABASE_SSL` | `true` for managed Postgres (Render/Railway), `false` locally |
| `JWT_SECRET` | HMAC secret used to sign tokens; long and random |
| `JWT_EXPIRES_IN` | Token lifetime, e.g. `1d` |
| `CORS_ORIGINS` | Comma-separated allowed origins (the deployed frontend URL). Empty allows all (dev only) |

### Frontend (see `frontend/.env.example`)

Flutter Web has no runtime environment, so the API URL is compiled in with `--dart-define=API_BASE_URL=...`.

## API

All routes are prefixed with `/api`. Protected routes need `Authorization: Bearer <token>`.

| Method | Path | Auth | Body / query | Response |
|---|---|---|---|---|
| POST | `/auth/register` | – | `{ firstName, lastName, email, phone, password }` | `201 { accessToken, user }` |
| POST | `/auth/login` | – | `{ email, password }` | `200 { accessToken, user }` |
| GET | `/auth/me` | ✔ | – | current user |
| GET | `/dashboard/overview` | ✔ | – | `{ balance, totalShipments, totalExports, totalImports }` |
| GET | `/dashboard/shipments` | ✔ | `?limit=10` | recent shipments |
| GET | `/dashboard/growth` | ✔ | `?period=year\|month\|week` | `{ period, points[] }` |
| GET | `/health` | – | – | `{ status: "ok" }` |

**Error shape** (every non-2xx response):

```json
{ "statusCode": 400, "error": "BAD_REQUEST", "message": "Validation failed", "details": ["email must be an email"] }
```

`400` validation · `401` bad credentials / missing or invalid token · `409` email already registered · `500` unexpected.

Validation: valid email (stored lower-cased); password 8–72 chars with at least one letter and one number; phone in international format (`+2348012345678`); unknown fields are rejected. Query params are validated too (`limit` 1–50, `period` one of year/month/week).

## Auth flow (end to end)

1. **Sign up / Sign in.** Forms validate on the client with the same rules as the backend DTOs and show errors inline under each field. Submitting disables the form and shows a spinner on the button.
2. **API.** `register` hashes the password with bcrypt (cost 10) and saves the user. New accounts are seeded with demo shipments and a demo balance, so the dashboard has data to show. `login` checks the password with bcrypt and returns the same `401` for an unknown email or a wrong password, so accounts can't be discovered by guessing. Both return `{ accessToken, user }`, where the access token is a JWT (`sub` = user id) signed with `JWT_SECRET`.
3. **Client storage.** `AuthController` saves the token with `flutter_secure_storage`. On web that encrypts it with a WebCrypto AES key before putting it in localStorage. Server errors (e.g. "Invalid email or password", "email already exists") appear in a banner above the submit button.
4. **Route guard.** `go_router`'s `redirect` sends signed-out users to `/login` and bounces signed-in users away from `/login` and `/signup`. It listens to `AuthController`, so logging in or out navigates straight away.
5. **Authenticated requests.** `ApiClient` adds `Authorization: Bearer <token>`. On the server, `JwtStrategy` checks the signature and expiry, then reloads the user, so a token for a deleted account is rejected.
6. **Restore and expiry.** On startup the app reads the stored token and a cached copy of the profile, and shows the dashboard straight away without waiting on the network, so a sleeping Render instance does not block the first screen. It then checks the token with `/auth/me` in the background, and a `401` ends the session. A `401` from any dashboard call logs the user out, and the router sends them back to `/login`.
7. **Logout.** Deletes the stored token and clears the in-memory session.

## Responsive behaviour

Breakpoints (`tokens.dart`): mobile under 600px, tablet 600–1023px, desktop 1024px and up.

- **Auth screens.** Desktop keeps the design's 700/740 split with the world-map brand panel. Tablet and mobile hide the panel and centre the form. On narrow phones the first and last name fields stack, and the submit button goes full width.
- **Dashboard.** Desktop has a fixed 240px side nav. Smaller screens use a drawer opened from a menu button in the top bar. The overview shows one row on desktop, the balance above a row of stats on tablet, and on mobile a full-width balance card above three compact stat cards. On mobile, shipment cards give the tracking ID its own row and put the other fields in 2 columns, and the chart labels every other month. The banner and chart scale with width.

## Deployment

**Backend (Render):** push this repo to GitHub, then in Render choose **New → Blueprint** and select the repo. `render.yaml` creates the Postgres database and the web service, and generates `JWT_SECRET`. Once the frontend is live, set `CORS_ORIGINS` to its URL.

**Frontend (Vercel):**

```bash
cd frontend
flutter build web --release --dart-define=API_BASE_URL=https://<render-app>.onrender.com/api
cp -r build/web /tmp/site && cd /tmp/site && vercel deploy --prod   # copy out first: the CLI skips build/ because it is gitignored
```

`web/vercel.json` rewrites every path to `index.html`, so deep links like `/dashboard` work.

> Render's free tier sleeps when idle, so the first request can take around 30 seconds. The client waits up to 60 seconds before timing out.

## Notes and trade-offs

- The Figma file only has desktop (1440px) frames, so the tablet and mobile layouts are adapted from them.
- Nav items other than Dashboard, "Forgot password", "See All", "Fund Wallet" and "Pay Now" are visual only. They are outside the auth scope and have no backend flow yet.
- The growth chart uses static demo data served by the API, since there is no real revenue source behind it.
