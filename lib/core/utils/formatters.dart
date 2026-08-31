import 'package:intl/intl.dart';

/// Formateadores numéricos, fechas y moneda para la interfaz de FundAPP
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('es_CO');

  /// Formatea valores en moneda colombiana (ej. $50.000)
  static String formatCurrency(num amount) {
    return _currencyFormat.format(amount);
  }

  /// Formatea números con separador de miles (ej. 6.482 pasos)
  static String formatNumber(num number) {
    return _numberFormat.format(number);
  }

  /// Formatea fechas cortas (ej. Sáb 23 Ago)
  static String formatDateShort(DateTime date) {
    return DateFormat('EEE d MMM', 'es_ES').format(date);
  }

  /// Formatea fechas completas (ej. 23 de Agosto de 2026)
  static String formatDateFull(DateTime date) {
    return DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(date);
  }

  /// Formatea tiempo en minutos y segundos (ej. 42:18 min)
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;

    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes:$seconds min';
  }

  /// Estima kilómetros recorridos a partir del número de pasos (aprox. 0.75m por paso)
  static double stepsToKilometers(int steps) {
    return (steps * 0.75) / 1000.0;
  }
}
