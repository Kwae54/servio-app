import 'customer_menu.dart';

class CustomerCartItem {
  final CustomerMenuItem menuItem;

  int quantity;
  String note;

  CustomerCartItem({required this.menuItem, this.quantity = 1, this.note = ''});

  int get totalSatang => menuItem.priceSatang * quantity;
}
