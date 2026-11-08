import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspector.freezed.dart';
part 'inspector.g.dart';

@freezed
abstract class Inspector with _$Inspector {
  const factory Inspector({
    required String id,
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
    @Default('active') String status,
  }) = _Inspector;

  factory Inspector.fromJson(Map<String, dynamic> json) =>
      _$InspectorFromJson(json);
}
