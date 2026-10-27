# College Placement Management System

Plain HTML/CSS/vanilla JavaScript frontend, Node.js + Express API, and MySQL database. The supplied landing page and original database tables were retained and expanded. The referenced `auth.js` and `/mnt/data` files were unavailable in this workspace, so authentication was implemented from scratch from the supplied requirements.

## Features

- Student self-registration, profile editing, CGPA and PDF resume upload. Resume files are stored outside the public web root, limited to 5 MB, and served through an authenticated download endpoint.
- TPO dashboard for companies, drives, application review, department placement summaries, and recent audit events.
- Recruiter dashboard scoped to the recruiter's assigned company, drives, and applicants. Recruiter accounts are provisioned by an administrator directly in the database; there is no public recruiter signup.
- Eligibility checked in the API against CGPA, department, graduation year, publication status, and deadline. The apply transaction locks the drive and the unique database key prevents duplicate applications.
- Application status history and audit records.
- HTTP-only SameSite cookie sessions, eight-hour token expiry, password hashing, logout token revocation, rate-limited login, origin and custom-header checks for state changes, and role/company checks.

## macOS setup

Install Node.js 20+ and MySQL 8 (for example with Homebrew), then start MySQL:

```sh
brew install node mysql
brew services start mysql
```

Initialize the database and a least-privilege application user:

```sh
cd backend
mysql -u root -p < database/schema.sql
mysql -u root -p -e "CREATE USER 'placement_app'@'localhost' IDENTIFIED BY 'choose-a-password'; GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,ALTER,INDEX ON placement_db.* TO 'placement_app'@'localhost';"
npm install
cp .env.example .env
```

Edit `backend/.env`: set the database password, `FRONTEND_ORIGIN=http://localhost:5173`, and a strong random `JWT_SECRET` (at least 32 characters). Then create the first officer. Set `ADMIN_EMAIL` and a 12+ character `ADMIN_PASSWORD` in `.env`, run:

```sh
npm run seed:admin
```

Remove `ADMIN_PASSWORD` from `.env` after seeding. To provision a recruiter, first create a company through the TPO dashboard, then insert the recruiter user and company link using a bcrypt hash (see `backend/src/seed-admin.js` for the hash pattern). Never use public student registration for staff accounts.

Start the API in `backend`:

```sh
npm run dev
```

In another terminal, start the static frontend:

```sh
cd frontend
python3 -m http.server 5173
```

Visit <http://localhost:5173>. Keep both origins on `localhost`; use `COOKIE_SECURE=true` and HTTPS when deploying. `UPLOAD_DIR` should point to persistent private storage with restrictive filesystem permissions. Back up the database and upload directory together.

## Tests

From `backend`, run `npm test` for the standalone eligibility-rule tests. `npm run test` does not start a database. For an end-to-end check, configure MySQL, start the API, then test registration/login, role boundaries, drive publishing and applying, duplicate submissions, deadline/eligibility rejection, status history, reports, and resume access.

## API overview

All routes are under `/api`. Authentication: `POST /auth/register`, `POST /auth/login`, `POST /auth/logout`, `GET /auth/me`. Other routes include `GET /dashboard`, `GET|PUT /profile`, `POST /profile/resume`, `GET /profile/resume`, `GET|POST /companies`, `GET|POST /drives`, `PATCH /drives/:id/status`, `POST /drives/:id/apply`, `GET /applications`, `PATCH /applications/:id/status`, `GET /applications/:id/history`, `GET /reports/placements`, and `GET /audit`. State-changing browser requests require the configured frontend `Origin` and `X-Requested-With: XMLHttpRequest` header. The frontend sets these automatically.

## Current limitations

- The API and frontend require a local MySQL database to exercise end-to-end; no database credentials or server were available in the build workspace.
- Recruiter provisioning is an operator/database task, and this starter does not include password reset, email verification, bulk import, or production deployment infrastructure.
- The dashboard supports the primary workflows; it is a foundation for production branding, accessibility review, and additional report filters.
