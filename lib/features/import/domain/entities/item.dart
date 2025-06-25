class Item {
  final String code;
  final String label;
  final String description;
  final String date;
  final int quantity;
  final String? imageBase64;

  const Item({
    required this.code,
    required this.label,
    required this.description,
    required this.date,
    required this.quantity,
    this.imageBase64,
  });
}
