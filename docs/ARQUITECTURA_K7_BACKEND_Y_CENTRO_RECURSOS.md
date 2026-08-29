# K.7 — Backend seguro + Centro de Recursos

## Objetivo
Preparar la frontera entre la web pública y los datos sensibles, y convertir Recursos y Actualizaciones en un centro editorial verificable.

## Arquitectura
Fuente autorizada -> bandeja de entrada -> clasificación -> revisión -> aprobación -> base publicada -> API -> web/asistente.

## Regla de WhatsApp
El grupo/canal no se leerá ni publicará directamente en la web. Una integración futura solo podrá incorporar contenido mediante un método autorizado, con clasificación y revisión antes de publicar.

## Seguridad
- secretos solo en variables del backend;
- documentos privados fuera de GitHub Pages;
- administración autenticada;
- API pública con mínimos datos;
- auditoría y estado de revisión;
- ninguna respuesta jurídica debe afirmar una fuente inexistente.
