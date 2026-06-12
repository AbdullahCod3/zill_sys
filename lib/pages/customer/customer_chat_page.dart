import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/webrtc_config.dart';
import '../../core/localization/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../cubits/chat_cubits/customer_chat_cubit/customer_chat_cubit.dart';
import '../../services/firestore/chat_repository.dart';
import '../../services/socket/signaling_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/chat/chat_composer.dart';
import '../../widgets/chat/chat_message_list.dart';
import '../../widgets/common/glass_pill.dart';
import '../../widgets/common/live_dot.dart';

/// Customer-side chat surface. The customer taps Start to create the `chats`
/// doc and announce themselves to the agent over signaling.
class CustomerChatPage extends StatelessWidget {
  const CustomerChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WebRtcConfig.useRealCall
          ? CustomerChatCubit(
              signaling: SignalingService(),
              repo: ChatRepository(),
            )
          : CustomerChatCubit(),
      child: AppShell(
        statusLabel: AppStrings.chatTitle,
        showSwitchRole: true,
        body: const _CustomerChatBody(),
      ),
    );
  }
}

class _CustomerChatBody extends StatelessWidget {
  const _CustomerChatBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerChatCubit, CustomerChatState>(
      builder: (context, state) => switch (state) {
        CustomerChatIdle() => const _CustomerIdle(),
        CustomerChatConnecting() => const _CustomerConnecting(),
        CustomerChatInChat() => _CustomerChatSurface(state: state),
        CustomerChatEnded(:final resolved) => _CustomerEnded(
          resolved: resolved,
        ),
      },
    );
  }
}

class _CustomerIdle extends StatelessWidget {
  const _CustomerIdle();

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    final colors = context.colors;
    final cubit = context.read<CustomerChatCubit>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 56,
                color: colors.fgSecondary,
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                AppStrings.telcoSupport.resolve(context),
                style: AppTextStyles.display(
                  arabic: ar,
                  size: 32,
                  weight: FontWeight.w600,
                  color: colors.fgPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                AppStrings.channelChatSubCustomer.resolve(context),
                textAlign: TextAlign.center,
                style: AppTextStyles.ui(
                  arabic: ar,
                  size: 14,
                  color: colors.fgSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              FilledButton.icon(
                onPressed: cubit.start,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.neon,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(AppStrings.startChat.resolve(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerConnecting extends StatelessWidget {
  const _CustomerConnecting();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassPill(
            children: [
              const LiveDot(color: AppColors.neonCyan, size: 7),
              const SizedBox(width: 10),
              Text(
                AppStrings.chatTitle.resolve(context),
                style: AppTextStyles.mono(
                  size: 11,
                  color: AppColors.neonCyan,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            AppStrings.waitingForAgent.resolve(context),
            textAlign: TextAlign.center,
            style: AppTextStyles.ui(
              arabic: isArabic(context),
              size: 16,
              color: context.colors.fgSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerChatSurface extends StatelessWidget {
  final CustomerChatInChat state;

  const _CustomerChatSurface({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s4,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GlassPill(
                    children: [
                      const LiveDot(color: AppColors.neon, size: 7),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.agentLabelCaps.resolve(context),
                        style: AppTextStyles.mono(
                          size: 11,
                          color: AppColors.neon,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s3),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ChatMessageList(
                          messages: state.messages,
                          viewerIsAgent: false,
                          emptyHint: AppStrings.waitingForAgent.resolve(
                            context,
                          ),
                        ),
                      ),
                      ChatComposer(
                        onSend: (text) =>
                            context.read<CustomerChatCubit>().sendMessage(text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerEnded extends StatelessWidget {
  final bool resolved;

  const _CustomerEnded({required this.resolved});

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassPill(
            children: [
              Icon(
                resolved ? Icons.check_circle : Icons.cancel_outlined,
                color: resolved ? AppColors.success : AppColors.danger,
                size: 16,
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.chatEnded.resolve(context),
                style: AppTextStyles.mono(
                  size: 11,
                  color: colors.fgPrimary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            AppStrings.tapToStart.resolve(context),
            textAlign: TextAlign.center,
            style: AppTextStyles.ui(
              arabic: ar,
              size: 14,
              color: colors.fgSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
                child: Text(AppStrings.switchRole.resolve(context)),
              ),
              const SizedBox(width: AppSpacing.s3),
              FilledButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
                style: FilledButton.styleFrom(backgroundColor: AppColors.neon),
                child: Text(AppStrings.chatAgain.resolve(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
