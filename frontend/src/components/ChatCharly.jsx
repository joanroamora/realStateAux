import React, { useState, useRef, useEffect } from 'react';
import { Bot, Send, Mic, MicOff, Volume2, Sparkles, RefreshCw, CheckCheck, Clock, ExternalLink, Calendar, MapPin, DollarSign, ShieldAlert } from 'lucide-react';

export default function ChatCharly({ initialPrompt }) {
  const [messages, setMessages] = useState([
    {
      id: 1,
      sender: 'charly',
      text: '¡Hola! Soy **Charly**, tu Asistente Inmobiliario Autónomo 24/7 de OpenClaw. Estoy conectado al inventario privado, la agenda y los canales de WhatsApp/Telegram.\n\n¿En qué tarea automatizada te ayudo hoy?',
      time: '19:45 PM',
      type: 'welcome'
    },
    {
      id: 2,
      sender: 'charly',
      text: '💡 **Sugerencias de tareas automáticas:**',
      time: '19:45 PM',
      type: 'quick_actions'
    }
  ]);

  const [input, setInput] = useState('');
  const [isRecording, setIsRecording] = useState(false);
  const [recordingSeconds, setRecordingSeconds] = useState(0);
  const [isTyping, setIsTyping] = useState(false);

  const messagesEndRef = useRef(null);
  const timerRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages, isTyping]);

  // Handle external feature click prompt injection
  useEffect(() => {
    if (initialPrompt) {
      handleSendMessage(initialPrompt);
    }
  }, [initialPrompt]);

  // Timer for voice recording simulation
  useEffect(() => {
    if (isRecording) {
      setRecordingSeconds(0);
      timerRef.current = setInterval(() => {
        setRecordingSeconds((prev) => prev + 1);
      }, 1000);
    } else {
      clearInterval(timerRef.current);
    }
    return () => clearInterval(timerRef.current);
  }, [isRecording]);

  const handleSendMessage = (textToSend) => {
    const query = textToSend || input;
    if (!query.trim()) return;

    const userMsg = {
      id: Date.now(),
      sender: 'user',
      text: query,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };

    setMessages((prev) => [...prev, userMsg]);
    if (!textToSend) setInput('');
    setIsTyping(true);

    // Simulate AI reasoning and openclaw response
    setTimeout(() => {
      generateCharlyResponse(query);
      setIsTyping(false);
    }, 1200);
  };

  const toggleVoiceRecording = () => {
    if (!isRecording) {
      setIsRecording(true);
    } else {
      setIsRecording(false);
      // Simulate speech-to-text result
      const voicePrompts = [
        "Hola Charly, ¿cuáles casas tenemos disponibles en zona Norte con presupuesto hasta 370 mil dólares?",
        "Charly, revisa los huecos de agenda libres para visitas el 10 de junio",
        "Califica el perfil de búsqueda de la clienta Sofía Martínez de WhatsApp"
      ];
      const randomPrompt = voicePrompts[Math.floor(Math.random() * voicePrompts.length)];
      
      handleSendMessage(`🎙️ [Nota de Voz - 0:0${recordingSeconds + 2}]: "${randomPrompt}"`);
    }
  };

  const generateCharlyResponse = (userQuery) => {
    const q = userQuery.toLowerCase();
    let charlyText = '';
    let cardData = null;

    if (q.includes('casa') || q.includes('propiedad') || q.includes('norte') || q.includes('match') || q.includes('370')) {
      charlyText = '🔍 **Matchmaking Inmobiliario Ejecutado:**\nHe filtrado la base de datos privada en subred aislada GCP. Se encontró 1 propiedad perfecta que coincide con la búsqueda de **Zona Norte** y presupuesto ≤ **$370,000 USD**:';
      cardData = {
        type: 'property',
        data: {
          id: 'PROP-101',
          direccion: '1428 Elm Street, North District',
          precio: 350000,
          habitaciones: 3,
          banos: 2,
          zona: 'Norte',
          estado: 'Disponible',
          tipo: 'Casa',
          url_fotos: 'https://ejemplo.com/fotos/prop101.jpg'
        }
      };
    } else if (q.includes('agenda') || q.includes('horario') || q.includes('visita') || q.includes('junio') || q.includes('slot')) {
      charlyText = '📅 **Sincronización de Agenda (agent_carlos_01):**\nHe consultado el simulador de disponibilidad en zona horaria **America/Chicago**. Próximos slots sin traslapes para visitas presenciales:';
      cardData = {
        type: 'calendar',
        data: [
          { fecha: '2026-06-10', horarios: ['10:00 AM', '02:00 PM', '04:30 PM'] },
          { fecha: '2026-06-11', horarios: ['09:00 AM', '11:30 AM', '03:00 PM'] }
        ]
      };
    } else if (q.includes('lead') || q.includes('sofía') || q.includes('martínez') || q.includes('captura')) {
      charlyText = '📋 **Calificación Automática de Lead (WhatsApp):**\n\n- **Cliente**: Sofía Martínez (`LEAD-001`)\n- **Canal**: WhatsApp Business API\n- **Estado**: ✅ **Calificado Exitosamente**\n- **Criterio**: Presupuesto de $370,000 USD (Cubre propiedad `PROP-101` de $350,000 USD). Crédito hipotecario pre-aprobado.';
    } else if (q.includes('seguimiento') || q.includes('david') || q.includes('post-visita')) {
      charlyText = '📩 **Seguimiento Post-Visita Automatizado:**\nHe enviado un mensaje de seguimiento personalizado vía Telegram al inversor **David Johnson** (`LEAD-002`) con recomendación de apartamentos en Zona Costera.';
    } else {
      charlyText = `🤖 He procesado tu solicitud: "${userQuery}".\n\nDe acuerdo con la política interna (**faq_inmobiliaria.md**):\n1. Todo comprador requiere calificación inicial previa.\n2. No se revelan direcciones exactas de propiedades bajo contrato hasta verificar identidad.`;
    }

    setMessages((prev) => [
      ...prev,
      {
        id: Date.now(),
        sender: 'charly',
        text: charlyText,
        cardData: cardData,
        time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      }
    ]);
  };

  return (
    <div className="glass-panel rounded-3xl border border-gray-800 flex flex-col h-[580px] shadow-2xl relative overflow-hidden">
      
      {/* Header del Chat */}
      <div className="px-5 py-3.5 border-b border-gray-800/80 bg-gray-900/90 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="relative">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-emerald-500 to-teal-400 p-0.5 shadow-md shadow-emerald-500/20">
              <div className="w-full h-full bg-gray-950 rounded-[14px] flex items-center justify-center">
                <Bot className="w-5 h-5 text-emerald-400" />
              </div>
            </div>
            <div className="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-emerald-500 rounded-full border-2 border-gray-900 glow-emerald" />
          </div>
          
          <div>
            <div className="flex items-center gap-2">
              <h3 className="font-['Outfit'] font-bold text-base text-white">Charly AI</h3>
              <span className="text-[10px] font-medium px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                OpenClaw 24/7
              </span>
            </div>
            <p className="text-[11px] text-gray-400">
              Asistente Autónomo Inmobiliario &bull; Texto y Voz
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2 text-xs text-gray-400">
          <span className="hidden sm:inline text-[11px] px-2.5 py-1 rounded-lg bg-gray-800 border border-gray-700 text-gray-300">
            e2-micro 256MB RAM
          </span>
          <button
            onClick={() => setMessages([{ id: 1, sender: 'charly', text: '¡Chat reiniciado! ¿En qué te puedo colaborar?', time: 'Ahora' }])}
            className="p-2 rounded-xl bg-gray-800/60 hover:bg-gray-700 text-gray-400 hover:text-white transition-colors"
            title="Reiniciar conversación"
          >
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Historial de Mensajes */}
      <div className="flex-1 p-4 lg:p-6 overflow-y-auto space-y-4">
        {messages.map((msg) => {
          const isCharly = msg.sender === 'charly';

          return (
            <div
              key={msg.id}
              className={`flex items-start gap-3 ${isCharly ? 'justify-start' : 'justify-end'}`}
            >
              {isCharly && (
                <div className="w-8 h-8 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 shrink-0 mt-1">
                  <Bot className="w-4.5 h-4.5" />
                </div>
              )}

              <div className={`max-w-[85%] sm:max-w-[75%] space-y-2`}>
                <div
                  className={`p-4 rounded-2xl text-xs sm:text-sm leading-relaxed ${
                    isCharly
                      ? 'bg-gray-900/90 text-gray-200 border border-gray-800 rounded-tl-sm shadow-md'
                      : 'bg-gradient-to-r from-emerald-600 to-teal-600 text-white rounded-tr-sm shadow-lg shadow-emerald-600/20'
                  }`}
                >
                  <p className="whitespace-pre-line">{msg.text}</p>

                  {/* Render Quick Action Chips inside chat */}
                  {msg.type === 'quick_actions' && (
                    <div className="mt-3 grid grid-cols-1 sm:grid-cols-2 gap-2 pt-2 border-t border-gray-800">
                      <button
                        onClick={() => handleSendMessage('🔍 Busca casas en Zona Norte con presupuesto $370,000 USD')}
                        className="text-left px-3 py-2 rounded-xl bg-gray-800/80 hover:bg-emerald-500/20 border border-gray-700 hover:border-emerald-500/40 text-xs text-emerald-300 transition-colors flex items-center justify-between"
                      >
                        <span>🔍 Match: Casas Norte</span>
                        <ExternalLink className="w-3 h-3 text-emerald-400" />
                      </button>

                      <button
                        onClick={() => handleSendMessage('📅 Ver horarios libres para visitas en agenda')}
                        className="text-left px-3 py-2 rounded-xl bg-gray-800/80 hover:bg-blue-500/20 border border-gray-700 hover:border-blue-500/40 text-xs text-blue-300 transition-colors flex items-center justify-between"
                      >
                        <span>📅 Ver Huecos de Agenda</span>
                        <ExternalLink className="w-3 h-3 text-blue-400" />
                      </button>

                      <button
                        onClick={() => handleSendMessage('📋 Calificar Lead Sofía Martínez de WhatsApp')}
                        className="text-left px-3 py-2 rounded-xl bg-gray-800/80 hover:bg-purple-500/20 border border-gray-700 hover:border-purple-500/40 text-xs text-purple-300 transition-colors flex items-center justify-between"
                      >
                        <span>📋 Calificar Lead Sofía</span>
                        <ExternalLink className="w-3 h-3 text-purple-400" />
                      </button>

                      <button
                        onClick={() => handleSendMessage('📩 Simular seguimiento post-visita Telegram')}
                        className="text-left px-3 py-2 rounded-xl bg-gray-800/80 hover:bg-amber-500/20 border border-gray-700 hover:border-amber-500/40 text-xs text-amber-300 transition-colors flex items-center justify-between"
                      >
                        <span>📩 Seguimiento Post-Visita</span>
                        <ExternalLink className="w-3 h-3 text-amber-400" />
                      </button>
                    </div>
                  )}

                  {/* Render Property Card matched by Charly */}
                  {msg.cardData?.type === 'property' && (
                    <div className="mt-3 p-3 rounded-xl bg-gray-950/80 border border-emerald-500/30 text-xs space-y-2">
                      <div className="flex items-center justify-between">
                        <span className="font-bold text-emerald-400">{msg.cardData.data.id} - {msg.cardData.data.tipo}</span>
                        <span className="px-2 py-0.5 bg-emerald-500/20 text-emerald-300 text-[10px] font-semibold rounded-full">
                          {msg.cardData.data.estado}
                        </span>
                      </div>
                      <p className="text-gray-300 flex items-center gap-1">
                        <MapPin className="w-3.5 h-3.5 text-gray-400" />
                        {msg.cardData.data.direccion}
                      </p>
                      <div className="flex items-center justify-between pt-1 border-t border-gray-800 text-gray-400">
                        <span>{msg.cardData.data.habitaciones} habs &bull; {msg.cardData.data.banos} baños</span>
                        <span className="font-extrabold text-white text-sm text-emerald-400">
                          ${msg.cardData.data.precio.toLocaleString()} USD
                        </span>
                      </div>
                    </div>
                  )}

                  {/* Render Calendar Slots matched by Charly */}
                  {msg.cardData?.type === 'calendar' && (
                    <div className="mt-3 space-y-2">
                      {msg.cardData.data.map((item, idx) => (
                        <div key={idx} className="p-2.5 rounded-xl bg-gray-950/80 border border-blue-500/30 text-xs">
                          <div className="flex items-center gap-1.5 font-semibold text-blue-300 mb-1.5">
                            <Calendar className="w-3.5 h-3.5" />
                            <span>Fecha: {item.fecha}</span>
                          </div>
                          <div className="flex flex-wrap gap-1.5">
                            {item.horarios.map((slot, sIdx) => (
                              <button
                                key={sIdx}
                                onClick={() => handleSendMessage(`Agendar visita el ${item.fecha} a las ${slot}`)}
                                className="px-2.5 py-1 rounded-lg bg-blue-500/10 hover:bg-blue-500/20 border border-blue-500/30 text-blue-300 font-medium transition-colors"
                              >
                                {slot}
                              </button>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                <div className={`text-[10px] text-gray-500 px-1 ${isCharly ? 'text-left' : 'text-right'}`}>
                  {msg.time} {isCharly && '&bull; OpenClaw Verified'}
                </div>
              </div>
            </div>
          );
        })}

        {/* Typing Indicator */}
        {isTyping && (
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400">
              <Bot className="w-4 h-4" />
            </div>
            <div className="px-4 py-3 rounded-2xl bg-gray-900 border border-gray-800 text-xs text-gray-400 flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-bounce"></span>
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-bounce [animation-delay:0.2s]"></span>
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-bounce [animation-delay:0.4s]"></span>
              <span className="ml-1 text-gray-400">Charly procesando en subred aislada...</span>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Voice Recording Waveform Overlay */}
      {isRecording && (
        <div className="px-4 py-3 bg-red-950/40 border-t border-red-500/30 flex items-center justify-between text-xs text-red-300 animate-pulse">
          <div className="flex items-center gap-3">
            <div className="w-3 h-3 rounded-full bg-red-500 animate-ping" />
            <span className="font-semibold">Grabando comando de voz... (0:0{recordingSeconds})</span>
          </div>
          <div className="flex items-center gap-1">
            <span className="w-1 h-4 bg-red-400 rounded-full animate-wave"></span>
            <span className="w-1 h-6 bg-red-400 rounded-full animate-wave [animation-delay:0.2s]"></span>
            <span className="w-1 h-8 bg-red-400 rounded-full animate-wave [animation-delay:0.4s]"></span>
            <span className="w-1 h-5 bg-red-400 rounded-full animate-wave [animation-delay:0.1s]"></span>
          </div>
        </div>
      )}

      {/* Area de Entrada (Texto y Voz) */}
      <div className="p-3 bg-gray-900/90 border-t border-gray-800">
        <form
          onSubmit={(e) => {
            e.preventDefault();
            handleSendMessage();
          }}
          className="flex items-center gap-2"
        >
          {/* Audio Voice Input Button */}
          <button
            type="button"
            onClick={toggleVoiceRecording}
            className={`p-3 rounded-2xl transition-all ${
              isRecording
                ? 'bg-red-600 text-white shadow-lg shadow-red-600/30 scale-105'
                : 'bg-gray-800 hover:bg-gray-700 text-emerald-400 border border-gray-700/80 hover:text-emerald-300'
            }`}
            title={isRecording ? 'Detener y procesar audio' : 'Entrada por Voz (Comando)'}
          >
            {isRecording ? <MicOff className="w-5 h-5 animate-pulse" /> : <Mic className="w-5 h-5" />}
          </button>

          {/* Text Input */}
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder={isRecording ? "Escuchando nota de voz..." : "Escribe un mensaje o tarea a Charly..."}
            disabled={isRecording}
            className="flex-1 bg-gray-950 border border-gray-800 rounded-2xl px-4 py-3 text-xs sm:text-sm text-white placeholder-gray-500 focus:outline-none focus:border-emerald-500/60 focus:ring-1 focus:ring-emerald-500/50 transition-all disabled:opacity-50"
          />

          {/* Submit Button */}
          <button
            type="submit"
            disabled={!input.trim() || isRecording}
            className="p-3 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-400 hover:from-emerald-400 hover:to-teal-300 text-gray-950 font-bold transition-all shadow-md shadow-emerald-500/20 disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <Send className="w-5 h-5" />
          </button>
        </form>
      </div>

    </div>
  );
}
