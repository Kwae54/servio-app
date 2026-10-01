import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../order/model/restaurant_order.dart';
import '../data/customer_repository.dart';

class CustomerOrderStatusPage extends StatefulWidget {
  final String tableToken;

  const CustomerOrderStatusPage({super.key, required this.tableToken});

  @override
  State<CustomerOrderStatusPage> createState() =>
      _CustomerOrderStatusPageState();
}

class _CustomerOrderStatusPageState extends State<CustomerOrderStatusPage> {
  final CustomerRepository repository = CustomerRepository();

  List<RestaurantOrder> orders = [];

  bool loading = true;

  String? error;

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();

    _load();

    refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _load(showLoading: false);
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();

    super.dispose();
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final result = await repository.getOrders(widget.tableToken);

      if (!mounted) {
        return;
      }

      setState(() {
        orders = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        error = _errorMessage(e);

        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการที่สั่ง'),

        actions: [
          IconButton(
            tooltip: 'รีเฟรช',

            onPressed: _load,

            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? _buildError()
          : orders.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _load,

              child: ListView.separated(
                padding: const EdgeInsets.all(16),

                itemCount: orders.length,

                separatorBuilder: (_, __) => const SizedBox(height: 12),

                itemBuilder: (context, index) {
                  return _OrderStatusCard(order: orders[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(Icons.receipt_long, size: 64),

          SizedBox(height: 16),

          Text('ยังไม่มีรายการที่สั่ง'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(error!),

          const SizedBox(height: 16),

          FilledButton(onPressed: _load, child: const Text('ลองใหม่')),
        ],
      ),
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  final RestaurantOrder order;

  const _OrderStatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        order.orderCode,

                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const SizedBox(height: 4),

                      Text(_formatDateTime(order.createdAt)),
                    ],
                  ),
                ),

                _StatusChip(status: order.status),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      width: 38,
                      height: 38,

                      alignment: Alignment.center,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),

                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),

                      child: Text('${item.quantity}x'),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            item.menuItemName,

                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          if (item.note != null && item.note!.isNotEmpty)
                            Text('หมายเหตุ: ${item.note}'),
                        ],
                      ),
                    ),

                    Text(_formatPrice(item.totalSatang)),
                  ],
                ),
              );
            }),

            const Divider(),

            Row(
              children: [
                const Text(
                  'รวม',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const Spacer(),

                Text(
                  _formatPrice(order.totalSatang),

                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),

            if (order.customerNote != null &&
                order.customerNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),

              Text('หมายเหตุถึงร้าน: ${order.customerNote}'),
            ],

            const SizedBox(height: 16),

            _StatusDescription(status: order.status),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(_statusIcon(status), size: 18),

      label: Text(_statusLabel(status)),
    );
  }
}

class _StatusDescription extends StatelessWidget {
  final String status;

  const _StatusDescription({required this.status});

  @override
  Widget build(BuildContext context) {
    String message;

    switch (status) {
      case 'PENDING':
        message = 'ร้านได้รับรายการแล้ว กำลังรอรับออเดอร์';
        break;

      case 'ACCEPTED':
        message = 'ร้านรับออเดอร์แล้ว';
        break;

      case 'PREPARING':
        message = 'กำลังเตรียมอาหาร';
        break;

      case 'READY':
        message = 'อาหารพร้อมเสิร์ฟแล้ว';
        break;

      case 'SERVED':
        message = 'เสิร์ฟอาหารเรียบร้อยแล้ว';
        break;

      case 'CANCELLED':
        message = 'ออเดอร์นี้ถูกยกเลิก';
        break;

      default:
        message = status;
    }

    return Row(
      children: [
        Icon(_statusIcon(status), size: 20),

        const SizedBox(width: 8),

        Expanded(child: Text(message)),
      ],
    );
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'PENDING':
      return Icons.schedule;

    case 'ACCEPTED':
      return Icons.check_circle;

    case 'PREPARING':
      return Icons.soup_kitchen;

    case 'READY':
      return Icons.room_service;

    case 'SERVED':
      return Icons.done_all;

    case 'CANCELLED':
      return Icons.cancel;

    default:
      return Icons.receipt_long;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'PENDING':
      return 'รอรับ';

    case 'ACCEPTED':
      return 'รับแล้ว';

    case 'PREPARING':
      return 'กำลังทำ';

    case 'READY':
      return 'พร้อมเสิร์ฟ';

    case 'SERVED':
      return 'เสิร์ฟแล้ว';

    case 'CANCELLED':
      return 'ยกเลิก';

    default:
      return status;
  }
}

String _formatPrice(int satang) {
  final baht = satang ~/ 100;

  final decimal = satang % 100;

  if (decimal == 0) {
    return '฿$baht';
  }

  return '฿$baht.${decimal.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '';
  }

  final local = value.toLocal();

  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
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
