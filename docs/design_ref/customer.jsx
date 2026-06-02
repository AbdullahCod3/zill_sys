// Customer page — simple phone-style call screen. Customer sees NO sign of Shadow.

function CustomerPage({ lang, mood }) {
  const t = (en, ar) => (lang === 'ar' ? ar : en);
  // 'idle' → 'ringing' → 'connected' → 'ended'
  const [phase, setPhase] = React.useState('idle');
  const [seconds, setSeconds] = React.useState(0);
  const [muted, setMuted] = React.useState(false);
  const [speakerOn, setSpeakerOn] = React.useState(false);

  // Ring for 3.5s, then the agent "answers" → connected
  React.useEffect(() => {
    if (phase !== 'ringing') return;
    const id = setTimeout(() => { setSeconds(0); setPhase('connected'); }, 3500);
    return () => clearTimeout(id);
  }, [phase]);

  // Call timer only while connected
  React.useEffect(() => {
    if (phase !== 'connected') return;
    const id = setInterval(() => setSeconds((s) => s + 1), 1000);
    return () => clearInterval(id);
  }, [phase]);

  const fmt = (s) => `${Math.floor(s / 60).toString().padStart(2, '0')}:${(s % 60).toString().padStart(2, '0')}`;

  const moodLabel = mood === 'frustrated' ? t('Static · poor signal?', 'تشويش · إشارة ضعيفة؟') : t('Clear', 'واضحة');

  const startCall = () => { setMuted(false); setPhase('ringing'); };
  const endCall = () => setPhase('ended');
  const reset = () => { setSeconds(0); setPhase('idle'); };

  return (
    <div className="page customer">
      <div className="cust-stage">
        <div className="phone">
          <div className="phone-notch">
            <span className="phone-time">9:41</span>
            <div className="phone-notch-island"></div>
            <div className="phone-notch-meta">
              <span className="kbd" style={{ fontSize: 9 }}>5G</span>
              <span style={{ marginLeft: 6 }}>●●●</span>
            </div>
          </div>

          <div className={`phone-body ${phase === 'ended' ? 'phone-body-ended' : ''}`}>
            {phase === 'idle' && (
              <div className="cust-idle">
                <div className="cust-idle-top">
                  <div className="kbd" style={{ color: 'var(--neon-cyan)' }}>{t('TELCO SUPPORT', 'دعم تيلكو')}</div>
                  <div className="cust-idle-num">800 100 2020</div>
                </div>

                <div className="cust-avatar-wrap cust-avatar-static">
                  <div className="cust-avatar">
                    <svg viewBox="0 0 80 80" width="80" height="80">
                      <circle cx="40" cy="32" r="14" fill="var(--bg-base)" opacity="0.7" />
                      <path d="M 14 80 Q 14 50 40 50 Q 66 50 66 80 Z" fill="var(--bg-base)" opacity="0.7" />
                    </svg>
                  </div>
                </div>

                <div className="cust-name">{t('Telco Support', 'دعم تيلكو')}</div>
                <div className="cust-idle-sub">{t('Tap to start your support call', 'اضغط لبدء مكالمة الدعم')}</div>

                <button className="call-start-btn" onClick={startCall}>
                  <svg viewBox="0 0 24 24" width="26" height="26" fill="currentColor">
                    <path d="M21 15.5l-2.4-.5a1 1 0 0 1-.8-1L17.6 12a11 11 0 0 0-11.2 0l-.2 2a1 1 0 0 1-.8 1L3 15.5a1 1 0 0 1-1.2-.7c-1.2-3.6 4.2-7.8 10.2-7.8s11.4 4.2 10.2 7.8a1 1 0 0 1-1.2.7z" />
                  </svg>
                </button>
                <div className="call-start-label">{t('Call', 'اتصال')}</div>
              </div>
            )}

            {phase === 'ringing' && (
              <>
                <div className="cust-meta">
                  <div className="kbd" style={{ color: 'var(--neon-cyan)' }}>{t('CALLING…', 'يتّصل…')}</div>
                </div>

                <div className="cust-avatar-wrap">
                  <div className="cust-rings">
                    <div className="ring r1"></div>
                    <div className="ring r2"></div>
                    <div className="ring r3"></div>
                  </div>
                  <div className="cust-avatar">
                    <svg viewBox="0 0 80 80" width="80" height="80">
                      <circle cx="40" cy="32" r="14" fill="var(--bg-base)" opacity="0.7" />
                      <path d="M 14 80 Q 14 50 40 50 Q 66 50 66 80 Z" fill="var(--bg-base)" opacity="0.7" />
                    </svg>
                  </div>
                </div>

                <div className="cust-name">{t('Telco Support', 'دعم تيلكو')}</div>
                <div className="cust-status">
                  <span className="cust-ringdots"><span/><span/><span/></span>
                  <span>{t('Ringing', 'يرنّ')}</span>
                </div>

                <button className="end-btn end-btn-ring" onClick={endCall}>
                  <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor">
                    <path d="M21 15.5l-2.4-.5a1 1 0 0 1-.8-1L17.6 12a11 11 0 0 0-11.2 0l-.2 2a1 1 0 0 1-.8 1L3 15.5a1 1 0 0 1-1.2-.7c-1.2-3.6 4.2-7.8 10.2-7.8s11.4 4.2 10.2 7.8a1 1 0 0 1-1.2.7z" />
                  </svg>
                </button>
              </>
            )}

            {phase === 'connected' && (
              <>
                <div className="cust-meta">
                  <div className="kbd" style={{ color: 'var(--neon-cyan)' }}>{t('SUPPORT', 'الدعم')}</div>
                  <div className="cust-line"></div>
                  <div className="kbd">{fmt(seconds)}</div>
                </div>

                <div className="cust-avatar-wrap">
                  <div className="cust-rings">
                    <div className="ring r1"></div>
                    <div className="ring r2"></div>
                    <div className="ring r3"></div>
                  </div>
                  <div className="cust-avatar">
                    <svg viewBox="0 0 80 80" width="80" height="80">
                      <circle cx="40" cy="32" r="14" fill="var(--bg-base)" opacity="0.7" />
                      <path d="M 14 80 Q 14 50 40 50 Q 66 50 66 80 Z" fill="var(--bg-base)" opacity="0.7" />
                    </svg>
                  </div>
                </div>

                <div className="cust-name">{t('Telco Support', 'دعم تيلكو')}</div>
                <div className="cust-status">
                  <span className="bars"><span/><span/><span/><span/><span/></span>
                  <span>{t('Connected', 'متصل')} · {moodLabel}</span>
                </div>

                <div className="cust-actions">
                  <button
                    className={`pill-btn ${muted ? 'pill-btn-on' : ''}`}
                    onClick={() => setMuted((m) => !m)}
                  >
                    <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="1.8">
                      <rect x="9" y="3" width="6" height="12" rx="3" />
                      <path d="M5 11a7 7 0 0 0 14 0" />
                      <path d="M12 18v3" />
                      {muted && <line x1="3" y1="3" x2="21" y2="21" stroke="currentColor" strokeWidth="2" />}
                    </svg>
                    <span>{muted ? t('Unmute', 'إلغاء الكتم') : t('Mute', 'كتم')}</span>
                  </button>

                  <button
                    className={`pill-btn ${speakerOn ? 'pill-btn-on' : ''}`}
                    onClick={() => setSpeakerOn((s) => !s)}
                  >
                    <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="1.8">
                      <path d="M4 9v6h4l5 4V5L8 9H4z" />
                      <path d="M17 8a5 5 0 0 1 0 8" />
                    </svg>
                    <span>{t('Speaker', 'مكبر')}</span>
                  </button>

                  <button className="pill-btn">
                    <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="1.8">
                      <rect x="3" y="4" width="18" height="14" rx="2" />
                      <path d="M3 8h18" />
                    </svg>
                    <span>{t('Keypad', 'لوحة')}</span>
                  </button>
                </div>

                <button className="end-btn" onClick={endCall}>
                  <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor">
                    <path d="M21 15.5l-2.4-.5a1 1 0 0 1-.8-1L17.6 12a11 11 0 0 0-11.2 0l-.2 2a1 1 0 0 1-.8 1L3 15.5a1 1 0 0 1-1.2-.7c-1.2-3.6 4.2-7.8 10.2-7.8s11.4 4.2 10.2 7.8a1 1 0 0 1-1.2.7z" />
                  </svg>
                </button>
              </>
            )}

            {phase === 'ended' && (
              <div className="cust-ended">
                <div className="kbd" style={{ color: 'var(--color-danger)' }}>● {t('CALL ENDED', 'انتهت المكالمة')}</div>
                <div className="ended-time">{fmt(seconds)}</div>
                <div className="ended-name">{t('Telco Support', 'دعم تيلكو')}</div>
                <button className="btn btn-ghost" onClick={reset}>
                  {t('Call again', 'اتصل مرة أخرى')}
                </button>
              </div>
            )}
          </div>

          <div className="phone-home"></div>
        </div>

        <div className="cust-hint">
          <span className="kbd" style={{ color: 'var(--neon-cyan)' }}>NOTE</span>
          <span>{t("The customer doesn't see Shadow.", 'العميل لا يرى زِل.')}</span>
        </div>
      </div>

      <style>{`
        .cust-stage {
          flex: 1;
          display: grid;
          place-items: center;
          padding: 24px;
          position: relative;
          gap: 32px;
        }
        .phone {
          width: 360px;
          height: 720px;
          background: var(--color-void);
          border-radius: 48px;
          padding: 14px;
          border: 1px solid var(--border-strong);
          box-shadow:
            inset 0 0 0 2px rgba(255,255,255,0.04),
            0 40px 80px rgba(0,0,0,0.5),
            0 0 60px rgba(94, 234, 212, 0.12);
          position: relative;
          display: flex; flex-direction: column;
        }
        [data-theme="light"] .phone {
          background: #1a1a24;
          box-shadow:
            0 40px 80px rgba(0,0,0,0.25),
            0 0 60px rgba(94, 234, 212, 0.18);
        }
        .phone-notch {
          height: 36px;
          display: flex; align-items: center; justify-content: space-between;
          padding: 0 16px;
          color: #fff;
          position: relative;
        }
        .phone-time { font-family: var(--font-ui); font-weight: 600; font-size: 14px; }
        .phone-notch-island {
          position: absolute; left: 50%; top: 6px; transform: translateX(-50%);
          width: 80px; height: 24px; background: #000; border-radius: 12px;
        }
        .phone-notch-meta { font-family: var(--font-mono); font-size: 11px; color: #fff; opacity: 0.85; }
        .phone-body {
          flex: 1;
          background: linear-gradient(180deg, #1a1a26 0%, #0e0e16 100%);
          border-radius: 32px;
          padding: 28px 24px;
          display: flex; flex-direction: column;
          align-items: center;
          color: #fff;
          position: relative;
          overflow: hidden;
        }
        .phone-body::before {
          content: '';
          position: absolute; inset: 0;
          background: radial-gradient(ellipse 80% 60% at 50% 30%, rgba(94, 234, 212, 0.18), transparent 60%);
          pointer-events: none;
        }
        .phone-home {
          height: 6px;
          width: 120px;
          background: rgba(255,255,255,0.4);
          border-radius: 3px;
          margin: 8px auto 0;
        }
        .cust-meta {
          display: flex; align-items: center; gap: 12px;
          width: 100%; justify-content: center;
          position: relative; z-index: 1;
        }
        .cust-line { width: 36px; height: 1px; background: rgba(255,255,255,0.3); }
        .cust-avatar-wrap {
          position: relative; width: 200px; height: 200px;
          margin: 40px 0 24px;
          display: grid; place-items: center;
          z-index: 1;
        }
        .cust-avatar {
          width: 120px; height: 120px;
          border-radius: 50%;
          background: linear-gradient(135deg, var(--neon-cyan), var(--neon));
          display: grid; place-items: center;
          box-shadow: 0 0 40px rgba(94, 234, 212, 0.5);
        }

        /* —— Idle (pre-call) —— */
        .cust-idle {
          flex: 1;
          display: flex; flex-direction: column; align-items: center;
          z-index: 1;
        }
        .cust-idle-top {
          display: flex; flex-direction: column; align-items: center; gap: 6px;
          margin-bottom: 24px;
        }
        .cust-idle-num {
          font-family: var(--font-mono); font-size: 13px; letter-spacing: 0.1em;
          color: rgba(255,255,255,0.55);
        }
        .cust-avatar-static { margin: 24px 0 20px; }
        .cust-idle-sub {
          font-family: var(--font-ui); font-size: 14px;
          color: rgba(255,255,255,0.55);
          margin-top: 8px; margin-bottom: auto;
          text-align: center;
        }
        .call-start-btn {
          width: 76px; height: 76px;
          border-radius: 50%;
          background: var(--color-success);
          color: #fff;
          border: none;
          cursor: pointer;
          display: grid; place-items: center;
          box-shadow: 0 8px 28px rgba(61, 201, 106, 0.45);
          transition: transform var(--duration-fast) var(--ease-out);
          animation: startPulse 1.8s ease-in-out infinite;
        }
        .call-start-btn:hover { transform: scale(1.06); animation: none; }
        @keyframes startPulse {
          0%, 100% { box-shadow: 0 8px 28px rgba(61, 201, 106, 0.4); }
          50% { box-shadow: 0 8px 36px rgba(61, 201, 106, 0.75); }
        }
        .call-start-label {
          font-family: var(--font-ui); font-size: 12px; font-weight: 500;
          color: rgba(255,255,255,0.7);
          margin-top: 12px; margin-bottom: 8px;
        }

        /* —— Ringing dots —— */
        .cust-ringdots { display: inline-flex; gap: 4px; }
        .cust-ringdots span {
          width: 5px; height: 5px; border-radius: 50%; background: var(--neon-cyan);
          animation: typing 1.2s ease-in-out infinite;
        }
        .cust-ringdots span:nth-child(2) { animation-delay: 0.15s; }
        .cust-ringdots span:nth-child(3) { animation-delay: 0.3s; }
        @keyframes typing { 0%, 80%, 100% { opacity: 0.3; transform: translateY(0); } 40% { opacity: 1; transform: translateY(-3px); } }
        .end-btn-ring { margin-top: auto; }
        .ring {
          position: absolute;
          border-radius: 50%;
          border: 1px solid rgba(94, 234, 212, 0.5);
          animation: ring 2.6s ease-out infinite;
        }
        .r1 { width: 140px; height: 140px; animation-delay: 0s; }
        .r2 { width: 170px; height: 170px; animation-delay: 0.7s; opacity: 0.6; }
        .r3 { width: 200px; height: 200px; animation-delay: 1.4s; opacity: 0.3; }
        @keyframes ring {
          0% { transform: scale(0.85); opacity: 0.8; }
          100% { transform: scale(1.15); opacity: 0; }
        }
        .cust-name {
          font-family: var(--font-display);
          font-size: 28px;
          font-weight: 400;
          letter-spacing: -0.01em;
          z-index: 1;
        }
        .cust-status {
          display: flex; align-items: center; gap: 10px;
          margin-top: 8px;
          font-family: var(--font-mono);
          font-size: 11px;
          letter-spacing: 0.12em;
          text-transform: uppercase;
          color: rgba(255,255,255,0.6);
          z-index: 1;
        }
        .cust-status .bars { color: var(--neon-cyan); }
        .cust-actions {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 12px;
          margin: auto 0 24px;
          width: 100%;
          z-index: 1;
        }
        .pill-btn {
          background: rgba(255,255,255,0.06);
          border: 1px solid rgba(255,255,255,0.1);
          color: #fff;
          padding: 14px 4px;
          border-radius: 16px;
          display: flex; flex-direction: column; align-items: center; gap: 6px;
          font-family: var(--font-ui);
          font-size: 11px;
          cursor: pointer;
          transition: all var(--duration-fast) var(--ease-out);
        }
        .pill-btn:hover { background: rgba(255,255,255,0.12); }
        .pill-btn-on {
          background: var(--neon-cyan); color: var(--color-void); border-color: var(--neon-cyan);
          box-shadow: 0 0 16px rgba(94, 234, 212, 0.5);
        }
        .end-btn {
          width: 64px; height: 64px;
          border-radius: 50%;
          background: var(--color-danger);
          color: #fff;
          border: none;
          cursor: pointer;
          display: grid; place-items: center;
          box-shadow: 0 8px 24px rgba(232, 84, 84, 0.4);
          transition: transform var(--duration-fast) var(--ease-out);
          margin-bottom: 8px;
          z-index: 1;
        }
        .end-btn:hover { transform: scale(1.05); }
        .end-btn svg { transform: rotate(135deg); }

        .cust-ended {
          display: flex; flex-direction: column; align-items: center; justify-content: center;
          flex: 1; gap: 16px; z-index: 1;
        }
        .ended-time { font-family: var(--font-mono); font-size: 28px; color: #fff; }
        .ended-name { font-family: var(--font-display); font-size: 22px; opacity: 0.8; }

        .cust-hint {
          display: flex; align-items: center; gap: 12px;
          padding: 12px 18px;
          border: 1px dashed var(--border-default);
          border-radius: var(--radius-pill);
          font-family: var(--font-ui);
          font-size: 13px;
          color: var(--fg-secondary);
          max-width: 540px;
          background: var(--bg-overlay);
        }
      `}</style>
    </div>
  );
}

window.CustomerPage = CustomerPage;
