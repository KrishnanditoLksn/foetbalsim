import 'package:flutter/material.dart';

import 'player_search_view.dart';

/// Layar penuh pencarian pemain di database (semua liga & agen bebas).
class PlayerSearchScreen extends StatelessWidget {
  const PlayerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Pemain')),
      body: const PlayerSearchView(),
    );
  }
}
