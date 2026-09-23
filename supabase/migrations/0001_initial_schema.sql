-- ASAM platform baseline. Apply with Supabase CLI or SQL editor.
create extension if not exists pgcrypto;
create type public.app_role as enum ('member','event_manager','content_manager','admin');
create type public.application_status as enum ('pending','under_review','approved','rejected','withdrawn');
create type public.event_status as enum ('draft','published','full','closed','cancelled');
create type public.registration_status as enum ('registered','waitlisted','cancelled');
create type public.attendance_status as enum ('not_checked_in','checked_in');

create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 email text not null,
 full_name text,
 preferred_name text,
 phone text,
 date_of_birth date,
 nationality text,
 university text,
 student_id text,
 program text,
 academic_level text,
 city text,
 state text,
 avatar_path text,
 asam_id text unique,
 verification_token uuid unique default gen_random_uuid(),
 role public.app_role not null default 'member',
 membership_status text not null default 'applicant' check (membership_status in ('applicant','active','inactive','suspended')),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.membership_applications (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 status public.application_status not null default 'pending', membership_type text,
 statement text, consent_at timestamptz not null, privacy_version text not null default '1',
 reviewed_by uuid references public.profiles(id), reviewed_at timestamptz, review_note text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.universities (
 id uuid primary key default gen_random_uuid(), name text not null, city text, state text,
 website text, is_published boolean not null default false, created_at timestamptz not null default now()
);
create table public.chapters (
 id uuid primary key default gen_random_uuid(), university_id uuid references public.universities(id) on delete set null,
 name text not null, description text, coordinator_id uuid references public.profiles(id) on delete set null,
 status text not null default 'inactive' check(status in ('active','inactive','forming')),
 is_published boolean not null default false, created_at timestamptz not null default now()
);
create table public.leaders (
 id uuid primary key default gen_random_uuid(), name text not null, position text not null,
 category text not null check(category in ('executive','advisor','committee')), university text,
 bio text, photo_path text, social_links jsonb not null default '{}', sort_order int not null default 0,
 is_published boolean not null default false, created_at timestamptz not null default now()
);
create table public.events (
 id uuid primary key default gen_random_uuid(), slug text not null unique, title text not null, summary text,
 description text, category text not null default 'community', venue text, starts_at timestamptz not null,
 ends_at timestamptz, registration_deadline timestamptz, capacity int check(capacity is null or capacity >= 0),
 poster_path text, organizer text, status public.event_status not null default 'draft',
 created_by uuid references public.profiles(id), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.event_registrations (
 id uuid primary key default gen_random_uuid(), event_id uuid not null references public.events(id) on delete cascade,
 member_id uuid not null references public.profiles(id) on delete cascade, status public.registration_status not null default 'registered',
 attendance_status public.attendance_status not null default 'not_checked_in', registered_at timestamptz not null default now(),
 checked_in_at timestamptz, checked_in_by uuid references public.profiles(id),
 unique(event_id,member_id), check((attendance_status='not_checked_in' and checked_in_at is null) or (attendance_status='checked_in' and checked_in_at is not null))
);
create table public.certificates (
 id uuid primary key default gen_random_uuid(), member_id uuid not null references public.profiles(id) on delete cascade,
 event_id uuid references public.events(id) on delete set null, title text not null, certificate_number text unique not null,
 verification_token uuid unique not null default gen_random_uuid(), file_path text, issued_at timestamptz not null default now(),
 revoked_at timestamptz, created_by uuid references public.profiles(id)
);
create table public.news_posts (
 id uuid primary key default gen_random_uuid(), slug text unique not null, title text not null, excerpt text,
 body text not null, cover_path text, published_at timestamptz, author_id uuid references public.profiles(id),
 is_published boolean not null default false, created_at timestamptz not null default now()
);
create table public.site_content (
 key text primary key, value jsonb not null default '{}', updated_by uuid references public.profiles(id), updated_at timestamptz not null default now()
);
create table public.notifications (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 title text not null, body text not null, kind text not null default 'info', read_at timestamptz,
 created_at timestamptz not null default now()
);
create table public.audit_logs (
 id bigint generated always as identity primary key, actor_id uuid references public.profiles(id) on delete set null,
 action text not null, table_name text not null, record_id text, metadata jsonb not null default '{}',
 created_at timestamptz not null default now()
);
create index events_public_idx on public.events(starts_at) where status='published';
create index news_public_idx on public.news_posts(published_at desc) where is_published;
create index registrations_event_idx on public.event_registrations(event_id,status);
create index notifications_user_idx on public.notifications(user_id,created_at desc);

create function public.has_role(allowed public.app_role[]) returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.profiles where id=auth.uid() and role=any(allowed)); $$;
create function public.protect_profile_privileges() returns trigger language plpgsql security definer set search_path=public as $$
begin
 if auth.uid() is not null and not public.has_role(array['admin']::public.app_role[]) then
   if new.role is distinct from old.role or new.membership_status is distinct from old.membership_status or new.asam_id is distinct from old.asam_id or new.verification_token is distinct from old.verification_token then
     raise exception 'Membership privileges can only be changed by ASAM administrators';
   end if;
 end if;
 return new;
end; $$;
create trigger protect_profile_privileges before update on public.profiles for each row execute procedure public.protect_profile_privileges();
create function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,email,full_name) values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name','')); return new; end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.membership_applications enable row level security;
alter table public.universities enable row level security;
alter table public.chapters enable row level security;
alter table public.leaders enable row level security;
alter table public.events enable row level security;
alter table public.event_registrations enable row level security;
alter table public.certificates enable row level security;
alter table public.news_posts enable row level security;
alter table public.site_content enable row level security;
alter table public.notifications enable row level security;
alter table public.audit_logs enable row level security;

create policy "Profiles visible to self or staff" on public.profiles for select to authenticated using(id=auth.uid() or public.has_role(array['admin','event_manager','content_manager']::public.app_role[]));
create policy "Users update own profile" on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
create policy "Published universities public" on public.universities for select using(is_published or public.has_role(array['admin','content_manager']::public.app_role[]));
create policy "Content staff manage universities" on public.universities for all to authenticated using(public.has_role(array['admin','content_manager']::public.app_role[])) with check(public.has_role(array['admin','content_manager']::public.app_role[]));
create policy "Published chapters public" on public.chapters for select using(is_published or public.has_role(array['admin','content_manager']::public.app_role[]));
create policy "Content staff manage chapters" on public.chapters for all to authenticated using(public.has_role(array['admin','content_manager']::public.app_role[])) with check(public.has_role(array['admin','content_manager']::public.app_role[]));
create policy "Published leaders public" on public.leaders for select using(is_published or public.has_role(array['admin','content_manager']::public.app_role[]));
create policy "Content staff manage leaders" on public.leaders for all to authenticated using(public.has_role(array['admin','content_manager']::public.app_role[])) with check(public.has_role(array['admin','content_manager']::public.app_role[]));
create policy "Published events public" on public.events for select using(status='published' or public.has_role(array['admin','event_manager']::public.app_role[]));
create policy "Event staff manage events" on public.events for all to authenticated using(public.has_role(array['admin','event_manager']::public.app_role[])) with check(public.has_role(array['admin','event_manager']::public.app_role[]));
create policy "Member reads own applications" on public.membership_applications for select to authenticated using(user_id=auth.uid() or public.has_role(array['admin']::public.app_role[]));
create policy "Member submits own application" on public.membership_applications for insert to authenticated with check(user_id=auth.uid() and status='pending');
create policy "Admin reviews applications" on public.membership_applications for update to authenticated using(public.has_role(array['admin']::public.app_role[])) with check(public.has_role(array['admin']::public.app_role[]));
create policy "Members read own registrations" on public.event_registrations for select to authenticated using(member_id=auth.uid() or public.has_role(array['admin','event_manager']::public.app_role[]));
create policy "Members register themselves" on public.event_registrations for insert to authenticated with check(member_id=auth.uid() and status='registered' and attendance_status='not_checked_in');
create policy "Staff manage registrations" on public.event_registrations for update to authenticated using(public.has_role(array['admin','event_manager']::public.app_role[])) with check(public.has_role(array['admin','event_manager']::public.app_role[]));
create policy "Own certificates and public verification" on public.certificates for select using(member_id=auth.uid() or public.has_role(array['admin']::public.app_role[]));
create policy "Admin manages certificates" on public.certificates for all to authenticated using(public.has_role(array['admin']::public.app_role[])) with check(public.has_role(array['admin']::public.app_role[]));
create policy "Published news public" on public.news_posts for select using(is_published or public.has_role(array['admin','content_manager']::public.app_role[]));
create policy "Content staff manage news" on public.news_posts for all to authenticated using(public.has_role(array['admin','content_manager']::public.app_role[])) with check(public.has_role(array['admin','content_manager']::public.app_role[]));
create policy "Public site content read" on public.site_content for select using(true);
create policy "Admin manages site content" on public.site_content for all to authenticated using(public.has_role(array['admin']::public.app_role[])) with check(public.has_role(array['admin']::public.app_role[]));
create policy "Users read own notifications" on public.notifications for select to authenticated using(user_id=auth.uid());
create policy "Users update own notifications" on public.notifications for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "Admin reads audit logs" on public.audit_logs for select to authenticated using(public.has_role(array['admin']::public.app_role[]));
create policy "Authenticated audit insert" on public.audit_logs for insert to authenticated with check(actor_id=auth.uid());

-- Capacity and deadline are enforced transactionally to prevent overbooking races.
create function public.register_for_event(p_event_id uuid) returns public.event_registrations language plpgsql security invoker set search_path=public as $$
declare e public.events%rowtype; registered_count int; result public.event_registrations%rowtype;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select * into e from public.events where id=p_event_id and status='published' for update;
 if not found then raise exception 'Event registration is unavailable'; end if;
 if e.registration_deadline is not null and e.registration_deadline < now() then raise exception 'Registration has closed'; end if;
 if exists(select 1 from public.event_registrations where event_id=p_event_id and member_id=auth.uid() and status<>'cancelled') then raise exception 'Already registered'; end if;
 select count(*) into registered_count from public.event_registrations where event_id=p_event_id and status='registered';
 if e.capacity is not null and registered_count>=e.capacity then raise exception 'Event is full'; end if;
 insert into public.event_registrations(event_id,member_id,status) values(p_event_id,auth.uid(),'registered') returning * into result;
 return result;
end; $$;
revoke all on function public.register_for_event(uuid) from public;
grant execute on function public.register_for_event(uuid) to authenticated;

create function public.check_in_member(p_registration_id uuid) returns public.event_registrations language plpgsql security invoker set search_path=public as $$
declare result public.event_registrations%rowtype;
begin
 if not public.has_role(array['admin','event_manager']::public.app_role[]) then raise exception 'Not authorized'; end if;
 update public.event_registrations set attendance_status='checked_in',checked_in_at=now(),checked_in_by=auth.uid()
 where id=p_registration_id and attendance_status='not_checked_in' and status='registered' returning * into result;
 if not found then raise exception 'Registration unavailable or already checked in'; end if;
 return result;
end; $$;
revoke all on function public.check_in_member(uuid) from public;
grant execute on function public.check_in_member(uuid) to authenticated;

create function public.review_membership_application(p_application_id uuid,p_approved boolean) returns void language plpgsql security definer set search_path=public as $$
declare app public.membership_applications%rowtype; generated_id text;
begin
 if not public.has_role(array['admin']::public.app_role[]) then raise exception 'Not authorized'; end if;
 select * into app from public.membership_applications where id=p_application_id for update;
 if not found or app.status not in ('pending','under_review') then raise exception 'Application is not reviewable'; end if;
 if p_approved then
   generated_id := 'ASAM-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
   update public.profiles set membership_status='active',asam_id=generated_id,verification_token=gen_random_uuid() where id=app.user_id;
   update public.membership_applications set status='approved',reviewed_by=auth.uid(),reviewed_at=now() where id=p_application_id;
 else
   update public.membership_applications set status='rejected',reviewed_by=auth.uid(),reviewed_at=now() where id=p_application_id;
 end if;
 insert into public.audit_logs(actor_id,action,table_name,record_id) values(auth.uid(),case when p_approved then 'membership.approved' else 'membership.rejected' end,'membership_applications',p_application_id::text);
end; $$;
revoke all on function public.review_membership_application(uuid,boolean) from public;
grant execute on function public.review_membership_application(uuid,boolean) to authenticated;

-- Public verification only reveals a status and credential title; it never exposes member contact or academic data.
create function public.verify_member_id(p_token uuid) returns table(valid boolean,member_name text,asam_id text,status text) language sql stable security definer set search_path=public as $$
 select (p.membership_status='active'),p.full_name,p.asam_id,p.membership_status
 from public.profiles p where p.verification_token=p_token and p.asam_id is not null;
$$;
create function public.verify_certificate(p_token uuid) returns table(valid boolean,title text,issued_at timestamptz) language sql stable security definer set search_path=public as $$
 select (c.revoked_at is null),c.title,c.issued_at from public.certificates c where c.verification_token=p_token;
$$;
revoke all on function public.verify_member_id(uuid) from public;
revoke all on function public.verify_certificate(uuid) from public;
grant execute on function public.verify_member_id(uuid) to anon,authenticated;
grant execute on function public.verify_certificate(uuid) to anon,authenticated;
