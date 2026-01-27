import 'package:flutter/material.dart';
import 'scan_page.dart';
import 'history_page.dart';
import 'item_status_page.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = AuthService();
  final _fs = FirestoreService();
  AppUser? _me;
  bool _loading = true;

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final u = await _fs.getUserById(uid);
    setState(() {
      _me = u;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_me == null || !_me!.isActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Waiting approval')),
        body: Center(
          child: Text('Your account is not yet activated. Wait for admin.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${_me!.name.isEmpty ? _me!.email : _me!.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_scanner, size: 36),
                title: const Text('Scan SN'),
                subtitle: const Text('Open scanner to scan item SN'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanPage(currentUser: _me!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, size: 36),
                title: const Text('My Scan History'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryPage(currentUser: _me!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Card(
            //   child: ListTile(
            //     leading: const Icon(Icons.info, size: 36),
            //     title: const Text('Item Status (optional)'),
            //     onTap: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => ItemStatusPage()),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
