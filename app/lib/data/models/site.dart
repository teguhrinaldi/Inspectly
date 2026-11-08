import 'package:freezed_annotation/freezed_annotation.dart';

part 'site.freezed.dart';
part 'site.g.dart';

@freezed
abstract class Site with _$Site {
  const factory Site({
    required String id,
    required String customerId,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    required String qrCode,
    @Default('active') String status,
    String? coverImageUrl,
    // Denormalized for list/detail display without an extra lookup.
    String? customerName,
  }) = _Site;

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);
}
