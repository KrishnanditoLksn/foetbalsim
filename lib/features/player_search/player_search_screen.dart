import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'player_search_view.dart';

/// Layar penuh pencarian pemain di database (semua liga & agen bebas).
class PlayerSearchScreen extends StatelessWidget {
  const PlayerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('search.title'))),
      body: const PlayerSearchView(),
    );
  }
}
