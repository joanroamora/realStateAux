import React from 'react';
import { Bot, UserPlus, Database, ShieldCheck, Sparkles, Cpu } from 'lucide-react';

export default function Navbar({ onOpenAdmin, onOpenData, activeAgent }) {
  return (
    <header className="sticky top-0 z-40 w-full glass-panel border-b border-gray-800/80 px-4 lg:px-8 py-3">
      <div className="max-w-7xl mx-auto flex items-center justify-between">
        
        {/* Brand & Logo */}
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-emerald-500 to-teal-400 flex items-center justify-center shadow-lg shadow-emerald-500/20">
            <Bot className="w-6 h-6 text-gray-950 font-bold" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="font-['Outfit'] font-extrabold text-xl tracking-tight text-white">
                realState<span className="text-emerald-400">Aux</span>
              </h1>
              <span className="px-2 py-0.5 text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-full flex items-center gap-1">
                <Cpu className="w-3 h-3 text-emerald-400" />
                Vertex AI Gemini
              </span>
            </div>
            <p className="text-xs text-gray-400 hidden sm:block">
              Asistente Inmobiliario Autónomo Multi-Usuario (GCP e2-micro + Vertex AI)
            </p>
          </div>
        </div>

        {/* Central Engine Indicator */}
        <div className="hidden md:flex items-center gap-2 px-3 py-1.5 rounded-full bg-gray-900/80 border border-gray-800 text-xs text-gray-300">
          <div className="w-2 h-2 rounded-full bg-emerald-400 animate-ping"></div>
          <ShieldCheck className="w-4 h-4 text-emerald-400" />
          <span>VPC Aislada GCP &bull; Contenedor: <strong className="text-emerald-300">{activeAgent}</strong></span>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-2 sm:gap-3">
          <button
            onClick={onOpenData}
            className="flex items-center gap-1.5 px-3 py-2 text-xs font-medium text-gray-300 bg-gray-900/90 hover:bg-gray-800 border border-gray-700/80 rounded-xl transition-all hover:text-white"
            title="Ver Datos Dummy"
          >
            <Database className="w-4 h-4 text-teal-400" />
            <span className="hidden sm:inline">Ver Datos Dummy</span>
          </button>

          <button
            onClick={onOpenAdmin}
            className="flex items-center gap-1.5 px-3.5 py-2 text-xs font-semibold text-gray-950 bg-gradient-to-r from-emerald-400 to-teal-300 hover:from-emerald-300 hover:to-teal-200 rounded-xl transition-all shadow-md shadow-emerald-500/20 hover:scale-[1.02] active:scale-[0.98]"
          >
            <UserPlus className="w-4 h-4" />
            <span>+ Nuevo Agente</span>
          </button>
        </div>

      </div>
    </header>
  );
}
