# Consultoría Martínez — Asistente 05.5.2-K.1 / K.2

## Qué se implementa en esta versión

Esta versión separa por primera vez el comportamiento conversacional del asistente del HTML principal mediante `js/assistant-core.js`.

### K.1 — Comportamiento conversacional
- Saludos y cortesías.
- Respuesta contextual para Finza.M.
- Acceso a la DEMO de 72 horas sin redirección automática a WhatsApp.
- Identificación preliminar de las áreas de servicio.
- Preguntas de seguimiento para comprender el problema antes de vender.
- Derivación a WhatsApp únicamente cuando el usuario expresa una intención explícita de atención/contratación.
- Detección de una oportunidad comercial suave (`softLead`) sin enviar automáticamente al usuario a un canal externo.
- Estado temporal de sesión mediante `sessionStorage`; no almacena documentos, credenciales ni información jurídica privada.

### K.2 — Preparación de la base de conocimiento
Se define una separación conceptual entre:
1. Fuente normativa oficial.
2. Material de análisis y explicación de Consultoría Martínez.
3. Respuesta generada por el asistente.

Todavía **no** se conectan documentos jurídicos privados ni WhatsApp. Eso será parte del backend seguro.

## Lo que significa backend

El sitio actual funciona principalmente en el navegador. El backend será un servicio privado que ejecutará tareas que no deben quedar expuestas en GitHub Pages, como:
- almacenar documentos;
- controlar usuarios administradores;
- buscar información jurídica;
- registrar versiones y vigencia;
- consultar un modelo de IA de forma segura;
- mantener las claves privadas fuera del navegador.

## Próximo paso: K.3

Crear el modelo documental de la Base de Conocimiento:
- título;
- tipo de norma;
- número;
- organismo emisor;
- fecha;
- materia;
- estado de vigencia;
- fuente;
- análisis de Consultoría Martínez;
- versión/reemplazo;
- fecha de incorporación.

No se debe introducir información jurídica real en el frontend como sustituto del backend.
