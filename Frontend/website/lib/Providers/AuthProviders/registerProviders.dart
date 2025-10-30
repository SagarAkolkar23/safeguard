import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:website/Services/Register.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data({}));

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      state = AsyncValue.data(response);
      return response;
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
      return {"success": false, "message": "Registration failed: $err"};
    }
  }

    Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response);
      return response;
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
      return {"success": false, "message": "Login failed: $err"};
    }
  }

}

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<Map<String, dynamic>>>((
      ref,
    ) {
      final service = ref.watch(authServiceProvider);
      return AuthNotifier(service);
    });
