-- Ролі: «viewer» — лише перегляд. Усі інші користувачі можуть редагувати.
-- Крок 1. Права в базі (запустити один раз у SQL Editor).
drop policy if exists "auth all" on public.objects;
drop policy if exists "objects read" on public.objects;
drop policy if exists "objects insert" on public.objects;
drop policy if exists "objects update" on public.objects;
drop policy if exists "objects delete" on public.objects;
create policy "objects read" on public.objects for select to authenticated using (true);
create policy "objects insert" on public.objects for insert to authenticated
  with check (coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') <> 'viewer');
create policy "objects update" on public.objects for update to authenticated
  using (coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') <> 'viewer')
  with check (coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') <> 'viewer');
create policy "objects delete" on public.objects for delete to authenticated
  using (coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') <> 'viewer');

drop policy if exists "photos insert" on storage.objects;
drop policy if exists "photos update" on storage.objects;
drop policy if exists "photos delete" on storage.objects;
create policy "photos insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'photos' and coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') <> 'viewer');
create policy "photos update" on storage.objects for update to authenticated
  using (bucket_id = 'photos' and coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') <> 'viewer')
  with check (bucket_id = 'photos' and coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') <> 'viewer');
create policy "photos delete" on storage.objects for delete to authenticated
  using (bucket_id = 'photos' and coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') <> 'viewer');

-- Крок 2. Зробити колегу «лише перегляд» (підставте його пошту, запускати для кожного):
-- update auth.users set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"viewer"}'::jsonb where email = 'colleague@example.com';
-- Щоб повернути право редагування:
-- update auth.users set raw_app_meta_data = raw_app_meta_data - 'role' where email = 'colleague@example.com';
