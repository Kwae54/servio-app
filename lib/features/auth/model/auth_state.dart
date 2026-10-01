import 'auth_restaurant.dart';
import 'auth_user.dart';

class AuthState {
  final AuthUser user;

  final List<AuthRestaurant> restaurants;

  const AuthState({required this.user, required this.restaurants});
}
