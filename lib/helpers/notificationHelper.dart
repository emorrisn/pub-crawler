import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationHelper {

  /// Initializes the notification plugin and configures notification channels.
  /// This function initializes the `awesome_notifications` plugin and sets up
  /// notification channels for displaying notifications within the application.
  /// It defines a channel named "Basic notifications" with high importance
  /// and configures notification behavior (sound, badge, etc.). It also requests
  /// notification permission from the user if not already granted and sets up
  /// listeners for various notification events.
  /// Returns:
  ///   A [Future<void>] that completes the initialization process.
  static Future<void> initializeNotifications() async
  {
    await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelGroupKey: 'high_importance_channel_group',
              channelKey: 'high_importance_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: const Color(0xFF9D50DD),
              ledColor: Colors.white,
              importance: NotificationImportance.Max,
              channelShowBadge: true,
              onlyAlertOnce: true,
              playSound: true,
              criticalAlerts: true
          )
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: 'high_importance_channel_group',
              channelGroupName: 'High Importance Channel')
        ],
        debug: true
    );

    await AwesomeNotifications().isNotificationAllowed().then(
            (isAllowed) async {
              await AwesomeNotifications().requestPermissionToSendNotifications();
            }
    );

    await AwesomeNotifications().setListeners(
        onActionReceivedMethod:         onActionReceived,
        onNotificationCreatedMethod:    onNotificationCreated,
        onNotificationDisplayedMethod:  onNotificationDisplayed,
        onDismissActionReceivedMethod:  onDismissActionReceived
    );
  }

  /// Invoked when a notification is created by the library.
  /// This function is an internal listener method invoked when a notification
  /// is created by the `awesome_notifications` library.
  /// Parameters:
  ///   * [receivedNotification] (ReceivedNotification): An object containing
  ///     information about the created notification.
  /// Returns:
  ///   A [Future<void>] that completes the listener callback.
  /// Details:
  ///   Currently logs a debug message. You can customize this behavior to
  ///   perform actions upon notification creation (e.g., analytics tracking).
  static Future<void> onNotificationCreated(ReceivedNotification receivedNotification) async
  {
    debugPrint('onNotificationCreated');
  }

  /// Invoked when a notification is displayed to the user.
  /// This function is an internal listener method invoked when a notification
  /// is displayed to the user by the `awesome_notifications` library.
  /// Parameters:
  ///   * [receivedNotification] (ReceivedNotification): An object containing
  ///     information about the displayed notification.
  /// Returns:
  ///   A [Future<void>] that completes the listener callback.
  ///
  /// Details:
  ///   Currently logs a debug message. You can customize this behavior to
  ///   perform actions when a notification is shown (e.g., update UI elements).
  static Future<void> onNotificationDisplayed(ReceivedNotification receivedNotification) async
  {
    debugPrint('onNotificationDisplayed');
  }

  /// Invoked when a user interacts with a notification action button.
  /// This function is an internal listener method invoked when a user interacts
  /// with a notification action button.
  /// Parameters:
  ///   * [receivedAction] (ReceivedAction): An object containing information
  ///     about the user interaction with the notification action.
  /// Returns:
  ///   A [Future<void>] that completes the listener callback.
  ///
  /// Details:
  ///   Currently logs a debug message. You can customize this behavior to handle
  ///   user actions on notification buttons (e.g., navigate to a specific screen).
  static Future<void> onActionReceived(ReceivedAction receivedAction) async
  {
    debugPrint('onActionReceived');
  }

  /// Invoked when a user dismisses a notification.
  /// This function is an internal listener method invoked when a user dismisses
  /// a notification.
  /// Parameters:
  ///   * [receivedAction] (ReceivedAction): An object containing information
  ///     about the dismissal event (might be null).
  /// Returns:
  ///   A [Future<void>] that completes the listener callback.
  ///
  /// Details:
  ///   Currently logs a debug message. You can customize this behavior to perform
  ///   actions when a notification is dismissed (e.g., log user behavior).
  static Future<void> onDismissActionReceived(ReceivedAction receivedAction) async
  {
    debugPrint('onDismissActionReceived');
  }


  /// Displays a notification to the user with the provided configuration options.
  /// This function displays a notification to the user with the specified
  /// configuration options. It utilizes the `awesome_notifications` library
  /// for creating and presenting the notification.
  /// Returns:
  ///   A [Future<void>] that completes the notification creation process. This
  ///   future resolves once the notification has been successfully created and
  ///   scheduled (if applicable) by the `awesome_notifications` library.
  /// Throws:
  ///   An assertion error if `scheduled` is true but `interval` is null. This
  ///   ensures that a valid interval is provided for scheduling notifications.
  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async
  {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1,
            channelKey: 'high_importance_channel',
          title: title,
          body: body,
          actionType: actionType,
          notificationLayout: notificationLayout,
          summary: summary,
          category: category,
          payload: payload,
          bigPicture: bigPicture
        ),
      actionButtons: actionButtons,
      schedule: scheduled ? NotificationInterval(
          interval: interval,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          preciseAlarm: true
      ) : null
    );
  }

}
