import 'package:flutter/material.dart';
import 'scan_page.dart';
import 'history_page.dart';
import 'item_status_page.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/custom_button.dart';

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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_me == null || !_me!.isActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Waiting approval')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.hourglass_top,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 10),
                          Text(
                            'Not activated yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your account is registered, but still needs admin approval. Please wait and try again later.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: 'Sign out',
                        icon: Icons.logout,
                        onPressed: () async => _auth.signOut(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await _auth.signOut();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Role',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                label: Text(_me!.role),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.verified_user_outlined,
                        color: Theme.of(context).colorScheme.primary),
                  ],
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
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_scanner, size: 36),
                title: const Text('Scan SN'),
                subtitle: const Text('Scan a barcode / QR, or enter SN manually'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanPage(currentUser: _me!),
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
