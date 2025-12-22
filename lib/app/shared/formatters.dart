import 'package:intl/intl.dart';

String formatIdr(num value) {
  final f = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return f.format(value);
}
