import 'package:intl/intl.dart';

String formatIdr(num value) {
  final f = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return f.format(value);
}

String formatDate(DateTime date) {
  final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  return formatter.format(date);
}

String formatDateShort(DateTime date) {
  final formatter = DateFormat('dd MMM yyyy', 'id_ID');
  return formatter.format(date);
}
