import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/lang_text.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/common/glass_pill.dart';
import '../../widgets/common/live_dot.dart';
import '../../widgets/home/hero_frame.dart';
import '../../widgets/home/role_card.dart';

/// Role chooser — "Choose a side." Routes to the agent console or the customer
/// phone screen.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 880;
          final left = _Left();
          final right = _Right();
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1480),
                child: narrow
                    ? Column(
                        children: [right, const SizedBox(height: 32), left],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 85, child: left),
                          const SizedBox(width: 48),
                          Expanded(flex: 115, child: right),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Left extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.chooseSide.resolve(context),
          style: AppTextStyles.display(
            arabic: ar,
            size: 76,
            weight: FontWeight.w700,
            color: AppColors.neon,
            height: 1.05,
            letterSpacing: -0.03 * 76,
          ),
        ),
        const SizedBox(height: 36),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            children: [
              RoleCard(
                number: '01',
                title: AppStrings.imEmployee.resolve(context),
                accent: AppColors.neon,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.channelChooser,
                  arguments: const {'role': 'agent'},
                ),
              ),
              const SizedBox(height: 12),
              RoleCard(
                number: '02',
                title: AppStrings.imCustomer.resolve(context),
                accent: AppColors.neonCyan,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.channelChooser,
                  arguments: const {'role': 'customer'},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Right extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: HeroFrame(
        callout: GlassPill(
          children: [
            const LiveDot(color: AppColors.neon, size: 7),
            const SizedBox(width: 10),
            Text(
              AppStrings.shadowLive,
              style: AppTextStyles.mono(
                size: 11,
                color: AppColors.neon,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
