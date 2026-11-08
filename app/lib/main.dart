import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers/repository_providers.dart';
import 'core/network/api_client.dart';
import 'data/datasources/demo/demo_data_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fail fast on a misconfigured release build instead of letting every
  // request fail silently (QC-049).
  final configProblem = apiConfigProblem(
    useApi: useApiMode,
    baseUrl: apiBaseUrl,
    release: kReleaseMode,
  );
  if (configProblem != null) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(configProblem, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
    return;
  }
  // Resume any inspection progress left over from a previous session before
  // the first screen renders (spec §9.22/§9.23 — draft/offline autosave).
  await DemoDataStore.instance.restoreFromDisk();
  runApp(const ProviderScope(child: InspectlyApp()));
}
