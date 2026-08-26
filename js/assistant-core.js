/*
 * Consultoría Martínez — Assistant Core K.1
 * Frontend-only conversational layer.
 * IMPORTANT: this file does NOT contain private documents, API keys or legal source text.
 * It is deliberately prepared to be replaced/extended by the secure backend in K.4.
 */
(function () {
  "use strict";

  const SERVICES = [
    { id:"finanzas", label:"Asesoría Financiera", terms:["financiera","finanzas","flujo de caja","liquidez","rentabilidad","riesgo"] },
    { id:"contabilidad", label:"Contabilidad Oportuna Personalizada", terms:["contabilidad","contable","libros","teneduria","registros","asientos"] },
    { id:"impuestos", label:"Asesoría para pagos de Impuestos y Declaración Jurada", terms:["impuesto","impuestos","tributario","tributaria","declaracion jurada","declaración jurada","fiscal"] },
    { id:"estadistica", label:"Análisis Estadístico Descriptivo", terms:["estadistico","estadística","estadisticas","datos","indicadores","analisis de datos"] },
    { id:"factibilidad", label:"Estudios de factibilidad financiera", terms:["factibilidad","emprendedor","emprender","proyecto","viabilidad","punto de equilibrio"] },
    { id:"capital-humano", label:"Gestión del Capital Humano", terms:["capital humano","trabajador","trabajadores","empleado","empleados","personal","recursos humanos"] },
    { id:"laboral", label:"Gestión Documental de la Legislación Laboral", terms:["laboral","contrato de trabajo","documentacion laboral","legislacion laboral","expediente laboral"] },
    { id:"cargos", label:"Organización de Nomenclatura y clasificación de cargos", terms:["nomenclatura","clasificacion de cargos","clasificación de cargos","cargo","cargos","plantilla"] },
    { id:"control", label:"Fiscalización y Control", terms:["fiscalizacion","fiscalización","control interno","control","deficiencia","riesgo de control"] },
    { id:"res60", label:"Implementación de la Resolución 60 y Planes de Medidas", terms:["resolucion 60","resolución 60","plan de medidas","deficiencias detectadas"] }
  ];

  const KNOWLEDGE_AREAS = {
    fiscal: "Puedo orientarte de forma general sobre el tema fiscal, pero una respuesta normativa concreta debe apoyarse en la disposición vigente aplicable al caso.",
    laboral: "Puedo ayudarte a identificar qué información laboral conviene revisar. La aplicación concreta debe comprobarse contra la legislación vigente y la situación del negocio.",
    contable: "Puedo orientarte sobre organización contable y registros. Para una recomendación concreta necesito conocer la actividad y el problema que estás teniendo.",
    control: "Puedo explicarte el enfoque general de fiscalización y control y la preparación de planes de medidas. La aplicación normativa debe verificarse según la disposición vigente."
  };

  function normalize(v) {
    return String(v || "").toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/\s+/g, " ").trim();
  }

  function hasAny(text, terms) { return terms.some(t => text.includes(normalize(t))); }

  function detectServices(text) {
    return SERVICES.filter(s => hasAny(text, s.terms)).map(s => s.id);
  }

  function state() {
    const key = "cm_assistant_session_v1";
    let s;
    try { s = JSON.parse(sessionStorage.getItem(key) || "{}"); } catch (_) { s = {}; }
    s.turns = Number(s.turns || 0);
    s.leadScore = Number(s.leadScore || 0);
    s.services = Array.isArray(s.services) ? s.services : [];
    return {
      get value(){ return s; },
      save(){ try { sessionStorage.setItem(key, JSON.stringify(s)); } catch (_) {} }
    };
  }

  function reply(input, config) {
    const text = normalize(input);
    const st = state();
    const s = st.value;
    s.turns += 1;

    const services = detectServices(text);
    services.forEach(id => { if (!s.services.includes(id)) s.services.push(id); });

    const explicitAdvisor = /hablar con (un )?asesor|contactar (con )?un asesor|quiero un asesor|quiero contratar|contratar|solicitar una consulta|consulta personalizada/.test(text);
    const pricing = /precio|precios|tarifa|tarifas|cotizacion|cotizacion|presupuesto|cuanto cuesta|cuanto cobran/.test(text);
    const commercial = explicitAdvisor || pricing;

    if (/^(hola|holi|hello|buenos dias|buenas tardes|buenas noches|buenas|saludos|que tal|como estas)/.test(text)) {
      st.save();
      return { reply:"¡Hola! 👋 Es un gusto atenderte. Soy el asistente virtual de Consultoría Martínez. Puedo orientarte sobre contabilidad, impuestos, finanzas, capital humano, fiscalización, factibilidad o Finza.M. Cuéntame qué necesitas resolver.", action:null, softLead:false };
    }

    if (/^(gracias|muchas gracias|te agradezco|perfecto|excelente|ok|vale|de acuerdo)/.test(text)) {
      st.save();
      return { reply:"¡A ti! Me alegra poder ayudarte. Si quieres, seguimos con tu caso y vemos cuál es el camino más adecuado.", action:null, softLead:false };
    }

    if (text.includes("finza") || text.includes("demo") || text.includes("72 horas")) {
      s.leadScore += 1;
      st.save();
      return { reply:"Finza.M es nuestra herramienta de gestión contable y financiera. Puedes probarla directamente durante 72 horas y decidir después si necesitas acompañamiento profesional.", action:"finza", softLead:false };
    }

    if (explicitAdvisor) {
      st.save();
      return { reply:"Claro. Como ya me indicas que quieres atención personalizada, puedo facilitarte el contacto con Consultoría Martínez. Si prefieres, también puedo ayudarte primero a precisar qué servicio necesitas.", action:"advisor", softLead:false };
    }

    if (pricing) {
      s.leadScore += 2;
      st.save();
      return { reply:"Las tarifas dependen del servicio, alcance y volumen de trabajo. No quiero darte una cifra genérica que pueda inducirte a error. Si me cuentas qué necesitas resolver, puedo ayudarte a identificar el servicio adecuado y después puedes solicitar una propuesta personalizada.", action:null, softLead:s.leadScore >= 3 };
    }

    if (services.length) {
      s.leadScore += 1;
      const labels = services.map(id => SERVICES.find(x => x.id === id)?.label).filter(Boolean);
      let areaText = labels.length === 1 ? `Esto se relaciona directamente con ${labels[0]}.` : `Veo varias áreas relacionadas: ${labels.join(", ")}.`;
      let follow = " Cuéntame brevemente qué actividad realizas y qué problema concreto estás intentando resolver.";
      let caution = "";
      if (services.includes("impuestos")) caution = " La respuesta fiscal concreta debe comprobarse con la normativa vigente aplicable a tu caso.";
      if (services.includes("res60") || services.includes("control")) caution = " La aplicación concreta debe verificarse según la disposición vigente y la situación de la entidad.";
      st.save();
      return { reply:areaText + caution + follow, action:null, softLead:s.leadScore >= 3 && s.turns >= 2 };
    }

    if (hasAny(text,["que servicios","servicios ofrecen","servicios tienen","que hacen"])) {
      st.save();
      return { reply:"Trabajamos en asesoría financiera, contabilidad oportuna personalizada, impuestos y declaración jurada, análisis estadístico descriptivo, estudios de factibilidad financiera, gestión del capital humano, documentación laboral, organización de cargos, fiscalización y control e implementación de la Resolución 60.", action:null, softLead:false };
    }

    if (hasAny(text,["impuesto","fiscal","declaracion jurada","tributario","tributaria"])) {
      s.leadScore += 1; st.save();
      return { reply:KNOWLEDGE_AREAS.fiscal + " Dime qué actividad realizas y qué período o situación quieres revisar." , action:null, softLead:s.leadScore >= 3 };
    }

    if (hasAny(text,["contabilidad","contable","teneduria","libros","asientos"])) {
      s.leadScore += 1; st.save();
      return { reply:KNOWLEDGE_AREAS.contable + " ¿Qué actividad realizas y qué sistema o forma de registro utilizas actualmente?", action:null, softLead:s.leadScore >= 3 };
    }

    if (hasAny(text,["trabajador","trabajadores","empleado","empleados","laboral","capital humano"])) {
      s.leadScore += 1; st.save();
      return { reply:KNOWLEDGE_AREAS.laboral + " ¿Necesitas revisar documentación, cargos, organización del personal o una situación laboral concreta?", action:null, softLead:s.leadScore >= 3 };
    }

    if (hasAny(text,["resolucion 60","resolución 60","plan de medidas","control interno","fiscalizacion","fiscalización"])) {
      s.leadScore += 1; st.save();
      return { reply:KNOWLEDGE_AREAS.control + " Si me explicas qué deficiencia o situación estás revisando, puedo ayudarte a ordenar el problema.", action:null, softLead:s.leadScore >= 3 };
    }

    st.save();
    return {
      reply:"Quiero evitar darte una respuesta genérica o presentarte como vigente algo que no haya sido verificado. Cuéntame un poco más: ¿tu consulta está relacionada con contabilidad, impuestos, finanzas, trabajadores, control, factibilidad o Finza.M?",
      action:null,
      softLead:false
    };
  }

  window.MartinezAssistant = { reply, normalize, detectServices, SERVICES, lastResult:null };
})();
