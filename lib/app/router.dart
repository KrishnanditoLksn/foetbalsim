import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/fixtures/fixtures_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/load_game/load_game_screen.dart';
import '../features/match/match_screen.dart';
import '../features/new_career/new_career_screen.dart';
import '../features/player/player_detail_screen.dart';
import '../features/player_search/player_search_screen.dart';
import '../features/squad/squad_screen.dart';
import '../features/start/start_screen.dart';
import '../features/tactics/tactics_screen.dart';
import '../features/transfer/transfer_screen.dart';

abstract final class AppRoutes {
  static const String start = '/';
  static const String newCareer = '/new-career';
  static const String loadGame = '/load-game';
  static const String dashboard = '/dashboard';
  static const String squad = '/squad';
  static const String player = '/player';
  static const String inbox = '/inbox';
  static const String fixtures = '/fixtures';
  static const String tactics = '/tactics';
  static const String match = '/match';
  static const String transfer = '/transfer';
  static const String playerSearch = '/player-search';

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
      tactics => (_) => const TacticsScreen(),
      match => (_) => const MatchScreen(),
      transfer => (_) => const TransferScreen(),
      playerSearch => (_) => const PlayerSearchScreen(),
      _ => (_) => const StartScreen(),
    };
    return MaterialPageRoute<void>(builder: builder, settings: settings);
  }
}
