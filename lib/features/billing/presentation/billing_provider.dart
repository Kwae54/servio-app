import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/billing_repository.dart';
import '../model/active_session.dart';
import '../model/bill.dart';

final billingRepositoryProvider = Provider<BillingRepository>(
  (ref) => BillingRepository(),
);

final activeSessionsProvider = FutureProvider.autoDispose
    .family<List<ActiveSession>, String>((ref, restaurantId) {
      return ref
          .read(billingRepositoryProvider)
          .getActiveSessions(restaurantId);
    });

final billProvider = FutureProvider.autoDispose.family<Bill, String>((
  ref,
  sessionId,
) {
  return ref.read(billingRepositoryProvider).getBill(sessionId);
});
