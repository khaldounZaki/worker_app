import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/firestore_service.dart';

class HistoryPage extends StatelessWidget {
  final AppUser currentUser;
  const HistoryPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final _fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Scan History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fs.getDetailedLogsForUser(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(child: Text('No scans yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: logs.length,
            itemBuilder: (context, i) {
              final l = logs[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SN: ${l['sn']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Job Order: ${l['jobOrderNumber']}'),
                      Text('Client: ${l['clientName']}'),
                      Text('Item Code: ${l['itemCode']}'),
                      const SizedBox(height: 6),
                      Text(
                        'Date: ${l['date'].toLocal()}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
