-- AWM DIGITAL SHOWROOM V4 SAFE MIGRATION
-- No cart, checkout, payment, shipping or sales tables.
-- Safe to run after the AWM V2 SAFE migration.
begin;

-- Extend products with showroom-only presentation flags.
alter table if exists public.products
  add column if not exists showroom_badge text,
  add column if not exists display_note text,
  add column if not exists is_coming_soon boolean not null default false,
  add column if not exists is_last_piece boolean not null default false;

-- Extend product_meta for SEO / size guidance.
alter table if exists public.product_meta
  add column if not exists badge text,
  add column if not exists display_note text,
  add column if not exists is_coming_soon boolean not null default false,
  add column if not exists is_last_piece boolean not null default false;

-- Singleton showroom settings.
create table if not exists public.showroom_settings (
  id uuid primary key default gen_random_uuid(),
  singleton_key text not null unique default 'default',
  store_name text,
  tagline text,
  about_text text,
  address text,
  hours text,
  phone text,
  whatsapp text,
  map_url text,
  instagram_url text,
  tiktok_url text,
  facebook_url text,
  display_message text,
  updated_at timestamptz not null default now()
);

insert into public.showroom_settings (singleton_key, store_name, tagline, whatsapp)
select 'default', 'AWM Store', 'المعرض الرقمي لـ AWM', '201020776397'
where not exists (select 1 from public.showroom_settings where singleton_key='default');

-- Lookbooks.
create table if not exists public.lookbooks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  description text,
  cover_image_url text,
  product_ids text[] not null default '{}',
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- QR codes for physical showroom use.
create table if not exists public.qr_codes (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  type text not null default 'product',
  target text not null,
  product_id text,
  image_url text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Helpful indexes for public showroom reads.
create index if not exists idx_showroom_settings_singleton on public.showroom_settings(singleton_key);
create index if not exists idx_lookbooks_active_order on public.lookbooks(is_active, sort_order);
create index if not exists idx_qr_codes_active_order on public.qr_codes(is_active, sort_order);

-- RLS.
alter table public.showroom_settings enable row level security;
alter table public.lookbooks enable row level security;
alter table public.qr_codes enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='showroom_settings' and policyname='showroom_settings_public_read') then
    create policy showroom_settings_public_read on public.showroom_settings for select using (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='showroom_settings' and policyname='showroom_settings_auth_write') then
    create policy showroom_settings_auth_write on public.showroom_settings for all using (auth.uid() is not null) with check (auth.uid() is not null);
  end if;

  if not exists (select 1 from pg_policies where schemaname='public' and tablename='lookbooks' and policyname='lookbooks_public_read') then
    create policy lookbooks_public_read on public.lookbooks for select using (is_active = true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='lookbooks' and policyname='lookbooks_auth_write') then
    create policy lookbooks_auth_write on public.lookbooks for all using (auth.uid() is not null) with check (auth.uid() is not null);
  end if;

  if not exists (select 1 from pg_policies where schemaname='public' and tablename='qr_codes' and policyname='qr_codes_public_read') then
    create policy qr_codes_public_read on public.qr_codes for select using (is_active = true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='qr_codes' and policyname='qr_codes_auth_write') then
    create policy qr_codes_auth_write on public.qr_codes for all using (auth.uid() is not null) with check (auth.uid() is not null);
  end if;
end $$;

-- Realtime for the new showroom tables.
do $$
begin
  if exists (select 1 from pg_publication where pubname='supabase_realtime') then
    begin alter publication supabase_realtime add table public.showroom_settings; exception when duplicate_object then null; end;
    begin alter publication supabase_realtime add table public.lookbooks; exception when duplicate_object then null; end;
    begin alter publication supabase_realtime add table public.qr_codes; exception when duplicate_object then null; end;
  end if;
end $$;

commit;

select
  'AWM DIGITAL SHOWROOM V4 MIGRATION COMPLETED' as status,
  to_regclass('public.showroom_settings') is not null as showroom_settings_ok,
  to_regclass('public.lookbooks') is not null as lookbooks_ok,
  to_regclass('public.qr_codes') is not null as qr_codes_ok;
