import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/inspection.dart';

/// Local reminders for scheduled/recurring inspections (spec §9.24/§33).
/// Deliberately local-only — no push infrastructure, no Firebase Cloud
/// Messaging. If notification permission is denied, the app keeps working
/// normally; it just never reminds the inspector.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();
    // Best-effort local timezone: fall back to UTC rather than throwing if
    // the platform can't resolve one — a reminder a few hours off is far
    // better than a crash.
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      // Leave tz.local at its default (UTC) — scheduling still works, the
      // displayed reminder time just isn't timezone-corrected.
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  /// Returns whether the user granted permission. Safe to call repeatedly —
  /// the OS only prompts once; subsequent calls just report the current
  /// state.
  Future<bool> requestPermission() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// Schedules a reminder for a scheduled inspection at [remindAt] (typically
  /// "the day before, at a sensible hour" — the caller decides the offset).
  /// Uses the inexact Android scheduling mode deliberately: a reminder being
  /// a few minutes late is fine, and this avoids requiring the separate
  /// "exact alarm" permission dance for something this low-stakes.
  Future<void> scheduleInspectionReminder({
    required Inspection inspection,
    required DateTime remindAt,
  }) async {
    await initialize();
    if (remindAt.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: _notificationIdFor(inspection.id),
      scheduledDate: tz.TZDateTime.from(remindAt, tz.local),
      title: '${inspection.templateName} at ${inspection.siteName}',
      body: 'Tomorrow — tap to view details.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'inspection_reminders',
          'Inspection Reminders',
          channelDescription:
              'Reminders for scheduled and recurring inspections',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: inspection.id,
    );
  }

  Future<void> cancelReminder(String inspectionId) async {
    await _plugin.cancel(id: _notificationIdFor(inspectionId));
  }

  /// Notification ids must be 32-bit ints; inspection ids are strings (see
  /// core/network/api_client.dart's normalizeIds), so derive a stable int.
  int _notificationIdFor(String inspectionId) =>
      inspectionId.hashCode & 0x7fffffff;
}
