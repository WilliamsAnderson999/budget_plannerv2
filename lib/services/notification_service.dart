import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Configuration Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Gérer le clic sur la notification
        _handleNotificationClick(response.payload);
      },
    );

    // Initialiser les timezones
    tz.initializeTimeZones();

    // Demander les permissions
    await _requestPermissions();

    // Configurer Firebase Messaging
    await _setupFirebaseMessaging();
  }

  Future<void> _requestPermissions() async {
    // Android n'a pas besoin de permission supplémentaire

    // iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      // Obtenir le token FCM
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      // Configurer les handlers de message
      FirebaseMessaging.onMessage.listen(_showFirebaseNotification);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Erreur Firebase Messaging: $e');
    }
  }

  Future<void> showBudgetAlertNotification(
      double currentExpense, double budget) async {
    final percentage = (currentExpense / budget) * 100;
    if (percentage >= 80) {
      await showInstantNotification(
        title: 'Alerte Budget',
        body:
            'Vous avez dépensé ${percentage.toStringAsFixed(0)}% de votre budget mensuel.',
      );
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'instant_channel_id',
        'Instant Notifications',
        channelDescription: 'Instant notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        4,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint(
          'Erreur lors de l\'affichage de la notification instantanée: $e');
    }
  }

  Future<void> scheduleBudgetReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'budget_channel_id',
        'Budget Reminders',
        channelDescription: 'Notifications for budget tracking and reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convertir DateTime en TZDateTime
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tzDateTime,
        platformDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Erreur lors de la planification: $e');
    }
  }

  Future<void> showTransactionNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Créer le canal Android pour les transactions
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'transaction_channel_id',
        'Transaction Updates',
        channelDescription: 'Notifications for transaction updates',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        1,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'affichage de la notification: $e');
    }
  }

  Future<void> showWeeklySummary() async {
    try {
      const title = 'Résumé Hebdomadaire';
      const body =
          'Votre résumé hebdomadaire est prêt ! Voyez comment vous avez géré vos dépenses cette semaine.';

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'summary_channel_id',
        'Weekly Summary',
        channelDescription: 'Weekly financial summary notifications',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        2,
        title,
        body,
        platformDetails,
      );
    } catch (e) {
      debugPrint('Erreur résumé hebdomadaire: $e');
    }
  }

  Future<void> showBudgetAlert({
    required String category,
    required double spent,
    required double budget,
    required double percentage,
  }) async {
    try {
      final title = 'Alerte Budget : $category';
      final body =
          'Vous avez dépensé \$${spent.toStringAsFixed(2)} sur \$${budget.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)';

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'alert_channel_id',
        'Budget Alerts',
        channelDescription: 'Notifications when approaching budget limits',
        importance: Importance.max,
        priority: Priority.max,
        colorized: true,
        color: Colors.red,
        enableVibration: true,
        enableLights: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        3,
        title,
        body,
        platformDetails,
      );
    } catch (e) {
      debugPrint('Erreur alerte budget: $e');
    }
  }

  Future<void> _showFirebaseNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final android = message.notification?.android;
      final apple = message.notification?.apple;

      if (notification != null) {
        AndroidNotificationDetails androidDetails;
        DarwinNotificationDetails iosDetails;

        if (android != null) {
          androidDetails = AndroidNotificationDetails(
            android.channelId ?? 'default_channel',
            android.channelId ?? 'Default',
            channelDescription: 'Default notifications',
            importance: Importance.max,
            priority: Priority.high,
          );
        } else {
          androidDetails = const AndroidNotificationDetails(
            'default_channel',
            'Default',
            channelDescription: 'Default notifications',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          );
        }

        if (apple != null) {
          iosDetails = const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
        } else {
          iosDetails = const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
        }

        final platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _notificationsPlugin.show(
          message.hashCode,
          notification.title ?? 'Notification',
          notification.body ?? '',
          platformDetails,
          payload: message.data['payload'],
        );
      }
    } catch (e) {
      debugPrint('Erreur Firebase notification: $e');
    }
  }

  void _handleNotificationClick(String? payload) {
    // Gérer la navigation selon le payload
    if (payload != null) {
      // Exemple: payload = "transaction:123"
      final parts = payload.split(':');
      if (parts.length == 2) {
        final type = parts[0];
        final id = parts[1];

        // Naviguer vers l'écran approprié
        // Utiliser Get.toNamed() ou Navigator.push() selon ton routing
        debugPrint('Notification cliquée: $type - $id');
      }
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _handleNotificationClick(message.data['payload']);
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    try {
      var scheduledTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );

      if (scheduledTime.isBefore(DateTime.now())) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      const title = 'Rappel Quotidien';
      const body = 'N\'oubliez pas de saisir vos transactions aujourd\'hui !';

      await scheduleBudgetReminder(
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        payload: 'daily_reminder',
      );
    } catch (e) {
      debugPrint('Erreur rappel quotidien: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Méthode pour créer les canaux de notification (appeler au démarrage)
  Future<void> createNotificationChannels() async {
    // Canal pour les rappels de budget
    const AndroidNotificationChannel budgetChannel = AndroidNotificationChannel(
      'budget_channel_id',
      'Budget Reminders',
      description: 'Notifications for budget tracking and reminders',
      importance: Importance.high,
    );

    // Canal pour les transactions
    const AndroidNotificationChannel transactionChannel =
        AndroidNotificationChannel(
      'transaction_channel_id',
      'Transaction Updates',
      description: 'Notifications for transaction updates',
      importance: Importance.defaultImportance,
    );

    // Canal pour les résumés
    const AndroidNotificationChannel summaryChannel =
        AndroidNotificationChannel(
      'summary_channel_id',
      'Weekly Summary',
      description: 'Weekly financial summary notifications',
      importance: Importance.high,
    );

    // Canal pour les alertes
    const AndroidNotificationChannel alertChannel = AndroidNotificationChannel(
      'alert_channel_id',
      'Budget Alerts',
      description: 'Notifications when approaching budget limits',
      importance: Importance.max,
    );

    // Canal pour les notifications instantanées
    const AndroidNotificationChannel instantChannel =
        AndroidNotificationChannel(
      'instant_channel_id',
      'Instant Notifications',
      description: 'Instant notifications',
      importance: Importance.defaultImportance,
    );

    // Créer les canaux
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(budgetChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(transactionChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(summaryChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alertChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(instantChannel);
  }
}

// Handler pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialiser les plugins nécessaires
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialiser les timezones
  tz.initializeTimeZones();

  final notification = message.notification;

  if (notification != null) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      notification.title ?? 'Notification',
      notification.body ?? '',
      platformDetails,
      payload: message.data['payload'],
    );
  }
}
