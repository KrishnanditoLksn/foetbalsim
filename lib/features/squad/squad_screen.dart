import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/utils/format_utils.dart';
import '../../domain/enums/position.dart';
import '../../domain/models/game_models.dart';

enum _SortField { position, name, age, ca, condition, morale, value }

class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key});

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  _SortField _sortField = _SortField.ca;
  bool _ascending = false;
  Position? _positionFilter; // null = semua posisi

  static const _columns = <(_SortField, String)>[
    (_SortField.position, 'Posisi'),
    (_SortField.name, 'Nama'),
    (_SortField.age, 'Usia'),
    (_SortField.ca, 'CA'),
    (_SortField.condition, 'Kondisi'),
    (_SortField.morale, 'Moral'),
    (_SortField.value, 'Nilai'),
  ];

  void _sortBy(_SortField field) {
    setState(() {
      if (_sortField == field) {
        _ascending = !_ascending;
      } else {
        _sortField = field;
        _ascending = field == _SortField.name || field == _SortField.position;
      }
    });
  }

  List<Player> _applySortAndFilter(List<Player> input) {
    final list =
        input
            .where(
              (p) => _positionFilter == null || p.position == _positionFilter,
            )
            .toList();

    int compare(Player a, Player b) {
      switch (_sortField) {
        case _SortField.position:
          return a.position.index.compareTo(b.position.index);
        case _SortField.name:
          return a.fullName.compareTo(b.fullName);
        case _SortField.age:
          return a.age.compareTo(b.age);
        case _SortField.ca:
          return a.currentAbility.compareTo(b.currentAbility);
        case _SortField.condition:
          return a.condition.compareTo(b.condition);
        case _SortField.morale:
          return a.morale.compareTo(b.morale);
        case _SortField.value:
          return a.marketValue.compareTo(b.marketValue);
      }
    }

    list.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final clubId = state?.clubId;

    return Scaffold(
      appBar: AppBar(title: const Text('Skuad')),
      body:
          clubId == null
              ? const Center(child: Text('Belum ada klub.'))
              : _buildBody(ref.watch(squadProvider(clubId))),
    );
  }

  Widget _buildBody(AsyncValue<List<Player>> squad) {
    return squad.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat skuad: $e')),
      data: (players) {
        final rows = _applySortAndFilter(players);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Text('Posisi: '),
                  const SizedBox(width: 8),
                  DropdownButton<Position?>(
                    value: _positionFilter,
                    items: [
                      const DropdownMenuItem<Position?>(
                        value: null,
                        child: Text('Semua'),
                      ),
                      for (final pos in Position.values)
                        DropdownMenuItem<Position?>(
                          value: pos,
                          child: Text(pos.label),
                        ),
                    ],
                    onChanged: (v) => setState(() => _positionFilter = v),
                  ),
                  const Spacer(),
                  Text('${rows.length} pemain'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn: false,
                    sortColumnIndex: _columns.indexWhere(
                      (c) => c.$1 == _sortField,
                    ),
                    sortAscending: _ascending,
                    columns: [
                      for (final (field, label) in _columns)
                        DataColumn(
                          label: Text(label),
                          numeric:
                              field != _SortField.position &&
                              field != _SortField.name,
                          onSort: (_, __) => _sortBy(field),
                        ),
                    ],
                    rows: [
                      for (final p in rows)
                        DataRow(
                          onSelectChanged:
                              (_) => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.player, arguments: p.id),
                          cells: [
                            DataCell(Text(p.position.label)),
                            DataCell(Text(p.fullName)),
                            DataCell(Text('${p.age}')),
                            DataCell(_StarsCell(ca: p.currentAbility)),
                            DataCell(Text('${p.condition}%')),
                            DataCell(Text('${p.morale}')),
                            DataCell(Text(formatMoney(p.marketValue))),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StarsCell extends StatelessWidget {
  const _StarsCell({required this.ca});

  final int ca;

  @override
  Widget build(BuildContext context) {
    final stars = caToStars(ca);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= stars ? Icons.star : Icons.star_border,
            size: 16,
            color: Colors.amber.shade700,
          ),
      ],
    );
  }
}
