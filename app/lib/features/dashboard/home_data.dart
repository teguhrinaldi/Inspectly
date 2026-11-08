import '../../core/utils/date_labels.dart';
import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';

/// Derivations shared by the phone and tablet Home and the tablet sidebar.
/// All of them read the inspections already loaded from the repository —
/// nothing here is stored or invented.
class HomeData {
  HomeData(this.all, this.userId, {DateTime? now})
    : now = now ?? DateTime.now();

  final List<Inspection> all;
  final String? userId;
  final DateTime now;

  DateTime get _today => DateTime(now.year, now.month, now.day);
  DateTime get _tomorrow => _today.add(const Duration(days: 1));

  Iterable<Inspection> get mine => all.where((i) => i.inspectorId == userId);

  int countMine(InspectionStatus status) =>
      mine.where((i) => i.status == status).length;

  /// The signed-in inspector's inspection in progress, most recently started
  /// first — what "Continue" resumes.
  Inspection? get activeInspection {
    final active =
        mine.where((i) => i.status == InspectionStatus.inProgress).toList()
          ..sort(
            (a, b) => (b.startedAt ?? b.scheduledAt ?? DateTime(0)).compareTo(
              a.startedAt ?? a.scheduledAt ?? DateTime(0),
            ),
          );
    return active.firstOrNull;
  }

  /// Not completed/draft and dated today or later, soonest first (phone Home).
  List<Inspection> get upcoming =>
      all
          .where(
            (i) =>
                i.status != InspectionStatus.completed &&
                i.status != InspectionStatus.draft &&
                displayDate(i) != null &&
                !displayDate(i)!.isBefore(_today),
          )
          .toList()
        ..sort((a, b) => displayDate(a)!.compareTo(displayDate(b)!));

  /// The inspector's work for today: open inspections due today or overdue,
  /// plus anything completed today. The active inspection first, then other
  /// in-progress, scheduled and review work, each by time.
  List<Inspection> get today {
    bool dueByToday(Inspection i) {
      final d = displayDate(i);
      return d != null && d.isBefore(_tomorrow);
    }

    bool completedToday(Inspection i) {
      final c = i.completedAt;
      return c != null && !c.isBefore(_today) && c.isBefore(_tomorrow);
    }

    final activeId = activeInspection?.id;
    int rank(Inspection i) => i.id == activeId
        ? 0
        : switch (i.status) {
            InspectionStatus.inProgress => 1,
            InspectionStatus.scheduled => 2,
            InspectionStatus.review => 3,
            _ => 4,
          };

    return mine
        .where(
          (i) => switch (i.status) {
            InspectionStatus.scheduled ||
            InspectionStatus.inProgress ||
            InspectionStatus.review => dueByToday(i),
            InspectionStatus.completed => completedToday(i),
            InspectionStatus.draft => false,
          },
        )
        .toList()
      ..sort((a, b) {
        final byRank = rank(a).compareTo(rank(b));
        if (byRank != 0) return byRank;
        return (displayDate(a) ?? DateTime(0)).compareTo(
          displayDate(b) ?? DateTime(0),
        );
      });
  }

  /// Completed inspections (each has a report), newest first.
  List<Inspection> get recentReports =>
      all
          .where(
            (i) =>
                i.status == InspectionStatus.completed && i.completedAt != null,
          )
          .toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
}
