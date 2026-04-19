import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rentora_app/config/config.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

void setupOneSignal() {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize(AppConfig.appIdOneSignal);

  OneSignal.Notifications.requestPermission(true);

  OneSignal.Notifications.addClickListener((event) {
    final additionalData = event.notification.additionalData ?? {};
    final title = event.notification.title ?? '';
    final body = event.notification.body ?? '';

    PreferenceHandler().addNotification(
      title: title,
      body: body,
      data: additionalData,
    );

    if (additionalData.isNotEmpty) {}

    // Uncomment dan sesuaikan blok ini jika ingin melakukan navigasi
    // berdasarkan payload tambahan yang dikirim OneSignal.
    // if (additionalData.containsKey('type')) {
    //   final String type = additionalData['type'];
    //   final String? idString = additionalData['id']?.toString();
    //   final int? id = idString != null ? int.tryParse(idString) : null;
    //   if (id != null) {
    //     navigateToScreen(type, id);
    //   }
    // }
  });

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    final additionalData = event.notification.additionalData ?? {};
    final title = event.notification.title ?? '';
    final body = event.notification.body ?? '';

    PreferenceHandler().addNotification(
      title: title,
      body: body,
      data: additionalData,
    );

    try {
      OneSignal.Notifications.displayNotification(
        event.notification.notificationId,
      );
    } catch (_) {}
  });
}

Future<void> setOneSignalExternalId(String externalId) async {
  try {
    await OneSignal.login(externalId);
  } catch (_) {}
}

Future<void> removeOneSignalExternalId() async {
  try {
    await OneSignal.logout();
  } catch (_) {}
}
