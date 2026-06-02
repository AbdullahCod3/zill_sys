// Home page — minimal: image + 2 clean role buttons.

function HomePage({ lang, goTo }) {
  const t = (en, ar) => (lang === 'ar' ? ar : en);

  return (
    <div className="page home">
      <div className="home-grid">
        {/* LEFT — minimal copy + buttons */}
        <div className="home-left">
          <h1 className="home-title">
            <em className="home-title-em">{t('Choose a side.', 'اختر دورك.')}</em>
          </h1>

          <div className="home-roles">
            <button className="role-card role-card-agent" onClick={() => goTo('employee')}>
              <span className="role-card-num">01</span>
              <span className="role-card-title">{t("I'm the Employee", 'أنا موظف الدعم')}</span>
              <span className="role-card-arrow">
                <svg width="28" height="14" viewBox="0 0 28 14" fill="none">
                  <path d="M0 7 H25 M19 1 L25 7 L19 13" stroke="currentColor" strokeWidth="1.5" />
                </svg>
              </span>
            </button>

            <button className="role-card role-card-customer" onClick={() => goTo('customer')}>
              <span className="role-card-num">02</span>
              <span className="role-card-title">{t("I'm the Customer", 'أنا العميل')}</span>
              <span className="role-card-arrow">
                <svg width="28" height="14" viewBox="0 0 28 14" fill="none">
                  <path d="M0 7 H25 M19 1 L25 7 L19 13" stroke="currentColor" strokeWidth="1.5" />
                </svg>
              </span>
            </button>
          </div>
        </div>

        {/* RIGHT — Hero image */}
        <div className="home-right">
          <div className="hero-frame">
            <img src="caricature.png" alt="A customer service agent with an AI assistant beside him" />
            <div className="hero-corner hero-corner-tl"></div>
            <div className="hero-corner hero-corner-tr"></div>
            <div className="hero-corner hero-corner-bl"></div>
            <div className="hero-corner hero-corner-br"></div>
          </div>
          <div className="home-callout home-callout-top">
            <span className="dot-live"></span>
            <span className="kbd" style={{ color: 'var(--neon)' }}>SHADOW · LIVE</span>
          </div>
        </div>
      </div>

      <style>{`
        .home-grid {
          flex: 1;
          display: grid;
          grid-template-columns: minmax(0, 0.85fr) minmax(0, 1.15fr);
          gap: clamp(24px, 4vw, 56px);
          padding: clamp(24px, 4vw, 56px) clamp(24px, 5vw, 64px);
          align-items: center;
          max-width: 1480px;
          width: 100%;
          margin: 0 auto;
        }
        .home-left {
          display: flex; flex-direction: column; gap: 36px;
          min-width: 0;
        }
        .home-title {
          font-family: var(--font-display);
          font-weight: 700;
          font-size: clamp(56px, 6.4vw, 88px);
          line-height: 1.05;
          letter-spacing: -0.03em;
          color: var(--fg-primary);
          margin-top: 12px;
        }
        .home-title-em {
          font-style: normal;
          color: var(--neon);
          text-shadow: 0 0 24px rgba(124, 111, 247, 0.35);
        }

        .home-roles {
          display: flex; flex-direction: column;
          gap: 12px;
          max-width: 460px;
        }
        .role-card {
          position: relative;
          background: var(--bg-surface);
          border: 1px solid var(--border-default);
          border-radius: var(--radius-lg);
          padding: 22px 26px;
          text-align: left;
          cursor: pointer;
          color: var(--fg-primary);
          font-family: var(--font-ui);
          display: grid;
          grid-template-columns: auto 1fr auto;
          align-items: center;
          gap: 20px;
          transition: all var(--duration-base) var(--ease-out);
          overflow: hidden;
        }
        .role-card::before {
          content: '';
          position: absolute; inset: 0;
          background:
            linear-gradient(var(--grid-color) 1px, transparent 1px) 0 0 / 32px 32px,
            linear-gradient(90deg, var(--grid-color) 1px, transparent 1px) 0 0 / 32px 32px;
          opacity: 0.5;
          pointer-events: none;
        }
        .role-card:hover {
          border-color: var(--neon);
          transform: translateY(-2px);
          box-shadow: 0 0 28px rgba(124, 111, 247, 0.25);
        }
        .role-card-customer:hover {
          border-color: var(--neon-cyan);
          box-shadow: 0 0 28px rgba(94, 234, 212, 0.22);
        }
        .role-card-num {
          font-family: var(--font-mono);
          font-size: 14px;
          color: var(--neon);
          letter-spacing: 0.1em;
          opacity: 0.8;
          position: relative; z-index: 1;
        }
        .role-card-customer .role-card-num { color: var(--neon-cyan); }
        .role-card-title {
          font-family: var(--font-display);
          font-weight: 600;
          font-size: 24px;
          line-height: 1.2;
          letter-spacing: -0.01em;
          color: var(--fg-primary);
          position: relative; z-index: 1;
        }
        .role-card-arrow {
          color: var(--fg-tertiary);
          position: relative; z-index: 1;
          transition: transform var(--duration-base) var(--ease-out), color var(--duration-base) var(--ease-out);
        }
        .role-card:hover .role-card-arrow { transform: translateX(6px); color: var(--neon); }
        .role-card-customer:hover .role-card-arrow { color: var(--neon-cyan); }

        .home-right {
          position: relative;
          display: grid;
          place-items: center;
          min-width: 0;
        }
        .hero-frame {
          position: relative;
          width: 100%;
          aspect-ratio: 1672 / 941;
          max-width: 720px;
          border-radius: var(--radius-lg);
          overflow: hidden;
          box-shadow: 0 24px 60px rgba(0,0,0,0.4), 0 0 60px rgba(124,111,247,0.15);
          border: 1px solid var(--border-default);
        }
        .hero-frame img {
          width: 100%; height: 100%;
          object-fit: cover;
          display: block;
        }
        .hero-corner {
          position: absolute;
          width: 18px; height: 18px;
          border-color: var(--neon);
          border-style: solid;
          border-width: 0;
          opacity: 0.7;
        }
        .hero-corner-tl { top: 10px; left: 10px; border-top-width: 1.5px; border-left-width: 1.5px; }
        .hero-corner-tr { top: 10px; right: 10px; border-top-width: 1.5px; border-right-width: 1.5px; }
        .hero-corner-bl { bottom: 10px; left: 10px; border-bottom-width: 1.5px; border-left-width: 1.5px; }
        .hero-corner-br { bottom: 10px; right: 10px; border-bottom-width: 1.5px; border-right-width: 1.5px; }

        .home-callout {
          position: absolute;
          background: var(--bg-overlay);
          backdrop-filter: blur(12px);
          -webkit-backdrop-filter: blur(12px);
          border: 1px solid var(--border-default);
          border-radius: var(--radius-pill);
          padding: 6px 14px;
          display: flex; align-items: center; gap: 10px;
        }
        .home-callout-top { top: 24px; right: 24px; }
        .dot-live {
          width: 7px; height: 7px; border-radius: 50%;
          background: var(--neon);
          box-shadow: 0 0 10px var(--neon);
          animation: pulse 1.8s ease-in-out infinite;
        }

        @media (max-width: 880px) {
          .home-grid { grid-template-columns: 1fr; padding: 24px; gap: 24px; }
          .home-right { order: -1; }
          .hero-frame { max-width: 100%; }
          .home-roles { max-width: 100%; }
        }
      `}</style>
    </div>
  );
}

window.HomePage = HomePage;
