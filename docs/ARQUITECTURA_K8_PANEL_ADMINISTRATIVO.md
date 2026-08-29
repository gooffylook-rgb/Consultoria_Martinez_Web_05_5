# 05.5.2-K.8 — Panel Administrativo y Gobierno de Información

## Objetivo
Convertir el futuro panel administrativo en el punto de control editorial de Consultoría Martínez.

## Flujo
Fuente autorizada -> Bandeja de entrada -> Clasificación -> Revisión humana -> Aprobación -> Publicación.

## Destinos
- `published`: Centro de Recursos público.
- `approved` y autorizado para conocimiento: base del asistente.

## WhatsApp
El canal/grupo no se trata como publicación automática. Una futura integración autorizada podrá llevar publicaciones y archivos a la bandeja de entrada, conservando fuente, fecha y trazabilidad. La viabilidad técnica dependerá del método oficial de acceso disponible y de los permisos correspondientes.

## Seguridad
El prototipo `/admin/` actual es solo interfaz local. No es un panel seguro: no contiene autenticación real y no debe usarse para datos sensibles. K.7/K.8 requieren backend real para producción.
