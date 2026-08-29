# Fase 05.5.2-K.5 — Preparación de la base documental

## Alcance implementado
K.5 prepara la estructura; no realiza todavía ingesta automática, acceso a WhatsApp ni conexión a un backend.

### Separación de conocimiento
- `normativa`: fuentes normativas.
- `analisis`: análisis profesionales de Consultoría Martínez, nunca confundidos con una norma.
- `guias`: contenido educativo.
- `faq`: respuestas frecuentes revisables.

## Estados
**Documento:** draft, pending_review, approved, archived, blocked.

**Situación jurídica:** vigente, modificado, sustituido, derogado, historico, pending_review.

## Principio de seguridad
El asistente solo podrá utilizar en el futuro contenido:
- aprobado;
- permitido para el asistente;
- con clasificación pública;
- y, para afirmaciones jurídicas, con fuente verificada cuando la regla correspondiente lo exija.

## Flujo futuro
K.6 define límites y reglas → K.7 mueve la lógica sensible al backend → K.8 crea administración y fuentes → K.9 procesa documentos → K.10 intenta romper el sistema.

## Qué NO hacer
No copiar documentos privados dentro de `index.json`, JavaScript o HTML. GitHub Pages es público: cualquier archivo publicado en el repositorio puede quedar accesible.
