-- AWM / Always Your Store
-- نفّذ الملف كله مرة واحدة داخل Supabase SQL Editor.
-- مهم: لا تضع SUPABASE_SECRET_KEY داخل أي HTML أو JavaScript في المتصفح.

create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,
  price numeric(12,2) not null default 0 check (price >= 0),
  condition text default 'جديد',
  sizes text,
  colors text,
  description text,
  image_url text,
  is_available boolean not null default true,
  is_featured boolean not null default false,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_products_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists products_updated_at on public.products;
create trigger products_updated_at
before update on public.products
for each row execute function public.set_products_updated_at();

alter table public.products enable row level security;

drop policy if exists "public can view active products" on public.products;
create policy "public can view active products"
on public.products for select
to anon, authenticated
using (is_active = true);

drop policy if exists "admins can view all products" on public.products;
create policy "admins can view all products"
on public.products for select
to authenticated
using (true);

drop policy if exists "authenticated admins can insert products" on public.products;
create policy "authenticated admins can insert products"
on public.products for insert
to authenticated
with check (true);

drop policy if exists "authenticated admins can update products" on public.products;
create policy "authenticated admins can update products"
on public.products for update
to authenticated
using (true)
with check (true);

drop policy if exists "authenticated admins can delete products" on public.products;
create policy "authenticated admins can delete products"
on public.products for delete
to authenticated
using (true);

-- Storage bucket للصور
insert into storage.buckets (id, name, public)
values ('products','products',true)
on conflict (id) do update set public=true;

drop policy if exists "public can view product images" on storage.objects;
create policy "public can view product images"
on storage.objects for select
to public
using (bucket_id = 'products');

drop policy if exists "authenticated can upload product images" on storage.objects;
create policy "authenticated can upload product images"
on storage.objects for insert
to authenticated
with check (bucket_id = 'products');

drop policy if exists "authenticated can update product images" on storage.objects;
create policy "authenticated can update product images"
on storage.objects for update
to authenticated
using (bucket_id = 'products')
with check (bucket_id = 'products');

drop policy if exists "authenticated can delete product images" on storage.objects;
create policy "authenticated can delete product images"
on storage.objects for delete
to authenticated
using (bucket_id = 'products');

-- بيانات تجريبية اختيارية:
-- insert into public.products (name, category, price, condition, sizes, colors, description, is_available, is_featured, sort_order)
-- values ('تيشيرت AWM', 'تيشيرتات', 350, 'جديد', 'M / L / XL', 'أسود', 'وصف القطعة هنا', true, true, 1);

-- إنشاء مستخدم الإدارة:
-- من Supabase Dashboard > Authentication > Users > Add user
-- أنشئ بريد وكلمة مرور للإدارة، ثم استخدمهما في admin.html.
