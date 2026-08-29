// =========================================================
// CONFIGURACIÓN DE SUPABASE
// Reemplaza los dos valores de abajo por los tuyos.
// Los obtienes en tu proyecto Supabase en:
//   Configuración del proyecto -> API
//
// "Project URL"       -> pégalo en SUPABASE_URL
// "anon public" (clave) -> pégalo en SUPABASE_ANON_KEY
//
// Estos dos valores NO son secretos peligrosos: están
// protegidos por las reglas de seguridad que ya creamos
// en el script esquema.sql, así que es normal y seguro
// que queden visibles en el sitio público.
// =========================================================

const SUPABASE_URL = "https://vwidkuebimvzoiyodjff.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3aWRrdWViaW12em9peW9kamZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgwMTA1ODEsImV4cCI6MjEwMzU4NjU4MX0.KHRIkUqtGLUOwk7wJKoQWZ_AUQyCYI167lCVSKoUZNM";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
