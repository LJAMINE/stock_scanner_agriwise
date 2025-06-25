import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';

// The ItemModel will be used to convert your entities to/from formats suitable for SQLite (Map, JSON, etc.).

class ItemModel extends Item {
  const ItemModel({
    required super.code,
    required super.label,
    required super.description,
    required super.date,
    required super.quantity,
    super.imageBase64,
  });

  // From DB (Map) to Model

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      code: map['code'],
      label: map['label'],
      description: map['description'],
      date: map['date'],
      quantity: map['quantity'],
      imageBase64: map['imageBase64'],
    );
  }

  // From Model to DB (Map)

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'label': label,
      'description': description,
      'date': date,
      'quantity': quantity,
      'imageBase64': imageBase64,
    };
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      code: json['code'],
      label: json['label'],
      description: json['description'],
      date: json['date'],
      quantity: json['quantity'],
      imageBase64: json['imageBase64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'label': label,
      'description': description,
      'date': date,
      'quantity': quantity,
      'imageBase64': imageBase64,
    };
  }
}
