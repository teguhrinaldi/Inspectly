import 'package:dio/dio.dart';

import '../errors/failure.dart';
import '../storage/token_storage.dart';

/// Base URL of the Laravel API. `10.0.2.2` is how the Android emulator
/// reaches the host machine's `localhost`; adjust for a physical device or
/// production deployment. This is the *only* place a buyer needs to point at
/// their own deployed backend when switching to API Mode.
const String apiBaseUrl = String.fromEnvironment(
  'INSPECTLY_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000/api',
);

/// Laravel's Eloquent models use auto-increment integer primary/foreign
/// keys; every Flutter domain model treats every id as a `String` (so the
/// same models work whether an id came from MySQL or was generated
/// client-side, e.g. `Uuid().v4()`, while offline). Rather than sprinkling a
/// `@JsonKey(fromJson: ...)` over every one of the ~50 id fields across every
/// model, every response is normalized once, centrally, right after
/// decoding: any map key that is exactly `id` or ends in `_id` whose value is
/// a number gets stringified.
dynamic normalizeIds(dynamic data) {
  if (data is Map) {
    return <String, dynamic>{
      for (final entry in data.entries)
        entry.key as String:
            (entry.key is String &&
                (entry.key == 'id' || (entry.key as String).endsWith('_id')) &&
                entry.value is num)
            ? entry.value.toString()
            : normalizeIds(entry.value),
    };
  }
  if (data is List) {
    return data.map(normalizeIds).toList();
  }
  return data;
}

/// Thin Dio wrapper: attaches the Sanctum bearer token to every request and
/// converts transport/HTTP errors into the app's [Failure] types so
/// repositories never leak raw Dio/HTTP exceptions to the UI (spec §24).
class ApiClient {
  ApiClient({Dio? dio, TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? TokenStorage(),
      dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Accept': 'application/json'},
            ),
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          response.data = normalizeIds(response.data);
          handler.next(response);
        },
      ),
    );
  }

  final Dio dio;
  final TokenStorage _tokenStorage;

  /// Runs [request] and maps any [DioException] to a [Failure], so callers
  /// only ever deal with `Result<T>` (see core/utils/result.dart).
  Future<T> guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Laravel's `JsonResource` wraps every *single*-item response in a
  /// `{"data": {...}}` envelope by default (collections do too, which is
  /// already the natural shape for pagination — this helper is only for the
  /// single-item case). Use this instead of casting `response.data` directly.
  Map<String, dynamic> unwrap(Response response) =>
      (response.data as Map)['data'] as Map<String, dynamic>;

  Failure _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final message = body is Map && body['message'] is String
        ? body['message'] as String
        : null;

    switch (status) {
      case 401:
        return UnauthorizedFailure(
          message ?? 'Your session has expired. Please log in again.',
        );
      case 403:
        return ForbiddenFailure(
          message ?? 'You do not have permission to do this.',
        );
      case 404:
        return NotFoundFailure(
          message ?? 'The requested item could not be found.',
        );
      case 422:
        final errorsRaw = (body is Map ? body['errors'] : null) as Map?;
        final errors = <String, List<String>>{
          if (errorsRaw != null)
            for (final entry in errorsRaw.entries)
              entry.key as String: List<String>.from(entry.value as List),
        };
        return ValidationFailure(
          errors,
          message ?? 'Please check the information you entered.',
        );
      default:
        if (status != null && status >= 500) return const ServerFailure();
        return UnknownFailure(message ?? 'An unexpected error occurred.');
    }
  }
}
