import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/habit.dart';
import '../models/reminder_repeat.dart';
import '../models/day_of_week.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Inicializa o timezone
    tz.initializeTimeZones();

    // Configurações para Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configurações para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Callback quando a notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Implementar navegação para o hábito específico
    print('Notification tapped: ${response.payload}');
  }

  /// Solicita permissões de notificação (iOS)
  Future<bool> requestPermissions() async {
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  /// Agenda notificação para um hábito
  Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.reminder == null) return;

    await initialize();

    final reminder = habit.reminder!;

    switch (reminder.repeat) {
      case ReminderRepeat.none:
        await _scheduleOneTimeNotification(
          habit,
          reminder.time.hour,
          reminder.time.minute,
        );
        break;

      case ReminderRepeat.daily:
        await _scheduleDailyNotification(
          habit,
          reminder.time.hour,
          reminder.time.minute,
        );
        break;

      case ReminderRepeat.weekly:
        await _scheduleWeeklyNotification(
          habit,
          reminder.time.hour,
          reminder.time.minute,
          reminder.daysOfWeek,
        );
        break;

      case ReminderRepeat.monthly:
        await _scheduleMonthlyNotification(
          habit,
          reminder.time.hour,
          reminder.time.minute,
        );
        break;
    }
  }

  /// Agenda uma notificação única
  Future<void> _scheduleOneTimeNotification(
    Habit habit,
    int hour,
    int minute,
  ) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // Se o horário já passou hoje, agenda para amanhã
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      habit.id.hashCode,
      'Habit Reminder',
      'Time to complete: ${habit.title}',
      tzScheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: habit.id,
    );
  }

  /// Agenda notificação diária
  Future<void> _scheduleDailyNotification(
    Habit habit,
    int hour,
    int minute,
  ) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // Se o horário já passou hoje, agenda para amanhã
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      habit.id.hashCode,
      'Habit Reminder',
      'Time to complete: ${habit.title}',
      tzScheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: habit.id,
    );
  }

  /// Agenda notificação semanal para dias específicos
  Future<void> _scheduleWeeklyNotification(
    Habit habit,
    int hour,
    int minute,
    List<DayOfWeek> daysOfWeek,
  ) async {
    // Cancela notificações anteriores deste hábito
    await cancelHabitReminder(habit.id);

    final now = DateTime.now();

    // Agenda uma notificação para cada dia da semana selecionado
    for (var i = 0; i < daysOfWeek.length; i++) {
      final dayOfWeek = daysOfWeek[i];
      final notificationId = habit.id.hashCode + i;

      // Calcula a próxima ocorrência deste dia da semana
      var scheduledDate = _getNextWeekday(
        now,
        dayOfWeek.weekdayNumber,
        hour,
        minute,
      );

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(
        notificationId,
        'Habit Reminder',
        'Time to complete: ${habit.title}',
        tzScheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: habit.id,
      );
    }
  }

  /// Agenda notificação mensal (mesmo dia do mês)
  Future<void> _scheduleMonthlyNotification(
    Habit habit,
    int hour,
    int minute,
  ) async {
    final now = DateTime.now();
    final dayOfMonth = now.day;
    var scheduledDate = DateTime(now.year, now.month, dayOfMonth, hour, minute);

    // Se o horário já passou hoje, agenda para o mês seguinte
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(
        now.year,
        now.month + 1,
        dayOfMonth,
        hour,
        minute,
      );
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      habit.id.hashCode,
      'Habit Reminder',
      'Time to complete: ${habit.title}',
      tzScheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: habit.id,
    );
  }

  /// Calcula a próxima ocorrência de um dia da semana específico
  DateTime _getNextWeekday(DateTime from, int weekday, int hour, int minute) {
    var daysToAdd = weekday - from.weekday;
    if (daysToAdd <= 0) daysToAdd += 7;

    var scheduledDate = from.add(Duration(days: daysToAdd));
    scheduledDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      hour,
      minute,
    );

    // Se o horário já passou e é hoje, agenda para a próxima semana
    if (scheduledDate.isBefore(from)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  /// Cancela a notificação de um hábito específico
  Future<void> cancelHabitReminder(String habitId) async {
    // Cancela a notificação principal
    await _notifications.cancel(habitId.hashCode);

    // Cancela possíveis notificações semanais (até 7 notificações)
    for (var i = 0; i < 7; i++) {
      await _notifications.cancel(habitId.hashCode + i);
    }
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Obtém todas as notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Detalhes da notificação (personalização visual)
  NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Notifications for habit reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }
}
