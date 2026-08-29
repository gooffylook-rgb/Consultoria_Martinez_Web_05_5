-- =========================================================
-- CONSULTORÍA MARTÍNEZ — K.9 / Backend mínimo real
-- Este script crea la base de datos completa en Supabase.
-- Se ejecuta UNA sola vez, pegandolo en el SQL Editor de
-- tu proyecto Supabase y presionando RUN.
-- =========================================================

-- 1) TABLA PRINCIPAL: documentos registrados en el sistema
create table if not exists public.documents (
  id                    uuid primary key default gen_random_uuid(),
  title                 text not null,
  source                text not null,
  source_type           text not null default 'other'
                          check (source_type in ('official','consultoria_martinez','authorized_channel','educational','other')),
  content_type          text not null default 'faq'
                          check (content_type in ('normativa','fiscal','laboral','contable','guia_educativa','analisis_profesional','faq','publication')),
  reference             text,
  document_date         date,
  effective_date        date,
  legal_status          text default 'pending_review'
                          check (legal_status in ('pending_review','vigente','modificado','sustituido','derogado','historico')),
  topics                text[] default '{}',
  relations             text,
  notes                 text,
  status                text not null default 'inbox'
                          check (status in ('inbox','classified','review','approved','published','rejected','archived')),
  assistant_authorized  boolean not null default false,
  resources_authorized  boolean not null default false,
  reviewer              text,
  reviewed_at           timestamptz,
  file_name             text,
  file_size             integer,
  file_type             text,
  file_path             text,          -- ruta dentro del almacenamiento (Storage)
  extraction_status     text default 'not_applicable',
  received_at           timestamptz not null default now(),
  created_by            uuid references auth.users(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

-- 2) TABLA DE AUDITORÍA: historial de cada cambio de estado
create table if not exists public.audit_log (
  id            uuid primary key default gen_random_uuid(),
  document_id   uuid references public.documents(id) on delete cascade,
  event         text not null,
  actor_email   text,
  at            timestamptz not null default now()
);

-- 3) Mantener el campo updated_at al dia automaticamente
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_documents_updated_at on public.documents;
create trigger trg_documents_updated_at
before update on public.documents
for each row execute function public.set_updated_at();

-- =========================================================
-- SEGURIDAD: esta es la parte que hace cumplir tu regla:
--   Entrada no es igual a publicacion, ni igual a conocimiento autorizado
-- La base de datos, no el sitio web, es quien la vigila.
-- =========================================================

alter table public.documents enable row level security;
alter table public.audit_log enable row level security;

-- El publico (visitantes del sitio, sin iniciar sesion) SOLO puede
-- ver documentos que esten publicados Y autorizados para Recursos.
drop policy if exists "publico_solo_publicado" on public.documents;
create policy "publico_solo_publicado"
on public.documents for select
to anon
using (status = 'published' and resources_authorized = true);

-- Cualquier persona que haya iniciado sesión en el panel admin
-- (es decir, tú) puede ver, crear y modificar todo.
drop policy if exists "admin_acceso_total_select" on public.documents;
create policy "admin_acceso_total_select"
on public.documents for select
to authenticated
using (true);

drop policy if exists "admin_acceso_total_insert" on public.documents;
create policy "admin_acceso_total_insert"
on public.documents for insert
to authenticated
with check (true);

drop policy if exists "admin_acceso_total_update" on public.documents;
create policy "admin_acceso_total_update"
on public.documents for update
to authenticated
using (true)
with check (true);

-- El registro de auditoría solo lo puede ver/crear el admin autenticado.
drop policy if exists "admin_audit_select" on public.audit_log;
create policy "admin_audit_select"
on public.audit_log for select
to authenticated
using (true);

drop policy if exists "admin_audit_insert" on public.audit_log;
create policy "admin_audit_insert"
on public.audit_log for insert
to authenticated
with check (true);

-- =========================================================
-- ALMACENAMIENTO: carpeta privada para los archivos subidos
-- (PDF, DOCX, XLSX, TXT, imágenes)
-- =========================================================
insert into storage.buckets (id, name, public)
values ('documentos-privados', 'documentos-privados', false)
on conflict (id) do nothing;

drop policy if exists "admin_storage_select" on storage.objects;
create policy "admin_storage_select"
on storage.objects for select
to authenticated
using (bucket_id = 'documentos-privados');

drop policy if exists "admin_storage_insert" on storage.objects;
create policy "admin_storage_insert"
on storage.objects for insert
to authenticated
with check (bucket_id = 'documentos-privados');

-- =========================================================
-- FIN DEL SCRIPT.
-- Si el resultado dice Success, sin mensajes en rojo,
-- todo se creo correctamente.
-- =========================================================
select 'esquema creado correctamente' as resultado;
