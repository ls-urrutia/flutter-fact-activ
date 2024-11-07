class Product {
  final int id;
  final int stock;
  final String descripcion;
  final double precio;
  final String bodega;
  final bool activo;

  Product({
    required this.id,
    required this.stock,
    required this.descripcion,
    required this.precio,
    required this.bodega,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stock': stock,
      'descripcion': descripcion,
      'precio': precio,
      'bodega': bodega,
      'activo': activo ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      stock: map['stock'],
      descripcion: map['descripcion'],
      precio: map['precio'],
      bodega: map['bodega'],
      activo: map['activo'] == 1,
    );
  }
}
