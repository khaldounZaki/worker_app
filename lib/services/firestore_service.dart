import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:worker_app/models/history_log.dart';
import '../models/user.dart';
import '../models/job_order.dart';
import '../models/item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ======================
  // USERS
  // ======================
  Future<AppUser?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  // ======================
  // LOGS (global collection: scan_logs)
  // ======================

  /// Stream logs for a specific user
  Stream<List<HistoryLog>> getLogsForUser(String userId) {
    return _db
        .collection('scan_logs') // use your global collection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => HistoryLog.fromFirestore(d)).toList(),
        );
  }

  /// Add a scan log
  Future<void> addScanLog(Map<String, dynamic> log) async {
    await _db.collection('scan_logs').add(log);
  }

  /// Find logs by SN + role
  Future<QuerySnapshot<Map<String, dynamic>>> queryLogsBySnAndRole(
    String sn,
    String role,
  ) {
    return _db
        .collection('scan_logs')
        .where('sn', isEqualTo: sn)
        .where('role', isEqualTo: role)
        .get();
  }

  // ======================
  // JOB ORDERS + ITEMS
  // ======================

  Stream<List<JobOrder>> getJobOrders() {
    return _db
        .collection('job_orders')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => JobOrder.fromFirestore(d)).toList(),
        );
  }

  Stream<List<Item>> getItems(String jobOrderId) {
    return _db
        .collection('job_orders')
        .doc(jobOrderId)
        .collection('items')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Item.fromFirestore(d)).toList());
  }

  /// Find an item by SN → since SN is stored at `parts` level,
  /// we query `parts` collectionGroup instead of `items`.
  Future<List<Map<String, dynamic>>> findItemsBySn(String sn) async {
    final q = await _db
        .collectionGroup('parts')
        .where('sn', isEqualTo: sn)
        .get();

    return q.docs.map((d) {
      return {'id': d.id, 'data': d.data(), 'ref': d.reference};
    }).toList();
  }

  Future<List<HistoryLog>> getLogsForUserOnce(String userId) async {
    final snap = await _db
        .collection('scan_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snap.docs.map((d) => HistoryLog.fromFirestore(d)).toList();
  }

  Future<List<Map<String, dynamic>>> getDetailedLogsForUser(
    String userId,
  ) async {
    final snap = await _db
        .collection('scan_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> result = [];

    for (var doc in snap.docs) {
      final log = HistoryLog.fromFirestore(doc);

      // Get job order
      final jobDoc = await _db
          .collection('job_orders')
          .doc(log.jobOrderId)
          .get();

      final jobData = jobDoc.data() ?? {};

      print(jobData);

      // Get item
      final itemDoc = await _db
          .collection('job_orders')
          .doc(log.jobOrderId)
          .collection('items')
          .doc(log.itemId)
          .get();

      final itemData = itemDoc.data() ?? {};

      print(itemData);

      result.add({
        'sn': log.sn,
        'date': log.timestamp,
        'jobOrderNumber': jobData['orderNumber'] ?? '',
        'clientName': jobData['clientName'] ?? '',
        'itemCode': itemData['code'] ?? '',
      });
    }

    return result;
  }
}
