import 'package:intl/intl.dart';

class AppFormatters {
  static String formatRupiah(dynamic number) {
    if (number == null) return "Rp 0";
    final value =
        int.tryParse(number.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final formatter = NumberFormat("#,###", "id_ID");
    return formatter.format(value).replaceAll(",", ".");
  }
}
