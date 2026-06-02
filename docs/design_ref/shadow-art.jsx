// Agent-with-robot-shadow hero illustration
// Two figures stand on a horizon line: human agent in the front, robot shadow cast behind/beside,
// projected as if the agent's silhouette were a robot all along.

function ShadowArt({ size }) {
  return (
    <svg
      viewBox="0 0 560 560"
      width={size}
      height={size}
      style={{ display: 'block', width: size ? undefined : '100%', height: size ? undefined : 'auto' }}
      preserveAspectRatio="xMidYMid meet"
      aria-label="An agent and their robot shadow"
    >
      <defs>
        <linearGradient id="shadowGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="var(--neon)" stopOpacity="0.85" />
          <stop offset="100%" stopColor="var(--neon)" stopOpacity="0.15" />
        </linearGradient>
        <linearGradient id="agentGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="var(--fg-primary)" stopOpacity="1" />
          <stop offset="100%" stopColor="var(--fg-primary)" stopOpacity="0.85" />
        </linearGradient>
        <radialGradient id="floorGlow" cx="50%" cy="50%">
          <stop offset="0%" stopColor="var(--neon)" stopOpacity="0.5" />
          <stop offset="100%" stopColor="var(--neon)" stopOpacity="0" />
        </radialGradient>
        <filter id="glow" x="-30%" y="-30%" width="160%" height="160%">
          <feGaussianBlur stdDeviation="3" result="blur" />
          <feMerge>
            <feMergeNode in="blur" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      {/* Soft floor glow under both figures */}
      <ellipse cx="280" cy="500" rx="220" ry="22" fill="url(#floorGlow)" />

      {/* Horizon scan line */}
      <line x1="20" y1="498" x2="540" y2="498" stroke="var(--neon)" strokeOpacity="0.35" strokeWidth="1" strokeDasharray="2 4" />

      {/* ——— ROBOT SHADOW (behind, skewed, projected) ——— */}
      <g transform="translate(360, 100) skewX(-18) scale(0.95)" opacity="0.9" filter="url(#glow)">
        {/* Head — square w/ antenna and eye-strip */}
        <rect x="38" y="20" width="62" height="58" rx="6" fill="none" stroke="var(--neon)" strokeWidth="1.5" />
        <line x1="69" y1="20" x2="69" y2="6" stroke="var(--neon)" strokeWidth="1.5" />
        <circle cx="69" cy="3" r="3" fill="var(--neon)" />
        {/* Eye strip */}
        <rect x="48" y="40" width="42" height="8" fill="var(--neon)" opacity="0.9" />
        <rect x="48" y="40" width="42" height="8" fill="none" stroke="var(--neon)" strokeWidth="0.5" />
        {/* Headset over ear */}
        <path d="M 32 36 Q 32 28 38 28" fill="none" stroke="var(--neon)" strokeWidth="1.5" />
        <rect x="28" y="34" width="10" height="14" rx="3" fill="var(--neon)" opacity="0.4" />
        <line x1="38" y1="48" x2="44" y2="62" stroke="var(--neon)" strokeWidth="1.5" />
        {/* Neck */}
        <rect x="60" y="78" width="18" height="10" fill="none" stroke="var(--neon)" strokeWidth="1.5" />
        {/* Body — segmented panels */}
        <rect x="20" y="88" width="100" height="120" rx="4" fill="none" stroke="var(--neon)" strokeWidth="1.5" />
        <line x1="20" y1="118" x2="120" y2="118" stroke="var(--neon)" strokeWidth="1" strokeOpacity="0.5" />
        {/* Chest indicator */}
        <circle cx="70" cy="135" r="6" fill="var(--neon)" opacity="0.9" />
        <circle cx="70" cy="135" r="10" fill="none" stroke="var(--neon)" strokeWidth="1" strokeOpacity="0.5" />
        {/* Hex shoulder cap */}
        <path d="M 20 92 L 8 100 L 8 120 L 20 128 Z" fill="none" stroke="var(--neon)" strokeWidth="1.5" />
        {/* Arm hint */}
        <rect x="2" y="120" width="10" height="60" rx="3" fill="none" stroke="var(--neon)" strokeWidth="1.5" />
        {/* Body grid */}
        <line x1="40" y1="150" x2="100" y2="150" stroke="var(--neon)" strokeWidth="0.5" strokeOpacity="0.4" />
        <line x1="40" y1="170" x2="100" y2="170" stroke="var(--neon)" strokeWidth="0.5" strokeOpacity="0.4" />
        <line x1="40" y1="190" x2="100" y2="190" stroke="var(--neon)" strokeWidth="0.5" strokeOpacity="0.4" />
        {/* Lower torso fade */}
        <rect x="36" y="208" width="68" height="80" rx="3" fill="url(#shadowGrad)" opacity="0.5" />
      </g>

      {/* ——— AGENT (foreground, solid silhouette) ——— */}
      <g transform="translate(140, 130)">
        {/* Head */}
        <circle cx="100" cy="60" r="44" fill="url(#agentGrad)" />
        {/* Headset band */}
        <path d="M 56 50 Q 100 4 144 50" fill="none" stroke="var(--fg-primary)" strokeWidth="6" strokeLinecap="round" />
        {/* Ear cup */}
        <ellipse cx="56" cy="58" rx="10" ry="14" fill="var(--neon)" />
        <ellipse cx="56" cy="58" rx="10" ry="14" fill="none" stroke="var(--bg-base)" strokeWidth="2" />
        {/* Boom mic */}
        <path d="M 56 70 Q 50 90 78 96" fill="none" stroke="var(--fg-primary)" strokeWidth="4" strokeLinecap="round" />
        <circle cx="78" cy="96" r="5" fill="var(--neon)" />
        {/* Neck */}
        <rect x="86" y="100" width="28" height="22" fill="url(#agentGrad)" />
        {/* Shoulders / shirt — open collar */}
        <path d="M 20 200 Q 20 140 70 124 L 100 138 L 130 124 Q 180 140 180 200 L 180 240 L 20 240 Z" fill="url(#agentGrad)" />
        {/* Collar V */}
        <path d="M 70 124 L 100 168 L 130 124 L 100 140 Z" fill="var(--bg-base)" opacity="0.45" />
        {/* Lanyard / badge cord */}
        <path d="M 76 138 L 100 220 L 124 138" fill="none" stroke="var(--neon)" strokeWidth="1.5" strokeOpacity="0.7" />
        <rect x="92" y="218" width="16" height="22" rx="2" fill="var(--neon)" />
        <rect x="94" y="222" width="12" height="2" fill="var(--bg-base)" opacity="0.6" />
        <rect x="94" y="227" width="8" height="2" fill="var(--bg-base)" opacity="0.6" />
      </g>

      {/* Connecting whisper lines from agent to shadow */}
      <g opacity="0.5">
        <path d="M 215 180 Q 320 160 380 180" fill="none" stroke="var(--neon)" strokeWidth="1" strokeDasharray="1 3" />
        <path d="M 220 220 Q 320 210 380 230" fill="none" stroke="var(--neon)" strokeWidth="1" strokeDasharray="1 3" />
      </g>

      {/* Telemetry brackets */}
      <g fontFamily="var(--font-mono)" fontSize="9" fill="var(--neon)" letterSpacing="1.5">
        <text x="372" y="86">[ SHADOW.ZL ]</text>
        <text x="372" y="98" opacity="0.6">v1.0 · LISTENING</text>
        <text x="148" y="118" fill="var(--fg-tertiary)">AGENT_07</text>
      </g>

      {/* Corner ticks */}
      <g stroke="var(--neon)" strokeWidth="1" opacity="0.4" fill="none">
        <path d="M 16 16 L 16 36 M 16 16 L 36 16" />
        <path d="M 544 16 L 544 36 M 544 16 L 524 16" />
        <path d="M 16 544 L 16 524 M 16 544 L 36 544" />
        <path d="M 544 544 L 544 524 M 544 544 L 524 544" />
      </g>
    </svg>
  );
}

window.ShadowArt = ShadowArt;
