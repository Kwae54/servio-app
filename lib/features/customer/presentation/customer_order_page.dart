import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';

import '../data/customer_repository.dart';
import '../model/customer_cart_item.dart';
import '../model/customer_menu.dart';
import '../model/customer_table_info.dart';
import 'customer_order_status_page.dart';

class CustomerOrderPage extends StatefulWidget {
  final String tableToken;

  const CustomerOrderPage({super.key, required this.tableToken});

  @override
  State<CustomerOrderPage> createState() => _CustomerOrderPageState();
}

class _CustomerOrderPageState extends State<CustomerOrderPage> {
  final CustomerRepository repository = CustomerRepository();

  final Map<String, CustomerCartItem> cart = {};

  CustomerTableInfo? tableInfo;

  List<CustomerMenuCategory> categories = [];

  String? selectedCategoryId;

  String search = '';

  bool loading = true;

  String? error;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final table = await repository.getTableInfo(widget.tableToken);

      final menu = await repository.getMenu(widget.tableToken);

      if (!mounted) {
        return;
      }

      setState(() {
        tableInfo = table;
        categories = menu;
        loading = false;
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

  List<CustomerMenuItem> get visibleItems {
    final items = <CustomerMenuItem>[];

    for (final category in categories) {
      if (selectedCategoryId != null && category.id != selectedCategoryId) {
        continue;
      }

      for (final item in category.items) {
        if (search.isNotEmpty &&
            !item.name.toLowerCase().contains(search.toLowerCase())) {
          continue;
        }

        items.add(item);
      }
    }

    return items;
  }

  int get cartQuantity {
    return cart.values.fold(0, (total, item) => total + item.quantity);
  }

  int get cartTotal {
    return cart.values.fold(0, (total, item) => total + item.totalSatang);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null || tableInfo == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(error ?? 'ไม่พบข้อมูลร้าน'),

              const SizedBox(height: 16),

              FilledButton(onPressed: _load, child: const Text('ลองใหม่')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            _buildSearch(),

            _buildCategories(),

            const Divider(height: 1),

            Expanded(child: _buildMenuList()),

            if (cart.isNotEmpty) _buildCartBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final info = tableInfo!;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),

      child: Row(
        children: [
          if (info.restaurantImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: Image.network(
                AppConfig.imageUrl(info.restaurantImageUrl),

                width: 60,
                height: 60,
                fit: BoxFit.cover,

                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 60,
                    height: 60,

                    child: Icon(Icons.restaurant, size: 36),
                  );
                },
              ),
            )
          else
            const SizedBox(
              width: 60,
              height: 60,

              child: Icon(Icons.restaurant, size: 36),
            ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  info.restaurantName,

                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 4),

                Text('โต๊ะ ${info.tableNo}'),

                if (info.tableName != null && info.tableName!.isNotEmpty)
                  Text(info.tableName!),
              ],
            ),
          ),
          IconButton(
            tooltip: 'รายการที่สั่ง',

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      CustomerOrderStatusPage(tableToken: widget.tableToken),
                ),
              );
            },

            icon: const Icon(Icons.receipt_long),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: TextField(
        decoration: const InputDecoration(
          hintText: 'ค้นหาเมนู...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),

        onChanged: (value) {
          setState(() {
            search = value.trim();
          });
        },
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 64,

      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        scrollDirection: Axis.horizontal,

        children: [
          ChoiceChip(
            label: const Text('ทั้งหมด'),

            selected: selectedCategoryId == null,

            onSelected: (_) {
              setState(() {
                selectedCategoryId = null;
              });
            },
          ),

          const SizedBox(width: 8),

          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),

              child: ChoiceChip(
                label: Text(category.name),

                selected: selectedCategoryId == category.id,

                onSelected: (_) {
                  setState(() {
                    selectedCategoryId = category.id;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    final items = visibleItems;

    if (items.isEmpty) {
      return const Center(child: Text('ไม่พบเมนูอาหาร'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(20),

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,

            mainAxisExtent: 190,

            crossAxisSpacing: 12,

            mainAxisSpacing: 12,
          ),

          itemCount: items.length,

          itemBuilder: (context, index) {
            final item = items[index];

            return _buildMenuCard(item);
          },
        );
      },
    );
  }

  Widget _buildMenuCard(CustomerMenuItem item) {
    final cartItem = cart[item.id];

    return Card(
      clipBehavior: Clip.antiAlias,

      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: double.infinity,

            child: item.imageUrl != null
                ? Image.network(
                    AppConfig.imageUrl(item.imageUrl),

                    fit: BoxFit.cover,

                    errorBuilder: (context, error, stackTrace) =>
                        _menuPlaceholder(),
                  )
                : _menuPlaceholder(),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    item.name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      item.description,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],

                  const Spacer(),

                  Text(
                    _formatPrice(item.priceSatang),

                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  if (cartItem == null)
                    SizedBox(
                      width: double.infinity,

                      child: FilledButton(
                        onPressed: () {
                          _addItem(item);
                        },

                        child: const Text('เพิ่ม'),
                      ),
                    )
                  else
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _decreaseItem(item);
                          },

                          icon: const Icon(Icons.remove),
                        ),

                        Expanded(
                          child: Text(
                            '${cartItem.quantity}',

                            textAlign: TextAlign.center,

                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            _addItem(item);
                          },

                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuPlaceholder() {
    return Container(
      alignment: Alignment.center,

      color: Colors.grey.shade100,

      child: const Icon(Icons.restaurant_menu, size: 44),
    );
  }

  void _addItem(CustomerMenuItem item) {
    setState(() {
      final current = cart[item.id];

      if (current == null) {
        cart[item.id] = CustomerCartItem(menuItem: item);
      } else {
        current.quantity++;
      }
    });
  }

  void _decreaseItem(CustomerMenuItem item) {
    setState(() {
      final current = cart[item.id];

      if (current == null) {
        return;
      }

      current.quantity--;

      if (current.quantity <= 0) {
        cart.remove(item.id);
      }
    });
  }

  Widget _buildCartBar() {
    return SafeArea(
      top: false,

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: FilledButton(
          onPressed: _showCart,

          style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)),

          child: Row(
            children: [
              const Icon(Icons.shopping_cart),

              const SizedBox(width: 8),

              Text('$cartQuantity รายการ'),

              const Spacer(),

              Text(_formatPrice(cartTotal)),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCart() async {
    final customerNoteController = TextEditingController();

    bool submitting = false;

    await showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,

                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),

                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,

                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'ตะกร้า',

                            style: Theme.of(context).textTheme.headlineSmall,
                          ),

                          const Spacer(),

                          IconButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                            },

                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),

                      const Divider(),

                      Expanded(
                        child: ListView(
                          children: cart.values
                              .map(
                                (cartItem) =>
                                    _buildCartItem(cartItem, setSheetState),
                              )
                              .toList(),
                        ),
                      ),

                      TextField(
                        controller: customerNoteController,

                        maxLines: 2,

                        decoration: const InputDecoration(
                          labelText: 'หมายเหตุถึงร้าน (ไม่บังคับ)',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Text(
                            'รวมทั้งหมด',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const Spacer(),

                          Text(
                            _formatPrice(cartTotal),

                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,

                        child: FilledButton(
                          onPressed: submitting || cart.isEmpty
                              ? null
                              : () async {
                                  setSheetState(() {
                                    submitting = true;
                                  });

                                  final success = await _submitOrder(
                                    customerNoteController.text,
                                  );

                                  if (!mounted) {
                                    return;
                                  }

                                  if (success) {
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                  } else {
                                    setSheetState(() {
                                      submitting = false;
                                    });
                                  }
                                },

                          child: submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,

                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'ยืนยันสั่งอาหาร ${_formatPrice(cartTotal)}',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    customerNoteController.dispose();
  }

  Widget _buildCartItem(CustomerCartItem cartItem, StateSetter setSheetState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),

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
                      cartItem.menuItem.name,

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(_formatPrice(cartItem.totalSatang)),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    _decreaseItemWithoutSetState(cartItem);
                  });

                  setSheetState(() {});
                },

                icon: const Icon(Icons.remove_circle_outline),
              ),

              Text('${cartItem.quantity}'),

              IconButton(
                onPressed: () {
                  setState(() {
                    cartItem.quantity++;
                  });

                  setSheetState(() {});
                },

                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),

          TextButton.icon(
            onPressed: () {
              _editItemNote(cartItem, setSheetState);
            },

            icon: const Icon(Icons.edit_note),

            label: Text(
              cartItem.note.isEmpty
                  ? 'เพิ่มหมายเหตุ'
                  : 'หมายเหตุ: ${cartItem.note}',
            ),
          ),

          const Divider(),
        ],
      ),
    );
  }

  void _decreaseItemWithoutSetState(CustomerCartItem item) {
    item.quantity--;

    if (item.quantity <= 0) {
      cart.remove(item.menuItem.id);
    }
  }

  Future<void> _editItemNote(
    CustomerCartItem item,
    StateSetter sheetSetState,
  ) async {
    final controller = TextEditingController(text: item.note);

    await showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item.menuItem.name),

          content: TextField(
            controller: controller,

            autofocus: true,
            maxLines: 3,

            decoration: const InputDecoration(
              labelText: 'หมายเหตุ',
              hintText: 'เช่น ไม่เผ็ด, ไม่ใส่ผัก',
              border: OutlineInputBorder(),
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
              onPressed: () {
                setState(() {
                  item.note = controller.text.trim();
                });

                sheetSetState(() {});

                Navigator.pop(dialogContext);
              },

              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<bool> _submitOrder(String customerNote) async {
    try {
      final items = cart.values
          .map(
            (cartItem) => {
              'menuItemId': cartItem.menuItem.id,

              'quantity': cartItem.quantity,

              'note': cartItem.note,
            },
          )
          .toList();

      final result = await repository.createOrder(
        tableToken: widget.tableToken,

        customerNote: customerNote.trim(),

        items: items,
      );

      if (!mounted) {
        return false;
      }

      final orderCode =
          result['orderCode']?.toString() ??
          result['orderNo']?.toString() ??
          '';

      setState(() {
        cart.clear();
      });

      await showDialog(
        context: context,

        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(Icons.check_circle, size: 56),

            title: const Text('สั่งอาหารสำเร็จ'),

            content: Text(
              orderCode.isEmpty
                  ? 'ส่งรายการอาหารให้ร้านแล้ว'
                  : 'หมายเลขออเดอร์ $orderCode',
              textAlign: TextAlign.center,
            ),

            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },

                child: const Text('ตกลง'),
              ),
            ],
          );
        },
      );

      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_errorMessage(error))));

      return false;
    }
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

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
  }

  return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
}
