import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/bill.dart';
import 'billing_provider.dart';
import '../../../core/printing/thermal_print_service.dart';

class BillPage extends ConsumerWidget {
  final String sessionId;
  final String tableNo;

  const BillPage({super.key, required this.sessionId, required this.tableNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bill = ref.watch(billProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: Text('Bill - โต๊ะ $tableNo')),

      body: bill.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => Center(child: Text(_errorMessage(error))),

        data: (bill) {
          return _BillContent(
            bill: bill,

            repository: ref.read(billingRepositoryProvider),

            onRefresh: () {
              ref.invalidate(billProvider(sessionId));
            },
          );
        },
      ),
    );
  }
}

class _BillContent extends StatelessWidget {
  final Bill bill;
  final dynamic repository;
  final VoidCallback onRefresh;

  const _BillContent({
    required this.bill,
    required this.repository,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),

        child: ListView(
          padding: const EdgeInsets.all(24),

          children: [
            Text(
              'โต๊ะ ${bill.tableNo}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            Chip(label: Text(bill.sessionStatus)),

            const SizedBox(height: 24),

            ...bill.items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,

                title: Text(item.menuItemName),

                subtitle: Text(
                  '${item.quantity} × ${_formatPrice(item.unitPriceSatang)}',
                ),

                trailing: Text(_formatPrice(item.totalSatang)),
              ),
            ),

            const Divider(),

            _MoneyRow(label: 'Subtotal', value: bill.subtotalSatang),

            if (bill.discounts.isNotEmpty) ...[
              const SizedBox(height: 12),

              const Text(
                'ส่วนลด',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              ...bill.discounts.map(
                (discount) => ListTile(
                  contentPadding: EdgeInsets.zero,

                  title: Text(discount.discountName),

                  subtitle: Text(
                    discount.discountType == 'PERCENT'
                        ? '${discount.discountValue}%'
                        : _formatPrice(discount.discountValue),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('-${_formatPrice(discount.discountAmountSatang)}'),

                      if (bill.sessionStatus == 'CHECKOUT_REQUESTED')
                        IconButton(
                          onPressed: () async {
                            try {
                              await repository.deleteDiscount(
                                sessionId: bill.sessionId,
                                discountId: discount.id,
                              );

                              onRefresh();
                            } catch (error) {
                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(_errorMessage(error))),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                    ],
                  ),
                ),
              ),

              _MoneyRow(label: 'Discount', value: -bill.discountTotalSatang),
            ],

            const Divider(),

            _MoneyRow(label: 'Total', value: bill.totalSatang, large: true),

            const SizedBox(height: 32),

            if (bill.sessionStatus == 'OPEN')
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await repository.checkout(bill.sessionId);

                    onRefresh();
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_errorMessage(error))),
                    );
                  }
                },

                icon: const Icon(Icons.receipt),

                label: const Text('ขอเช็กบิล'),
              ),

            if (bill.sessionStatus == 'CHECKOUT_REQUESTED') ...[
              OutlinedButton.icon(
                onPressed: () {
                  _showDiscountDialog(context, repository);
                },
                icon: const Icon(Icons.discount),
                label: const Text('เพิ่มส่วนลด'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await ThermalPrintService.printBill(bill: bill);
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'พิมพ์บิลไม่สำเร็จ: '
                          '${error.toString()}',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.print),
                label: const Text('พิมพ์บิล'),
              ),

              const SizedBox(height: 12),

              FilledButton.icon(
                onPressed: () {
                  _showPaymentDialog(context, repository);
                },
                icon: const Icon(Icons.payments),
                label: Text(
                  'รับชำระ '
                  '${_formatPrice(bill.totalSatang)}',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showDiscountDialog(
    BuildContext context,
    dynamic repository,
  ) async {
    final nameController = TextEditingController();

    final valueController = TextEditingController();

    final promotionController = TextEditingController();

    String type = 'PERCENT';

    await showDialog(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('เพิ่มส่วนลด'),

              content: SizedBox(
                width: 450,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: nameController,

                      decoration: const InputDecoration(
                        labelText: 'ชื่อส่วนลด',
                        hintText: 'เช่น สมาชิก',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: type,

                      items: const [
                        DropdownMenuItem(
                          value: 'PERCENT',
                          child: Text('เปอร์เซ็นต์'),
                        ),

                        DropdownMenuItem(
                          value: 'FIXED',
                          child: Text('จำนวนเงิน'),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            type = value;
                          });
                        }
                      },

                      decoration: const InputDecoration(
                        labelText: 'ประเภท',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: valueController,

                      keyboardType: TextInputType.number,

                      decoration: InputDecoration(
                        labelText: type == 'PERCENT'
                            ? 'เปอร์เซ็นต์'
                            : 'จำนวนเงิน (บาท)',

                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: promotionController,

                      decoration: const InputDecoration(
                        labelText: 'Promotion Code (ไม่บังคับ)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },

                  child: const Text('ยกเลิก'),
                ),

                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();

                    final rawValue = valueController.text.trim();

                    if (name.isEmpty || rawValue.isEmpty) {
                      return;
                    }

                    int? value;

                    if (type == 'PERCENT') {
                      value = int.tryParse(rawValue);
                    } else {
                      value = _bahtToSatang(rawValue);
                    }

                    if (value == null || value <= 0) {
                      return;
                    }

                    try {
                      await repository.addDiscount(
                        sessionId: bill.sessionId,
                        discountName: name,
                        discountType: type,
                        discountValue: value,
                        promotionCode: promotionController.text,
                      );

                      onRefresh();

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_errorMessage(error))),
                      );
                    }
                  },

                  child: const Text('เพิ่มส่วนลด'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    valueController.dispose();
    promotionController.dispose();
  }

  Future<void> _showPaymentDialog(
    BuildContext context,
    dynamic repository,
  ) async {
    String method = 'CASH';

    final transactionController = TextEditingController();

    await showDialog(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('รับชำระเงิน'),

              content: SizedBox(
                width: 450,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Text(
                      _formatPrice(bill.totalSatang),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 24),

                    DropdownButtonFormField<String>(
                      value: method,

                      items: const [
                        DropdownMenuItem(value: 'CASH', child: Text('เงินสด')),

                        DropdownMenuItem(
                          value: 'PROMPTPAY',
                          child: Text('PromptPay'),
                        ),

                        DropdownMenuItem(
                          value: 'CREDIT_CARD',
                          child: Text('บัตรเครดิต'),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            method = value;
                          });
                        }
                      },

                      decoration: const InputDecoration(
                        labelText: 'ช่องทางชำระ',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    if (method != 'CASH') ...[
                      const SizedBox(height: 16),

                      TextField(
                        controller: transactionController,

                        decoration: const InputDecoration(
                          labelText: 'Transaction Reference',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },

                  child: const Text('ยกเลิก'),
                ),

                FilledButton(
                  onPressed: () async {
                    try {
                      await repository.pay(
                        sessionId: bill.sessionId,
                        method: method,
                        transactionRef: method == 'CASH'
                            ? null
                            : transactionController.text,
                      );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_errorMessage(error))),
                      );
                    }
                  },

                  child: const Text('ยืนยันรับชำระ'),
                ),
              ],
            );
          },
        );
      },
    );

    transactionController.dispose();
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final int value;
  final bool large;

  const _MoneyRow({
    required this.label,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [
          Text(
            label,

            style: large ? Theme.of(context).textTheme.titleLarge : null,
          ),

          const Spacer(),

          Text(
            value < 0 ? '-${_formatPrice(-value)}' : _formatPrice(value),

            style: large ? Theme.of(context).textTheme.headlineSmall : null,
          ),
        ],
      ),
    );
  }
}

int? _bahtToSatang(String value) {
  final text = value.trim().replaceAll(',', '');

  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) {
    return null;
  }

  final parts = text.split('.');

  final baht = int.tryParse(parts[0]);

  if (baht == null) {
    return null;
  }

  var satang = 0;

  if (parts.length == 2) {
    satang = int.parse(parts[1].padRight(2, '0').substring(0, 2));
  }

  return baht * 100 + satang;
}

String _formatPrice(int satang) {
  final baht = satang ~/ 100;

  final decimal = satang % 100;

  if (decimal == 0) {
    return '฿$baht';
  }

  return '฿$baht.${decimal.toString().padLeft(2, '0')}';
}

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
  }

  return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
}
