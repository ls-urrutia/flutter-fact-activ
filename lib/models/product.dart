class Product {
  final int? id;
  final String codigo;
  final int stock;
  final String descripcion;
  final double precio;
  final String bodega;
  final bool activo;

  Product({
    this.id,
    required this.codigo,
    required this.stock,
    required this.descripcion,
    required this.precio,
    required this.bodega,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'codigo': codigo,
      'stock': stock,
      'descripcion': descripcion,
      'precio': precio,
      'bodega': bodega,
      'activo': activo ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id as int;
    }
    return map;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      codigo: map['codigo'],
      stock: map['stock'],
      descripcion: map['descripcion'],
      precio: map['precio'],
      bodega: map['bodega'],
      activo: map['activo'] == 1,
    );
  }
}
