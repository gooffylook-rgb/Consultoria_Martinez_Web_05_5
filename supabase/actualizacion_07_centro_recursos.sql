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
