-- CleanPro booking requests
-- Run this in the SQL Editor of the dedicated CleanPro Supabase project.
create table if not exists public.booking_requests (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null check (char_length(customer_name) between 1 and 120),
  contact text not null check (char_length(contact) between 3 and 240),
  service text not null check (service in ('Home Cleaning', 'Office Cleaning', 'Deep Cleaning', 'Other')),
  preferred_date date,
  details text check (details is null or char_length(details) <= 3000),
  status text not null default 'new' check (status in ('new', 'contacted', 'scheduled', 'completed', 'cancelled')),
  created_at timestamptz not null default now()
);

alter table public.booking_requests enable row level security;

-- Visitors can submit requests, but cannot read or modify customer records.
drop policy if exists "Public can submit CleanPro booking requests" on public.booking_requests;
create policy "Public can submit CleanPro booking requests"
  on public.booking_requests
  for insert
  to anon, authenticated
  with check (
    char_length(customer_name) between 1 and 120
    and char_length(contact) between 3 and 240
    and service in ('Home Cleaning', 'Office Cleaning', 'Deep Cleaning', 'Other')
  );

-- Intentionally no public SELECT, UPDATE, or DELETE policies.
-- Add a separately secured admin workflow before building an admin dashboard.
