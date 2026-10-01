import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pages/admin_home_page.dart';
import '../../../pages/restaurant_home_page.dart';
import '../../../pages/super_admin_home_page.dart';

import 'auth_provider.dart';
import 'login_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return auth.when(
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },

      error: (error, stackTrace) {
        return const LoginPage();
      },

      data: (state) {
        if (state == null) {
          return const LoginPage();
        }

        switch (state.user.role) {
          case 'SUPER_ADMIN':
            return const SuperAdminHomePage();

          case 'ADMIN':
            return const AdminHomePage();

          case 'RESTAURANT_USER':
            return const RestaurantHomePage();

          default:
            return const LoginPage();
        }
      },
    );
  }
}
