// App shell — routing + global state + Tweaks panel

const { useState, useEffect } = React;

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "mood": "frustrated",
  "theme": "dark",
  "lang": "en"
}/*EDITMODE-END*/;

function App() {
  const [route, setRoute] = useState(() => {
    const h = window.location.hash.replace('#', '');
    return ['home', 'customer', 'employee'].includes(h) ? h : 'home';
  });
  const [t, setT] = useTweaks(TWEAK_DEFAULTS);

  useEffect(() => {
    const onHash = () => {
      const h = window.location.hash.replace('#', '') || 'home';
      if (['home', 'customer', 'employee'].includes(h)) setRoute(h);
    };
    window.addEventListener('hashchange', onHash);
    return () => window.removeEventListener('hashchange', onHash);
  }, []);

  useEffect(() => {
    document.documentElement.dataset.theme = t.theme;
  }, [t.theme]);

  const goTo = (r) => {
    window.location.hash = r;
    setRoute(r);
  };

  const tx = (en, ar) => (t.lang === 'ar' ? ar : en);

  return (
    <div className="shell" dir={t.lang === 'ar' ? 'rtl' : 'ltr'}>
      <div className="bg-stage" />

      {/* —— App bar —— */}
      <header className="appbar">
        <div className="appbar-brand" onClick={() => goTo('home')}>
          <div className="brand-mark">
            <BrandMark />
          </div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
            <span className="brand-word">ظل</span>
            <span className="brand-tag">SHADOW</span>
          </div>
        </div>

        <div className="appbar-meta">
          {route !== 'home' && (
            <div className="meta-chunk">
              <span className="dot"></span>
              <span>
                {route === 'employee'
                  ? tx('AGENT COCKPIT · LIVE', 'موظف · مباشر')
                  : tx('CALL IN PROGRESS', 'مكالمة جارية')}
              </span>
            </div>
          )}
          {route !== 'home' && (
            <button className="role-back" onClick={() => goTo('home')}>
              ← {tx('Switch role', 'تغيير الدور')}
            </button>
          )}
          <button
            className="lang-toggle"
            onClick={() => setT('lang', t.lang === 'en' ? 'ar' : 'en')}
            title="Language"
          >
            {t.lang === 'en' ? 'EN' : 'AR'}
          </button>
          <button
            className="theme-toggle"
            onClick={() => setT('theme', t.theme === 'dark' ? 'light' : 'dark')}
            title="Theme"
          >
            {t.theme === 'dark' ? '◐ DARK' : '◑ LIGHT'}
          </button>
        </div>
      </header>

      {/* —— Page —— */}
      {route === 'home' && <HomePage lang={t.lang} goTo={goTo} />}
      {route === 'customer' && <CustomerPage lang={t.lang} mood={t.mood} />}
      {route === 'employee' && <EmployeePage lang={t.lang} mood={t.mood} key={t.mood + t.lang} />}

      {/* —— Tweaks —— */}
      <TweaksPanel title="Tweaks">
        <TweakSection label="Demo">
          <TweakRadio
            label="Customer mood"
            value={t.mood}
            onChange={(v) => setT('mood', v)}
            options={[
              { value: 'calm', label: 'Calm' },
              { value: 'frustrated', label: 'Frustrated' },
            ]}
          />
          <TweakRadio
            label="Theme"
            value={t.theme}
            onChange={(v) => setT('theme', v)}
            options={[
              { value: 'dark', label: 'Dark' },
              { value: 'light', label: 'Light' },
            ]}
          />
          <TweakRadio
            label="Language"
            value={t.lang}
            onChange={(v) => setT('lang', v)}
            options={[
              { value: 'en', label: 'English' },
              { value: 'ar', label: 'عربي' },
            ]}
          />
        </TweakSection>
        <TweakSection label="Jump to screen">
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            <TweakButton label="Home" onClick={() => goTo('home')} />
            <TweakButton label="Customer" onClick={() => goTo('customer')} />
            <TweakButton label="Employee" onClick={() => goTo('employee')} />
          </div>
        </TweakSection>
      </TweaksPanel>
    </div>
  );
}

function BrandMark() {
  // Z-glyph that doubles as a shadow projection
  return (
    <svg viewBox="0 0 32 32" fill="none">
      <defs>
        <linearGradient id="zgrad" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="var(--neon)" />
          <stop offset="100%" stopColor="var(--neon-cyan)" />
        </linearGradient>
      </defs>
      <path d="M 6 6 H 26 L 8 26 H 26" stroke="url(#zgrad)" strokeWidth="2.5" strokeLinecap="square" strokeLinejoin="miter" fill="none" />
      <path d="M 8 8 H 24 L 10 24 H 24" stroke="var(--neon)" strokeOpacity="0.25" strokeWidth="1" fill="none" transform="translate(2 2)" />
    </svg>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
