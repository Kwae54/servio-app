import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SessionQRPage extends StatelessWidget {
  final String tableNo;
  final String sessionToken;

  const SessionQRPage({
    super.key,
    required this.tableNo,
    required this.sessionToken,
  });

  @override
  Widget build(BuildContext context) {
    const customerWebUrl = String.fromEnvironment(
      'CUSTOMER_WEB_URL',
      defaultValue: 'http://localhost:3000',
    );

    final orderUrl =
        '$customerWebUrl/?sessionToken=${Uri.encodeQueryComponent(sessionToken)}';

    return Scaffold(
      appBar: AppBar(title: Text('QR โต๊ะ $tableNo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'โต๊ะ $tableNo',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 12),

              const Text('สแกน QR เพื่อสั่งอาหาร'),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: QrImageView(data: orderUrl, size: 280),
              ),

              const SizedBox(height: 24),

              SelectableText(orderUrl, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
