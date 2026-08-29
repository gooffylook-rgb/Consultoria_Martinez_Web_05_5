CONSULTORÍA MARTÍNEZ — 05.5.2-K.1/K.2

Esta versión es la primera implementación de la nueva arquitectura del asistente.

PASO 1 — Descargar el ZIP.
PASO 2 — Descomprimirlo.
PASO 3 — Subir TODO su contenido a GitHub, respetando la carpeta images/ y js/.
PASO 4 — Abrir la página publicada.
PASO 5 — Probar primero en móvil.

PRUEBAS RECOMENDADAS
1. Escribir: Hola
   Esperado: saludo natural; NO WhatsApp.
2. Escribir: Gracias
   Esperado: respuesta de cortesía; NO WhatsApp.
3. Escribir: Quiero conocer Finza.M
   Esperado: explicación + botón DEMO 72 horas.
4. Escribir: Necesito ayuda con impuestos
   Esperado: orientación general + pregunta de contexto.
5. Escribir: Necesito organizar los cargos de mis trabajadores
   Esperado: identificación del servicio + pregunta de contexto.
6. Escribir: Quiero contratar
   Esperado: calificación breve y posterior opción de contacto.
7. Escribir: ¿Cuánto cuesta?
   Esperado: no inventar precio; explicar que depende del alcance.

NOTA DE SEGURIDAD
Esta versión NO contiene backend, claves API ni documentos jurídicos privados. No se debe intentar conectar directamente el grupo privado de WhatsApp al HTML público.

La explicación completa de la arquitectura está en docs/ARQUITECTURA_K1_K2.md.


K.4 — Actualización visual del asistente: avatar ejecutivo definitivo, escenario degradado violeta, estado Disponible, botones temáticos y respuesta con indicador de escritura/demora adaptativa.

K.5 añadido: infraestructura documental local, esquema de metadatos, índice vacío y configuración. No contiene documentos jurídicos ni información privada.

K.8: añadido prototipo de panel editorial en /admin/ y flujo de gobierno de contenido. No usar para información sensible hasta conectar autenticación y almacenamiento de servidor.


K.9 — INGESTA DOCUMENTAL IMPLEMENTADA (PROTOTIPO LOCAL)
- Nuevo panel /admin/ para registrar archivos, enlaces, publicaciones y mensajes de fuentes autorizadas.
- Metadatos de procedencia, fechas, estado jurídico, temas y relaciones.
- Flujo: inbox → classified → review → approved → published / rejected / archived.
- Autorización explícita e independiente para Recursos y Asistente.
- Trazabilidad local mediante historial de eventos.
- TXT/MD preparado para extracción local; PDF/DOCX/XLSX registrados y marcados para procesador documental del futuro backend; imágenes pendientes de OCR.
- IMPORTANTE: localStorage NO es almacenamiento seguro ni multiusuario.

REFINAMIENTO VISUAL K.9
- Servicios con efecto cristal y acentos cromáticos diferenciados.
- Bloque Finza.M rediseñado como presentación de producto: identidad, DEMO 72 h, beneficios, dashboard y CTAs.

PRUEBA K.9
1. Abrir /admin/.
2. Registrar un archivo o una entrada sin archivo.
3. Verificar que aparece en inbox.
4. Intentar autorizar al asistente antes de aprobar: debe impedirlo.
5. Clasificar → revisión → aprobar.
6. Autorizar para asistente y/o recursos.
7. Publicar solo después de autorización para recursos.
8. Recargar: la prueba local persiste en el navegador, no en GitHub.


05.5.2-K.9 (BACKEND REAL) — ACTUALIZACIÓN
- El panel /admin/ ya NO usa localStorage: ahora guarda todo en una base
  de datos real (Supabase), con inicio de sesión por correo y contraseña.
- Instrucciones completas paso a paso en GUIA_PASO_A_PASO_BACKEND_REAL.md
- Antes de subir esto a GitHub, sigue esa guía completa (crea tu proyecto
  Supabase, ejecuta supabase/esquema.sql y completa js/supabase-config.js).
- Si subes este ZIP sin completar la guía, el panel mostrará un error de
  conexión: es normal, falta configurar tus claves.
