import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/dining_table.dart';
import 'dining_table_provider.dart';
import '../../table_qr/presentation/table_qr_page.dart';

class DiningTablePage extends ConsumerWidget {
  final String restaurantId;
  final String restaurantName;

  const DiningTablePage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(diningTablesProvider(restaurantId));

    return Scaffold(
      appBar: AppBar(title: Text('โต๊ะ - $restaurantName')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateDialog(context, ref);
        },

        icon: const Icon(Icons.add),

        label: const Text('เพิ่มโต๊ะ'),
      ),

      body: tables.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => _ErrorView(
          message: _getErrorMessage(error),

          onRetry: () {
            ref.invalidate(diningTablesProvider(restaurantId));
          },
        ),

        data: (tables) {
          if (tables.isEmpty) {
            return const Center(child: Text('ยังไม่มีโต๊ะ'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(diningTablesProvider(restaurantId));

              await ref.read(diningTablesProvider(restaurantId).future);
            },

            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 700) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(24),

                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          mainAxisExtent: 210,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),

                    itemCount: tables.length,

                    itemBuilder: (context, index) {
                      return _TableCard(
                        table: tables[index],
                        restaurantId: restaurantId,
                      );
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),

                  itemCount: tables.length,

                  separatorBuilder: (_, __) => const SizedBox(height: 8),

                  itemBuilder: (context, index) {
                    return _TableCard(
                      table: tables[index],
                      restaurantId: restaurantId,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final tableNoController = TextEditingController();

    final tableNameController = TextEditingController();

    bool loading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('เพิ่มโต๊ะ'),

              content: SizedBox(
                width: 420,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: tableNoController,

                      autofocus: true,

                      decoration: const InputDecoration(
                        labelText: 'หมายเลขโต๊ะ',
                        hintText: 'เช่น A01',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: tableNameController,

                      decoration: const InputDecoration(
                        labelText: 'ชื่อโต๊ะ (ไม่บังคับ)',
                        hintText: 'เช่น ริมหน้าต่าง',
                        border: OutlineInputBorder(),
                      ),
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
                          final tableNo = tableNoController.text.trim();

                          if (tableNo.isEmpty) {
                            return;
                          }

                          setState(() {
                            loading = true;
                          });

                          try {
                            final repository = ref.read(
                              diningTableRepositoryProvider,
                            );

                            await repository.createTable(
                              restaurantId: restaurantId,
                              tableNo: tableNo,
                              tableName: tableNameController.text,
                            );

                            ref.invalidate(diningTablesProvider(restaurantId));

                            if (dialogContext.mounted) {
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
                      : const Text('เพิ่มโต๊ะ'),
                ),
              ],
            );
          },
        );
      },
    );

    tableNoController.dispose();
    tableNameController.dispose();
  }
}

class _TableCard extends ConsumerWidget {
  final DiningTable table;
  final String restaurantId;

  const _TableCard({required this.table, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                _TableStatusIcon(status: table.status),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'โต๊ะ ${table.tableNo}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      if (table.tableName != null &&
                          table.tableName!.isNotEmpty)
                        Text(table.tableName!),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(context, ref);
                    }

                    if (value == 'qr') {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => TableQRPage(
                            tableId: table.id,
                            tableNo: table.tableNo,
                          ),
                        ),
                      );
                    }
                  },

                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',

                      child: Row(
                        children: [
                          Icon(Icons.edit),

                          SizedBox(width: 8),

                          Text('แก้ไขโต๊ะ'),
                        ],
                      ),
                    ),

                    PopupMenuItem(
                      value: 'qr',

                      child: Row(
                        children: [
                          Icon(Icons.qr_code),

                          SizedBox(width: 8),

                          Text('QR โต๊ะ'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            Row(
              children: [
                _StatusBadge(status: table.status),

                const Spacer(),

                if (!table.isOccupied)
                  Switch(
                    value: table.isAvailable,

                    onChanged: (active) async {
                      try {
                        final repository = ref.read(
                          diningTableRepositoryProvider,
                        );

                        await repository.updateStatus(
                          tableId: table.id,
                          status: active ? 'AVAILABLE' : 'INACTIVE',
                        );

                        ref.invalidate(diningTablesProvider(restaurantId));
                      } catch (error) {
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_getErrorMessage(error))),
                        );
                      }
                    },
                  ),
              ],
            ),

            if (table.isOccupied)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'โต๊ะกำลังใช้งาน ไม่สามารถปิดโต๊ะด้วยตนเองได้',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final tableNoController = TextEditingController(text: table.tableNo);

    final tableNameController = TextEditingController(
      text: table.tableName ?? '',
    );

    bool loading = false;

    await showDialog(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('แก้ไขโต๊ะ'),

              content: SizedBox(
                width: 420,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: tableNoController,

                      decoration: const InputDecoration(
                        labelText: 'หมายเลขโต๊ะ',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: tableNameController,

                      decoration: const InputDecoration(
                        labelText: 'ชื่อโต๊ะ',
                        border: OutlineInputBorder(),
                      ),
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
                          final tableNo = tableNoController.text.trim();

                          if (tableNo.isEmpty) {
                            return;
                          }

                          setState(() {
                            loading = true;
                          });

                          try {
                            final repository = ref.read(
                              diningTableRepositoryProvider,
                            );

                            await repository.updateTable(
                              tableId: table.id,
                              tableNo: tableNo,
                              tableName: tableNameController.text,
                            );

                            ref.invalidate(diningTablesProvider(restaurantId));

                            if (dialogContext.mounted) {
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
                      : const Text('บันทึก'),
                ),
              ],
            );
          },
        );
      },
    );

    tableNoController.dispose();
    tableNameController.dispose();
  }
}

class _TableStatusIcon extends StatelessWidget {
  final String status;

  const _TableStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (status) {
      case 'OCCUPIED':
        icon = Icons.people;
        break;

      case 'INACTIVE':
        icon = Icons.block;
        break;

      default:
        icon = Icons.table_restaurant;
    }

    return CircleAvatar(radius: 24, child: Icon(icon));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;

    switch (status) {
      case 'AVAILABLE':
        label = 'ว่าง';
        break;

      case 'OCCUPIED':
        label = 'กำลังใช้งาน';
        break;

      case 'INACTIVE':
        label = 'ปิดใช้งาน';
        break;

      default:
        label = status;
    }

    return Chip(label: Text(label));
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),

          const SizedBox(height: 16),

          FilledButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ],
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
  }

  return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
}
