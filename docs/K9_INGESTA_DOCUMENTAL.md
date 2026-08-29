# 05.5.2-K.9 — Ingesta documental

## Implementado físicamente
Panel local de ingesta en `/admin/` con registro, metadatos, trazabilidad, estados y autorizaciones independientes.

## Regla de autorización
`inbox`, `classified` y `review` nunca son conocimiento autorizado. Solo una entrada `approved` o `published` puede recibir autorización explícita para el asistente. Publicar exige autorización explícita para Recursos.

## Extracción
El navegador no implementa procesamiento completo y fiable de PDF/DOCX/XLSX en esta versión. K.9 registra el archivo y conserva el estado `pending_processor`; la extracción real corresponde al futuro backend. TXT y Markdown quedan preparados para extracción local.

## Límite de seguridad
Esta implementación usa `localStorage` exclusivamente para demostrar el flujo. No debe recibir documentos confidenciales ni considerarse un backend.
