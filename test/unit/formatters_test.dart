import 'package:flutter_test/flutter_test.dart';
import 'package:fundapp_mobile/core/utils/formatters.dart';

void main() {
  group('AppFormatters Tests', () {
    test('Formatea número de pasos a kilómetros correctamente', () {
      final km = AppFormatters.stepsToKilometers(6482);
      expect(km, closeTo(4.86, 0.1));
    });

    test('Formatea duración legible en minutos y segundos', () {
      const duration = Duration(minutes: 42, seconds: 18);
      final formatted = AppFormatters.formatDuration(duration);
      expect(formatted, contains('42:18 min'));
    });
  });
}
