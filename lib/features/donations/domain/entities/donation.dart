enum PaymentMethod {
  creditCard,
  pse,
  nequiDaviplata,
}

/// Entidad de Donación
class Donation {
  final String id;
  final String usuarioId;
  final double monto;
  final PaymentMethod metodoPago;
  final String estado; // 'completada' | 'pendiente' | 'fallida'
  final DateTime fecha;
  final String codigoTransaccion;
  final String? proyectoDestino;

  const Donation({
    required this.id,
    required this.usuarioId,
    required this.monto,
    required this.metodoPago,
    required this.estado,
    required this.fecha,
    required this.codigoTransaccion,
    this.proyectoDestino,
  });

  String get metodoPagoNombre {
    switch (metodoPago) {
      case PaymentMethod.creditCard:
        return 'Tarjeta de crédito/débito';
      case PaymentMethod.pse:
        return 'PSE';
      case PaymentMethod.nequiDaviplata:
        return 'Nequi / Daviplata';
    }
  }
}
