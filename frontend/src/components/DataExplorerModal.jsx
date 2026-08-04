import React, { useState } from 'react';
import { X, Database, Home, Calendar, BookOpen, Users, FileText, Check } from 'lucide-react';

export default function DataExplorerModal({ isOpen, onClose }) {
  const [activeTab, setActiveTab] = useState('properties');

  if (!isOpen) return null;

  const dummyProperties = [
    {
      id: "PROP-101",
      direccion: "1428 Elm Street, North District",
      precio: 350000,
      habitaciones: 3,
      banos: 2,
      zona: "Norte",
      estado: "Disponible",
      tipo: "Casa",
      url_fotos: "https://ejemplo.com/fotos/prop101.jpg"
    },
    {
      id: "PROP-102",
      direccion: "894 Maple Avenue, West Hills",
      precio: 480000,
      habitaciones: 4,
      banos: 3,
      zona: "Oeste",
      estado: "Disponible",
      tipo: "Casa",
      url_fotos: "https://ejemplo.com/fotos/prop102.jpg"
    },
    {
      id: "PROP-103",
      direccion: "55 Ocean Drive, Bay View",
      precio: 620000,
      habitaciones: 2,
      banos: 2,
      zona: "Costera",
      estado: "Bajo Contrato",
      tipo: "Apartamento",
      url_fotos: "https://ejemplo.com/fotos/prop103.jpg"
    }
  ];

  const calendarMock = {
    agente_id: "agent_carlos_01",
    zona_horaria: "America/Chicago",
    slots_disponibles: [
      { fecha: "2026-06-10", horarios: ["10:00 AM", "02:00 PM", "04:30 PM"] },
      { fecha: "2026-06-11", horarios: ["09:00 AM", "11:30 AM", "03:00 PM"] }
    ]
  };

  const faqContent = `# Guía y Políticas del Asistente Inmobiliario

## 1. Proceso de Compra
- Todo comprador interesado debe pasar por una calificación inicial (presupuesto, tipo de financiamiento y zona de interés) antes de agendar una visita presencial.
- No se revelan direcciones exactas de propiedades bajo contrato estricto hasta verificar identidad del cliente.

## 2. Comisiones y Pagos
- Las comisiones estándar del servicio de corretaje están cubiertas por el vendedor en la mayoría de los listados residenciales.
- Se trabaja con créditos hipotecarios pre-aprobados y compradores de recursos propios (all-cash).

## 3. Zonas de Operación
- El agente cubre exclusivamente las zonas Norte, Oeste y Costera. Si un cliente busca en otra zona, derivar amablemente o tomar nota de referencia.`;

  const syntheticLeads = [
    {
      lead_id: "LEAD-001",
      nombre: "Sofia Martínez",
      canal: "WhatsApp",
      perfil_busqueda: "Busca casa de 3 habitaciones en zona norte, presupuesto hasta $370,000 USD, prefiere crédito hipotecario."
    },
    {
      lead_id: "LEAD-002",
      nombre: "David Johnson",
      canal: "Telegram",
      perfil_busqueda: "Inversionista buscando propiedades tipo apartamento en zona costera, pago de contado."
    }
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-950/80 backdrop-blur-md animate-fadeIn">
      <div className="glass-panel w-full max-w-3xl rounded-3xl border border-gray-800 shadow-2xl overflow-hidden relative">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-800 bg-gray-900/90 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-teal-500/10 border border-teal-500/30 text-teal-400">
              <Database className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-['Outfit'] font-bold text-lg text-white">Explorador de Datos Dummy</h3>
              <p className="text-xs text-gray-400">Archivos JSON y MD cargados en la capa privada aislada</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-xl text-gray-400 hover:text-white bg-gray-800/60 hover:bg-gray-800 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tab Buttons */}
        <div className="flex border-b border-gray-800 bg-gray-950 px-6 pt-3 gap-2 overflow-x-auto">
          <button
            onClick={() => setActiveTab('properties')}
            className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-t-xl transition-colors border-b-2 ${
              activeTab === 'properties'
                ? 'bg-gray-900 text-emerald-400 border-emerald-500'
                : 'text-gray-400 border-transparent hover:text-white'
            }`}
          >
            <Home className="w-4 h-4" />
            <span>Propiedades ({dummyProperties.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('calendar')}
            className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-t-xl transition-colors border-b-2 ${
              activeTab === 'calendar'
                ? 'bg-gray-900 text-blue-400 border-blue-500'
                : 'text-gray-400 border-transparent hover:text-white'
            }`}
          >
            <Calendar className="w-4 h-4" />
            <span>Agenda Mock</span>
          </button>

          <button
            onClick={() => setActiveTab('faq')}
            className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-t-xl transition-colors border-b-2 ${
              activeTab === 'faq'
                ? 'bg-gray-900 text-purple-400 border-purple-500'
                : 'text-gray-400 border-transparent hover:text-white'
            }`}
          >
            <BookOpen className="w-4 h-4" />
            <span>Políticas & FAQ</span>
          </button>

          <button
            onClick={() => setActiveTab('leads')}
            className={`flex items-center gap-2 px-4 py-2.5 text-xs font-semibold rounded-t-xl transition-colors border-b-2 ${
              activeTab === 'leads'
                ? 'bg-gray-900 text-amber-400 border-amber-500'
                : 'text-gray-400 border-transparent hover:text-white'
            }`}
          >
            <Users className="w-4 h-4" />
            <span>Leads Sintéticos</span>
          </button>
        </div>

        {/* Tab Content */}
        <div className="p-6 max-h-[60vh] overflow-y-auto space-y-4">
          {activeTab === 'properties' && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
              {dummyProperties.map((prop) => (
                <div key={prop.id} className="p-3.5 rounded-2xl bg-gray-950 border border-gray-800 text-xs space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="font-bold text-emerald-400">{prop.id}</span>
                    <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-300">
                      {prop.estado}
                    </span>
                  </div>
                  <p className="font-semibold text-white">{prop.direccion}</p>
                  <div className="text-gray-400">
                    {prop.tipo} &bull; {prop.habitaciones} habs / {prop.banos} baños
                  </div>
                  <div className="text-right font-extrabold text-sm text-emerald-300 pt-1 border-t border-gray-800">
                    ${prop.precio.toLocaleString()} USD
                  </div>
                </div>
              ))}
            </div>
          )}

          {activeTab === 'calendar' && (
            <div className="p-4 rounded-2xl bg-gray-950 border border-gray-800 text-xs font-mono text-blue-300">
              <pre>{JSON.stringify(calendarMock, null, 2)}</pre>
            </div>
          )}

          {activeTab === 'faq' && (
            <div className="p-4 rounded-2xl bg-gray-950 border border-gray-800 text-xs text-gray-300 font-mono whitespace-pre-line leading-relaxed">
              {faqContent}
            </div>
          )}

          {activeTab === 'leads' && (
            <div className="space-y-3">
              {syntheticLeads.map((lead) => (
                <div key={lead.lead_id} className="p-4 rounded-2xl bg-gray-950 border border-gray-800 text-xs space-y-1.5">
                  <div className="flex justify-between font-bold text-amber-400">
                    <span>{lead.nombre} ({lead.lead_id})</span>
                    <span className="text-[10px] px-2.5 py-0.5 rounded-full bg-amber-500/10 text-amber-300">
                      Canal: {lead.canal}
                    </span>
                  </div>
                  <p className="text-gray-300 leading-relaxed">{lead.perfil_busqueda}</p>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-3 border-t border-gray-800 bg-gray-900/90 flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 rounded-xl text-xs font-bold bg-gray-800 text-white hover:bg-gray-700 transition-colors"
          >
            Cerrar
          </button>
        </div>

      </div>
    </div>
  );
}
