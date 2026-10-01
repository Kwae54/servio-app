import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_storage.dart';

import '../data/auth_repository.dart';
import '../model/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState?> {
  late AuthRepository repository;

  @override
  Future<AuthState?> build() async {
    repository = ref.read(authRepositoryProvider);

    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await repository.me();
    } catch (_) {
      await TokenStorage.clear();

      return null;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final authState = await repository.login(
        username: username,
        password: password,
      );

      state = AsyncData(authState);

      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();

    state = const AsyncData(null);
  }

  Future<void> refreshMe() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() => repository.me());
  }
}
