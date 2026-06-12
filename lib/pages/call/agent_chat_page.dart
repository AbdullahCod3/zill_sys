import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/webrtc_config.dart';
import '../../core/localization/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../cubits/chat_cubits/agent_chat_cubit/agent_chat_cubit.dart';
import '../../services/firestore/chat_repository.dart';
import '../../services/socket/signaling_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/chat/chat_composer.dart';
import '../../widgets/chat/chat_message_list.dart';
import '../../widgets/chat/resolve_chat_dialog.dart';
import '../../widgets/common/glass_pill.dart';
import '../../widgets/common/live_dot.dart';

/// Agent-side chat surface (FR-8). Live messaging with no AI assist; only the
/// agent can end the chat ([ResolveChatDialog] popup → patches Firestore).
class AgentChatPage extends StatelessWidget {
  const AgentChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (WebRtcConfig.useRealCall
                ? AgentChatCubit(
                    signaling: SignalingService(),
                    repo: ChatRepository(),
                  )
                : AgentChatCubit())
            ..begin(),
      child: AppShell(
        statusLabel: AppStrings.chatTitle,
        showSwitchRole: true,
        body: const _AgentChatBody(),
      ),
    );
  }
}

class _AgentChatBody extends StatelessWidget {
  const _AgentChatBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AgentChatCubit, AgentChatState>(
      listenWhen: (p, c) => c is AgentChatEndingPrompt,
      listener: (context, state) async {
        if (state is! AgentChatEndingPrompt) return;
        final answered = await ResolveChatDialog.show(context);
        if (!context.mounted) return;
        final cubit = context.read<AgentChatCubit>();
        if (answered == null) {
          cubit.cancelEnd();
        } else {
          await cubit.confirmEnd(resolved: answered);
        }
      },
      builder: (context, state) {
        return switch (state) {
          AgentChatInitial() || AgentChatWaiting() => const _AgentWaiting(),
          AgentChatInChat() => _AgentChatSurface(state: state),
          AgentChatEndingPrompt() => _AgentChatSurface(
            state: AgentChatInChat(
              chatId: state.chatId,
              messages: state.messages,
            ),
          ),
          AgentChatEnded(:final resolved) => _AgentChatEndedView(
            resolved: resolved,
          ),
        };
      },
    );
  }
}

class _AgentWaiting extends StatelessWidget {
  const _AgentWaiting();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassPill(
              children: [
                const LiveDot(color: AppColors.neon, size: 7),
                const SizedBox(width: 10),
                Text(
                  AppStrings.chatTitle.resolve(context),
                  style: AppTextStyles.mono(
                    size: 11,
                    color: AppColors.neon,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              AppStrings.waitingForCustomer.resolve(context),
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
      ),
    );
  }
}

class _AgentChatSurface extends StatelessWidget {
  final AgentChatInChat state;

  const _AgentChatSurface({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s4,
          ),
          child: Column(
            children: [
              const _ChatHeader(),
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
                          viewerIsAgent: true,
                          emptyHint: AppStrings.waitingForCustomer.resolve(
                            context,
                          ),
                        ),
                      ),
                      ChatComposer(
                        onSend: (text) =>
                            context.read<AgentChatCubit>().sendMessage(text),
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

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    return Row(
      children: [
        GlassPill(
          children: [
            const LiveDot(color: AppColors.neonCyan, size: 7),
            const SizedBox(width: 10),
            Text(
              AppStrings.customerLabelCaps.resolve(context),
              style: AppTextStyles.mono(
                size: 11,
                color: AppColors.neonCyan,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        _EndChatButton(
          onTap: () => context.read<AgentChatCubit>().requestEnd(),
          label: AppStrings.endChat.resolve(context),
          arabic: ar,
        ),
      ],
    );
  }
}

class _EndChatButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final bool arabic;

  const _EndChatButton({
    required this.onTap,
    required this.label,
    required this.arabic,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.stop_circle_outlined,
                color: AppColors.danger,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.ui(
                  arabic: arabic,
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgentChatEndedView extends StatelessWidget {
  final bool resolved;

  const _AgentChatEndedView({required this.resolved});

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
            (resolved ? AppStrings.resolved : AppStrings.escalated).resolve(
              context,
            ),
            style: AppTextStyles.ui(
              arabic: ar,
              size: 16,
              color: colors.fgSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          OutlinedButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
            child: Text(AppStrings.switchRole.resolve(context)),
          ),
        ],
      ),
    );
  }
}
