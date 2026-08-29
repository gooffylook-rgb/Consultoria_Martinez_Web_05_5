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
const SUPABASE_ANON_KEY = "sb_publishable_OFBSAlL5CsPm7YhU8Sxj3Q_NmbQEEkH";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
