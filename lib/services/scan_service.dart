import 'package:cloud_firestore/cloud_firestore.dart';

class ScanService {
  final _fs = FirebaseFirestore.instance;

  /// Handles scan logging with duplicate rules
  /// Returns `String?` = error message if duplicate block, or null if success
  Future<String?> scanAndLog({
    required String sn,
    required String userId,
    required String userName,
    required String role,
    required String jobOrderId,
    required String itemId,
    String? partId,
    String? reason,
    bool force = false, // 👈 new flag for confirmed duplicates
  }) async {
    final logsRef = _fs.collection('scan_logs');

    // If not forcing, check duplicate rules
    if (!force) {
      final existing = await logsRef.where('sn', isEqualTo: sn).limit(20).get();

      if (existing.docs.isNotEmpty) {
        for (var doc in existing.docs) {
          final data = doc.data();

          final prevRole = data['role'] as String? ?? '';
          final prevUserId = data['userId'] as String? ?? '';

          // Rule 1: Same SN + same role + same user → block
          if (prevRole == role && prevUserId == userId) {
            return "Duplicate scan by the same user in the same role.";
          }

          // Rule 2: Same SN + same role + different user → block
          if (prevRole == role && prevUserId != userId) {
            return "Duplicate scan by another user with the same role.";
          }

          // Rule 3: Same SN + different role → allow (skip checks)
        }
      }
    }

    // ✅ Allowed or forced → create new log
    await logsRef.add({
      'sn': sn,
      'jobOrderId': jobOrderId,
      'itemId': itemId,
      'partId': partId ?? '',
      'userId': userId,
      'userName': userName,
      'role': role,
      'reason': reason ?? '', // 👈 store reason if duplicate
      'timestamp': FieldValue.serverTimestamp(),
    });

    return null; // Success
  }
}
