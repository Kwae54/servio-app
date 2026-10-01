import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../model/menu_category.dart';
import '../model/menu_item.dart';

class MenuRepository {
  // ==========================
  // CATEGORY
  // ==========================

  Future<List<MenuCategory>> getCategories(String restaurantId) async {
    final response = await ApiClient.dio.get(
      '/restaurants/$restaurantId/categories',
    );

    final List data = response.data['data'] ?? [];

    return data
        .map((json) => MenuCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MenuCategory> createCategory({
    required String restaurantId,
    required String name,
    required int sortOrder,
  }) async {
    final response = await ApiClient.dio.post(
      '/restaurants/$restaurantId/categories',
      data: {'name': name, 'sortOrder': sortOrder},
    );

    return MenuCategory.fromJson(response.data['data']);
  }

  Future<MenuCategory> updateCategory({
    required String categoryId,
    required String name,
    required int sortOrder,
  }) async {
    final response = await ApiClient.dio.put(
      '/categories/$categoryId',
      data: {'name': name, 'sortOrder': sortOrder},
    );

    return MenuCategory.fromJson(response.data['data']);
  }

  Future<MenuCategory> updateCategoryActive({
    required String categoryId,
    required bool active,
  }) async {
    final response = await ApiClient.dio.patch(
      '/categories/$categoryId/active',
      data: {'active': active},
    );

    return MenuCategory.fromJson(response.data['data']);
  }

  // ==========================
  // MENU ITEM
  // ==========================

  Future<List<MenuItem>> getMenuItems({
    required String restaurantId,
    String search = '',
  }) async {
    final response = await ApiClient.dio.get(
      '/restaurants/$restaurantId/menu-items',
      queryParameters: {if (search.trim().isNotEmpty) 'search': search.trim()},
    );

    final List data = response.data['data'] ?? [];

    return data
        .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MenuItem> createMenuItem({
    required String restaurantId,
    required String categoryId,
    required String name,
    required String description,
    required int priceSatang,
    required int sortOrder,
  }) async {
    final response = await ApiClient.dio.post(
      '/restaurants/$restaurantId/menu-items',
      data: {
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'priceSatang': priceSatang,
        'sortOrder': sortOrder,
      },
    );

    return MenuItem.fromJson(response.data['data']);
  }

  Future<MenuItem> updateMenuItem({
    required String menuItemId,
    required String categoryId,
    required String name,
    required String description,
    required int priceSatang,
    required int sortOrder,
  }) async {
    final response = await ApiClient.dio.put(
      '/menu-items/$menuItemId',
      data: {
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'priceSatang': priceSatang,
        'sortOrder': sortOrder,
      },
    );

    return MenuItem.fromJson(response.data['data']);
  }

  Future<MenuItem> updateAvailable({
    required String menuItemId,
    required bool available,
  }) async {
    final response = await ApiClient.dio.patch(
      '/menu-items/$menuItemId/available',
      data: {'available': available},
    );

    return MenuItem.fromJson(response.data['data']);
  }

  Future<MenuItem> uploadImage({
    required String menuItemId,
    required List<int> bytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await ApiClient.dio.post(
      '/menu-items/$menuItemId/image',
      data: formData,
    );

    return MenuItem.fromJson(response.data['data']);
  }
}
