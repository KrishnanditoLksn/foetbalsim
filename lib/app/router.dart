import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/fixtures/fixtures_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/load_game/load_game_screen.dart';
import '../features/new_career/new_career_screen.dart';
import '../features/player/player_detail_screen.dart';
import '../features/squad/squad_screen.dart';
import '../features/start/start_screen.dart';

abstract final class AppRoutes {
  static const String start = '/';
  static const String newCareer = '/new-career';
  static const String loadGame = '/load-game';
  static const String dashboard = '/dashboard';
  static const String squad = '/squad';
  static const String player = '/player';
  static const String inbox = '/inbox';
  static const String fixtures = '/fixtures';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final WidgetBuilder builder = switch (settings.name) {
      start => (_) => const StartScreen(),
      newCareer => (_) => const NewCareerScreen(),
      loadGame => (_) => const LoadGameScreen(),
      dashboard => (_) => const DashboardScreen(),
      squad => (_) => const SquadScreen(),
      player => (_) => PlayerDetailScreen(playerId: settings.arguments as int),
      inbox => (_) => const InboxScreen(),
      fixtures => (_) => const FixturesScreen(),
      _ => (_) => const StartScreen(),
    };
    return MaterialPageRoute<void>(builder: builder, settings: settings);
  }
}
