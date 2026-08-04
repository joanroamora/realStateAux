import React, { useState } from 'react';
import Navbar from './components/Navbar';
import FeatureGrid from './components/FeatureGrid';
import ChatCharly from './components/ChatCharly';
import AdminModal from './components/AdminModal';
import DataExplorerModal from './components/DataExplorerModal';
import { Bot, Shield, Server, Sparkles, Heart } from 'lucide-react';

export default function App() {
  const [isAdminOpen, setIsAdminOpen] = useState(false);
  const [isDataOpen, setIsDataOpen] = useState(false);
  const [chatPrompt, setChatPrompt] = useState(null);
  const [activeFeature, setActiveFeature] = useState(null);
  const [activeAgent, setActiveAgent] = useState('openclaw-agent-carlos-01');

  const handleTriggerFeature = (feature) => {
    setActiveFeature(feature.id);
    setChatPrompt(feature.prompt);
  };

  const handleAgentProvisioned = (newAgent) => {
    setActiveAgent(newAgent.container_name);
  };

  return (
    <div className="min-h-screen bg-[#0b0f19] text-gray-100 flex flex-col font-['Inter'] selection:bg-emerald-500 selection:text-white">
      
      {/* Navbar Superior */}
      <Navbar
        onOpenAdmin={() => setIsAdminOpen(true)}
        onOpenData={() => setIsDataOpen(true)}
        activeAgent={activeAgent}
      />

      {/* Main Container */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 lg:px-8 py-6 flex flex-col gap-6">
        
        {/* Banner de Bienvenida / Estado SRE */}
        <section className="glass-panel p-5 rounded-3xl border border-gray-800/80 relative overflow-hidden flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="space-y-1 relative z-10">
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 flex items-center gap-1">
                <Sparkles className="w-3 h-3" />
                Arquitectura GCP Aislada Multi-Usuario
              </span>
            </div>
            <h2 className="font-['Outfit'] font-extrabold text-xl sm:text-2xl text-white tracking-tight">
              Asistente Inmobiliario Inteligente
            </h2>
            <p className="text-xs sm:text-sm text-gray-400 max-w-2xl">
              Interactúa con <strong>Charly</strong> para automatizar la captura de leads, agendar visitas y filtrar propiedades. Cada usuario corre en su propia instancia aislada de OpenClaw.
            </p>
          </div>

          <div className="flex items-center gap-2 self-start md:self-center shrink-0">
            <button
              onClick={() => setIsAdminOpen(true)}
              className="px-4 py-2.5 text-xs font-semibold text-white bg-gray-900 hover:bg-gray-800 border border-gray-700/80 rounded-xl transition-all flex items-center gap-2"
            >
              <Shield className="w-4 h-4 text-emerald-400" />
              <span>Aprovisionamiento SRE</span>
            </button>
          </div>
        </section>

        {/* 1. Las 4 Funcionalidades Principales Automatizadas */}
        <FeatureGrid
          onTriggerFeature={handleTriggerFeature}
          activeFeature={activeFeature}
        />

        {/* 2. Componente Central: Chat Interactivo con Charly AI */}
        <section className="w-full">
          <ChatCharly initialPrompt={chatPrompt} />
        </section>

      </main>

      {/* Footer */}
      <footer className="border-t border-gray-800/80 py-4 px-6 text-center text-xs text-gray-500 bg-gray-950/80">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <Server className="w-4 h-4 text-emerald-400" />
            <span>Infraestructura GCP: Subred Protegida &bull; Tipo Máquina: <strong>e2-micro</strong> ($7/mes)</span>
          </div>
          <div>
            realStateAux &copy; 2026 &bull; Asistente Inmobiliario Autónomo (OpenClaw)
          </div>
        </div>
      </footer>

      {/* Modales */}
      <AdminModal
        isOpen={isAdminOpen}
        onClose={() => setIsAdminOpen(false)}
        onAgentProvisioned={handleAgentProvisioned}
      />

      <DataExplorerModal
        isOpen={isDataOpen}
        onClose={() => setIsDataOpen(false)}
      />

    </div>
  );
}
