import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/utils/format_utils.dart';
import '../../domain/enums/position.dart';
import '../../domain/models/game_models.dart';
import '../../domain/generators/world_generator.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/player_search.dart';

/// Pencarian pemain lintas klub dengan filter dan pengurutan. Dipakai di
/// tab "Cari Pemain" dan di layar penuh.
class PlayerSearchView extends ConsumerStatefulWidget {
  const PlayerSearchView({super.key});

  @override
  ConsumerState<PlayerSearchView> createState() => _PlayerSearchViewState();
}

class _PlayerSearchViewState extends ConsumerState<PlayerSearchView> {
  PlayerSearchFilter _f = const PlayerSearchFilter();
  bool _advanced = false;

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(playerSearchRowsProvider);
    final state = ref.watch(gameStateProvider).valueOrNull;
    final leagues = ref.watch(leaguesProvider).valueOrNull ?? const <League>[];
    final now = state?.currentDate ?? WorldGenerator.seasonStart;

    return rows.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat pemain: $e')),
      data: (all) {
        final result = PlayerSearch.apply(all, _f, now: now);
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari nama pemain',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged:
                    (v) => setState(() => _f = _f.copyWith(query: v)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<Object?>(
                    value: _f.position ?? _f.group,
                    hint: const Text('Posisi'),
                    items: [
                      const DropdownMenuItem<Object?>(
                        value: null,
                        child: Text('Semua posisi'),
                      ),
                      for (final g in PositionGroup.values)
                        DropdownMenuItem<Object?>(
                          value: g,
                          child: Text(g.label),
                        ),
                      for (final p in Position.values)
                        DropdownMenuItem<Object?>(
                          value: p,
                          child: Text('  ${p.label}'),
                        ),
                    ],
                    onChanged: _onPosition,
                  ),
                  DropdownButton<PlayerSearchStatus>(
                    value: _f.status,
                    items: [
                      for (final s in PlayerSearchStatus.values)
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged:
                        (s) => setState(
                          () => _f = _f.copyWith(status: s),
                        ),
                  ),
                  DropdownButton<PlayerSort>(
                    value: _f.sort,
                    items: [
                      for (final s in PlayerSort.values)
                        DropdownMenuItem(
                          value: s,
                          child: Text('Urut: ${s.label}'),
                        ),
                    ],
                    onChanged:
                        (s) => setState(() => _f = _f.copyWith(sort: s)),
                  ),
                  IconButton(
                    tooltip: _f.ascending ? 'Naik' : 'Turun',
                    onPressed:
                        () => setState(
                          () => _f = _f.copyWith(ascending: !_f.ascending),
                        ),
                    icon: Icon(
                      _f.ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              initiallyExpanded: _advanced,
              onExpansionChanged: (v) => setState(() => _advanced = v),
              title: const Text('Filter lanjutan'),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _NumField(
                      label: 'Usia min',
                      value: _f.ageMin,
                      onChanged:
                          (v) => setState(
                            () => _f = _f.copyWith(
                              ageMin: v,
                              clearAgeMin: v == null,
                            ),
                          ),
                    ),
                    _NumField(
                      label: 'Usia maks',
                      value: _f.ageMax,
                      onChanged:
                          (v) => setState(
                            () => _f = _f.copyWith(
                              ageMax: v,
                              clearAgeMax: v == null,
                            ),
                          ),
                    ),
                    _NumField(
                      label: 'CA min',
                      value: _f.caMin,
                      onChanged:
                          (v) => setState(
                            () => _f = _f.copyWith(
                              caMin: v,
                              clearCaMin: v == null,
                            ),
                          ),
                    ),
                    _NumField(
                      label: 'CA maks',
                      value: _f.caMax,
                      onChanged:
                          (v) => setState(
                            () => _f = _f.copyWith(
                              caMax: v,
                              clearCaMax: v == null,
                            ),
                          ),
                    ),
                    _NumField(
                      label: 'Nilai maks (€ jt)',
                      value:
                          _f.maxMarketValue == null
                              ? null
                              : _f.maxMarketValue! ~/ 1000,
                      onChanged:
                          (v) => setState(
                            () => _f = _f.copyWith(
                              maxMarketValue: v == null ? null : v * 1000,
                              clearMaxValue: v == null,
                            ),
                          ),
                    ),
                    DropdownButton<String?>(
                      value: _f.leagueId,
                      hint: const Text('Liga'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Semua liga'),
                        ),
                        for (final l in leagues)
                          DropdownMenuItem<String?>(
                            value: l.id,
                            child: Text(l.name),
                          ),
                      ],
                      onChanged:
                          (v) => setState(
                            () => _f = _f.copyWith(
                              leagueId: v,
                              clearLeague: v == null,
                            ),
                          ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${result.length} pemain',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
            Expanded(
              child:
                  result.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Tidak ada pemain yang cocok dengan filter.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: result.length,
                        itemBuilder:
                            (context, i) => _SearchTile(row: result[i]),
                      ),
            ),
          ],
        );
      },
    );
  }

  void _onPosition(Object? v) {
    setState(() {
      if (v is Position) {
        _f = _f.copyWith(position: v, clearGroup: true);
      } else if (v is PositionGroup) {
        _f = _f.copyWith(group: v, clearPosition: true);
      } else {
        _f = _f.copyWith(clearPosition: true, clearGroup: true);
      }
    });
  }
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        initialValue: value?.toString() ?? '',
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, isDense: true),
        onChanged: (t) => onChanged(int.tryParse(t.trim())),
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({required this.row});

  final PlayerSearchRow row;

  @override
  Widget build(BuildContext context) {
    final p = row.player;
    return ListTile(
      onTap:
          () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.player, arguments: p.id),
      title: Text(p.fullName),
      subtitle: Text(
        '${p.position.label} · ${row.clubName} · ${p.age} th'
        '${row.isForSale ? ' · Daftar jual' : ''}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('CA ${p.currentAbility}'),
          Text(
            formatMoney(p.marketValue),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
