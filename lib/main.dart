import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/auth_gate.dart';
import 'features/customer/presentation/customer_order_page.dart';

void main() {
  runApp(const ProviderScope(child: ServioApp()));
}

class ServioApp extends StatelessWidget {
  const ServioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servio',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange),

      home: _buildHome(),
    );
  }
}

Widget _buildHome() {
  final tableToken = Uri.base.queryParameters['tableToken'];

  if (tableToken != null && tableToken.trim().isNotEmpty) {
    return CustomerOrderPage(tableToken: tableToken.trim());
  }

  return const AuthGate();
}
