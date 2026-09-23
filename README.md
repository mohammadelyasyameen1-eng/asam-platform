# ASAM digital platform

Next.js and Supabase starter platform for the Afghan Students Association in Malaysia. The public experience uses carefully labelled empty states until ASAM provides verified content; it does not invent leaders, event listings, history, statistics or contact details.

## What is included

- Responsive public home, about, leadership, chapters, universities, events, news, gallery, resources, contact and membership pages.
- Supabase Auth account creation/sign-in and a validated, authenticated membership application flow.
- PostgreSQL schema for profiles, roles, membership review, events, registrations, attendance, certificates, CMS content, notifications and audit records.
- Row-level security policies, transactional event registration and staff-only check-in RPC.
- Member portal with private profile/notification/event counts and an active-member digital ID QR, admin application review/approval, public credential verification, configuration example, accessibility motion handling and privacy-first public content states.

This is a substantial foundation, not a claim that every production operation is ready. Full CMS CRUD, media uploads and storage policies, event check-in interface/QR scanner, certificates issuance/management, richer reports and admin management screens, email notification delivery, rate limiting, and full automated workflow coverage remain to be completed and reviewed before handling real student information.

## Stack and structure

- Next.js App Router, React, strict TypeScript, Tailwind CSS.
- Supabase Auth, Postgres and Storage (storage buckets/policies must be configured as part of deployment).
- `src/app`: public routes and auth/application views.
- `src/components`: shared site shell.
- `src/lib`: Supabase browser client and Zod validation.
- `supabase/migrations`: database schema and RLS policies.

## Local setup

1. Install Node.js 20 or later and npm.
2. Install dependencies with `npm install`.
3. Copy `.env.example` to `.env.local` and set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` from your Supabase project.
4. Apply `supabase/migrations/0001_initial_schema.sql` in the Supabase SQL editor.
5. Run `npm run dev` and open http://localhost:3000.

Supabase email/password auth must be enabled. Configure the project's site URL and redirect URLs for local and production origins. The account creation page supports email/password registration; set confirmation and anti-abuse policies in Supabase. ASAM should confirm whether open self-registration is its intended membership onboarding policy before launch.

## Configuration and security

Never expose `SUPABASE_SERVICE_ROLE_KEY` to browser code or commit it. It is not needed by the current client flows. Use only the anon key in public environment variables. Establish an initial admin through a controlled, trusted SQL operation after the first user is created; never let users self-assign a role. Review the migration with a Supabase/Postgres security reviewer before production: add rate limiting, storage policies, data retention policy, monitoring and backups. Keep RLS enabled.

The application API uses the transactional `register_for_event(event_id)` RPC for registrations. It checks login, event state, deadline, duplicates and capacity under a row lock. The `check_in_member(registration_id)` RPC restricts check-in to event managers and admins and prevents duplicate check-in. Membership approval and ID issuance are restricted to the `review_membership_application` RPC. Public verification RPCs reveal only basic credential status and name/ID for membership confirmation, or certificate title/date.

## Deployment

Deploy the Next.js app to a supported Node hosting provider (for example, Vercel) and provision Supabase separately. Add environment variables in the hosting dashboard, set Supabase Auth URLs, apply migrations, configure private/public storage buckets and policies, then run a production build and end-to-end security review. Point `asam.my` DNS only after the domain is acquired and hosting/Supabase settings are verified; this repository makes no claim about domain ownership.

## ASAM content required

Before launch, ASAM needs to provide and approve its official mission and vision, contact channels, leadership names/photos/bios, university/chapter listings, membership categories and eligibility, policies and privacy notice, event/news content, branding assets, and administrator roster. The association should confirm the application consent, retention, verification disclosure and account creation policies.
