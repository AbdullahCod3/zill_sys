import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/webrtc_config.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../core/utils/time_format.dart';
import '../../cubits/app_cubits/demo_cubit/demo_cubit.dart';
import '../../cubits/customer_cubit/customer_cubit.dart';
import '../../models/enums.dart';
import '../../services/audio/audio_source.dart';
import '../../services/audio/deepgram_transcript_source.dart';
import '../../services/socket/signaling_service.dart';
import '../../services/webrtc/peer_call_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/call/remote_audio.dart';
import '../../widgets/common/glass_pill.dart';
import '../../widgets/customer/call_action_button.dart';
import '../../widgets/customer/call_avatar.dart';
import '../../widgets/customer/language_choice.dart';
import '../../widgets/customer/phone_frame.dart';
import '../../widgets/customer/round_call_button.dart';

/// Customer-side phone screen. The customer never sees Shadow (PRD §3).
class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WebRtcConfig.useRealCall
          ? CustomerCubit(
              signaling: SignalingService(),
              peer: PeerCallService(),
            )
          : CustomerCubit(),
      child: AppShell(
        statusLabel: AppStrings.callInProgress,
        showSwitchRole: true,
        body: const _CustomerBody(),
      ),
    );
  }
}

class _CustomerBody extends StatefulWidget {
  const _CustomerBody();

  @override
  State<_CustomerBody> createState() => _CustomerBodyState();
}

class _CustomerBodyState extends State<_CustomerBody> {
  // Streams the customer's mic to the backend so their speech is transcribed
  // and routed to the agent (role=customer). No transcript is rendered here —
  // the customer never sees Shadow (PRD §3).
  AudioSource? _uplink;

  /// Customer-chosen call language ('ar' | 'en'); picked before the call and
  /// used for both sides' transcription (independent of the UI locale).
  String _lang = 'ar';

  Future<void> _startUplink() async {
    if (!WebRtcConfig.useRealTranscription || _uplink != null) return;
    final uplink = DeepgramTranscriptSource(
      role: 'customer',
      lang: context.read<CustomerCubit>().callLang,
      consumeTranscript: false,
    );
    _uplink = uplink;
    await uplink.start();
  }

  void _stopUplink() {
    _uplink?.dispose();
    _uplink = null;
  }

  @override
  void dispose() {
    _uplink?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerCubit, CustomerState>(
      listenWhen: (prev, curr) => curr.runtimeType != prev.runtimeType,
      listener: (context, state) {
        if (state is CustomerConnected) {
          _startUplink();
        } else if (state is CustomerEnded || state is CustomerIdle) {
          _stopUplink();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: PhoneFrame(
                child: BlocBuilder<CustomerCubit, CustomerState>(
                  builder: (context, state) => _phoneContent(context, state),
                ),
              ),
            ),
            const SizedBox(height: 32),
            GlassPill(
              dashedBorder: true,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                Text(
                  'NOTE',
                  style: AppTextStyles.mono(
                    size: 10,
                    color: AppColors.neonCyan,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.customerNoShadow.resolve(context),
                  style: AppTextStyles.ui(
                    arabic: isArabic(context),
                    size: 13,
                    color: context.colors.fgSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _phoneContent(BuildContext context, CustomerState state) {
    final cubit = context.read<CustomerCubit>();
    final ar = isArabic(context);
    final telco = AppStrings.telcoSupport.resolve(context);

    Widget heading(String kbd, {Color color = AppColors.neonCyan}) => Text(
      kbd,
      style: AppTextStyles.mono(size: 10, color: color, letterSpacing: 2),
    );

    Widget name() => Text(
      telco,
      style: AppTextStyles.display(
        arabic: ar,
        size: 28,
        weight: FontWeight.w400,
        color: Colors.white,
      ),
    );

    switch (state) {
      case CustomerIdle():
        return Column(
          children: [
            heading(AppStrings.telcoSupportCaps.resolve(context)),
            const SizedBox(height: 6),
            Text(
              '800 100 2020',
              style: AppTextStyles.mono(
                size: 13,
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            const CallAvatar(size: 110),
            const SizedBox(height: 20),
            name(),
            const SizedBox(height: 8),
            Text(
              AppStrings.tapToStart.resolve(context),
              textAlign: TextAlign.center,
              style: AppTextStyles.ui(
                arabic: ar,
                size: 14,
                color: Colors.white60,
              ),
            ),
            const Spacer(),
            Text(
              AppStrings.callLanguage.resolve(context).toUpperCase(),
              style: AppTextStyles.mono(
                size: 10,
                color: Colors.white54,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            LanguageChoice(
              value: _lang,
              onChanged: (v) => setState(() => _lang = v),
            ),
            const SizedBox(height: 20),
            RoundCallButton(
              color: AppColors.success,
              icon: Icons.call,
              size: 76,
              onTap: () => cubit.startCall(lang: _lang),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.call.resolve(context),
              style: AppTextStyles.ui(
                arabic: ar,
                size: 12,
                color: Colors.white70,
              ),
            ),
          ],
        );

      case CustomerRinging():
        return Column(
          children: [
            heading(AppStrings.calling.resolve(context)),
            const SizedBox(height: 32),
            const CallAvatar(size: 120, showRings: true),
            const SizedBox(height: 20),
            name(),
            const SizedBox(height: 8),
            Text(
              AppStrings.ringing.resolve(context),
              style: AppTextStyles.mono(
                size: 11,
                color: Colors.white60,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            RoundCallButton(
              color: AppColors.danger,
              icon: Icons.call_end,
              onTap: cubit.endCall,
            ),
          ],
        );

      case CustomerConnected(:final seconds, :final muted, :final speakerOn):
        final frustrated = context.watch<DemoCubit>().state == Mood.frustrated;
        final moodLabel = frustrated
            ? AppStrings.staticPoorSignal.resolve(context)
            : AppStrings.clear.resolve(context);
        return Column(
          children: [
            RemoteAudio(renderer: cubit.remoteRenderer),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                heading(AppStrings.support.resolve(context)),
                const SizedBox(width: 12),
                Text(
                  formatMmss(seconds),
                  style: AppTextStyles.mono(size: 11, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const CallAvatar(size: 120, showRings: true),
            const SizedBox(height: 20),
            name(),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.connected.resolve(context)} · $moodLabel',
              style: AppTextStyles.mono(
                size: 10,
                color: Colors.white60,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                CallActionButton(
                  icon: muted ? Icons.mic_off : Icons.mic_none,
                  label: muted
                      ? AppStrings.unmute.resolve(context)
                      : AppStrings.mute.resolve(context),
                  active: muted,
                  onTap: cubit.toggleMute,
                ),
                const SizedBox(width: 12),
                CallActionButton(
                  icon: Icons.volume_up_outlined,
                  label: AppStrings.speaker.resolve(context),
                  active: speakerOn,
                  onTap: cubit.toggleSpeaker,
                ),
                const SizedBox(width: 12),
                CallActionButton(
                  icon: Icons.dialpad,
                  label: AppStrings.keypad.resolve(context),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            RoundCallButton(
              color: AppColors.danger,
              icon: Icons.call_end,
              onTap: cubit.endCall,
            ),
          ],
        );

      case CustomerEnded(:final seconds):
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            heading(
              '● ${AppStrings.callEnded.resolve(context)}',
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              formatMmss(seconds),
              style: AppTextStyles.mono(size: 28, color: Colors.white),
            ),
            const SizedBox(height: 8),
            name(),
            const SizedBox(height: 24),
            RoundCallButton(
              color: AppColors.success,
              icon: Icons.call,
              onTap: cubit.reset,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.callAgain.resolve(context),
              style: AppTextStyles.ui(
                arabic: ar,
                size: 13,
                color: Colors.white70,
              ),
            ),
          ],
        );
    }
  }
}
