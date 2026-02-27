-- MVP schema for the app marketplace

create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  title text not null,
  price int not null,
  description text not null default '',
  category text not null,
  media_url text not null default '',
  media_type text not null default 'image',
  seller_phone text not null
);

create index if not exists products_category_idx on public.products (category);
create index if not exists products_created_at_idx on public.products (created_at desc);

alter table public.products enable row level security;

drop policy if exists "public read" on public.products;
create policy "public read"
on public.products
for select
using (true);

drop policy if exists "public insert" on public.products;
create policy "public insert"
on public.products
for insert
with check (true);

-- Storage:
-- Create bucket 'product-media' in Supabase Storage (recommended: public),
-- so the app can upload an image and then display it via public URL.

