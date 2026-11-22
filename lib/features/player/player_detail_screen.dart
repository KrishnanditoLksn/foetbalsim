import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/format_utils.dart';
import '../../data/repositories/player_repository.dart';
import '../../domain/enums/attribute.dart';
import '../../domain/models/game_models.dart';
import '../../domain/models/player_attributes.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(playerDetailProvider(playerId));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pemain')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat pemain: $e')),
        data:
            (d) =>
                d == null
                    ? const Center(child: Text('Pemain tidak ditemukan.'))
                    : _PlayerBody(detail: d),
      ),
    );
  }
}

class _PlayerBody extends StatelessWidget {
  const _PlayerBody({required this.detail});

  final PlayerDetail detail;

  @override
  Widget build(BuildContext context) {
    final p = detail.player;
    final c = detail.contract;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(p.fullName, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('${p.position.label} · ${p.age} tahun · ${p.nationality}'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoChip(
              label: 'CA',
              value: '${caToStars(p.currentAbility)} ★ (${p.currentAbility})',
            ),
            _InfoChip(
              label: 'PA',
              value:
                  '${caToStars(p.potentialAbility)} ★ (${p.potentialAbility})',
            ),
            _InfoChip(label: 'Kondisi', value: '${p.condition}%'),
            _InfoChip(label: 'Moral', value: '${p.morale}'),
            _InfoChip(label: 'Nilai', value: formatMoney(p.marketValue)),
          ],
        ),
        const SizedBox(height: 16),
        if (c != null) _ContractCard(contract: c),
        const SizedBox(height: 16),
        for (final entry in p.attributes.byGroup.entries)
          _AttributeSection(
            title: entry.key.label,
            attributes: entry.value,
            values: p.attributes,
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({required this.contract});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final end = contract.endDate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kontrak', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Gaji: ${formatMoney(contract.wage)} / tahun'),
            Text('Berakhir: ${end.day}/${end.month}/${end.year}'),
            Text('Peran: ${contract.squadStatus.label}'),
          ],
        ),
      ),
    );
  }
}

class _AttributeSection extends StatelessWidget {
  const _AttributeSection({
    required this.title,
    required this.attributes,
    required this.values,
  });

  final String title;
  final List<Attribute> attributes;
  final PlayerAttributes values;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final a in attributes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(width: 140, child: Text(a.label)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: values[a] / 20,
                        minHeight: 8,
                        color: attributeColor(values[a]),
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${values[a]}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: attributeColor(values[a]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
