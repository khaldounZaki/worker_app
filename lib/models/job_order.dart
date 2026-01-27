import 'package:cloud_firestore/cloud_firestore.dart';

class JobOrder {
  final String id;
  final String orderNumber;
  final String clientName;
  final DateTime deliveryDate;
  final String status;

  JobOrder({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    required this.deliveryDate,
    required this.status,
  });

  factory JobOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobOrder(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      clientName: data['clientName'] ?? '',
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'In Progress',
    );
  }
}
