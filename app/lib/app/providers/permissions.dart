import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';
import 'auth_providers.dart';

/// Everyone can read every inspection (team view); only the assigned
/// inspector or an admin may change it — same rule as the API (QC-001).
bool canWriteInspection(AuthState auth, Inspection inspection) =>
    auth is AuthLoggedIn &&
    (auth.user.role == UserRole.admin ||
        auth.user.id == inspection.inspectorId);
