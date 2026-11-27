import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/save_session.dart';
import '../../core/widgets/club_badge.dart';
import '../../data/database/save_storage.dart';
import '../../data/repositories/world_repository.dart';
import '../../domain/models/game_models.dart';
import '../../l10n/l10n.dart';

/// Alur: nama manajer → pilih liga → pilih klub → membangun dunia → dashboard.
class NewCareerScreen extends ConsumerStatefulWidget {
  const NewCareerScreen({super.key});

  @override
  ConsumerState<NewCareerScreen> createState() => _NewCareerScreenState();
}

class _NewCareerScreenState extends ConsumerState<NewCareerScreen> {
  final _nameController = TextEditingController();
  int _step = 0;
  League? _league;
  bool _building = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _back() {
    if (_step == 0 || _building) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _pickClub(Club club) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(club.name),
            content: Text(
              tr('newCareer.confirm', {
                'name': _nameController.text.trim(),
                'club': club.name,
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr('common.cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr('newCareer.start')),
              ),
            ],
          ),
    );
    if (ok != true || !mounted) return;

    setState(() => _building = true);
    bool created;
    try {
      final seedJson = await WorldRepository.loadSeedJson();
      created = await createNewCareer(
        ref,
        seedJson: seedJson,
        managerName: _nameController.text.trim(),
        clubId: club.id,
      );
    } catch (e, st) {
      debugPrint('Gagal membuat karier: $e\n$st');
      if (!mounted) return;
      setState(() => _building = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('newCareer.failed', {'error': '$e'}))),
      );
      return;
    }
    if (!mounted) return;

    if (!created) {
      setState(() => _building = false);
      final navigator = Navigator.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('newCareer.slotsFull', {'max': SaveStorage.maxSlots}),
          ),
          action: SnackBarAction(
            label: tr('newCareer.manageSaves'),
            onPressed: () => navigator.pushNamed(AppRoutes.loadGame),
          ),
        ),
      );
      return;
    }
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_building) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(tr('newCareer.building')),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('newCareer.title')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _back,
          ),
        ),
        body: switch (_step) {
          0 => _buildNameStep(),
          1 => _buildLeagueStep(),
          _ => _buildClubStep(),
        },
      ),
    );
  }

  Widget _buildNameStep() {
    return _Padded(
      children: [
        Text(
          tr('newCareer.askName'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: tr('newCareer.nameLabel'),
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
        const Spacer(),
        FilledButton(
          onPressed:
              _nameController.text.trim().isEmpty
                  ? null
                  : () => setState(() => _step = 1),
          child: Text(tr('newCareer.next')),
        ),
      ],
    );
  }

  Widget _buildLeagueStep() {
    final catalog = ref.watch(seedCatalogProvider);
    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => Center(
            child: Text(tr('newCareer.leaguesFailed', {'error': '$e'})),
          ),
      data:
          (seed) => _Padded(
            children: [
              Text(
                tr('newCareer.pickLeague'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final league in seed.leagues)
                      Card(
                        child: ListTile(
                          title: Text(league.name),
                          subtitle: Text(
                            tr('newCareer.leagueInfo', {
                                  'tier': league.tier,
                                  'teams': league.jumlahTim,
                                  'down': league.slotDegradasi,
                                }) +
                                (league.slotPromosi > 0
                                    ? ' · ${tr('newCareer.promotion', {'n': league.slotPromosi})}'
                                    : ''),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap:
                              () => setState(() {
                                _league = league;
                                _step = 2;
                              }),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildClubStep() {
    final league = _league;
    if (league == null) return const SizedBox.shrink();
    final catalog = ref.watch(seedCatalogProvider);
    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) =>
              Center(child: Text(tr('newCareer.clubsFailed', {'error': '$e'}))),
      data: (seed) => _buildClubList(league, seed.clubsOf(league.id)),
    );
  }

  Widget _buildClubList(League league, List<Club> list) {
    return _Padded(
      children: [
        Text(league.name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final club = list[i];
              return ListTile(
                leading: ClubBadge(club: club),
                title: Text(club.name),
                subtitle: Text(
                  '${tr('newCareer.reputation', {'n': club.reputation})} · '
                  '${club.stadiumName} (${club.capacity})\n'
                  '${tr('newCareer.finances', {'balance': formatMoney(club.balance), 'transfer': formatMoney(club.transferBudget), 'wage': formatMoney(club.wageBudget)})}',
                ),
                isThreeLine: true,
                onTap: () => _pickClub(club),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Padded extends StatelessWidget {
  const _Padded({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
