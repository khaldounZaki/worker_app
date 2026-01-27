import 'package:flutter/material.dart';
import '../models/history_log.dart';

class HistoryCard extends StatelessWidget {
  final HistoryLog log;
  const HistoryCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.qr_code),
        title: Text(log.sn),
        subtitle: Text('${log.role} • ${log.userName}'),
        trailing: Text(log.timestamp.toLocal().toString().split('.')[0]),
      ),
    );
  }
}
