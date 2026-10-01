import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/menu_repository.dart';
import '../model/menu_category.dart';
import '../model/menu_item.dart';

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepository(),
);

final menuCategoriesProvider = FutureProvider.autoDispose
    .family<List<MenuCategory>, String>((ref, restaurantId) async {
      return ref.read(menuRepositoryProvider).getCategories(restaurantId);
    });

class MenuItemQuery {
  final String restaurantId;
  final String search;

  const MenuItemQuery({required this.restaurantId, this.search = ''});

  @override
  bool operator ==(Object other) {
    return other is MenuItemQuery &&
        other.restaurantId == restaurantId &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(restaurantId, search);
}

final menuItemsProvider = FutureProvider.autoDispose
    .family<List<MenuItem>, MenuItemQuery>((ref, query) async {
      return ref
          .read(menuRepositoryProvider)
          .getMenuItems(restaurantId: query.restaurantId, search: query.search);
    });
