import 'package:freezed_annotation/freezed_annotation.dart';

part 'evidence.freezed.dart';
part 'evidence.g.dart';

@freezed
abstract class Evidence with _$Evidence {
  const factory Evidence({
    required String id,
    required String inspectionId,
    String? inspectionItemId,
    String? findingId,
    required String filePath,
    String? watermarkedPath,
    String? fileUrl,
    double? latitude,
    double? longitude,
    required DateTime capturedAt,
  }) = _Evidence;

  factory Evidence.fromJson(Map<String, dynamic> json) =>
      _$EvidenceFromJson(json);
}
