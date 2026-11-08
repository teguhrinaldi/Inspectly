import 'package:freezed_annotation/freezed_annotation.dart';

part 'signature.freezed.dart';
part 'signature.g.dart';

enum SignatureType {
  @JsonValue('inspector')
  inspector,
  @JsonValue('customer')
  customer,
}

@freezed
abstract class InspectionSignature with _$InspectionSignature {
  const factory InspectionSignature({
    required String id,
    required String inspectionId,
    required SignatureType type,
    required String signerName,
    required String filePath,
    String? fileUrl,
    required DateTime signedAt,
  }) = _InspectionSignature;

  factory InspectionSignature.fromJson(Map<String, dynamic> json) =>
      _$InspectionSignatureFromJson(json);
}
