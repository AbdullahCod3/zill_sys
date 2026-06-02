import '../../models/analysis_result.dart';
import '../../models/answer_option.dart';
import '../../models/citation.dart';
import '../../models/enums.dart';
import '../../models/supervisor_model.dart';
import '../../models/transcript_line.dart';
import '../audio/audio_source.dart';

/// Single source of the scripted demo content, per (mood, language). Content is
/// lifted from the design prototype (`employee.jsx`) and PRD §5/§12: a
/// billing + internet-outage call that resolves with a grounded, cited answer —
/// and, when frustrated, a one-time anger alert + escalation to supervisor "Maha".
///
/// Replies come in two rounds: the agent can press "Don't use — re-read the
/// call", which appends an angrier follow-up customer line and swaps in a fresh
/// set of suggestions (round 1).
class DemoScriptService {
  const DemoScriptService();

  /// Number of distinct suggestion rounds available.
  static const int roundCount = 2;

  String _t(bool ar, String en, String arText) => ar ? arText : en;

  /// Timed transcript the [SimulatedWebRtcSource] replays after Get Answer.
  List<ScriptedUtterance> script(Mood mood, bool arabic) {
    final lang = arabic ? 'ar' : 'en';
    final customerText = mood == Mood.frustrated
        ? _t(
            arabic,
            "This is the third time I'm calling this week. My internet has been down since 7am, and you charged me for a premium plan I never asked for.",
            'هذه ثالث مرّة أتصل بها هذا الأسبوع. الإنترنت معطّل عندي منذ السابعة صباحاً، وفوق ذلك خصمتم منّي رسوم باقة مميّزة لم أطلبها.',
          )
        : _t(
            arabic,
            'Hi, my internet has been down since this morning, and I noticed an unexpected charge for a premium plan on my bill.',
            'مرحباً، الإنترنت معطّل عندي منذ هذا الصباح، ولاحظت أيضاً رسوماً غير متوقّعة لباقة مميّزة في فاتورتي.',
          );
    return [
      ScriptedUtterance(
        delay: const Duration(milliseconds: 1400),
        speaker: Speaker.customer,
        text: customerText,
        language: lang,
      ),
      ScriptedUtterance(
        delay: const Duration(milliseconds: 3400),
        speaker: Speaker.agent,
        text: _t(
          arabic,
          "I'm sorry to hear that. Let me pull up your account…",
          'آسف لسماع ذلك. دعني أتحقّق من حسابك…',
        ),
        language: lang,
      ),
    ];
  }

  /// The angrier follow-up customer line appended when the agent re-reads the
  /// call (prototype's round-1 transcript line).
  TranscriptLine followUp(Mood mood, bool arabic) {
    final lang = arabic ? 'ar' : 'en';
    final text = mood == Mood.frustrated
        ? _t(
            arabic,
            "A credit isn't enough — I lost a whole morning of work because of this. What are you actually going to do for me?",
            'الرصيد لا يكفي — خسرت صباحاً كاملاً من العمل بسبب هذا. ما الذي ستفعلونه فعلاً من أجلي؟',
          )
        : _t(
            arabic,
            'Okay, but I also work from home, so the outage is a real problem for me today. Is there anything you can do right now?',
            'حسناً، لكنّي أعمل من المنزل، فالانقطاع مشكلة حقيقية لي اليوم. هل هناك ما يمكنك فعله الآن؟',
          );
    return TranscriptLine(
      speaker: Speaker.customer,
      text: text,
      language: lang,
      at: DateTime.now(),
    );
  }

  /// The structured analysis result for this scenario (PRD §11 shape + the
  /// cockpit's 3 tiered candidate replies). [round] selects the suggestion set.
  AnalysisResult analysis(Mood mood, bool arabic, {int round = 0}) {
    final lang = arabic ? 'ar' : 'en';
    final frustrated = mood == Mood.frustrated;

    final options = round <= 0 ? _round0(arabic) : _round1(arabic);

    return AnalysisResult(
      language: lang,
      problemSummary: _t(
        arabic,
        'Internet outage since this morning + a disputed premium-plan charge.',
        'انقطاع إنترنت منذ الصباح + اعتراض على رسوم باقة مميّزة.',
      ),
      suggestedAnswer: options.first.text,
      options: options,
      citations: [
        Citation(
          documentId: 'KB-114',
          title: _t(arabic, 'Outage Credit Policy', 'سياسة تعويض الانقطاع'),
        ),
        Citation(
          documentId: 'KB-203',
          title: _t(arabic, 'Billing Dispute Flow', 'إجراء اعتراض الفواتير'),
        ),
      ],
      angerScore: frustrated ? 8 : 2,
      escalationRequested: false,
      confidence: Confidence.high,
    );
  }

  // —— Round 0 — initial suggestions (prototype recsByRound[0]) ——
  List<AnswerOption> _round0(bool arabic) => [
    AnswerOption(
      tier: AnswerTier.recommended,
      tag: _t(
        arabic,
        'Resolve billing & confirm outage',
        'حلّ الفاتورة وتأكيد الانقطاع',
      ),
      text: _t(
        arabic,
        "I'm sorry for both issues. There's an active outage in your area that should be resolved within two hours — I'll add a credit for the downtime. As for the premium charge, that was auto-applied from a promo that ended last month. I'm reversing it now and the refund will hit your account within 24 hours.",
        'آسف على المشكلتين. هناك انقطاع نشط في منطقتك وسيتم إصلاحه خلال ساعتين — سأقيّد لك رصيداً للانقطاع. أمّا رسوم الباقة المميّزة فقد فُعّلت تلقائياً بعد عرض ترويجي انتهى الشهر الماضي. أعكس العملية الآن وسيصل الاسترداد إلى حسابك خلال 24 ساعة.',
      ),
    ),
    AnswerOption(
      tier: AnswerTier.likely,
      tag: _t(arabic, 'Acknowledge & confirm outage', 'تأكيد وانقطاع الخدمة'),
      text: _t(
        arabic,
        "I completely understand your frustration, and I'm sorry for the disruption. I'm checking your area now — yes, there's an active fiber outage in your neighborhood, expected to be resolved within the next two hours. I'll apply a service credit to your account right away.",
        'أتفهّم انزعاجك تماماً، وأعتذر عن هذا الانقطاع. أتحقّق من منطقتك الآن — نعم، هناك انقطاع نشط في شبكة الألياف في حيّك، ومن المتوقّع إصلاحه خلال ساعتين. سأقيّد لك رصيد خدمة الآن.',
      ),
    ),
    AnswerOption(
      tier: AnswerTier.maybe,
      tag: _t(arabic, 'Goodwill retention offer', 'عرض احتفاظ ودّي'),
      text: _t(
        arabic,
        "I want to make this completely right. Beyond reversing the premium charge, I'd like to apply a 30% discount on your next three bills and personally follow up tomorrow once the outage is resolved to make sure everything is stable. Would that work for you?",
        'أريد أن أصلح الأمر كلّياً. إضافةً إلى إلغاء رسوم الباقة، أودّ منحك خصم 30٪ على فواتيرك الثلاث القادمة، وسأتابع معك شخصياً غداً للتأكّد من استقرار الاتصال. هل يناسبك ذلك؟',
      ),
    ),
  ];

  // —— Round 1 — after "Don't use" re-read (prototype recsByRound[1]) ——
  List<AnswerOption> _round1(bool arabic) => [
    AnswerOption(
      tier: AnswerTier.recommended,
      tag: _t(arabic, 'Offer instant 4G backup', 'تفعيل بديل 4G فوري'),
      text: _t(
        arabic,
        "Since you work from home, let me get you online right now — I can activate a free 4G backup hotspot on your account that starts within five minutes and runs until the fiber is restored. I'll also waive this month's fee entirely, not just credit it.",
        'بما أنّك تعمل من المنزل، دعني أعيدك للإنترنت الآن — يمكنني تفعيل نقطة اتصال 4G احتياطية مجاناً تبدأ خلال خمس دقائق وتستمرّ حتى عودة الألياف. وسأعفيك من رسوم هذا الشهر بالكامل، وليس مجرّد رصيد.',
      ),
    ),
    AnswerOption(
      tier: AnswerTier.likely,
      tag: _t(
        arabic,
        'Escalate with priority repair',
        'تصعيد مع إصلاح ذي أولوية',
      ),
      text: _t(
        arabic,
        "I hear you — this cost you real working hours. I'm flagging your line for priority repair so a technician reaches your area first, and I'll stay on top of it personally. You'll get an SMS the moment service is back.",
        'أتفهّمك — لقد كلّفك هذا ساعات عمل حقيقية. سأضع خطّك ضمن أولوية الإصلاح ليصل الفنّي إلى منطقتك أوّلاً، وسأتابع الأمر بنفسي. ستصلك رسالة فور عودة الخدمة.',
      ),
    ),
    AnswerOption(
      tier: AnswerTier.maybe,
      tag: _t(arabic, 'Compensate with bonus credit', 'تعويض برصيد إضافي'),
      text: _t(
        arabic,
        "To make up for the lost morning, I'd like to add two months at 50% off on top of fixing today's issue. It won't give you the time back, but it's the strongest goodwill I can offer on the spot.",
        'تعويضاً عن صباحك الضائع، أودّ إضافة شهرين بخصم 50٪ إلى جانب حلّ مشكلة اليوم. لن يعيد لك الوقت، لكنّه أقصى ما أستطيع تقديمه الآن كبادرة حسن نيّة.',
      ),
    ),
  ];

  /// Issue category used to route the escalation (PRD §13).
  String issueCategory(Mood mood) => 'technical';

  /// The supervisor named in the escalation dialog (seeded `supervisors`).
  SupervisorModel supervisor(bool arabic) => SupervisorModel(
    supervisorId: 'sup_maha',
    name: _t(arabic, 'Maha', 'مها'),
    department: 'technical',
    email: 'maha@telco.example',
    available: true,
  );
}
