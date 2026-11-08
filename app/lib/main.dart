import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/datasources/demo/demo_data_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Resume any inspection progress left over from a previous session before
  // the first screen renders (spec §9.22/§9.23 — draft/offline autosave).
  await DemoDataStore.instance.restoreFromDisk();
  runApp(const ProviderScope(child: InspectlyApp()));
}
