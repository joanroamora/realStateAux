import React from 'react';
import { Users, CalendarCheck, Home, MessageSquareHeart, ArrowUpRight, CheckCircle2 } from 'lucide-react';

export default function FeatureGrid({ onTriggerFeature, activeFeature }) {
  const features = [
    {
      id: 'leads',
      title: 'Captura de Leads',
      subtitle: 'WhatsApp & Telegram API',
      description: 'Calificación automática de presupuesto, financiamiento y zona de interés en tiempo real.',
      icon: Users,
      badge: '2 Leads Activos',
      badgeColor: 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20',
      accent: 'from-emerald-500/20 to-teal-500/10',
      prompt: '📋 Muéstrame la lista de leads capturados y califica el perfil de Sofía Martínez'
    },
    {
      id: 'agenda',
      title: 'Sincronización de Agenda',
      subtitle: 'Gestión 24/7 sin Traslapes',
      description: 'Reserva automática de slots para visitas presenciales sincronizada en America/Chicago.',
      icon: CalendarCheck,
      badge: '6 Slots Disponibles',
      badgeColor: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
      accent: 'from-blue-500/20 to-cyan-500/10',
      prompt: '📅 ¿Cuáles son los horarios disponibles para agendar una visita el 10 de junio?'
    },
    {
      id: 'properties',
      title: 'Matchmaking de Propiedades',
      subtitle: 'Filtro Inteligente de Inventario',
      description: 'Búsqueda por zonas (Norte, Oeste, Costera), presupuesto máximo y tipo de propiedad.',
      icon: Home,
      badge: '3 En Inventario',
      badgeColor: 'bg-purple-500/10 text-purple-400 border-purple-500/20',
      accent: 'from-purple-500/20 to-indigo-500/10',
      prompt: '🔍 Busca casas disponibles en Zona Norte con presupuesto de hasta $370,000 USD'
    },
    {
      id: 'followup',
      title: 'Seguimiento Post-Visita',
      subtitle: 'Fidelización Automatizada',
      description: 'Envío autónomo de encuestas de opinión y recomendaciones de propiedades similares.',
      icon: MessageSquareHeart,
      badge: 'Autónomo 24/7',
      badgeColor: 'bg-amber-500/10 text-amber-400 border-amber-500/20',
      accent: 'from-amber-500/20 to-orange-500/10',
      prompt: '📩 Simula el envío de un mensaje de seguimiento post-visita para el cliente David Johnson'
    }
  ];

  return (
    <section className="mb-6">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h2 className="text-lg font-['Outfit'] font-bold text-white flex items-center gap-2">
            Funcionalidades Automatizadas del Sistema
          </h2>
          <p className="text-xs text-gray-400">
            Haz clic en cualquiera de las 4 tareas automáticas para ejecutarlas directamente con Charly
          </p>
        </div>
      </div>

      {/* Grid 4 cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        {features.map((feat) => {
          const Icon = feat.icon;
          const isActive = activeFeature === feat.id;

          return (
            <div
              key={feat.id}
              onClick={() => onTriggerFeature(feat)}
              className={`glass-card p-4 rounded-2xl cursor-pointer relative overflow-hidden transition-all group ${
                isActive ? 'border-emerald-500/50 bg-gray-800/80 shadow-lg shadow-emerald-500/10' : ''
              }`}
            >
              {/* Background Glow Gradient */}
              <div className={`absolute top-0 right-0 w-32 h-32 bg-gradient-to-bl ${feat.accent} rounded-full blur-2xl -mr-10 -mt-10 pointer-events-none`} />

              <div className="flex items-start justify-between mb-3 relative z-10">
                <div className="p-2.5 rounded-xl bg-gray-900/90 border border-gray-800 text-emerald-400 group-hover:scale-110 transition-transform">
                  <Icon className="w-5 h-5" />
                </div>
                <span className={`text-[10px] font-semibold px-2 py-0.5 rounded-full border ${feat.badgeColor}`}>
                  {feat.badge}
                </span>
              </div>

              <div className="relative z-10">
                <h3 className="font-semibold text-sm text-white group-hover:text-emerald-300 transition-colors flex items-center justify-between">
                  {feat.title}
                  <ArrowUpRight className="w-3.5 h-3.5 opacity-0 group-hover:opacity-100 transition-opacity text-emerald-400" />
                </h3>
                <p className="text-[11px] font-medium text-emerald-400/90 mb-1">{feat.subtitle}</p>
                <p className="text-xs text-gray-400 line-clamp-2 leading-relaxed">
                  {feat.description}
                </p>
              </div>

              {isActive && (
                <div className="mt-3 pt-2 border-t border-gray-800 flex items-center gap-1.5 text-[11px] text-emerald-400 font-medium">
                  <CheckCircle2 className="w-3.5 h-3.5" />
                  <span>Ejecutando en Chat</span>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </section>
  );
}
