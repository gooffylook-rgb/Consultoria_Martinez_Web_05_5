# K.7 — Backend seguro (preparación)
La web pública no debe contener secretos, credenciales ni documentos privados. Este directorio define la frontera del backend para la futura API del asistente y el Centro de Recursos.

Flujo previsto: fuentes autorizadas -> inbox/cuarentena -> clasificación -> revisión humana -> publicación aprobada -> API pública de solo lectura.

WhatsApp no es una fuente de publicación automática. Cualquier integración futura deberá usar un mecanismo autorizado y pasar por revisión.
