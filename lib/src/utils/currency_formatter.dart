import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter() : _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final NumberFormat _formatter;

  String format(int nominal) => _formatter.format(nominal);
}

