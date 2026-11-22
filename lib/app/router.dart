import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/new_career/new_career_screen.dart';
import '../features/player/player_detail_screen.dart';
import '../features/squad/squad_screen.dart';
import '../features/start/start_screen.dart';

abstract final class AppRoutes {
  static const String start = '/';
  static const String newCareer = '/new-career';
  static const String dashboard = '/dashboard';
  static const String squad = '/squad';
  static const String player = '/player';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = switch (settings.name) {
      start => (BuildContext _) => const StartScreen(),
      newCareer => (BuildContext _) => const NewCareerScreen(),
      dashboard => (BuildContext _) => const DashboardScreen(),
      squad => (BuildContext _) => const SquadScreen(),
      player =>
        (BuildContext _) =>
            PlayerDetailScreen(playerId: settings.arguments as int),
      _ => (BuildContext _) => const StartScreen(),
    };
    return MaterialPageRoute<void>(builder: builder, settings: settings);
  }
}
