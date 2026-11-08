import '../../data/models/enums.dart';
import '../../data/models/inspection.dart';

/// Points deducted from 100 per finding, by severity.
const severityDeduction = {
  FindingSeverity.critical: 8,
  FindingSeverity.high: 5,
  FindingSeverity.medium: 2,
  FindingSeverity.low: 1,
};

/// Deterministic risk summary computed from recorded results:
/// - a failed item is "Failed" when it carries a critical/high finding and
///   "Needs Attention" otherwise;
/// - overall compliance is 100 minus the severity deductions of the
///   inspection's findings (never below 0).
class RiskBreakdown {
  RiskBreakdown(Inspection i)
    : passed = i.passCount,
      failed = i.items.where((item) {
        if (item.result != ChecklistResult.fail) return false;
        return i.findings.any(
          (f) =>
              f.inspectionItemId == item.id &&
              (f.severity == FindingSeverity.critical ||
                  f.severity == FindingSeverity.high),
        );
      }).length,
      notApplicable = i.naCount,
      passRate = i.computedPassPercentage,
      compliance =
          (100 -
                  i.findings.fold<int>(
                    0,
                    (sum, f) => sum + severityDeduction[f.severity]!,
                  ))
              .clamp(0, 100),
      _failCount = i.failCount;

  final int passed;
  final int failed;
  final int notApplicable;
  final double passRate;
  final int compliance;
  final int _failCount;

  int get needsAttention => _failCount - failed;
}
