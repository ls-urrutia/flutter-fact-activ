class BoletaRecord {
  final int? id;
  final String folio;
  final String rut;
  final double total;
  final String fecha;
  final String pdfPath;
  final String estado;
  final String usuario;

  BoletaRecord({
    this.id,
    required this.folio,
    required this.rut,
    required this.total,
    required this.fecha,
    required this.pdfPath,
    required this.estado,
    required this.usuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folio': folio,
      'rut': rut,
      'total': total,
      'fecha': fecha,
      'pdfPath': pdfPath,
      'estado': estado,
      'usuario': usuario,
    };
  }

  factory BoletaRecord.fromMap(Map<String, dynamic> map) {
    return BoletaRecord(
      id: map['id'],
      folio: map['folio'],
      rut: map['rut'],
      total: map['total'],
      fecha: map['fecha'],
      pdfPath: map['pdfPath'],
      estado: map['estado'],
      usuario: map['usuario'],
    );
  }
}