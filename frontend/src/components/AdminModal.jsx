import React, { useState } from 'react';
import { X, UserPlus, Cpu, HardDrive, ShieldCheck, CheckCircle2, Server, Key, Smartphone, MessageSquare } from 'lucide-react';

export default function AdminModal({ isOpen, onClose, onAgentProvisioned }) {
  const [formData, setFormData] = useState({
    user_email: 'carlos.martinez@inmobiliaria.com',
    agent_id: 'agent_carlos_01',
    whatsapp_number: '+15550192837',
    telegram_bot_token: '718293849:AAFx910283719283',
    llm_api_key: 'sk-proj-test123456789',
    memory_limit: '256m',
    cpu_limit: '0.5'
  });

  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    setLoading(true);

    // Simulate SRE Docker Engine API provisioning call
    setTimeout(() => {
      const cleanEmail = formData.user_email.replace(/[^a-zA-Z0-9]/g, '-').toLowerCase();
      const containerName = `openclaw-agent-${cleanEmail}`;
      const containerId = `oc-${Math.random().toString(36).substring(2, 9)}`;

      const provisionResult = {
        status: 'active',
        user_email: formData.user_email,
        agent_id: formData.agent_id,
        container_id: containerId,
        container_name: containerName,
        memory_limit: formData.memory_limit,
        cpu_limit: formData.cpu_limit,
        vpc_subnet: '10.0.2.0/24 (Subred Protegida Backend)',
        db_access: '10.0.3.0/24 (Subred Privada Datos)'
      };

      setResult(provisionResult);
      setLoading(false);
      if (onAgentProvisioned) {
        onAgentProvisioned(provisionResult);
      }
    }, 1200);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-950/80 backdrop-blur-md animate-fadeIn">
      <div className="glass-panel w-full max-w-xl rounded-3xl border border-gray-800 shadow-2xl overflow-hidden relative">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-800 bg-gray-900/90 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-400">
              <UserPlus className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-['Outfit'] font-bold text-lg text-white">Panel de Administración Central</h3>
              <p className="text-xs text-gray-400">Aprovisionamiento Dinámico SRE de OpenClaw (GCP e2-micro)</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-xl text-gray-400 hover:text-white bg-gray-800/60 hover:bg-gray-800 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content Form */}
        <div className="p-6 max-h-[80vh] overflow-y-auto space-y-5">
          {!result ? (
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-300 mb-1">Email del Agente *</label>
                  <input
                    type="email"
                    required
                    value={formData.user_email}
                    onChange={(e) => setFormData({ ...formData, user_email: e.target.value })}
                    className="w-full bg-gray-950 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:border-emerald-500/60 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-300 mb-1">ID Único de Agente *</label>
                  <input
                    type="text"
                    required
                    value={formData.agent_id}
                    onChange={(e) => setFormData({ ...formData, agent_id: e.target.value })}
                    className="w-full bg-gray-950 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:border-emerald-500/60 focus:outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-300 mb-1 flex items-center gap-1">
                    <Smartphone className="w-3.5 h-3.5 text-emerald-400" />
                    WhatsApp Business API
                  </label>
                  <input
                    type="text"
                    value={formData.whatsapp_number}
                    onChange={(e) => setFormData({ ...formData, whatsapp_number: e.target.value })}
                    className="w-full bg-gray-950 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:border-emerald-500/60 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-300 mb-1 flex items-center gap-1">
                    <MessageSquare className="w-3.5 h-3.5 text-blue-400" />
                    Telegram Bot Token
                  </label>
                  <input
                    type="text"
                    value={formData.telegram_bot_token}
                    onChange={(e) => setFormData({ ...formData, telegram_bot_token: e.target.value })}
                    className="w-full bg-gray-950 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:border-emerald-500/60 focus:outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-300 mb-1 flex items-center gap-1">
                  <Key className="w-3.5 h-3.5 text-amber-400" />
                  API Key LLM (Claude / GPT - Cifrado Fernet AES-256)
                </label>
                <input
                  type="password"
                  value={formData.llm_api_key}
                  onChange={(e) => setFormData({ ...formData, llm_api_key: e.target.value })}
                  className="w-full bg-gray-950 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:border-emerald-500/60 focus:outline-none"
                />
              </div>

              {/* Hardware / SRE Resource Preset Box */}
              <div className="p-3.5 rounded-2xl bg-gray-900/80 border border-gray-800 space-y-2">
                <div className="flex items-center justify-between text-xs font-semibold text-gray-300">
                  <span className="flex items-center gap-1.5">
                    <Server className="w-4 h-4 text-emerald-400" />
                    Preset de Recursos Aislados (GCP e2-micro)
                  </span>
                  <span className="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 text-[10px]">
                    Optimizado
                  </span>
                </div>
                <div className="grid grid-cols-2 gap-2 text-xs text-gray-400">
                  <div className="p-2 rounded-xl bg-gray-950 border border-gray-800 flex items-center gap-2">
                    <HardDrive className="w-4 h-4 text-teal-400" />
                    <span>RAM: <strong>{formData.memory_limit}</strong></span>
                  </div>
                  <div className="p-2 rounded-xl bg-gray-950 border border-gray-800 flex items-center gap-2">
                    <Cpu className="w-4 h-4 text-purple-400" />
                    <span>CPU: <strong>{formData.cpu_limit} vCPU</strong></span>
                  </div>
                </div>
              </div>

              <div className="pt-3 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={onClose}
                  className="px-4 py-2.5 rounded-xl text-xs font-medium text-gray-400 hover:text-white bg-gray-900 border border-gray-800"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="px-5 py-2.5 rounded-xl text-xs font-bold text-gray-950 bg-gradient-to-r from-emerald-400 to-teal-300 hover:from-emerald-300 hover:to-teal-200 transition-all flex items-center gap-2 shadow-lg shadow-emerald-500/20 disabled:opacity-50"
                >
                  {loading ? (
                    <>
                      <div className="w-3.5 h-3.5 border-2 border-gray-950 border-t-transparent rounded-full animate-spin" />
                      <span>Aprovisionando Contenedor...</span>
                    </>
                  ) : (
                    <>
                      <ShieldCheck className="w-4 h-4" />
                      <span>Generar Instancia Aislada</span>
                    </>
                  )}
                </button>
              </div>
            </form>
          ) : (
            /* Result Box */
            <div className="space-y-4 animate-fadeIn">
              <div className="p-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 space-y-2">
                <div className="flex items-center gap-2 font-bold text-sm text-emerald-400">
                  <CheckCircle2 className="w-5 h-5" />
                  <span>¡Instancia de OpenClaw Aprovisionada con Éxito!</span>
                </div>
                <p className="text-xs text-emerald-200/80">
                  El nuevo contenedor se ejecutará 24/7 en la subred aislada de GCP.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-gray-950 border border-gray-800 text-xs space-y-2.5">
                <div className="flex justify-between border-b border-gray-800 pb-2">
                  <span className="text-gray-400">Nombre Contenedor:</span>
                  <span className="font-mono text-emerald-400 font-bold">{result.container_name}</span>
                </div>
                <div className="flex justify-between border-b border-gray-800 pb-2">
                  <span className="text-gray-400">Container ID:</span>
                  <span className="font-mono text-white">{result.container_id}</span>
                </div>
                <div className="flex justify-between border-b border-gray-800 pb-2">
                  <span className="text-gray-400">Subred Aislada Backend:</span>
                  <span className="text-gray-300">{result.vpc_subnet}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Cuota Recursos (e2-micro):</span>
                  <span className="text-gray-300 font-semibold">{result.memory_limit} RAM | {result.cpu_limit} vCPU</span>
                </div>
              </div>

              <div className="flex justify-end gap-2 pt-2">
                <button
                  onClick={() => {
                    setResult(null);
                    onClose();
                  }}
                  className="px-5 py-2.5 rounded-xl text-xs font-bold text-gray-950 bg-emerald-400 hover:bg-emerald-300 transition-colors"
                >
                  Entendido y Cerrar
                </button>
              </div>
            </div>
          )}
        </div>

      </div>
    </div>
  );
}
