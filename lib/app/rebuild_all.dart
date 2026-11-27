import 'package:flutter/widgets.dart';

/// Menandai semua widget untuk dibangun ulang tanpa mengubah state navigasi
/// atau layar. Dipakai saat nilai global yang dibaca langsung oleh widget
/// berubah: bahasa (`tr()`) dan palet papan (`Chalk.*`).
void rebuildAllWidgets() {
  void visit(Element el) {
    el.markNeedsBuild();
    el.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
}
