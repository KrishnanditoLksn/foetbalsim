import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../dashboard/dashboard_screen.dart';
import '../fixtures/fixtures_screen.dart';
import '../inbox/inbox_screen.dart';
import '../squad/squad_screen.dart';
import '../transfer/transfer_screen.dart';

/// Indeks tab shell. Dipakai layar lain untuk berpindah tab.
abstract final class ShellTab {
  static const home = 0;
  static const squad = 1;
  static const fixtures = 2;
  static const transfer = 3;
  static const inbox = 4;
}

/// Wadah utama setelah karier dibuka: 5 tab dengan Bottom Navigation Bar.
///
/// Tab dibangun saat pertama kali dibuka (bukan sekaligus) lalu dijaga di
/// [IndexedStack], sehingga posisi scroll tiap tab tidak hilang.
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  final Set<int> _visited = {ShellTab.home};

  static const _pages = <Widget>[
    DashboardScreen(),
    SquadScreen(),
    FixturesScreen(),
    TransferScreen(),
    InboxScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(shellTabProvider);
    _visited.add(tab);
    final pending =
        ref.watch(gameStatusProvider).valueOrNull?.pendingActions.length ?? 0;

    return PopScope(
      canPop: false,
      // Kembali: tab lain → Beranda; dari Beranda → menu utama.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (tab != ShellTab.home) {
          ref.read(shellTabProvider.notifier).state = ShellTab.home;
        } else {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.start, (_) => false);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: tab,
          children: [
            for (var i = 0; i < _pages.length; i++)
              _visited.contains(i) ? _pages[i] : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected:
              (i) => ref.read(shellTabProvider.notifier).state = i,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            const NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups_rounded),
              label: 'Skuad',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Jadwal',
            ),
            const NavigationDestination(
              icon: Icon(Icons.swap_horiz_outlined),
              selectedIcon: Icon(Icons.swap_horiz_rounded),
              label: 'Transfer',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pending > 0,
                label: Text('$pending'),
                child: const Icon(Icons.inbox_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: pending > 0,
                label: Text('$pending'),
                child: const Icon(Icons.inbox_rounded),
              ),
              label: 'Inbox',
            ),
          ],
        ),
      ),
    );
  }
}
