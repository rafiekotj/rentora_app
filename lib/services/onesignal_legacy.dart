import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rentora_app/config/config.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';

void setupOneSignal() {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize(AppConfig.appIdOneSignal);
  // if (UserDataService.idUser != null) {
  //   setOneSignalExternalId(UserDataService.idUser.toString());
  // }

  // Meminta izin notifikasi (untuk iOS)
  OneSignal.Notifications.requestPermission(true);

  // Tangani notifikasi saat diklik (notification opened)
  OneSignal.Notifications.addClickListener((event) {
    final additionalData = event.notification.additionalData ?? {};
    final title = event.notification.title ?? '';
    final body = event.notification.body ?? '';

    // Simpan notifikasi ke local storage agar muncul di NotificationScreen
    PreferenceHandler().addNotification(
      title: title,
      body: body,
      data: additionalData,
    );

    if (additionalData.isNotEmpty) {
      print('OneSignal click additionalData: $additionalData');
    }

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

  // Tangani notifikasi yang masuk saat aplikasi sedang di-foreground
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    final additionalData = event.notification.additionalData ?? {};
    final title = event.notification.title ?? '';
    final body = event.notification.body ?? '';

    // Simpan notifikasi agar muncul di NotificationScreen
    PreferenceHandler().addNotification(
      title: title,
      body: body,
      data: additionalData,
    );

    try {
      OneSignal.Notifications.displayNotification(
        event.notification.notificationId,
      );
    } catch (e, s) {
      // ignore: avoid_print
      print('foreground display error: $e\n$s');
    }
  });
}

/// Set the external user id for OneSignal so you can target this device from
/// the OneSignal dashboard or REST API. Call this after the user logs in.
Future<void> setOneSignalExternalId(String externalId) async {
  try {
    await OneSignal.login(externalId);
  } catch (err, s) {
    // ignore: avoid_print
    print('setOneSignalExternalId error: $err\n$s');
  }
}

/// Remove the external user id previously set for this device.
Future<void> removeOneSignalExternalId() async {
  try {
    await OneSignal.logout();
  } catch (err, s) {
    // ignore: avoid_print
    print('removeOneSignalExternalId error: $err\n$s');
  }
}
