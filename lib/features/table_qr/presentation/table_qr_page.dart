import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/config/app_config.dart';
import '../data/table_qr_repository.dart';
import '../model/table_qr.dart';

class TableQRPage extends StatefulWidget {
  final String tableId;
  final String tableNo;

  const TableQRPage({super.key, required this.tableId, required this.tableNo});

  @override
  State<TableQRPage> createState() {
    return _TableQRPageState();
  }
}

class _TableQRPageState extends State<TableQRPage> {
  final TableQRRepository repository = TableQRRepository();

  late Future<TableQR> qrFuture;

  bool rotating = false;

  @override
  void initState() {
    super.initState();

    _loadQR();
  }

  void _loadQR() {
    qrFuture = repository.getOrCreateQR(widget.tableId);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadQR();
    });

    await qrFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR โต๊ะ ${widget.tableNo}'),

        actions: [
          IconButton(
            tooltip: 'Refresh',

            onPressed: _refresh,

            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: FutureBuilder<TableQR>(
        future: qrFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error!);
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('ไม่พบข้อมูล QR'));
          }

          final qr = snapshot.data!;

          final customerUrl = AppConfig.customerOrderUrl(qr.token);

          return _buildQRContent(qr, customerUrl);
        },
      ),
    );
  }

  Widget _buildQRContent(TableQR qr, String customerUrl) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),

          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  const Icon(Icons.table_restaurant, size: 48),

                  const SizedBox(height: 12),

                  Text(
                    'โต๊ะ ${qr.tableNo}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'ให้ลูกค้าสแกน QR Code เพื่อสั่งอาหาร',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: QrImageView(
                      data: customerUrl,
                      version: QrVersions.auto,
                      size: 280,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Customer URL',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,

                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: SelectableText(
                      customerUrl,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,

                    child: OutlinedButton.icon(
                      onPressed: () {
                        _copyUrl(customerUrl);
                      },

                      icon: const Icon(Icons.copy),

                      label: const Text('คัดลอก URL'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,

                    child: FilledButton.icon(
                      onPressed: rotating
                          ? null
                          : () {
                              _rotateQR();
                            },

                      icon: rotating
                          ? const SizedBox(
                              width: 18,
                              height: 18,

                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.autorenew),

                      label: Text(rotating ? 'กำลังสร้าง...' : 'สร้าง QR ใหม่'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'หากสร้าง QR ใหม่ QR เดิมจะไม่สามารถใช้งานได้',
                    textAlign: TextAlign.center,

                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('คัดลอก URL แล้ว')));
  }

  Future<void> _rotateQR() async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('สร้าง QR ใหม่'),

          content: const Text(
            'QR Code เดิมจะใช้ไม่ได้ทันที ต้องการสร้างใหม่หรือไม่?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },

              child: const Text('ยกเลิก'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },

              child: const Text('สร้างใหม่'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      rotating = true;
    });

    try {
      final newQR = await repository.rotateQR(widget.tableId);

      if (!mounted) {
        return;
      }

      setState(() {
        qrFuture = Future.value(newQR);

        rotating = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('สร้าง QR ใหม่เรียบร้อย')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        rotating = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_getErrorMessage(error))));
    }
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(Icons.error_outline, size: 52),

            const SizedBox(height: 16),

            Text(_getErrorMessage(error), textAlign: TextAlign.center),

            const SizedBox(height: 16),

            FilledButton(
              onPressed: () {
                setState(() {
                  _loadQR();
                });
              },

              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      ),
    );
  }
}

String _getErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (error.response?.statusCode == 403) {
      return 'ไม่มีสิทธิ์เข้าถึงโต๊ะนี้';
    }

    if (error.response?.statusCode == 404) {
      return 'ไม่พบข้อมูลโต๊ะ';
    }
  }

  return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
}
