import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_repository.dart';
import '../model/app_user.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

final userProvider = AsyncNotifierProvider<UserNotifier, List<AppUser>>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<List<AppUser>> {
  Timer? _searchTimer;

  String _currentSearch = '';

  UserRepository get repository => ref.read(userRepositoryProvider);

  @override
  Future<List<AppUser>> build() {
    ref.onDispose(() {
      _searchTimer?.cancel();
    });

    return repository.getUsers();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => repository.getUsers(search: _currentSearch),
    );
  }

  void search(String keyword) {
    _currentSearch = keyword.trim();

    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 400), () async {
      state = await AsyncValue.guard(
        () => repository.getUsers(search: _currentSearch),
      );
    });
  }

  Future<void> createUser({
    required String username,
    required String password,
    required String displayName,
    required String role,
  }) async {
    await repository.createUser(
      username: username,
      password: password,
      displayName: displayName,
      role: role,
    );

    await refresh();
  }

  Future<void> updateStatus({
    required String userId,
    required String status,
  }) async {
    await repository.updateStatus(userId: userId, status: status);

    await refresh();
  }
}
