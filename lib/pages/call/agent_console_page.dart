import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../core/utils/time_format.dart';
import '../../cubits/app_cubits/demo_cubit/demo_cubit.dart';
import '../../cubits/call_cubits/answer_cubit/answer_cubit.dart';
import '../../cubits/call_cubits/escalation_cubit/escalation_cubit.dart';
import '../../cubits/call_cubits/transcript_cubit/transcript_cubit.dart';
import '../../cubits/session_cubit/session_cubit.dart';
import '../../models/calls_model.dart';
import '../../models/citation.dart';
import '../../models/supervisor_model.dart';
import '../../services/audio/audio_source.dart';
import '../../services/audio/simulated_webrtc_source.dart';
import '../../services/demo/demo_script_service.dart';
import '../../services/demo/mock_analysis_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/call/anger_alert_banner.dart';
import '../../widgets/call/call_controls.dart';
import '../../widgets/call/call_summary_card.dart';
import '../../widgets/call/escalation_dialog.dart';
import '../../widgets/call/get_answer_button.dart';
import '../../widgets/call/incoming_call_card.dart';
import '../../widgets/call/suggested_answer_card.dart';
import '../../widgets/call/transcript_panel.dart';
import '../../widgets/call/waveform.dart';
import '../../widgets/common/audio_bars.dart';
import '../../widgets/common/live_dot.dart';

/// The agent cockpit (PRD §5/§6). Coordinates the session, transcript, answer,
/// and escalation cubits around the Get-Answer flow.
class AgentConsolePage extends StatelessWidget {
  const AgentConsolePage({super.key});

  static const _script = DemoScriptService();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SessionCubit()..begin()),
        BlocProvider(create: (_) => TranscriptCubit()),
        BlocProvider(
          create: (_) => AnswerCubit(const MockAnalysisService(_script)),
        ),
        BlocProvider(create: (_) => EscalationCubit()),
      ],
      child: AppShell(
        statusLabel: AppStrings.agentCockpitLive,
        showSwitchRole: true,
        body: const _ConsoleBody(),
      ),
    );
  }
}

class _ConsoleBody extends StatefulWidget {
  const _ConsoleBody();

  @override
  State<_ConsoleBody> createState() => _ConsoleBodyState();
}

class _ConsoleBodyState extends State<_ConsoleBody> {
  static const _script = DemoScriptService();
  AudioSource? _source;

  String get _customerName => langText(context, 'Layla Hassan', 'ليلى حسن');

  bool get _arabic => isArabic(context);

  DemoCubit get _demo => context.read<DemoCubit>();

  @override
  void dispose() {
    _source?.dispose();
    super.dispose();
  }

  Future<void> _onGetAnswer() async {
    final mood = _demo.state;
    final ar = _arabic;
    // Capture cubits before any async gap (avoids using context across awaits).
    final transcriptCubit = context.read<TranscriptCubit>();
    final sessionCubit = context.read<SessionCubit>();
    final answerCubit = context.read<AnswerCubit>();

    await _source?.dispose();
    _source = SimulatedWebRtcSource(_script.script(mood, ar));
    transcriptCubit.bind(_source!);
    await _source!.start();

    sessionCubit.markListening();
    answerCubit.fetch(mood: mood, arabic: ar);
  }

  void _onEnd() {
    final session = context.read<SessionCubit>();
    final escalation = context.read<EscalationCubit>();
    final answerState = context.read<AnswerCubit>().state;
    final citations = answerState is AnswerLoaded
        ? answerState.result.citations
        : const <Citation>[];

    _source?.stop();
    final summary = CallsModel(
      callId: 'demo',
      agentId: 'agent_self',
      customerId: 'cust_layla',
      customerName: _customerName,
      durationSec: session.elapsedSeconds,
      language: _arabic ? 'ar' : 'en',
      issueCategory: _script.issueCategory(_demo.state),
      angerAlertFired: escalation.alertFired,
      escalated: escalation.escalated,
      supervisorId: escalation.escalated
          ? _script.supervisor(_arabic).name
          : null,
      citations: citations,
      outcome: escalation.escalated ? 'transferred' : 'resolved',
    );
    session.end(summary);
  }

  void _onNewCall() {
    _source?.dispose();
    _source = null;
    context.read<TranscriptCubit>().clear();
    context.read<AnswerCubit>().reset();
    context.read<EscalationCubit>().reset();
    context.read<SessionCubit>().begin();
  }

  Future<void> _openEscalationDialog(SupervisorModel supervisor) async {
    final escalation = context.read<EscalationCubit>();
    final confirmed = await EscalationDialog.show(context, supervisor);
    if (confirmed == true) {
      escalation.confirm();
    } else {
      escalation.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fire escalation evaluation once the answer lands; auto-open the dialog
    // when the alert fires (PRD §5/§13).
    return MultiBlocListener(
      listeners: [
        BlocListener<AnswerCubit, AnswerState>(
          listener: (context, state) {
            if (state is AnswerLoaded) {
              context.read<EscalationCubit>().evaluate(
                state.result,
                _script.supervisor(_arabic),
              );
            }
          },
        ),
        BlocListener<EscalationCubit, EscalationState>(
          listener: (context, state) {
            if (state is EscalationAlert) {
              _openEscalationDialog(state.supervisor);
            }
          },
        ),
      ],
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, state) => switch (state) {
          SessionInitial() || SessionWaiting() => _Waiting(),
          SessionIncoming() => _Incoming(
            name: _customerName,
            onAnswer: () => context.read<SessionCubit>().answer(),
            onReject: () => context.read<SessionCubit>().reject(),
          ),
          SessionConnected() => _Connected(
            session: state,
            customerName: _customerName,
            onGetAnswer: _onGetAnswer,
            onEnd: _onEnd,
            onEscalate: () =>
                _openEscalationDialog(_script.supervisor(_arabic)),
          ),
          SessionEnded(:final summary) => CallSummaryCard(
            call: summary,
            onNewCall: _onNewCall,
          ),
        },
      ),
    );
  }
}

// ── Waiting ──────────────────────────────────────────────────────────────────
class _Waiting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neon.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.neon),
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              color: AppColors.neon,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            langText(context, 'Waiting for calls', 'في انتظار المكالمات'),
            style: AppTextStyles.display(
              arabic: ar,
              size: 44,
              weight: FontWeight.w700,
              color: colors.fgPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            langText(
              context,
              'The next customer will appear here automatically.',
              'سيظهر العميل القادم هنا تلقائياً.',
            ),
            style: AppTextStyles.ui(
              arabic: ar,
              size: 16,
              color: colors.fgSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Incoming ─────────────────────────────────────────────────────────────────
class _Incoming extends StatelessWidget {
  final String name;
  final VoidCallback onAnswer;
  final VoidCallback onReject;

  const _Incoming({
    required this.name,
    required this.onAnswer,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IncomingCallCard(
        customerName: name,
        meta: langText(
          context,
          '+966 5• ••• 4731 · Customer · 3 yrs',
          '+966 5• ••• 4731 · عميل · 3 سنوات',
        ),
        onAnswer: onAnswer,
        onReject: onReject,
      ),
    );
  }
}

// ── Connected ────────────────────────────────────────────────────────────────
class _Connected extends StatelessWidget {
  final SessionConnected session;
  final String customerName;
  final Future<void> Function() onGetAnswer;
  final VoidCallback onEnd;
  final VoidCallback onEscalate;

  const _Connected({
    required this.session,
    required this.customerName,
    required this.onGetAnswer,
    required this.onEnd,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopStrip(customerName: customerName, seconds: session.seconds),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final callView = _CallView(
                  customerName: customerName,
                  session: session,
                  onEnd: onEnd,
                );
                final shadowPanel = _ShadowPanel(
                  listening: session.listening,
                  onGetAnswer: onGetAnswer,
                  onEscalate: onEscalate,
                );
                if (constraints.maxWidth < 1100) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 420, child: callView),
                        const SizedBox(height: 16),
                        SizedBox(height: 560, child: shadowPanel),
                      ],
                    ),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 85, child: callView),
                    const SizedBox(width: 16),
                    Expanded(flex: 150, child: shadowPanel),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStrip extends StatelessWidget {
  final String customerName;
  final int seconds;

  const _TopStrip({required this.customerName, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.neon, AppColors.neonCyan],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: AppTextStyles.display(
                  arabic: ar,
                  size: 22,
                  weight: FontWeight.w500,
                  color: colors.fgPrimary,
                ),
              ),
              Text(
                'ZL-447-2210 · ${langText(context, 'Fiber Pro 500', 'فايبر برو 500')}',
                style: AppTextStyles.mono(size: 11, color: colors.fgTertiary),
              ),
            ],
          ),
          const Spacer(),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.amber, blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    langText(
                      context,
                      'Internet outage + disputed charge',
                      'انقطاع إنترنت + اعتراض على رسوم',
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.ui(
                      arabic: ar,
                      size: 14,
                      color: colors.fgSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              const AudioBars(color: AppColors.neon),
              const SizedBox(width: 12),
              Text(
                formatMmss(seconds),
                style: AppTextStyles.mono(size: 18, color: colors.fgPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallView extends StatelessWidget {
  final String customerName;
  final SessionConnected session;
  final VoidCallback onEnd;

  const _CallView({
    required this.customerName,
    required this.session,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.neon, AppColors.neonCyan],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neon.withValues(alpha: 0.45),
                  blurRadius: 48,
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 20),
          Text(
            customerName,
            style: AppTextStyles.display(
              arabic: ar,
              size: 32,
              weight: FontWeight.w500,
              color: colors.fgPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AudioBars(color: AppColors.neon),
              const SizedBox(width: 10),
              Text(
                '${langText(context, 'On call', 'مكالمة جارية')} · ${formatMmss(session.seconds)}',
                style: AppTextStyles.ui(
                  arabic: ar,
                  size: 13,
                  color: colors.fgSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Waveform(),
          const Spacer(),
          CallControls(
            muted: session.muted,
            speakerOn: session.speakerOn,
            onMute: () => context.read<SessionCubit>().toggleMute(),
            onSpeaker: () => context.read<SessionCubit>().toggleSpeaker(),
            onEnd: onEnd,
          ),
        ],
      ),
    );
  }
}

class _ShadowPanel extends StatelessWidget {
  final bool listening;
  final Future<void> Function() onGetAnswer;
  final VoidCallback onEscalate;

  const _ShadowPanel({
    required this.listening,
    required this.onGetAnswer,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderDefault),
      ),
      child: listening
          ? _LiveAssist(onEscalate: onEscalate)
          : _Empty(onGetAnswer: onGetAnswer),
    );
  }
}

class _Empty extends StatelessWidget {
  final Future<void> Function() onGetAnswer;

  const _Empty({required this.onGetAnswer});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ar = isArabic(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neon.withValues(alpha: 0.12),
              border: Border.all(color: colors.borderDefault),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.neon,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            langText(context, 'Need a reply?', 'تحتاج إلى ردّ؟'),
            style: AppTextStyles.display(
              arabic: ar,
              size: 32,
              weight: FontWeight.w500,
              color: colors.fgPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.shadowSuggestHint.resolve(context),
            style: AppTextStyles.ui(
              arabic: ar,
              size: 14,
              color: colors.fgTertiary,
            ),
          ),
          const SizedBox(height: 24),
          GetAnswerButton(
            label: AppStrings.getAnswer.resolve(context),
            onTap: onGetAnswer,
          ),
        ],
      ),
    );
  }
}

class _LiveAssist extends StatelessWidget {
  final VoidCallback onEscalate;

  const _LiveAssist({required this.onEscalate});

  @override
  Widget build(BuildContext context) {
    final escalationState = context.watch<EscalationCubit>().state;
    final showBanner = escalationState is EscalationAlert;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const LiveDot(color: AppColors.neon, size: 7),
            const SizedBox(width: 10),
            Text(
              AppStrings.shadowAssist.resolve(context),
              style: AppTextStyles.ui(
                arabic: isArabic(context),
                size: 16,
                weight: FontWeight.w600,
                color: context.colors.fgPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (showBanner) ...[
          AngerAlertBanner(onEscalate: onEscalate),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final transcript = BlocBuilder<TranscriptCubit, TranscriptState>(
                builder: (context, state) {
                  final lines = state is TranscriptUpdated
                      ? state.lines
                      : const [];
                  return TranscriptPanel(lines: lines.cast(), listening: true);
                },
              );
              final answer = _AnswerArea();
              if (constraints.maxWidth < 720) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 200, child: transcript),
                      const SizedBox(height: 16),
                      SizedBox(height: 460, child: answer),
                    ],
                  ),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 85, child: transcript),
                  const SizedBox(width: 18),
                  Expanded(flex: 115, child: answer),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnswerArea extends StatelessWidget {
  static const _script = DemoScriptService();

  /// "Don't use — re-read": append the angrier follow-up line, then re-analyse.
  void _reRead(BuildContext context) {
    final ar = isArabic(context);
    final mood = context.read<DemoCubit>().state;
    context.read<TranscriptCubit>().addLine(_script.followUp(mood, ar));
    context.read<AnswerCubit>().reRead(mood: mood, arabic: ar);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnswerCubit, AnswerState>(
      builder: (context, state) {
        switch (state) {
          case AnswerInitial():
          case AnswerLoading():
            return _Thinking();
          case AnswerError(:final message):
            return Center(
              child: Text(
                message,
                style: AppTextStyles.ui(
                  arabic: isArabic(context),
                  size: 13,
                  color: AppColors.danger,
                ),
              ),
            );
          case AnswerLoaded(:final result, :final selectedIndex, :final round):
            return SuggestedAnswerCard(
              result: result,
              selectedIndex: selectedIndex,
              round: round,
              onSelect: (i) => context.read<AnswerCubit>().select(i),
              onReRead: () => _reRead(context),
            );
        }
      },
    );
  }
}

class _Thinking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.neon,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.shadowThinking.resolve(context),
            style: AppTextStyles.ui(
              arabic: isArabic(context),
              size: 14,
              color: context.colors.fgTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
