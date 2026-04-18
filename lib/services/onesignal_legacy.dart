import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rentora_app/config/config.dart';

void setupOneSignal() {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize(AppConfig.appIdOneSignal);
  // if (UserDataService.idUser != null) {
  //   setOneSignalExternalId(UserDataService.idUser.toString());
  // }

  // Meminta izin notifikasi (untuk iOS)
  OneSignal.Notifications.requestPermission(true);

  // Tangani notifikasi saat diklik
  OneSignal.Notifications.addClickListener((event) {
    final additionalData = event.notification.additionalData ?? {};

    if (additionalData.isNotEmpty) {
      // Contoh penggunaan: log data tambahan. Sesuaikan sesuai kebutuhan.
      // Misalnya navigasi berdasarkan payload, atau penanganan tipe notifikasi.
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
}
