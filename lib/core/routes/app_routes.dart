import 'package:flutter/material.dart';

import '../../pages/call/agent_chat_page.dart';
import '../../pages/call/agent_console_page.dart';
import '../../pages/customer/customer_chat_page.dart';
import '../../pages/customer/customer_page.dart';
import '../../pages/home/channel_chooser_page.dart';
import '../../pages/home/home_page.dart';

/// Named routes + the central [onGenerateRoute]. Navigate with these constants
/// only (CLAUDE.md) — never raw strings or inline `MaterialPageRoute`.
class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String customer = '/customer';
  static const String call = '/call';
  static const String channelChooser = '/channelChooser';
  static const String agentChat = '/agentChat';
  static const String customerChat = '/customerChat';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _page(const HomePage(), settings);
      case customer:
        return _page(const CustomerPage(), settings);
      case call:
        return _page(const AgentConsolePage(), settings);
      case channelChooser:
        return _page(const ChannelChooserPage(), settings);
      case agentChat:
        return _page(const AgentChatPage(), settings);
      case customerChat:
        return _page(const CustomerChatPage(), settings);
      default:
        return _page(const HomePage(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) => MaterialPageRoute(builder: (_) => child, settings: settings);
}
