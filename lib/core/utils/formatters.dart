import 'package:intl/intl.dart';

/// Formateadores numéricos, fechas y moneda para la interfaz de FundAPP
class AppFormatters {
  AppFormatters._();

  static const List<String> _mesesCortos = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  static const List<String> _diasCortos = [
    'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'
  ];

  static const List<String> _mesesCompletos = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  /// Formatea valores en moneda colombiana (ej. $50.000)
  static String formatCurrency(num amount) {
    try {
      final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
      return formatter.format(amount);
    } catch (_) {
      return '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }
  }

  /// Formatea números con separador de miles (ej. 6.482 pasos)
  static String formatNumber(num number) {
    try {
      return NumberFormat.decimalPattern('es_CO').format(number);
    } catch (_) {
      return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    }
  }

  /// Formatea fechas cortas (ej. Sáb 23 Ago)
  static String formatDateShort(DateTime date) {
    try {
      return DateFormat('EEE d MMM', 'es_ES').format(date);
    } catch (_) {
      final diaSemana = _diasCortos[(date.weekday - 1).clamp(0, 6)];
      final mes = _mesesCortos[(date.month - 1).clamp(0, 11)];
      return '$diaSemana ${date.day} $mes';
    }
  }

  /// Formatea fechas completas (ej. 23 de Agosto de 2026)
  static String formatDateFull(DateTime date) {
    try {
      return DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(date);
    } catch (_) {
      final mes = _mesesCompletos[(date.month - 1).clamp(0, 11)];
      return '${date.day} de $mes de ${date.year}';
    }
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
