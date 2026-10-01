import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dining_table_repository.dart';
import '../model/dining_table.dart';

final diningTableRepositoryProvider = Provider<DiningTableRepository>(
  (ref) => DiningTableRepository(),
);

final diningTablesProvider = FutureProvider.autoDispose
    .family<List<DiningTable>, String>((ref, restaurantId) async {
      final repository = ref.read(diningTableRepositoryProvider);

      return repository.getTables(restaurantId);
    });
