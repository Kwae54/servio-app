import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_repository.dart';
import '../model/app_user.dart';
import '../model/user_restaurant.dart';
import 'user_provider.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('จัดการผู้ใช้งาน')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateUserDialog(context, ref);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('เพิ่มผู้ใช้งาน'),
      ),

      body: users.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getErrorMessage(error)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.read(userProvider.notifier).refresh();
                  },
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        },

        data: (users) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'ค้นหาชื่อผู้ใช้งาน...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).search(value);
                  },
                ),
              ),

              Expanded(
                child: users.isEmpty
                    ? const Center(child: Text('ไม่พบผู้ใช้งาน'))
                    : RefreshIndicator(
                        onRefresh: () {
                          return ref.read(userProvider.notifier).refresh();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: users.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final user = users[index];

                            return _UserCard(
                              user: user,
                              onStatusChanged: (value) async {
                                await ref
                                    .read(userProvider.notifier)
                                    .updateStatus(
                                      userId: user.id,
                                      status: value ? 'ACTIVE' : 'INACTIVE',
                                    );
                              },
                              onRestaurants: () {
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    return _AssignRestaurantDialog(
                                      user: user,
                                      repository: ref.read(
                                        userRepositoryProvider,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateUserDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final usernameController = TextEditingController();

    final passwordController = TextEditingController();

    final displayNameController = TextEditingController();

    String role = 'RESTAURANT_USER';

    bool loading = false;

    await showDialog(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('เพิ่มผู้ใช้งาน'),

              content: SizedBox(
                width: 420,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: usernameController,

                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: displayNameController,

                      decoration: const InputDecoration(
                        labelText: 'ชื่อที่แสดง',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,

                      obscureText: true,

                      decoration: const InputDecoration(
                        labelText: 'Password',
                        helperText: 'อย่างน้อย 8 ตัวอักษร',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: role,

                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: 'SUPER_ADMIN',
                          child: Text('Super Admin'),
                        ),

                        DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),

                        DropdownMenuItem(
                          value: 'RESTAURANT_USER',
                          child: Text('Restaurant User'),
                        ),
                      ],

                      onChanged: loading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  role = value;
                                });
                              }
                            },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('ยกเลิก'),
                ),

                FilledButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final username = usernameController.text.trim();

                          final displayName = displayNameController.text.trim();

                          final password = passwordController.text;

                          if (username.isEmpty ||
                              displayName.isEmpty ||
                              password.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'กรุณากรอกข้อมูลให้ครบ และ Password อย่างน้อย 8 ตัว',
                                ),
                              ),
                            );

                            return;
                          }

                          setState(() {
                            loading = true;
                          });

                          try {
                            await ref
                                .read(userProvider.notifier)
                                .createUser(
                                  username: username,
                                  password: password,
                                  displayName: displayName,
                                  role: role,
                                );

                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (error) {
                            setState(() {
                              loading = false;
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_getErrorMessage(error)),
                                ),
                              );
                            }
                          }
                        },

                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('สร้าง User'),
                ),
              ],
            );
          },
        );
      },
    );

    usernameController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  final ValueChanged<bool> onStatusChanged;
  final VoidCallback onRestaurants;

  const _UserCard({
    required this.user,
    required this.onStatusChanged,
    required this.onRestaurants,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Text(
                user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase()
                    : '?',
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 4),

                  Text('@${user.username}'),

                  const SizedBox(height: 4),

                  Text(_roleName(user.role)),
                ],
              ),
            ),

            if (user.role == 'RESTAURANT_USER')
              OutlinedButton.icon(
                onPressed: onRestaurants,
                icon: const Icon(Icons.storefront),
                label: const Text('ร้าน'),
              ),

            const SizedBox(width: 16),

            Column(
              children: [
                Switch(value: user.isActive, onChanged: onStatusChanged),

                Text(user.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _roleName(String role) {
  switch (role) {
    case 'SUPER_ADMIN':
      return 'Super Admin';

    case 'ADMIN':
      return 'Admin';

    case 'RESTAURANT_USER':
      return 'Restaurant User';

    default:
      return role;
  }
}

class _AssignRestaurantDialog extends StatefulWidget {
  final AppUser user;
  final UserRepository repository;

  const _AssignRestaurantDialog({required this.user, required this.repository});

  @override
  State<_AssignRestaurantDialog> createState() =>
      _AssignRestaurantDialogState();
}

class _AssignRestaurantDialogState extends State<_AssignRestaurantDialog> {
  bool loading = true;

  List<UserRestaurant> allRestaurants = [];

  List<UserRestaurant> assignedRestaurants = [];

  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
    });

    try {
      final results = await Future.wait([
        widget.repository.getRestaurants(),

        widget.repository.getUserRestaurants(widget.user.id),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        allRestaurants = results[0];

        assignedRestaurants = results[1];

        loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });
    }
  }

  bool isAssigned(String restaurantId) {
    return assignedRestaurants.any(
      (restaurant) => restaurant.id == restaurantId,
    );
  }

  Future<void> toggleRestaurant(UserRestaurant restaurant, bool value) async {
    try {
      if (value) {
        await widget.repository.assignRestaurant(
          userId: widget.user.id,
          restaurantId: restaurant.id,
        );
      } else {
        await widget.repository.removeRestaurant(
          userId: widget.user.id,
          restaurantId: restaurant.id,
        );
      }

      await load();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_getErrorMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('ร้านของ ${widget.user.displayName}'),

      content: SizedBox(
        width: 500,
        height: 400,

        child: loading
            ? const Center(child: CircularProgressIndicator())
            : allRestaurants.isEmpty
            ? const Center(child: Text('ยังไม่มีร้านอาหาร'))
            : ListView.builder(
                itemCount: allRestaurants.length,

                itemBuilder: (context, index) {
                  final restaurant = allRestaurants[index];

                  final assigned = isAssigned(restaurant.id);

                  return CheckboxListTile(
                    value: assigned,

                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      toggleRestaurant(restaurant, value);
                    },

                    title: Text(restaurant.name),

                    subtitle: Text(restaurant.status),

                    secondary: const Icon(Icons.storefront),
                  );
                },
              ),
      ),

      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('ปิด'),
        ),
      ],
    );
  }
}

String _getErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
  }

  return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
}
