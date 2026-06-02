import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/utils/lang_text.dart';
import 'app_bar/zill_app_bar.dart';
import 'background_stage.dart';
import 'demo_controls_panel.dart';

/// Common page chrome: background stage, the shared app bar, the page [body],
/// and the floating demo controls. Keeps every screen visually consistent.
class AppShell extends StatelessWidget {
  final Widget body;
  final TextPair? statusLabel;
  final bool showSwitchRole;
  final bool showDemoPanel;

  const AppShell({
    super.key,
    required this.body,
    this.statusLabel,
    this.showSwitchRole = false,
    this.showDemoPanel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundStage()),
          Column(
            children: [
              ZillAppBar(
                statusLabel: statusLabel,
                onBrandTap: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
                onSwitchRole: showSwitchRole
                    ? () => Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false)
                    : null,
              ),
              Expanded(child: body),
            ],
          ),
          if (showDemoPanel)
            const PositionedDirectional(
              start: 24,
              bottom: 24,
              child: DemoControlsPanel(),
            ),
        ],
      ),
    );
  }
}
