import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String code;
  final String description;
  final int quantity;

  Item({
    required this.id,
    required this.code,
    required this.description,
    required this.quantity,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      quantity: data['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'code': code, 'description': description, 'quantity': quantity};
  }
}
