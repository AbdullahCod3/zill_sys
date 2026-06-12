import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/home/channel_card.dart';

/// PRD §6 entry flow: after picking a role at home, the user picks a channel —
/// **Call** or **Chat** — and lands on the right page for that role.
///
/// Route argument: `{'role': 'agent' | 'customer'}` (see [AppRoutes]).
class ChannelChooserPage extends StatelessWidget {
  const ChannelChooserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final role = (args is Map && args['role'] is String)
        ? args['role'] as String
        : 'agent';
    final isAgent = role == 'agent';
    final ar = isArabic(context);

    return AppShell(
      showSwitchRole: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 760;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 56),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.pickChannel.resolve(context),
                      style: AppTextStyles.display(
                        arabic: ar,
                        size: 56,
                        weight: FontWeight.w700,
                        color: AppColors.neon,
                        height: 1.05,
                        letterSpacing: -0.03 * 56,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (isAgent
                              ? AppStrings.channelHintAgent
                              : AppStrings.channelHintCustomer)
                          .resolve(context),
                      style: AppTextStyles.ui(
                        arabic: ar,
                        size: 16,
                        color: context.colors.fgSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    narrow
                        ? Column(
                            children: [
                              _callCard(context, isAgent),
                              const SizedBox(height: AppSpacing.s4),
                              _chatCard(context, isAgent),
                            ],
                          )
                        : IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _callCard(context, isAgent)),
                                const SizedBox(width: AppSpacing.s4),
                                Expanded(child: _chatCard(context, isAgent)),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _callCard(BuildContext context, bool isAgent) => ChannelCard(
    number: '01',
    title: AppStrings.channelCall.resolve(context),
    subtitle: (isAgent
            ? AppStrings.channelCallSubAgent
            : AppStrings.channelCallSubCustomer)
        .resolve(context),
    icon: Icons.call,
    accent: AppColors.neon,
    onTap: () => Navigator.of(
      context,
    ).pushNamed(isAgent ? AppRoutes.call : AppRoutes.customer),
  );

  Widget _chatCard(BuildContext context, bool isAgent) => ChannelCard(
    number: '02',
    title: AppStrings.channelChat.resolve(context),
    subtitle: (isAgent
            ? AppStrings.channelChatSubAgent
            : AppStrings.channelChatSubCustomer)
        .resolve(context),
    icon: Icons.forum_outlined,
    accent: AppColors.neonCyan,
    onTap: () => Navigator.of(
      context,
    ).pushNamed(isAgent ? AppRoutes.agentChat : AppRoutes.customerChat),
  );
}
