import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/user.dart';
import '../../services/scan_service.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanPage extends StatefulWidget {
  final AppUser currentUser;
  const ScanPage({super.key, required this.currentUser});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _scannerKey = GlobalKey();
  final _scanService = ScanService();
  final _fs = FirestoreService();
  final _snController = TextEditingController();

  bool _processing = false;
  String? _scannedValue;

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String sn) async {
    if (_processing) return;
    setState(() => _processing = true);

    final results = await _fs.findItemsBySn(sn);
    if (results.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('SN not found in items.')));
      setState(() => _processing = false);
      return;
    }

    final first = results.first;
    final itemRef = (first['ref'] as DocumentReference).parent.parent;
    //final itemId = first['id'] as String;
    final itemId = itemRef?.id ?? '';
    final jobOrderRef =
        (first['ref'] as DocumentReference).parent.parent?.parent.parent;
    final jobOrderId = jobOrderRef?.id ?? '';

    final err = await _scanService.scanAndLog(
      sn: sn,
      userId: widget.currentUser.uid,
      userName: widget.currentUser.name.isEmpty
          ? widget.currentUser.email
          : widget.currentUser.name,
      role: widget.currentUser.role,
      jobOrderId: jobOrderId,
      itemId: itemId,
    );

    if (!mounted) return;
    if (err != null) {
      final reason = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          String? selectedReason;
          final TextEditingController otherController = TextEditingController();

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Duplicate Scan Detected'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Please select a reason to continue:'),
                    RadioListTile<String>(
                      value: 'Continue work',
                      groupValue: selectedReason,
                      onChanged: (v) => setState(() => selectedReason = v),
                      title: const Text('Continue work'),
                    ),
                    RadioListTile<String>(
                      value: 'Repeat after mistake',
                      groupValue: selectedReason,
                      onChanged: (v) => setState(() => selectedReason = v),
                      title: const Text('Repeat after mistake'),
                    ),
                    RadioListTile<String>(
                      value: 'Returned from quality checker',
                      groupValue: selectedReason,
                      onChanged: (v) => setState(() => selectedReason = v),
                      title: const Text('Returned from quality checker'),
                    ),
                    RadioListTile<String>(
                      value: 'Other',
                      groupValue: selectedReason,
                      onChanged: (v) => setState(() => selectedReason = v),
                      title: const Text('Other'),
                    ),
                    if (selectedReason == 'Other')
                      TextField(
                        controller: otherController,
                        decoration: const InputDecoration(
                          hintText: 'Enter custom reason',
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: selectedReason == null
                        ? null
                        : () {
                            if (selectedReason == 'Other' &&
                                otherController.text.trim().isNotEmpty) {
                              Navigator.pop(
                                context,
                                otherController.text.trim(),
                              );
                            } else {
                              Navigator.pop(context, selectedReason);
                            }
                          },
                    child: const Text('Confirm'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (reason != null) {
        // Save duplicate scan with reason
        await _scanService.scanAndLog(
          sn: sn,
          userId: widget.currentUser.uid,
          userName: widget.currentUser.name.isEmpty
              ? widget.currentUser.email
              : widget.currentUser.name,
          role: widget.currentUser.role,
          jobOrderId: jobOrderId,
          itemId: itemId,
          reason: reason,
          force: true, // 👈 force insert even if duplicate
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Duplicate recorded. Reason: $reason')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Scan cancelled.')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Scan recorded.')));
    }

    setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan or Enter SN')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 260,
                  child: Stack(
                    children: [
                      MobileScanner(
                        key: _scannerKey,
                        controller: MobileScannerController(
                          detectionSpeed: DetectionSpeed.noDuplicates,
                        ),
                        onDetect: (capture) {
                          final bar = capture.barcodes.first;
                          final raw = bar.rawValue ?? '';
                          if (raw.isNotEmpty) {
                            setState(() {
                              _scannedValue = raw;
                              _snController.text = raw; // auto-fill input
                            });
                          }
                        },
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Card(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.92),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.qr_code_scanner),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _scannedValue == null
                                        ? 'Point the camera at the SN barcode/QR'
                                        : 'Scanned: $_scannedValue',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_processing)
                                  const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Manual entry',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _snController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (_processing) return;
                        final sn = _snController.text.trim();
                        if (sn.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter or scan an SN.')),
                          );
                          return;
                        }
                        _handleScan(sn);
                      },
                      decoration: const InputDecoration(
                        labelText: 'SN',
                        hintText: 'Example: SN-123456',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _processing
                          ? null
                          : () {
                              final sn = _snController.text.trim();
                              if (sn.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Enter or scan an SN.'),
                                  ),
                                );
                                return;
                              }
                              _handleScan(sn);
                            },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Record scan'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
