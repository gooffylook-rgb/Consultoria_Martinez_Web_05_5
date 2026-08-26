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
