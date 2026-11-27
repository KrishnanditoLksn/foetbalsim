import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/widgets/futbol_ui.dart';
import '../../domain/enums/position.dart';
import '../../domain/models/game_models.dart';
import '../../l10n/l10n.dart';
import '../tactics/tactics_screen.dart';

/// Tab Skuad: daftar pemain dan taktik dalam satu tempat.
class SquadScreen extends StatelessWidget {
  const SquadScreen({super.key, this.initialTab = 0});

  /// 0 = Daftar Skuad, 1 = Taktik.
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('nav.squad')),
          bottom: TabBar(
            tabs: [
              Tab(text: tr('squad.tabList')),
              Tab(text: tr('squad.tabTactics')),
            ],
          ),
        ),
        body: const TabBarView(children: [SquadListView(), TacticsView()]),
      ),
    );
  }
}

enum _SortField {
  ca,
  condition,
  age,
  value,
  name,
  position;

  String get label => tr('squad.sort.$name');
}

/// Daftar skuad seperti lembar susunan pemain: filter posisi, urutan, dan
/// satu baris per pemain.
class SquadListView extends ConsumerStatefulWidget {
  const SquadListView({super.key});

  @override
  ConsumerState<SquadListView> createState() => _SquadListViewState();
}

class _SquadListViewState extends ConsumerState<SquadListView> {
  _SortField _sortField = _SortField.ca;
  bool _ascending = false;
  PositionGroup? _group; // null = semua posisi

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
            .where((p) => _group == null || p.position.group == _group)
            .toList();

    int compare(Player a, Player b) => switch (_sortField) {
      _SortField.position => a.position.index.compareTo(b.position.index),
      _SortField.name => a.fullName.compareTo(b.fullName),
      _SortField.age => a.age.compareTo(b.age),
      _SortField.ca => a.currentAbility.compareTo(b.currentAbility),
      _SortField.condition => a.condition.compareTo(b.condition),
      _SortField.value => a.marketValue.compareTo(b.marketValue),
    };

    list.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final clubId = ref.watch(gameStateProvider).valueOrNull?.clubId;
    if (clubId == null) return Center(child: Text(tr('common.noClub')));
    final squad = ref.watch(squadProvider(clubId));

    return squad.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) =>
              Center(child: Text(tr('squad.loadFailed', {'error': '$e'}))),
      data: (players) {
        final rows = _applySortAndFilter(players);
        return Column(
          children: [
            _FilterBar(
              group: _group,
              counts: {
                for (final g in PositionGroup.values)
                  g: players.where((p) => p.position.group == g).length,
              },
              total: players.length,
              onGroup: (g) => setState(() => _group = g),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr('squad.playerCount', {'n': rows.length}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Chalk.dim, fontSize: 13),
                    ),
                  ),
                  _SortMenu(
                    field: _sortField,
                    ascending: _ascending,
                    onSelected: _sortBy,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: rows.length,
                separatorBuilder: (_, _) => const Divider(indent: 20),
                itemBuilder:
                    (context, i) => PlayerListCard(
                      player: rows[i],
                      onTap:
                          () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.player, arguments: rows[i].id),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.group,
    required this.counts,
    required this.total,
    required this.onGroup,
  });

  final PositionGroup? group;
  final Map<PositionGroup, int> counts;
  final int total;
  final ValueChanged<PositionGroup?> onGroup;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          ChoiceChip(
            label: Text('${tr('searchStatus.all')} ($total)'),
            selected: group == null,
            showCheckmark: false,
            onSelected: (_) => onGroup(null),
          ),
          for (final g in PositionGroup.values) ...[
            const SizedBox(width: 6),
            ChoiceChip(
              label: Text('${positionGroupShort(g)} (${counts[g] ?? 0})'),
              selected: group == g,
              showCheckmark: false,
              side: BorderSide(
                color:
                    group == g
                        ? positionColor(g)
                        : Theme.of(context).colorScheme.outlineVariant,
              ),
              selectedColor: positionColor(g).withValues(alpha: 0.18),
              onSelected: (_) => onGroup(group == g ? null : g),
            ),
          ],
        ],
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({
    required this.field,
    required this.ascending,
    required this.onSelected,
  });

  final _SortField field;
  final bool ascending;
  final ValueChanged<_SortField> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SortField>(
      tooltip: tr('squad.changeSort'),
      onSelected: onSelected,
      itemBuilder:
          (_) => [
            for (final f in _SortField.values)
              CheckedPopupMenuItem(
                value: f,
                checked: f == field,
                child: Text(tr('squad.sortBy', {'field': f.label})),
              ),
          ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                tr('squad.sortBy', {'field': field.label}),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: Chalk.dim,
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu baris pemain: posisi, nama dan usia, kondisi, kemampuan (CA), dan
/// nilai pasar.
class PlayerListCard extends StatelessWidget {
  const PlayerListCard({
    super.key,
    required this.player,
    this.onTap,
    this.leading,
    this.selected = false,
  });

  final Player player;
  final VoidCallback? onTap;

  /// Widget tambahan sebelum [PositionBadge] (mis. label slot formasi).
  final Widget? leading;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = player;
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: selected ? accent.withValues(alpha: 0.16) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? accent : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 20, 10),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              PositionBadge(p.position),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            p.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (p.isTransferListed) ...[
                          const SizedBox(width: 6),
                          Tooltip(
                            message: tr('squad.onTransferList'),
                            child: const Icon(
                              Icons.sell_outlined,
                              size: 15,
                              color: Chalk.yellow,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Wrap: di baris sempit (mis. taktik) bar turun ke baris
                    // berikutnya alih-alih overflow.
                    Wrap(
                      spacing: 10,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          tr('common.age', {'n': p.age}),
                          style: const TextStyle(
                            color: Chalk.dim,
                            fontSize: 13,
                          ),
                        ),
                        ConditionBar(p.condition, width: 40),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RatingPill(p.currentAbility),
                  const SizedBox(height: 3),
                  Text(
                    formatMoney(p.marketValue),
                    style: const TextStyle(
                      color: Chalk.dim,
                      fontSize: 12,
                      fontFeatures: tabular,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
