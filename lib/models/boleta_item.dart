class BoletaItem {
  final int? id;
  final String codigo;
  final String descripcion;
  final int cantidad;
  final double precioUnitario;
  final double valorTotal;

  BoletaItem({
    this.id,
    required this.codigo,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.valorTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'valorTotal': valorTotal,
    };
  }

  factory BoletaItem.fromMap(Map<String, dynamic> map) {
    return BoletaItem(
      id: map['id'],
      codigo: map['codigo'],
      descripcion: map['descripcion'],
      cantidad: map['cantidad'],
      precioUnitario: map['precioUnitario'],
      valorTotal: map['valorTotal'],
    );
  }
}
