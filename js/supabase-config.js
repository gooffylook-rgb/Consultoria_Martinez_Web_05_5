// =========================================================
// CONFIGURACION DE SUPABASE
// Ya contiene tus claves reales, no necesitas editar nada aqui.
// =========================================================

const SUPABASE_URL = "https://vwidkuebimvzoiyodjff.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3aWRrdWViaW12em9peW9kamZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgwMTA1ODEsImV4cCI6MjEwMzU4NjU4MX0.KHRIkUqtGLUOwk7wJKoQWZ_AUQyCYI167lCVSKoUZNM";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
