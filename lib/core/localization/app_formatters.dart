import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/generated/app_localizations.dart';

class AppDateFormatter {
  const AppDateFormatter(this.locale);
  final Locale locale;
  String date(DateTime value) =>
      DateFormat.yMMMd(locale.toLanguageTag()).format(value);
  String fullDate(DateTime value) =>
      DateFormat.yMMMMEEEEd(locale.toLanguageTag()).format(value);
  String month(DateTime value) =>
      DateFormat.yMMMM(locale.toLanguageTag()).format(value);
}

class AppTimeFormatter {
  const AppTimeFormatter(this.locale);
  final Locale locale;
  String time(DateTime value, {bool use24Hour = false}) =>
      (use24Hour
              ? DateFormat.Hm(locale.toLanguageTag())
              : DateFormat.jm(locale.toLanguageTag()))
          .format(value);
  String timeOfDay(TimeOfDay value, {bool use24Hour = false}) => time(
    DateTime(2000, 1, 1, value.hour, value.minute),
    use24Hour: use24Hour,
  );
  String duration(Duration value, AppLocalizations l10n) {
    final numbers = AppNumberFormatter(locale);
    if (value.inMinutes.remainder(60) == 0) {
      return l10n.durationHoursOnly(numbers.integer(value.inHours));
    }
    return l10n.durationHoursMinutes(
      numbers.integer(value.inHours),
      numbers.integer(value.inMinutes.remainder(60)),
    );
  }
}

class AppNumberFormatter {
  const AppNumberFormatter(this.locale);
  final Locale locale;
  String integer(int value) =>
      NumberFormat.decimalPattern(locale.toLanguageTag()).format(value);
  String decimal(num value, {int decimalDigits = 2}) =>
      (NumberFormat.decimalPattern(locale.toLanguageTag())
            ..minimumFractionDigits = decimalDigits
            ..maximumFractionDigits = decimalDigits)
          .format(value);

  /// A ratio: 0.25 is 25%, in the active locale's notation.
  String percentage(num ratio) =>
      NumberFormat.percentPattern(locale.toLanguageTag()).format(ratio);

  /// Currency identity is explicit; it is never inferred from UI language.
  String currency(num amount, {required String currencyCode}) =>
      NumberFormat.simpleCurrency(
        locale: locale.toLanguageTag(),
        name: currencyCode,
      ).format(amount);
}
