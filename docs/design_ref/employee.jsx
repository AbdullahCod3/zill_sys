// Employee page — primary view is a CALL. "Get Answer" reveals chat + 3 options (one recommended).

function EmployeePage({ lang, mood }) {
  const t = (en, ar) => (lang === 'ar' ? ar : en);
  const isFrustrated = mood === 'frustrated';

  // 'waiting' → 'incoming' → 'connected'
  const [phase, setPhase] = React.useState('waiting');
  const [seconds, setSeconds] = React.useState(0);
  const [muted, setMuted] = React.useState(false);
  const [speakerOn, setSpeakerOn] = React.useState(true);
  const [ended, setEnded] = React.useState(false);
  const [answerOpen, setAnswerOpen] = React.useState(false);
  const [loadingAnswer, setLoadingAnswer] = React.useState(false);
  const [picked, setPicked] = React.useState(null);
  const [round, setRound] = React.useState(0);

  // waiting → incoming after 2s
  React.useEffect(() => {
    if (phase !== 'waiting') return;
    const id = setTimeout(() => setPhase('incoming'), 2000);
    return () => clearTimeout(id);
  }, [phase]);

  // Call timer only when connected
  React.useEffect(() => {
    if (phase !== 'connected' || ended) return;
    const id = setInterval(() => setSeconds((s) => s + 1), 1000);
    return () => clearInterval(id);
  }, [phase, ended]);

  const answerCall = () => {
    setSeconds(0);
    setEnded(false);
    setAnswerOpen(false);
    setPicked(null);
    setRound(0);
    setPhase('connected');
  };
  const rejectCall = () => {
    // back to waiting for the next call
    setPhase('waiting');
    setAnswerOpen(false);
    setPicked(null);
  };
  const endCall = () => {
    setEnded(true);
    // brief pause then back to waiting
    setTimeout(() => {
      setPhase('waiting');
      setAnswerOpen(false);
      setPicked(null);
      setEnded(false);
    }, 1400);
  };

  const fmt = (s) => `${Math.floor(s / 60).toString().padStart(2, '0')}:${(s % 60).toString().padStart(2, '0')}`;

  const transcript = [
    {
      who: 'customer',
      text: isFrustrated
        ? t(
            "This is the third time I'm calling this week. My internet has been down since 7am, and you charged me for a premium plan I never asked for.",
            'هذه ثالث مرّة أتصل بها هذا الأسبوع. الإنترنت معطّل عندي منذ السابعة صباحاً، وفوق ذلك خصمتم منّي رسوم باقة مميّزة لم أطلبها.'
          )
        : t(
            "Hi, my internet has been down since this morning, and I noticed an unexpected charge for a premium plan on my bill.",
            'مرحباً، الإنترنت معطّل عندي منذ هذا الصباح، ولاحظت أيضاً رسوماً غير متوقّعة لباقة مميّزة في فاتورتي.'
          ),
    },
    {
      who: 'agent',
      text: t("I'm sorry to hear that. Let me pull up your account…", 'آسف لسماع ذلك. دعني أتحقّق من حسابك…'),
    },
    // Follow-up appears only after the agent dismisses the first set of replies
    ...(round >= 1 ? [{
      who: 'customer',
      text: isFrustrated
        ? t(
            "A credit isn't enough — I lost a whole morning of work because of this. What are you actually going to do for me?",
            'الرصيد لا يكفي — خسرت صباحاً كاملاً من العمل بسبب هذا. ما الذي ستفعلونه فعلاً من أجلي؟'
          )
        : t(
            "Okay, but I also work from home, so the outage is a real problem for me today. Is there anything you can do right now?",
            'حسناً، لكنّي أعمل من المنزل، فالانقطاع مشكلة حقيقية لي اليوم. هل هناك ما يمكنك فعله الآن؟'
          ),
    }] : []),
  ];

  const recsByRound = [
    // —— Round 0 ——
    [
      {
        id: 'r1',
        tier: 'recommended',
        tag: t('Resolve billing & confirm outage', 'حلّ الفاتورة وتأكيد الانقطاع'),
        text: t(
          "I'm sorry for both issues. There's an active outage in your area that should be resolved within two hours — I'll add a credit for the downtime. As for the premium charge, that was auto-applied from a promo that ended last month. I'm reversing it now and the refund will hit your account within 24 hours.",
          'آسف على المشكلتين. هناك انقطاع نشط في منطقتك وسيتم إصلاحه خلال ساعتين — سأقيّد لك رصيداً للانقطاع. أمّا رسوم الباقة المميّزة فقد فُعّلت تلقائياً بعد عرض ترويجي انتهى الشهر الماضي. أعكس العملية الآن وسيصل الاسترداد إلى حسابك خلال 24 ساعة.'
        ),
      },
      {
        id: 'r2',
        tier: 'likely',
        tag: t('Acknowledge & confirm outage', 'تأكيد وانقطاع الخدمة'),
        text: t(
          "I completely understand your frustration, and I'm sorry for the disruption. I'm checking your area now — yes, there's an active fiber outage in your neighborhood, expected to be resolved within the next two hours. I'll apply a service credit to your account right away.",
          'أتفهّم انزعاجك تماماً، وأعتذر عن هذا الانقطاع. أتحقّق من منطقتك الآن — نعم، هناك انقطاع نشط في شبكة الألياف في حيّك، ومن المتوقّع إصلاحه خلال ساعتين. سأقيّد لك رصيد خدمة الآن.'
        ),
      },
      {
        id: 'r3',
        tier: 'maybe',
        tag: t('Goodwill retention offer', 'عرض احتفاظ ودّي'),
        text: t(
          "I want to make this completely right. Beyond reversing the premium charge, I'd like to apply a 30% discount on your next three bills and personally follow up tomorrow once the outage is resolved to make sure everything is stable. Would that work for you?",
          'أريد أن أصلح الأمر كلّياً. إضافةً إلى إلغاء رسوم الباقة، أودّ منحك خصم 30٪ على فواتيرك الثلاث القادمة، وسأتابع معك شخصياً غداً للتأكّد من استقرار الاتصال. هل يناسبك ذلك؟'
        ),
      },
    ],
    // —— Round 1 (after DON'T USE: re-read the new transcript) ——
    [
      {
        id: 'r4',
        tier: 'recommended',
        tag: t('Offer instant 4G backup', 'تفعيل بديل 4G فوري'),
        text: t(
          "Since you work from home, let me get you online right now — I can activate a free 4G backup hotspot on your account that starts within five minutes and runs until the fiber is restored. I'll also waive this month's fee entirely, not just credit it.",
          'بما أنّك تعمل من المنزل، دعني أعيدك للإنترنت الآن — يمكنني تفعيل نقطة اتصال 4G احتياطية مجاناً تبدأ خلال خمس دقائق وتستمرّ حتى عودة الألياف. وسأعفيك من رسوم هذا الشهر بالكامل، وليس مجرّد رصيد.'
        ),
      },
      {
        id: 'r5',
        tier: 'likely',
        tag: t('Escalate with priority repair', 'تصعيد مع إصلاح ذي أولوية'),
        text: t(
          "I hear you — this cost you real working hours. I'm flagging your line for priority repair so a technician reaches your area first, and I'll stay on top of it personally. You'll get an SMS the moment service is back.",
          'أتفهّمك — لقد كلّفك هذا ساعات عمل حقيقية. سأضع خطّك ضمن أولوية الإصلاح ليصل الفنّي إلى منطقتك أوّلاً، وسأتابع الأمر بنفسي. ستصلك رسالة فور عودة الخدمة.'
        ),
      },
      {
        id: 'r6',
        tier: 'maybe',
        tag: t('Compensate with bonus credit', 'تعويض برصيد إضافي'),
        text: t(
          "To make up for the lost morning, I'd like to add two months at 50% off on top of fixing today's issue. It won't give you the time back, but it's the strongest goodwill I can offer on the spot.",
          'تعويضاً عن صباحك الضائع، أودّ إضافة شهرين بخصم 50٪ إلى جانب حلّ مشكلة اليوم. لن يعيد لك الوقت، لكنّه أقصى ما أستطيع تقديمه الآن كبادرة حسن نيّة.'
        ),
      },
    ],
  ];

  const recs = recsByRound[Math.min(round, recsByRound.length - 1)];

  const TIERS = {
    recommended: { label: t('Recommended', 'موصى به'), tone: 'primary' },
    likely:      { label: t('More likely', 'الأرجح'), tone: 'cyan' },
    maybe:       { label: t('Maybe', 'ربّما'), tone: 'amber' },
  };

  const requestAnswer = () => {
    if (answerOpen) {
      setAnswerOpen(false);
      return;
    }
    setLoadingAnswer(true);
    setAnswerOpen(true);
    setTimeout(() => setLoadingAnswer(false), 1200);
  };

  // "Don't use" — agent rejects the current set; Shadow re-reads the new
  // transcript line and composes a fresh set of replies.
  const dontUse = () => {
    setPicked(null);
    setLoadingAnswer(true);
    setRound((r) => r + 1);
    setTimeout(() => setLoadingAnswer(false), 1400);
  };

  return (
    <div className="page emp">
      {phase === 'waiting' && (
        <div className="emp-waiting">
          <div className="wait-status">
            <span className="wait-dot"></span>
            <span>{t('Online · ready to receive', 'متّصل · جاهز للاستقبال')}</span>
          </div>
          <div className="wait-icon">
            <div className="wait-icon-pulse"></div>
            <div className="wait-icon-pulse pulse-2"></div>
            <svg viewBox="0 0 32 32" width="40" height="40" fill="none" stroke="currentColor" strokeWidth="1.6">
              <path d="M22 20.9l-2.8-.4a1.5 1.5 0 0 0-1.4.6l-2 2.6a13 13 0 0 1-6.5-6.5l2.6-2a1.5 1.5 0 0 0 .6-1.4L11.1 11A1.5 1.5 0 0 0 9.6 9.7H7a1.5 1.5 0 0 0-1.5 1.6 17 17 0 0 0 15.6 15.6 1.5 1.5 0 0 0 1.6-1.5v-2.6a1.5 1.5 0 0 0-1.3-1.5z" />
            </svg>
          </div>
          <h2 className="wait-title">{t('Waiting for calls', 'في انتظار المكالمات')}</h2>
          <p className="wait-sub">{t('The next customer will appear here automatically.', 'سيظهر العميل القادم هنا تلقائياً.')}</p>

          <div className="wait-stats">
            <div><div className="wait-stat-num">12</div><div className="wait-stat-lbl">{t('Today', 'اليوم')}</div></div>
            <div><div className="wait-stat-num">02:14</div><div className="wait-stat-lbl">{t('Avg. handle', 'متوسّط المعالجة')}</div></div>
            <div><div className="wait-stat-num">96%</div><div className="wait-stat-lbl">{t('CSAT', 'الرضا')}</div></div>
          </div>
        </div>
      )}

      {phase === 'incoming' && (
        <div className="emp-incoming">
          <div className="incoming-card">
            <div className="incoming-label">
              <span className="incoming-dot"></span>
              <span>{t('Incoming call', 'مكالمة واردة')}</span>
            </div>

            <div className="incoming-avatar">
              <div className="incoming-ring ring1"></div>
              <div className="incoming-ring ring2"></div>
              <div className="incoming-ring ring3"></div>
              <div className="incoming-avatar-core">
                <svg viewBox="0 0 80 80" width="64" height="64">
                  <circle cx="40" cy="32" r="14" fill="#fff" opacity="0.85" />
                  <path d="M 14 80 Q 14 50 40 50 Q 66 50 66 80 Z" fill="#fff" opacity="0.85" />
                </svg>
              </div>
            </div>

            <div className="incoming-name">Layla Hassan</div>
            <div className="incoming-meta">+966 5• ••• 4731 · {t('Customer · 3 yrs', 'عميل · 3 سنوات')}</div>

            <div className="incoming-actions">
              <button className="inc-btn inc-btn-reject" onClick={rejectCall}>
                <span className="inc-btn-icon">
                  <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor" style={{ transform: 'rotate(135deg)' }}>
                    <path d="M21 15.5l-2.4-.5a1 1 0 0 1-.8-1L17.6 12a11 11 0 0 0-11.2 0l-.2 2a1 1 0 0 1-.8 1L3 15.5a1 1 0 0 1-1.2-.7c-1.2-3.6 4.2-7.8 10.2-7.8s11.4 4.2 10.2 7.8a1 1 0 0 1-1.2.7z" />
                  </svg>
                </span>
                <span>{t('Reject', 'رفض')}</span>
              </button>
              <button className="inc-btn inc-btn-answer" onClick={answerCall}>
                <span className="inc-btn-icon">
                  <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor">
                    <path d="M21 15.5l-2.4-.5a1 1 0 0 1-.8-1L17.6 12a11 11 0 0 0-11.2 0l-.2 2a1 1 0 0 1-.8 1L3 15.5a1 1 0 0 1-1.2-.7c-1.2-3.6 4.2-7.8 10.2-7.8s11.4 4.2 10.2 7.8a1 1 0 0 1-1.2.7z" />
                  </svg>
                </span>
                <span>{t('Answer', 'ردّ')}</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {phase === 'connected' && <>
      {/* TOP STRIP — customer + call meta */}
      <div className="emp-top">
        <div className="emp-cust">
          <div className="emp-cust-av">
            <svg viewBox="0 0 40 40" width="40" height="40">
              <circle cx="20" cy="16" r="7" fill="currentColor" opacity="0.7" />
              <path d="M 7 40 Q 7 25 20 25 Q 33 25 33 40 Z" fill="currentColor" opacity="0.7" />
            </svg>
          </div>
          <div>
            <div className="emp-cust-name">Layla Hassan</div>
            <div className="emp-cust-sub">ZL-447-2210 · {t('Fiber Pro 500', 'فايبر برو 500')}</div>
          </div>
        </div>

        <div className="emp-region">
          <span className="emp-region-icon">
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.6">
              <path d="M12 21s-7-5.5-7-11a7 7 0 0 1 14 0c0 5.5-7 11-7 11z" />
              <circle cx="12" cy="10" r="2.5" />
            </svg>
          </span>
          <div>
            <div className="emp-region-city">{t('Riyadh, Al Olaya', 'الرياض، العليا')}</div>
            <div className="emp-region-sub">{t('Region · Zone 14-B', 'المنطقة · القطاع 14-B')}</div>
          </div>
        </div>

        <div className="emp-issue">
          <span className="amber-dot"></span>
          <span>{t('Internet outage + disputed premium charge', 'انقطاع إنترنت + اعتراض على رسوم')}</span>
        </div>

        <div className="emp-timer">
          <span className="bars"><span/><span/><span/><span/><span/></span>
          <span className="emp-timer-time">{fmt(seconds)}</span>
        </div>
      </div>

      {/* MAIN GRID */}
      <div className={`emp-grid ${answerOpen ? 'emp-grid-open' : ''}`}>
        {/* CALL VIEW */}
        <div className="emp-call">
          <div className="call-stage">
            <div className="cust-rings">
              <div className="ring r1"></div>
              <div className="ring r2"></div>
              <div className="ring r3"></div>
            </div>
            <div className="call-avatar">
              <svg viewBox="0 0 80 80" width="80" height="80">
                <circle cx="40" cy="32" r="14" fill="#fff" opacity="0.85" />
                <path d="M 14 80 Q 14 50 40 50 Q 66 50 66 80 Z" fill="#fff" opacity="0.85" />
              </svg>
            </div>
          </div>

          <div className="call-name">Layla Hassan</div>
          <div className="call-status">
            <span className="bars"><span/><span/><span/><span/><span/></span>
            <span>{ended ? t('Call ended', 'انتهت المكالمة') : t('On call', 'مكالمة جارية')} · {fmt(seconds)}</span>
          </div>

          {/* Live waveform */}
          <div className="waveform">
            {Array.from({ length: 48 }).map((_, i) => (
              <span key={i} style={{ animationDelay: `${(i % 12) * 80}ms`, height: `${20 + (i % 7) * 8}%` }} />
            ))}
          </div>

          <div className="call-controls">
            <button
              className={`call-ctl ${muted ? 'call-ctl-on' : ''}`}
              onClick={() => setMuted((m) => !m)}
              title={muted ? t('Unmute', 'إلغاء الكتم') : t('Mute', 'كتم')}
            >
              <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" strokeWidth="1.8">
                <rect x="9" y="3" width="6" height="12" rx="3" />
                <path d="M5 11a7 7 0 0 0 14 0" />
                <path d="M12 18v3" />
                {muted && <line x1="3" y1="3" x2="21" y2="21" stroke="currentColor" strokeWidth="2" />}
              </svg>
              <span>{muted ? t('Muted', 'مكتوم') : t('Mute', 'كتم')}</span>
            </button>

            <button
              className={`call-ctl ${speakerOn ? 'call-ctl-on' : ''}`}
              onClick={() => setSpeakerOn((s) => !s)}
            >
              <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" strokeWidth="1.8">
                <path d="M4 9v6h4l5 4V5L8 9H4z" />
                <path d="M17 8a5 5 0 0 1 0 8" />
              </svg>
              <span>{t('Speaker', 'مكبر')}</span>
            </button>

            <button className="call-ctl" title={t('Hold', 'انتظار')}>
              <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" strokeWidth="1.8">
                <rect x="6" y="5" width="4" height="14" rx="1" />
                <rect x="14" y="5" width="4" height="14" rx="1" />
              </svg>
              <span>{t('Hold', 'انتظار')}</span>
            </button>

            <button className="call-end" onClick={endCall}>
              <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor" style={{ transform: 'rotate(135deg)' }}>
                <path d="M21 15.5l-2.4-.5a1 1 0 0 1-.8-1L17.6 12a11 11 0 0 0-11.2 0l-.2 2a1 1 0 0 1-.8 1L3 15.5a1 1 0 0 1-1.2-.7c-1.2-3.6 4.2-7.8 10.2-7.8s11.4 4.2 10.2 7.8a1 1 0 0 1-1.2.7z" />
              </svg>
              <span>{t('End', 'إنهاء')}</span>
            </button>
          </div>
        </div>

        {/* RIGHT SIDE — Get Answer or split (chat + options) */}
        <div className="emp-right">
          {!answerOpen ? (
            <div className="answer-empty">
              <div className="answer-empty-orb">
                <div className="orb-pulse"></div>
                <svg viewBox="0 0 32 32" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="1.5">
                  <path d="M16 4 C 9 4 4 9 4 16 C 4 21 7 24 11 26 L 10 30 L 15 27 C 25 27 28 22 28 16 C 28 9 23 4 16 4 Z" />
                  <circle cx="11" cy="16" r="1.5" fill="currentColor" />
                  <circle cx="16" cy="16" r="1.5" fill="currentColor" />
                  <circle cx="21" cy="16" r="1.5" fill="currentColor" />
                </svg>
              </div>
              <div className="answer-empty-title">{t('Need a reply?', 'تحتاج إلى ردّ؟')}</div>
              <button className="get-answer-btn" onClick={requestAnswer}>
                <span className="get-answer-dot"></span>
                <span>{t('Get Answer', 'احصل على ردّ')}</span>
                <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
                  <path d="M0 6 H13 M9 1 L14 6 L9 11" stroke="currentColor" strokeWidth="1.8" />
                </svg>
              </button>
            </div>
          ) : (
            <div className="answer-open">
              <div className="answer-open-head">
                <div>
                  <div className="answer-open-title">
                    {loadingAnswer
                      ? (round >= 1 ? t('Re-reading the call…', 'إعادة قراءة المكالمة…') : t('Composing answers…', 'جارٍ صياغة الردود…'))
                      : t('Pick a reply', 'اختر الردّ')}
                  </div>
                  <div className="answer-open-sub">
                    {loadingAnswer
                      ? t('Shadow is analysing the call', 'يحلّل زِل المكالمة')
                      : t('Ranked by fit — recommended, more likely, then maybe', 'مرتّبة حسب الملاءمة — موصى به، الأرجح، ثمّ ربّما')}
                  </div>
                </div>
                <button className="get-answer-btn small" onClick={requestAnswer}>
                  <span>{t('Close', 'إغلاق')}</span>
                </button>
              </div>

              {loadingAnswer ? (
                <div className="loading-bar"><span></span></div>
              ) : (
                <div className="answer-body">
                  {/* CHAT */}
                  <div className="chat-col">
                    <div className="chat-col-head">{t('Live transcript', 'النصّ المباشر')}</div>
                    <div className="bubbles scroll">
                      {transcript.map((b, i) => (
                        <div key={i} className={`bubble bubble-${b.who}`}>
                          <div className="bubble-who">
                            {b.who === 'customer' ? 'Layla' : t('You', 'أنت')}
                          </div>
                          <div className="bubble-text">{b.text}</div>
                        </div>
                      ))}
                      <div className="bubble bubble-customer bubble-listening">
                        <div className="bubble-who">Layla</div>
                        <div className="bubble-text"><span className="dots"><span/><span/><span/></span></div>
                      </div>
                    </div>
                  </div>

                  {/* OPTIONS */}
                  <div className="opts-col">
                    <div className="chat-col-head">
                      {t('Suggested replies', 'الردود المقترحة')}
                      {round >= 1 && <span className="opts-round">{t('Updated', 'محدّثة')}</span>}
                    </div>
                    <div className="opts scroll">
                      {recs.map((r, i) => {
                        const isPicked = picked === r.id;
                        const tier = TIERS[r.tier];
                        return (
                          <div
                            key={r.id}
                            className={`opt opt-${tier.tone} opt-tier-${r.tier} ${isPicked ? 'opt-picked' : ''}`}
                            onClick={() => setPicked(r.id)}
                            role="button"
                          >
                            <div className="opt-head">
                              <span className={`opt-badge opt-badge-${r.tier}`}>
                                {r.tier === 'recommended' && (
                                  <svg width="10" height="10" viewBox="0 0 10 10" fill="currentColor">
                                    <path d="M5 0 L6.2 3.5 L10 3.8 L7 6.2 L8 10 L5 8 L2 10 L3 6.2 L0 3.8 L3.8 3.5 Z" />
                                  </svg>
                                )}
                                <span>{tier.label}</span>
                              </span>
                              <span className="opt-tag">{r.tag}</span>
                            </div>
                            <div className="opt-text">{r.text}</div>
                            {isPicked && (
                              <div className="opt-picked-bar">
                                <svg width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="2.5">
                                  <path d="M3 8l4 4 6-8" />
                                </svg>
                                <span>{t('Selected', 'تم الاختيار')}</span>
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>
                    <button className="dont-use-btn" onClick={dontUse}>
                      <svg viewBox="0 0 20 20" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="1.8">
                        <path d="M4 10a6 6 0 0 1 10-4.5L16 7M16 3v4h-4" />
                        <path d="M16 10a6 6 0 0 1-10 4.5L4 13M4 17v-4h4" />
                      </svg>
                      <span>{t("Don't use — re-read the call", 'لا تستخدم — أعِد قراءة المكالمة')}</span>
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
      </>}

      <style>{`
        .emp { padding: 16px 24px 24px; gap: 16px; }
        .emp-top {
          display: flex; align-items: center; gap: 24px;
          padding: 14px 20px;
          background: var(--bg-surface);
          border: 1px solid var(--border-default);
          border-radius: var(--radius-lg);
        }
        .emp-cust { display: flex; align-items: center; gap: 14px; }
        .emp-cust-av {
          width: 44px; height: 44px;
          border-radius: 50%;
          background: linear-gradient(135deg, var(--neon), var(--neon-cyan));
          color: var(--bg-base);
          display: grid; place-items: center;
        }
        .emp-cust-name { font-family: var(--font-display); font-size: 22px; line-height: 1.1; }
        .emp-cust-sub {
          font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.1em;
          color: var(--fg-tertiary); text-transform: uppercase; margin-top: 2px;
        }
        .emp-region {
          display: flex; align-items: center; gap: 12px;
          padding-left: 24px;
          margin-left: 4px;
          border-left: 1px solid var(--border-subtle);
        }
        .emp-region-icon {
          display: grid; place-items: center;
          width: 38px; height: 38px;
          border-radius: var(--radius-md);
          background: var(--accent-subtle);
          border: 1px solid var(--border-subtle);
          color: var(--neon);
        }
        .emp-region-city {
          font-family: var(--font-ui); font-weight: 600; font-size: 15px;
          color: var(--fg-primary); line-height: 1.2;
        }
        .emp-region-sub {
          font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.08em;
          color: var(--fg-tertiary); text-transform: uppercase; margin-top: 3px;
        }
        .emp-issue {
          flex: 1;
          display: flex; align-items: center; gap: 12px;
          padding-left: 24px;
          margin-left: 8px;
          border-left: 1px solid var(--border-subtle);
          font-size: 14px;
          color: var(--fg-secondary);
        }
        .amber-dot {
          width: 8px; height: 8px; border-radius: 50%;
          background: var(--color-amber);
          box-shadow: 0 0 10px var(--color-amber);
        }
        .emp-timer {
          display: flex; align-items: center; gap: 12px; color: var(--neon);
        }
        .emp-timer-time {
          font-family: var(--font-mono); font-size: 18px;
          letter-spacing: 0.08em; color: var(--fg-primary);
        }

        .emp-grid {
          flex: 1;
          display: grid;
          grid-template-columns: minmax(340px, 0.85fr) minmax(0, 1.4fr);
          gap: 16px;
          min-height: 620px;
          transition: grid-template-columns 400ms var(--ease-out);
        }
        .emp-grid-open { grid-template-columns: minmax(320px, 0.65fr) minmax(0, 1.6fr); }

        /* —— Call view —— */
        .emp-call {
          background: var(--bg-surface);
          border: 1px solid var(--border-default);
          border-radius: var(--radius-lg);
          padding: 32px;
          display: flex; flex-direction: column; align-items: center;
          gap: 24px;
          overflow: hidden;
          position: relative;
        }
        .emp-call::before {
          content: '';
          position: absolute; inset: 0;
          background: radial-gradient(ellipse 80% 60% at 50% 0%, var(--accent-subtle), transparent 60%);
          pointer-events: none;
        }
        .call-stage {
          position: relative;
          width: 220px; height: 220px;
          display: grid; place-items: center;
          margin-top: 12px;
          z-index: 1;
        }
        .call-avatar {
          width: 140px; height: 140px;
          border-radius: 50%;
          background: linear-gradient(135deg, var(--neon), var(--neon-cyan));
          display: grid; place-items: center;
          box-shadow: 0 0 48px rgba(124, 111, 247, 0.45);
        }
        .ring {
          position: absolute;
          border-radius: 50%;
          border: 1px solid rgba(124, 111, 247, 0.5);
          animation: ring 2.8s ease-out infinite;
        }
        .r1 { width: 160px; height: 160px; animation-delay: 0s; }
        .r2 { width: 190px; height: 190px; animation-delay: 0.8s; opacity: 0.6; }
        .r3 { width: 220px; height: 220px; animation-delay: 1.6s; opacity: 0.3; }
        @keyframes ring {
          0% { transform: scale(0.85); opacity: 0.8; }
          100% { transform: scale(1.12); opacity: 0; }
        }
        .call-name {
          font-family: var(--font-display);
          font-size: 36px;
          line-height: 1.1;
          letter-spacing: -0.01em;
          z-index: 1;
        }
        .call-status {
          display: flex; align-items: center; gap: 10px;
          font-family: var(--font-ui);
          font-size: 13px;
          color: var(--fg-secondary);
          z-index: 1;
        }
        .call-status .bars { color: var(--neon); }

        .waveform {
          display: flex; align-items: center; gap: 3px;
          height: 60px;
          width: 100%; max-width: 360px;
          z-index: 1;
          padding: 0 8px;
        }
        .waveform span {
          flex: 1;
          background: var(--neon);
          border-radius: 2px;
          opacity: 0.7;
          animation: wave 1.4s ease-in-out infinite;
          box-shadow: 0 0 6px rgba(124, 111, 247, 0.4);
        }
        @keyframes wave {
          0%, 100% { transform: scaleY(0.35); }
          50% { transform: scaleY(1); }
        }

        .call-controls {
          display: grid; grid-template-columns: repeat(4, 1fr);
          gap: 10px;
          width: 100%; max-width: 420px;
          z-index: 1;
          margin-top: auto;
        }
        .call-ctl {
          background: var(--bg-elevated);
          border: 1px solid var(--border-subtle);
          color: var(--fg-primary);
          padding: 12px 6px;
          border-radius: var(--radius-md);
          display: flex; flex-direction: column; align-items: center; gap: 6px;
          font-family: var(--font-ui); font-size: 11px;
          cursor: pointer;
          transition: all var(--duration-fast) var(--ease-out);
        }
        .call-ctl:hover { border-color: var(--neon); color: var(--neon); }
        .call-ctl-on {
          background: var(--neon);
          color: var(--color-white);
          border-color: var(--neon);
          box-shadow: var(--glow-soft);
        }
        .call-end {
          background: var(--color-danger);
          color: var(--color-white);
          border: 1px solid var(--color-danger);
          padding: 12px 6px;
          border-radius: var(--radius-md);
          display: flex; flex-direction: column; align-items: center; gap: 6px;
          font-family: var(--font-ui); font-size: 11px;
          cursor: pointer;
          transition: all var(--duration-fast) var(--ease-out);
        }
        .call-end:hover { background: #d63b3b; box-shadow: 0 0 16px rgba(232, 84, 84, 0.4); }

        /* —— Right side —— */
        .emp-right {
          background: var(--bg-surface);
          border: 1px solid var(--border-default);
          border-radius: var(--radius-lg);
          padding: 24px;
          display: flex; flex-direction: column;
          min-height: 0;
          overflow: hidden;
          position: relative;
        }

        /* Empty state */
        .answer-empty {
          flex: 1;
          display: flex; flex-direction: column; align-items: center; justify-content: center;
          gap: 24px;
          text-align: center;
          padding: 32px;
        }
        .answer-empty-orb {
          position: relative;
          width: 96px; height: 96px;
          border-radius: 50%;
          background: var(--accent-subtle);
          border: 1px solid var(--border-default);
          display: grid; place-items: center;
          color: var(--neon);
        }
        .orb-pulse {
          position: absolute; inset: -10px;
          border-radius: 50%;
          border: 1px solid var(--neon);
          opacity: 0.3;
          animation: orb 2.4s ease-out infinite;
        }
        @keyframes orb {
          0% { transform: scale(0.9); opacity: 0.5; }
          100% { transform: scale(1.25); opacity: 0; }
        }
        .answer-empty-title {
          font-family: var(--font-display);
          font-size: 32px;
          line-height: 1.1;
          color: var(--fg-primary);
        }
        .get-answer-btn {
          background: var(--neon);
          color: var(--color-white);
          border: 1px solid var(--neon);
          padding: 14px 24px;
          border-radius: var(--radius-pill);
          font-family: var(--font-ui); font-weight: 500; font-size: 16px;
          cursor: pointer;
          display: inline-flex; align-items: center; gap: 12px;
          box-shadow: var(--glow-soft);
          transition: all var(--duration-base) var(--ease-out);
        }
        .get-answer-btn:hover { box-shadow: var(--glow-neon); transform: translateY(-1px); }
        .get-answer-btn:active { transform: translateY(0) scale(0.98); }
        .get-answer-btn.small {
          padding: 8px 14px;
          font-size: 12px;
          background: transparent;
          color: var(--fg-secondary);
          border-color: var(--border-default);
          box-shadow: none;
        }
        .get-answer-btn.small:hover { color: var(--fg-primary); border-color: var(--neon); }
        .get-answer-dot {
          width: 8px; height: 8px; border-radius: 50%;
          background: var(--color-white);
          box-shadow: 0 0 8px var(--color-white);
        }

        /* Open state */
        .answer-open {
          flex: 1;
          display: flex; flex-direction: column;
          min-height: 0;
        }
        .answer-open-head {
          display: flex; align-items: flex-end; justify-content: space-between;
          gap: 16px;
          padding-bottom: 16px;
          margin-bottom: 16px;
          border-bottom: 1px solid var(--border-subtle);
        }
        .answer-open-title {
          font-family: var(--font-display);
          font-size: 26px;
          line-height: 1.1;
          color: var(--fg-primary);
        }
        .answer-open-sub {
          font-family: var(--font-ui);
          font-size: 13px;
          color: var(--fg-tertiary);
          margin-top: 4px;
        }

        .loading-bar {
          width: 240px; height: 2px; background: var(--border-subtle); border-radius: 2px;
          overflow: hidden; align-self: center; margin-top: 60px;
        }
        .loading-bar span {
          display: block; width: 40%; height: 100%;
          background: var(--neon);
          box-shadow: var(--glow-soft);
          animation: scan 1.2s ease-in-out infinite;
        }
        @keyframes scan {
          0% { transform: translateX(-100%); }
          100% { transform: translateX(350%); }
        }

        .answer-body {
          flex: 1;
          display: grid;
          grid-template-columns: minmax(0, 0.85fr) minmax(0, 1.15fr);
          gap: 18px;
          min-height: 0;
        }
        .chat-col, .opts-col {
          display: flex; flex-direction: column;
          min-height: 0;
        }
        .chat-col-head {
          font-family: var(--font-ui);
          font-size: 12px;
          font-weight: 500;
          letter-spacing: 0.08em;
          text-transform: uppercase;
          color: var(--fg-tertiary);
          margin-bottom: 12px;
        }

        /* Bubbles */
        .bubbles { flex: 1; display: flex; flex-direction: column; gap: 10px; padding-right: 4px; }
        .bubble { display: flex; flex-direction: column; gap: 4px; max-width: 95%; }
        .bubble-customer { align-self: flex-start; }
        .bubble-agent { align-self: flex-end; align-items: flex-end; }
        .bubble-who {
          font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.16em; text-transform: uppercase;
          color: var(--fg-tertiary);
        }
        .bubble-customer .bubble-who { color: var(--neon-cyan); }
        .bubble-agent .bubble-who { color: var(--neon); }
        .bubble-text {
          padding: 10px 14px;
          border-radius: 12px;
          font-size: 13px;
          line-height: 1.55;
          background: var(--bg-elevated);
          color: var(--fg-primary);
          border: 1px solid var(--border-subtle);
        }
        .bubble-agent .bubble-text {
          background: var(--accent-subtle);
          border-color: rgba(124, 111, 247, 0.25);
        }
        .bubble-listening .bubble-text {
          background: transparent;
          border-style: dashed;
        }
        .dots { display: inline-flex; gap: 5px; }
        .dots span {
          width: 6px; height: 6px; border-radius: 50%; background: var(--fg-tertiary);
          animation: typing 1.2s ease-in-out infinite;
        }
        .dots span:nth-child(2) { animation-delay: 0.15s; }
        .dots span:nth-child(3) { animation-delay: 0.3s; }
        @keyframes typing { 0%, 80%, 100% { opacity: 0.3; transform: translateY(0); } 40% { opacity: 1; transform: translateY(-3px); } }

        /* Options */
        .opts { flex: 1; display: flex; flex-direction: column; gap: 12px; padding-right: 4px; min-height: 0; overflow-y: auto; }
        .opts-round {
          margin-left: 8px;
          padding: 2px 8px;
          font-family: var(--font-ui); font-size: 10px; font-weight: 600;
          letter-spacing: 0.04em;
          color: var(--neon);
          background: var(--accent-subtle);
          border: 1px solid color-mix(in oklab, var(--neon) 40%, transparent);
          border-radius: var(--radius-pill);
          text-transform: uppercase;
        }
        .dont-use-btn {
          margin-top: 12px;
          flex-shrink: 0;
          display: flex; align-items: center; justify-content: center; gap: 10px;
          width: 100%;
          padding: 12px 16px;
          background: transparent;
          border: 1px dashed var(--border-strong);
          border-radius: var(--radius-md);
          color: var(--fg-secondary);
          font-family: var(--font-ui); font-size: 13px; font-weight: 600;
          cursor: pointer;
          transition: all var(--duration-fast) var(--ease-out);
        }
        .dont-use-btn:hover {
          border-color: var(--color-danger);
          color: var(--color-danger);
          background: var(--color-danger-subtle);
        }
        .dont-use-btn:active { transform: scale(0.98); }
        .opt {
          background: var(--bg-base);
          border: 1px solid var(--border-default);
          border-radius: var(--radius-lg);
          padding: 14px 16px;
          cursor: pointer;
          display: flex; flex-direction: column; gap: 10px;
          transition: all var(--duration-base) var(--ease-out);
          animation: optIn 400ms var(--ease-out) backwards;
          position: relative;
        }
        .opt:nth-child(1) { animation-delay: 0ms; }
        .opt:nth-child(2) { animation-delay: 100ms; }
        .opt:nth-child(3) { animation-delay: 200ms; }
        @keyframes optIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: none; } }
        .opt:hover {
          border-color: var(--neon);
          transform: translateY(-1px);
          box-shadow: 0 0 18px rgba(124, 111, 247, 0.2);
        }
        .opt-tier-recommended {
          border-color: var(--neon);
          background: linear-gradient(180deg, var(--accent-subtle), var(--bg-base) 40%);
          box-shadow: 0 0 24px rgba(124, 111, 247, 0.18);
        }
        .opt-picked {
          border-color: var(--neon);
          box-shadow: 0 0 24px rgba(124, 111, 247, 0.35) !important;
        }

        .opt-head { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .opt-tag {
          flex: 1;
          font-family: var(--font-ui); font-size: 13px; font-weight: 500;
          color: var(--fg-primary);
        }
        .opt-badge {
          display: inline-flex; align-items: center; gap: 6px;
          padding: 4px 10px;
          font-family: var(--font-ui); font-size: 11px; font-weight: 600;
          border-radius: var(--radius-pill);
          letter-spacing: 0.02em;
          white-space: nowrap;
        }
        .opt-badge-recommended {
          background: var(--neon);
          color: var(--color-white);
          box-shadow: var(--glow-soft);
        }
        .opt-badge-likely {
          background: color-mix(in oklab, var(--neon-cyan) 18%, transparent);
          color: var(--neon-cyan);
          border: 1px solid color-mix(in oklab, var(--neon-cyan) 40%, transparent);
        }
        .opt-badge-maybe {
          background: color-mix(in oklab, var(--color-amber) 16%, transparent);
          color: var(--color-amber);
          border: 1px solid color-mix(in oklab, var(--color-amber) 38%, transparent);
        }
        .opt-text {
          font-family: var(--font-ui); font-size: 13px;
          line-height: 1.55;
          color: var(--fg-secondary);
        }
        .opt-tier-recommended .opt-text { color: var(--fg-primary); }

        .opt-picked-bar {
          display: inline-flex; align-items: center; gap: 8px;
          padding: 6px 10px;
          background: var(--neon);
          color: var(--color-white);
          font-family: var(--font-ui); font-size: 12px; font-weight: 500;
          border-radius: var(--radius-md);
          align-self: flex-start;
        }

        @media (max-width: 1100px) {
          .emp-grid { grid-template-columns: 1fr; }
          .answer-body { grid-template-columns: 1fr; }
        }

        /* ——— WAITING STATE ——— */
        .emp-waiting {
          flex: 1;
          display: flex; flex-direction: column;
          align-items: center; justify-content: center;
          gap: 24px;
          padding: 32px;
          text-align: center;
        }
        .wait-status {
          display: inline-flex; align-items: center; gap: 10px;
          padding: 8px 16px;
          background: var(--bg-surface);
          border: 1px solid var(--border-default);
          border-radius: var(--radius-pill);
          font-family: var(--font-ui);
          font-size: 13px;
          font-weight: 500;
          color: var(--fg-secondary);
        }
        .wait-dot {
          width: 8px; height: 8px; border-radius: 50%;
          background: var(--color-success);
          box-shadow: 0 0 10px var(--color-success);
          animation: pulse 1.8s ease-in-out infinite;
        }
        .wait-icon {
          position: relative;
          width: 120px; height: 120px;
          border-radius: 50%;
          background: var(--accent-subtle);
          border: 1px solid var(--neon);
          display: grid; place-items: center;
          color: var(--neon);
          margin-top: 12px;
        }
        .wait-icon-pulse {
          position: absolute; inset: -8px;
          border-radius: 50%;
          border: 1px solid var(--neon);
          opacity: 0.4;
          animation: waitPulse 2.4s ease-out infinite;
        }
        .wait-icon-pulse.pulse-2 { animation-delay: 1.2s; }
        @keyframes waitPulse {
          0% { transform: scale(0.9); opacity: 0.6; }
          100% { transform: scale(1.5); opacity: 0; }
        }
        .wait-title {
          font-family: var(--font-display);
          font-weight: 700;
          font-size: 48px;
          line-height: 1.1;
          letter-spacing: -0.02em;
          color: var(--fg-primary);
          margin-top: 8px;
        }
        .wait-sub {
          font-family: var(--font-ui);
          font-size: 16px;
          color: var(--fg-secondary);
          max-width: 420px;
        }
        .wait-stats {
          display: flex; gap: 48px;
          margin-top: 24px;
          padding-top: 24px;
          border-top: 1px solid var(--border-subtle);
        }
        .wait-stat-num {
          font-family: var(--font-display);
          font-weight: 600;
          font-size: 28px;
          color: var(--fg-primary);
          line-height: 1;
        }
        .wait-stat-lbl {
          font-family: var(--font-ui);
          font-size: 12px;
          color: var(--fg-tertiary);
          margin-top: 6px;
        }

        /* ——— INCOMING CALL STATE ——— */
        .emp-incoming {
          flex: 1;
          display: flex;
          align-items: center; justify-content: center;
          padding: 32px;
        }
        .incoming-card {
          background: var(--bg-surface);
          border: 1px solid var(--neon);
          border-radius: 24px;
          padding: 36px 48px 32px;
          display: flex; flex-direction: column; align-items: center;
          gap: 18px;
          min-width: 380px;
          box-shadow: 0 0 48px rgba(124, 111, 247, 0.25), 0 24px 60px rgba(0,0,0,0.3);
          animation: incomingIn 320ms var(--ease-out);
          position: relative;
          overflow: hidden;
        }
        @keyframes incomingIn {
          from { opacity: 0; transform: scale(0.94); }
          to { opacity: 1; transform: none; }
        }
        .incoming-card::before {
          content: '';
          position: absolute; inset: 0;
          background: radial-gradient(ellipse 80% 50% at 50% 0%, var(--accent-subtle), transparent 70%);
          pointer-events: none;
        }
        .incoming-label {
          display: inline-flex; align-items: center; gap: 8px;
          padding: 6px 14px;
          background: var(--neon);
          color: var(--color-white);
          border-radius: var(--radius-pill);
          font-family: var(--font-ui);
          font-weight: 500;
          font-size: 12px;
          letter-spacing: 0.04em;
          text-transform: uppercase;
          position: relative; z-index: 1;
          box-shadow: 0 0 12px rgba(124, 111, 247, 0.5);
        }
        .incoming-dot {
          width: 7px; height: 7px; border-radius: 50%;
          background: var(--color-white);
          animation: blink 1s ease-in-out infinite;
        }
        @keyframes blink {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.3; }
        }

        .incoming-avatar {
          position: relative;
          width: 200px; height: 200px;
          display: grid; place-items: center;
          margin: 8px 0;
          z-index: 1;
        }
        .incoming-avatar-core {
          width: 110px; height: 110px;
          border-radius: 50%;
          background: linear-gradient(135deg, var(--neon), var(--neon-cyan));
          display: grid; place-items: center;
          box-shadow: 0 0 36px rgba(124, 111, 247, 0.5);
        }
        .incoming-ring {
          position: absolute;
          border-radius: 50%;
          border: 1.5px solid var(--neon);
          animation: incRing 2.2s ease-out infinite;
        }
        .incoming-ring.ring1 { width: 130px; height: 130px; }
        .incoming-ring.ring2 { width: 160px; height: 160px; animation-delay: 0.7s; }
        .incoming-ring.ring3 { width: 200px; height: 200px; animation-delay: 1.4s; }
        @keyframes incRing {
          0% { transform: scale(0.85); opacity: 0.7; }
          100% { transform: scale(1.15); opacity: 0; }
        }

        .incoming-name {
          font-family: var(--font-display);
          font-weight: 700;
          font-size: 32px;
          line-height: 1.1;
          letter-spacing: -0.01em;
          color: var(--fg-primary);
          z-index: 1;
        }
        .incoming-meta {
          font-family: var(--font-ui);
          font-size: 13px;
          color: var(--fg-tertiary);
          z-index: 1;
        }

        .incoming-actions {
          display: flex; gap: 16px;
          margin-top: 18px;
          z-index: 1;
        }
        .inc-btn {
          display: flex; align-items: center; gap: 12px;
          padding: 14px 28px;
          border-radius: var(--radius-pill);
          font-family: var(--font-ui);
          font-weight: 600;
          font-size: 15px;
          cursor: pointer;
          border: none;
          color: var(--color-white);
          transition: all var(--duration-fast) var(--ease-out);
        }
        .inc-btn-icon {
          display: grid; place-items: center;
          width: 28px; height: 28px;
          border-radius: 50%;
          background: rgba(255, 255, 255, 0.18);
        }
        .inc-btn-reject {
          background: var(--color-danger);
          box-shadow: 0 6px 20px rgba(232, 84, 84, 0.4);
        }
        .inc-btn-reject:hover { background: #d63b3b; transform: translateY(-1px); }
        .inc-btn-answer {
          background: var(--color-success);
          box-shadow: 0 6px 20px rgba(61, 201, 106, 0.4);
          animation: answerPulse 1.4s ease-in-out infinite;
        }
        .inc-btn-answer:hover { background: #34b85b; animation: none; transform: translateY(-1px); }
        @keyframes answerPulse {
          0%, 100% { box-shadow: 0 6px 20px rgba(61, 201, 106, 0.4); }
          50% { box-shadow: 0 6px 28px rgba(61, 201, 106, 0.7); }
        }
      `}</style>
    </div>
  );
}

window.EmployeePage = EmployeePage;
