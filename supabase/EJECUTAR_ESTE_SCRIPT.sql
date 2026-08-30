-- =========================================================
-- CONSULTORIA MARTINEZ - SCRIPT MAESTRO DE BASE DE DATOS
-- Contiene TODO: esquema inicial + API segura y procesamiento
-- + Centro de Recursos. Es seguro ejecutarlo aunque ya hayas
-- corrido partes de esto antes (no duplica ni borra datos).
-- =========================================================

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

-- ============ PARTE 2: API segura + procesamiento ============

-- =========================================================
-- CONSULTORIA MARTINEZ - Actualizacion puntos 5 y 6
-- API segura (funciones con reglas de negocio) + soporte
-- para texto extraido y multimedia de publicacion.
-- Ejecutar UNA vez en el SQL Editor de Supabase, despues
-- de haber ejecutado ya supabase/esquema.sql.
-- =========================================================

-- 1) Nuevas columnas para el texto extraido automaticamente
alter table public.documents add column if not exists extracted_text text;

alter table public.documents drop constraint if exists documents_extraction_status_check;
alter table public.documents add constraint documents_extraction_status_check
  check (extraction_status in (
    'not_applicable','available_local','pending_processor',
    'pending_ocr','extracted','failed_extraction'
  ));

-- =========================================================
-- 2) FUNCIONES DE NEGOCIO (la nueva API segura)
-- En vez de que el panel edite la tabla directamente, ahora
-- pasa por estas funciones, que verifican que los cambios de
-- estado y las autorizaciones sigan las reglas del proyecto.
-- =========================================================

create or replace function public.cambiar_estado(p_document_id uuid, p_nuevo_estado text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_estado_actual text;
  v_permitido boolean := false;
begin
  select status into v_estado_actual from public.documents where id = p_document_id;
  if v_estado_actual is null then
    raise exception 'documento no encontrado';
  end if;

  if v_estado_actual = 'inbox' and p_nuevo_estado in ('classified','rejected','archived') then
    v_permitido := true;
  end if;
  if v_estado_actual = 'classified' and p_nuevo_estado in ('review','rejected','archived') then
    v_permitido := true;
  end if;
  if v_estado_actual = 'review' and p_nuevo_estado in ('approved','rejected','archived') then
    v_permitido := true;
  end if;
  if v_estado_actual = 'approved' and p_nuevo_estado in ('published','archived','rejected') then
    v_permitido := true;
  end if;
  if p_nuevo_estado in ('archived','rejected') then
    v_permitido := true;
  end if;

  if not v_permitido then
    raise exception 'transicion no permitida: % a %', v_estado_actual, p_nuevo_estado;
  end if;

  if p_nuevo_estado = 'published' then
    if not (select resources_authorized from public.documents where id = p_document_id) then
      raise exception 'debe autorizarse para Recursos antes de publicar';
    end if;
  end if;

  update public.documents set status = p_nuevo_estado where id = p_document_id;

  insert into public.audit_log(document_id, event, actor_email)
  values (p_document_id, 'estado ' || v_estado_actual || ' a ' || p_nuevo_estado, auth.email());
end;
$$;

create or replace function public.autorizar(p_document_id uuid, p_campo text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_estado text;
begin
  if p_campo not in ('assistant_authorized','resources_authorized') then
    raise exception 'campo no valido';
  end if;

  select status into v_estado from public.documents where id = p_document_id;
  if v_estado is null then
    raise exception 'documento no encontrado';
  end if;
  if v_estado not in ('approved','published') then
    raise exception 'el documento debe estar aprobado antes de autorizar';
  end if;

  if p_campo = 'assistant_authorized' then
    update public.documents set assistant_authorized = true where id = p_document_id;
  else
    update public.documents set resources_authorized = true where id = p_document_id;
  end if;

  insert into public.audit_log(document_id, event, actor_email)
  values (p_document_id, 'autorizado: ' || p_campo, auth.email());
end;
$$;

revoke all on function public.cambiar_estado(uuid, text) from public;
grant execute on function public.cambiar_estado(uuid, text) to authenticated;

revoke all on function public.autorizar(uuid, text) from public;
grant execute on function public.autorizar(uuid, text) to authenticated;

-- Ya no se permite editar el estado ni las autorizaciones
-- escribiendo directo en la tabla; solo mediante las funciones
-- de arriba. El registro inicial (insert) sigue igual.
drop policy if exists "admin_acceso_total_update" on public.documents;

-- =========================================================
-- 3) MULTIMEDIA DE PUBLICACION: imagenes, enlaces o notas
-- que enriquecen un documento cuando se publica.
-- =========================================================
create table if not exists public.document_media (
  id            uuid primary key default gen_random_uuid(),
  document_id   uuid not null references public.documents(id) on delete cascade,
  media_type    text not null default 'image'
                  check (media_type in ('image','link','note')),
  storage_path  text,
  url           text,
  caption       text,
  sort_order    integer not null default 0,
  created_at    timestamptz not null default now(),
  created_by    uuid references auth.users(id)
);

alter table public.document_media enable row level security;

drop policy if exists "admin_media_select" on public.document_media;
create policy "admin_media_select"
on public.document_media for select
to authenticated
using (true);

drop policy if exists "admin_media_insert" on public.document_media;
create policy "admin_media_insert"
on public.document_media for insert
to authenticated
with check (true);

drop policy if exists "admin_media_delete" on public.document_media;
create policy "admin_media_delete"
on public.document_media for delete
to authenticated
using (true);

drop policy if exists "publico_media_select" on public.document_media;
create policy "publico_media_select"
on public.document_media for select
to anon
using (
  exists (
    select 1 from public.documents d
    where d.id = document_media.document_id
      and d.status = 'published'
      and d.resources_authorized = true
  )
);

-- Almacenamiento PUBLICO para estas imagenes (a diferencia del
-- bucket privado de documentos originales). Se necesita publico
-- porque el futuro Centro de Informacion las mostrara a cualquier
-- visitante sin iniciar sesion.
insert into storage.buckets (id, name, public)
values ('publicaciones-media', 'publicaciones-media', true)
on conflict (id) do nothing;

drop policy if exists "admin_media_storage_insert" on storage.objects;
create policy "admin_media_storage_insert"
on storage.objects for insert
to authenticated
with check (bucket_id = 'publicaciones-media');

drop policy if exists "admin_media_storage_delete" on storage.objects;
create policy "admin_media_storage_delete"
on storage.objects for delete
to authenticated
using (bucket_id = 'publicaciones-media');

-- =========================================================
-- FIN. Si el resultado dice Success, sin mensajes en rojo,
-- todo se actualizo correctamente.
-- =========================================================
select 'actualizacion de puntos 5 y 6 aplicada correctamente' as resultado;

-- ============ PARTE 3: Centro de Recursos ============

-- =========================================================
-- CONSULTORIA MARTINEZ - Actualizacion Centro de Recursos (punto 7)
-- Agrega control de descarga publica y permite adjuntar
-- archivos descargables (no solo imagenes y enlaces).
-- Ejecutar despues de esquema.sql y actualizacion_05_puntos5y6.sql
-- =========================================================

-- 1) Campo para decidir, documento por documento, si el
--    publico puede descargar algo de el. Por defecto NO.
alter table public.documents add column if not exists public_downloadable boolean not null default false;

-- 2) Permitir tambien archivos descargables en la multimedia
--    de publicacion (antes solo imagen, enlace o nota).
alter table public.document_media drop constraint if exists document_media_media_type_check;
alter table public.document_media add constraint document_media_media_type_check
  check (media_type in ('image','link','note','file'));

-- 3) Actualizar la funcion autorizar para que tambien pueda
--    activar la descarga publica, con la misma regla de
--    seguridad (documento aprobado o publicado).
create or replace function public.autorizar(p_document_id uuid, p_campo text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_estado text;
begin
  if p_campo not in ('assistant_authorized','resources_authorized','public_downloadable') then
    raise exception 'campo no valido';
  end if;

  select status into v_estado from public.documents where id = p_document_id;
  if v_estado is null then
    raise exception 'documento no encontrado';
  end if;
  if v_estado not in ('approved','published') then
    raise exception 'el documento debe estar aprobado antes de autorizar';
  end if;

  if p_campo = 'assistant_authorized' then
    update public.documents set assistant_authorized = true where id = p_document_id;
  elsif p_campo = 'resources_authorized' then
    update public.documents set resources_authorized = true where id = p_document_id;
  else
    update public.documents set public_downloadable = true where id = p_document_id;
  end if;

  insert into public.audit_log(document_id, event, actor_email)
  values (p_document_id, 'autorizado: ' || p_campo, auth.email());
end;
$$;

-- =========================================================
-- FIN. Si el resultado dice Success, sin mensajes en rojo,
-- todo se actualizo correctamente.
-- =========================================================
select 'actualizacion del centro de recursos aplicada correctamente' as resultado;
