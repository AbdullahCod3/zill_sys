import '../utils/lang_text.dart';

/// UI chrome strings as {en, ar} pairs (the prototype's inline `t(en, ar)`,
/// centralized). Demo *content* (transcript, suggested replies, citations) lives
/// in `DemoScriptService`, not here.
class AppStrings {
  AppStrings._();

  // ── App shell ────────────────────────────────────────────────────────────
  static const brandTag = 'SHADOW';
  static const agentCockpitLive = TextPair(
    'AGENT COCKPIT · LIVE',
    'موظف · مباشر',
  );
  static const callInProgress = TextPair('CALL IN PROGRESS', 'مكالمة جارية');
  static const switchRole = TextPair('Switch role', 'تغيير الدور');

  // ── Home ─────────────────────────────────────────────────────────────────
  static const chooseSide = TextPair('Choose a side.', 'اختر دورك.');
  static const imEmployee = TextPair("I'm the Employee", 'أنا موظف الدعم');
  static const imCustomer = TextPair("I'm the Customer", 'أنا العميل');
  static const shadowLive = 'SHADOW · LIVE';
  static const heroAlt = TextPair(
    'A customer service agent with an AI assistant beside him',
    'موظف خدمة عملاء بمساعد ذكاء اصطناعي بجانبه',
  );

  // ── Customer (phone) ─────────────────────────────────────────────────────
  static const telcoSupport = TextPair('Telco Support', 'دعم MyZill');
  static const telcoSupportCaps = TextPair('TELCO SUPPORT', 'دعم تيلكو');
  static const tapToStart = TextPair(
    'Tap to start your support call',
    'اضغط لبدء مكالمة الدعم',
  );
  static const call = TextPair('Call', 'اتصال');
  static const phoneNumber = TextPair('Phone number', 'رقم الهاتف');
  static const phoneNumberHint = TextPair(
    'Add your phone number',
    'أضف رقم هاتفك',
  );
  static const callLanguage = TextPair('Call language', 'لغة المكالمة');
  static const calling = TextPair('CALLING…', 'يتّصل…');
  static const ringing = TextPair('Ringing', 'يرنّ');
  static const support = TextPair('SUPPORT', 'الدعم');
  static const connected = TextPair('Connected', 'متصل');
  static const clear = TextPair('Clear', 'واضحة');
  static const staticPoorSignal = TextPair(
    'Static · poor signal?',
    'تشويش · إشارة ضعيفة؟',
  );
  static const mute = TextPair('Mute', 'كتم');
  static const unmute = TextPair('Unmute', 'إلغاء الكتم');
  static const speaker = TextPair('Speaker', 'مكبر');
  static const keypad = TextPair('Keypad', 'لوحة');
  static const callEnded = TextPair('CALL ENDED', 'انتهت المكالمة');
  static const callAgain = TextPair('Call again', 'اتصل مرة أخرى');
  static const customerNoShadow = TextPair(
    "The customer doesn't see Shadow.",
    'العميل لا يرى زِل.',
  );
  static const note = 'NOTE';

  // ── Agent console ────────────────────────────────────────────────────────
  static const customerCall = TextPair('Customer Call', 'مكالمة عميل');
  static const incomingTelco = TextPair(
    'Incoming · Telco Support',
    'وارد · دعم تيلكو',
  );
  static const customer = TextPair('Customer', 'العميل');
  static const agent = TextPair('Agent', 'الموظف');
  static const previousIssues = TextPair('Previous issues', 'المشاكل السابقة');
  // Previous-issues popup: field labels + values (ERD `previous_issues`).
  static const issueSummary = TextPair('Summary', 'الملخص');
  static const category = TextPair('Category', 'الفئة');
  static const status = TextPair('Status', 'الحالة');
  static const source = TextPair('Source', 'المصدر');
  static const date = TextPair('Date', 'التاريخ');
  static const openStatus = TextPair('Open', 'مفتوحة');
  static const categoryBilling = TextPair('Billing', 'فوترة');
  static const categoryTechnical = TextPair('Technical', 'تقني');
  static const categoryPolicy = TextPair('Policy', 'سياسة');
  static const sourceChat = TextPair('Chat', 'تطبيق MyZill');
  static const sourceCall = TextPair('Call', 'مكالمة');
  static const waiting = TextPair('Waiting…', 'بالانتظار…');
  static const waitingForCall = TextPair(
    'Waiting for the call to start…',
    'بانتظار بدء المكالمة…',
  );
  static const shadowAssist = TextPair('Shadow Assist', 'مساعد ظل');
  static const highTension = TextPair('High tension', 'توتر عالي');
  static const stable = TextPair('Stable', 'مستقر');
  static const angerHigh = TextPair(
    'Customer anger high — consider escalation',
    'غضب العميل مرتفع — فكّر بالتصعيد',
  );
  static const answerToBegin = TextPair(
    'Answer the call to begin.',
    'أجب على المكالمة للبدء.',
  );
  static const getAnswer = TextPair('Get Answer', 'احصل على إجابة');
  static const shadowSuggestHint = TextPair(
    'Shadow will suggest a grounded reply.',
    'سيقترح ظل رداً موثقاً.',
  );
  static const shadowThinking = TextPair('Shadow is thinking…', 'ظل يفكر…');
  static const problem = TextPair('PROBLEM', 'المشكلة');
  static const suggestedReplies = TextPair('SUGGESTED REPLIES', 'ردود مقترحة');
  static const recommended = TextPair('Recommended', 'موصى به');
  static const moreLikely = TextPair('More likely', 'الأرجح');
  static const maybe = TextPair('Maybe', 'ربّما');
  static const updated = TextPair('Updated', 'محدّثة');
  static const dontUseReRead = TextPair(
    "Don't use — re-read the call",
    'لا تستخدم — أعِد قراءة المكالمة',
  );
  static const reReading = TextPair(
    'Re-reading the call…',
    'إعادة قراءة المكالمة…',
  );
  static const sources = TextPair('SOURCES', 'المصادر');
  static const escalateToSupervisor = TextPair(
    'Escalate to Supervisor',
    'تصعيد للمشرف',
  );
  static const replySelected = TextPair(
    'Reply selected. Read it to the customer.',
    'تم اختيار الرد. اقرأه للعميل.',
  );

  // ── Escalation dialog ────────────────────────────────────────────────────
  static const escalationTitle = TextPair(
    'Escalate this call?',
    'تصعيد المكالمة؟',
  );
  static const escalationBody = TextPair(
    'Transfer the customer to the supervisor below.',
    'تحويل العميل إلى المشرف أدناه.',
  );
  static const confirmTransfer = TextPair('Confirm Transfer', 'تأكيد التحويل');
  static const dismiss = TextPair('Dismiss', 'تجاهل');
  static const supervisor = TextPair('Supervisor', 'المشرف');
  static const transferred = TextPair(
    'Transferred. Supervisor notified.',
    'تم التحويل. تم إشعار المشرف.',
  );

  // ── Channel chooser ──────────────────────────────────────────────────────
  static const pickChannel = TextPair('Pick a channel.', 'اختر القناة.');
  static const channelHintAgent = TextPair(
    'How will you serve this customer?',
    'كيف ستخدم هذا العميل؟',
  );
  static const channelHintCustomer = TextPair(
    'How would you like to reach support?',
    'كيف تريد الوصول للدعم؟',
  );
  static const channelCall = TextPair('Call', 'مكالمة');
  static const channelChat = TextPair('Chat', 'محادثة');
  static const channelCallSubAgent = TextPair(
    'Live voice with Shadow assist.',
    'صوت مباشر مع مساعدة ظل.',
  );
  static const channelChatSubAgent = TextPair(
    'Real-time text. No AI assist.',
    'نص فوري. بدون مساعدة الذكاء.',
  );
  static const channelCallSubCustomer = TextPair(
    'Talk to a support agent.',
    'تحدث مع موظف الدعم.',
  );
  static const channelChatSubCustomer = TextPair(
    'Type with a support agent.',
    'راسل موظف الدعم.',
  );

  // ── Chat ─────────────────────────────────────────────────────────────────
  static const chatTitle = TextPair('CHAT · LIVE', 'محادثة · مباشر');
  static const startChat = TextPair('Start chat', 'بدء المحادثة');
  static const composeHint = TextPair('Type a message…', 'اكتب رسالة…');
  static const send = TextPair('Send', 'إرسال');
  static const endChat = TextPair('End chat', 'إنهاء المحادثة');
  static const youLabel = TextPair('YOU', 'أنت');
  static const customerLabelCaps = TextPair('CUSTOMER', 'العميل');
  static const agentLabelCaps = TextPair('AGENT', 'الموظف');
  static const waitingForCustomer = TextPair(
    'Waiting for a customer to start chatting…',
    'بانتظار عميل لبدء المحادثة…',
  );
  static const waitingForAgent = TextPair(
    'Connecting you with an agent…',
    'يتم توصيلك بموظف…',
  );
  static const chatEnded = TextPair('CHAT ENDED', 'انتهت المحادثة');
  static const chatAgain = TextPair('New chat', 'محادثة جديدة');

  // ── End-chat dialog ──────────────────────────────────────────────────────
  static const resolveTitle = TextPair(
    'Problem resolved?',
    'هل تم حل المشكلة؟',
  );
  static const resolveBody = TextPair(
    'Mark this chat resolved before it gets archived.',
    'حدّد ما إذا تم حل المحادثة قبل أرشفتها.',
  );
  static const yesResolved = TextPair('Yes, resolved', 'نعم، تم الحل');
  static const noUnresolved = TextPair('No, unresolved', 'لا، لم يُحل');

  // ── Call summary ─────────────────────────────────────────────────────────
  static const callSummary = TextPair('CALL SUMMARY', 'ملخص المكالمة');
  static const duration = TextPair('Duration', 'المدة');
  static const issue = TextPair('Issue', 'المشكلة');
  static const outcome = TextPair('Outcome', 'النتيجة');
  static const escalated = TextPair('Escalated', 'تم التصعيد');
  static const resolved = TextPair('Resolved', 'تم الحل');
  static const newCall = TextPair('New call', 'مكالمة جديدة');
}
