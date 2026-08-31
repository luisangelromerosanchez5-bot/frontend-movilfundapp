import '../../domain/entities/donation.dart';

class DonationModel extends Donation {
  const DonationModel({
    required super.id,
    required super.usuarioId,
    required super.monto,
    required super.metodoPago,
    required super.estado,
    required super.fecha,
    required super.codigoTransaccion,
    super.proyectoDestino,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] ?? '',
      usuarioId: json['usuario_id'] ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      metodoPago: _parsePaymentMethod(json['metodo_pago']),
      estado: json['estado'] ?? 'completada',
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
      codigoTransaccion: json['codigo_transaccion'] ?? 'TX-DON-000',
      proyectoDestino: json['proyecto_destino'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'monto': monto,
      'metodo_pago': metodoPago.name,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
      'codigo_transaccion': codigoTransaccion,
      'proyecto_destino': proyectoDestino,
    };
  }

  static PaymentMethod _parsePaymentMethod(dynamic method) {
    if (method == 'pse' || method == PaymentMethod.pse.name) {
      return PaymentMethod.pse;
    }
    if (method == 'nequiDaviplata' || method == PaymentMethod.nequiDaviplata.name || method == 'nequi') {
      return PaymentMethod.nequiDaviplata;
    }
    return PaymentMethod.creditCard;
  }
}
