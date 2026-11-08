import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api/api_auth_repository.dart';
import '../../data/repositories/api/api_customer_repository.dart';
import '../../data/repositories/api/api_evidence_repository.dart';
import '../../data/repositories/api/api_inspection_repository.dart';
import '../../data/repositories/api/api_inspector_repository.dart';
import '../../data/repositories/api/api_signature_repository.dart';
import '../../data/repositories/api/api_site_repository.dart';
import '../../data/repositories/api/api_template_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/evidence_repository.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../data/repositories/inspector_repository.dart';
import '../../data/repositories/mock/mock_auth_repository.dart';
import '../../data/repositories/mock/mock_customer_repository.dart';
import '../../data/repositories/mock/mock_evidence_repository.dart';
import '../../data/repositories/mock/mock_inspection_repository.dart';
import '../../data/repositories/mock/mock_inspector_repository.dart';
import '../../data/repositories/mock/mock_signature_repository.dart';
import '../../data/repositories/mock/mock_site_repository.dart';
import '../../data/repositories/mock/mock_template_repository.dart';
import '../../data/repositories/signature_repository.dart';
import '../../data/repositories/site_repository.dart';
import '../../data/repositories/template_repository.dart';
import 'auth_providers.dart';

/// The single Demo Mode ↔ API Mode switch (spec §6). Every repository below
/// is wired through this one flag — screens and controllers only ever depend
/// on the repository *interfaces* (never `Mock*`/`Api*` directly), so this is
/// the only file a buyer needs to touch to point the app at their deployed
/// Laravel backend instead of the built-in demo dataset. Set the API base URL
/// in `core/network/api_client.dart` (`apiBaseUrl`) alongside this flag.
///
/// Kept as a plain compile-time constant (not a runtime settings toggle):
/// which backend a build talks to is a deployment decision, not something an
/// end user picks in the UI.
const bool useApiMode = bool.fromEnvironment(
  'INSPECTLY_USE_API',
  defaultValue: false,
);

/// Whether the login screen offers "Continue with Demo Account" (signs in as
/// the seeded demo inspector, docs/demo-data.md). Always on in demo mode; in
/// API mode only for builds pointed at a demo-seeded backend
/// (`--dart-define=INSPECTLY_DEMO_LOGIN=true`) — never for production.
const bool demoLoginAvailable =
    !useApiMode || bool.fromEnvironment('INSPECTLY_DEMO_LOGIN');
const demoAccountEmail = 'michael.carter@inspectly.test';
const demoAccountPassword = 'password';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => useApiMode ? ApiAuthRepository() : MockAuthRepository(),
);

/// Id of the signed-in user (null when signed out). Every data repository
/// below watches it, so all cached lists/details are rebuilt whenever the
/// user changes and one inspector never sees another's cached data on a
/// shared device (QC-009). The auth repository itself must not watch it.
final sessionUserIdProvider = Provider<String?>(
  (ref) => switch (ref.watch(authStateProvider)) {
    AuthLoggedIn(:final user) => user.id,
    _ => null,
  },
);

final inspectionRepositoryProvider = Provider<InspectionRepository>((ref) {
  ref.watch(sessionUserIdProvider);
  return useApiMode ? ApiInspectionRepository() : MockInspectionRepository();
});

final siteRepositoryProvider = Provider<SiteRepository>((ref) {
  ref.watch(sessionUserIdProvider);
  return useApiMode ? ApiSiteRepository() : MockSiteRepository();
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  ref.watch(sessionUserIdProvider);
  return useApiMode ? ApiCustomerRepository() : MockCustomerRepository();
});

final inspectorRepositoryProvider = Provider<InspectorRepository>((ref) {
  ref.watch(sessionUserIdProvider);
  return useApiMode ? ApiInspectorRepository() : MockInspectorRepository();
});

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  ref.watch(sessionUserIdProvider);
  return useApiMode ? ApiTemplateRepository() : MockTemplateRepository();
});

final evidenceRepositoryProvider = Provider<EvidenceRepository>((ref) {
  ref.watch(sessionUserIdProvider);
  return useApiMode ? ApiEvidenceRepository() : MockEvidenceRepository();
});

final signatureRepositoryProvider = Provider<SignatureRepository>((ref) {
  ref.watch(sessionUserIdProvider);
  return useApiMode ? ApiSignatureRepository() : MockSignatureRepository();
});
