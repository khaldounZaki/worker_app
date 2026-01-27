import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryLog {
  final String id;
  final String sn; // item sn
  final String userId;
  final String userName;
  final String role;
  final String jobOrderId;
  final String itemId;
  final DateTime timestamp;
  final String? reason;

  HistoryLog({
    required this.id,
    required this.sn,
    required this.userId,
    required this.userName,
    required this.role,
    required this.jobOrderId,
    required this.itemId,
    required this.timestamp,
    this.reason,
  });

  factory HistoryLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryLog(
      id: doc.id,
      sn: data['sn'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      role: data['role'] ?? '',
      jobOrderId: data['jobOrderId'] ?? '',
      itemId: data['itemId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'sn': sn,
    'userId': userId,
    'userName': userName,
    'role': role,
    'jobOrderId': jobOrderId,
    'itemId': itemId,
    'timestamp': Timestamp.fromDate(timestamp),
    'reason': reason,
  };
}
