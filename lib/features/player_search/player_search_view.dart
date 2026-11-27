import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../domain/enums/position.dart';
import '../../domain/models/game_models.dart';
import '../../domain/generators/world_generator.dart';
import '../../domain/models/transfer_models.dart';
import '../../domain/transfer/player_search.dart';
import '../../l10n/l10n.dart';

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
      error:
          (e, _) =>
              Center(child: Text(tr('player.loadFailed', {'error': '$e'}))),
      data: (all) {
        final result = PlayerSearch.apply(all, _f, now: now);
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: tr('search.hint'),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _f = _f.copyWith(query: v)),
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
                    hint: Text(tr('search.position')),
                    items: [
                      DropdownMenuItem<Object?>(
                        value: null,
                        child: Text(tr('search.allPositions')),
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
                        (s) => setState(() => _f = _f.copyWith(status: s)),
                  ),
                  DropdownButton<PlayerSort>(
                    value: _f.sort,
                    items: [
                      for (final s in PlayerSort.values)
                        DropdownMenuItem(
                          value: s,
                          child: Text(tr('search.sortBy', {'field': s.label})),
                        ),
                    ],
                    onChanged: (s) => setState(() => _f = _f.copyWith(sort: s)),
                  ),
                  IconButton(
                    tooltip:
                        _f.ascending
                            ? tr('search.ascending')
                            : tr('search.descending'),
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
              title: Text(tr('search.advanced')),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _NumField(
                      label: tr('search.ageMin'),
                      value: _f.ageMin,
                      onChanged:
                          (v) => setState(
                            () =>
                                _f = _f.copyWith(
                                  ageMin: v,
                                  clearAgeMin: v == null,
                                ),
                          ),
                    ),
                    _NumField(
                      label: tr('search.ageMax'),
                      value: _f.ageMax,
                      onChanged:
                          (v) => setState(
                            () =>
                                _f = _f.copyWith(
                                  ageMax: v,
                                  clearAgeMax: v == null,
                                ),
                          ),
                    ),
                    _NumField(
                      label: tr('search.caMin'),
                      value: _f.caMin,
                      onChanged:
                          (v) => setState(
                            () =>
                                _f = _f.copyWith(
                                  caMin: v,
                                  clearCaMin: v == null,
                                ),
                          ),
                    ),
                    _NumField(
                      label: tr('search.caMax'),
                      value: _f.caMax,
                      onChanged:
                          (v) => setState(
                            () =>
                                _f = _f.copyWith(
                                  caMax: v,
                                  clearCaMax: v == null,
                                ),
                          ),
                    ),
                    _NumField(
                      label: tr('search.maxValue'),
                      value:
                          _f.maxMarketValue == null
                              ? null
                              : _f.maxMarketValue! ~/ 1000,
                      onChanged:
                          (v) => setState(
                            () =>
                                _f = _f.copyWith(
                                  maxMarketValue: v == null ? null : v * 1000,
                                  clearMaxValue: v == null,
                                ),
                          ),
                    ),
                    DropdownButton<String?>(
                      value: _f.leagueId,
                      hint: Text(tr('search.league')),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(tr('search.allLeagues')),
                        ),
                        for (final l in leagues)
                          DropdownMenuItem<String?>(
                            value: l.id,
                            child: Text(l.name),
                          ),
                      ],
                      onChanged:
                          (v) => setState(
                            () =>
                                _f = _f.copyWith(
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
                  tr('squad.playerCount', {'n': result.length}),
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
            Expanded(
              child:
                  result.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            tr('search.noResults'),
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
        '${p.position.label} · ${row.clubName} · '
        '${tr('common.age', {'n': p.age})}'
        '${row.isForSale ? ' · ${tr('searchStatus.forSale')}' : ''}',
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
