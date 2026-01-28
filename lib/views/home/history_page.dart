import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../services/firestore_service.dart';

class HistoryPage extends StatefulWidget {
  final AppUser currentUser;
  const HistoryPage({super.key, required this.currentUser});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _fs = FirestoreService();
  final _search = TextEditingController();
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _fs.getDetailedLogsForUser(widget.currentUser.uid);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _fs.getDetailedLogsForUser(widget.currentUser.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd  HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scan History'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'SN, job order, client, item code...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final all = snapshot.data ?? [];
                  final q = _search.text.trim().toLowerCase();
                  final logs = q.isEmpty
                      ? all
                      : all.where((l) {
                          final s = (
                            '${l['sn']} ${l['jobOrderNumber']} ${l['clientName']} ${l['itemCode']}'
                          ).toLowerCase();
                          return s.contains(q);
                        }).toList();

                  if (logs.isEmpty) {
                    return const Center(child: Text('No scans yet.'));
                  }

                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final l = logs[i];
                        final dt = (l['date'] as DateTime).toLocal();
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.qr_code_2, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${l['sn']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      df.format(dt),
                                      style: TextStyle(
                                        color: Theme.of(context).hintColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _chip(context, 'Job', '${l['jobOrderNumber']}'),
                                    _chip(context, 'Client', '${l['clientName']}'),
                                    _chip(context, 'Item', '${l['itemCode']}'),
                                    if ((l['reason'] ?? '').toString().trim().isNotEmpty)
                                      _chip(context, 'Reason', '${l['reason']}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
