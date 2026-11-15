import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Indonesian date formatting helpers ("Rabu, 11 November 2026").
///
/// A single [DateTime] (report date) feeds the poster header, caption
/// section III, and the signature block — always through these helpers so
/// everything stays consistent.
final class DateFormatterId {
  DateFormatterId._();

  static bool _initialized = false;

  /// Must be called once before formatting (id_ID locale data is not
  /// initialized automatically). Safe to call multiple times.
  static void ensureInitialized() {
    if (_initialized) return;
    initializeDateFormatting('id_ID');
    _initialized = true;
  }

  static final DateFormat _full = DateFormat('EEEE, d MMMM y', 'id_ID');
  static final DateFormat _short = DateFormat('d MMMM y', 'id_ID');

  /// e.g. "Rabu, 11 November 2026" (poster header / caption section III).
  static String full(DateTime date) {
    ensureInitialized();
    return _full.format(date);
  }

  /// e.g. "11 November 2026" (signature block).
  static String short(DateTime date) {
    ensureInitialized();
    return _short.format(date);
  }
}
