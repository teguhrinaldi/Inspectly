import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failure.dart';
import '../../core/network/api_client.dart';
import '../../data/models/app_user.dart';
import 'repository_providers.dart';

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthLoggedIn extends AuthState {
  const AuthLoggedIn(this.user);
  final AppUser user;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Any request rejected with 401 (expired/revoked token, deactivated
    // account) ends the session app-wide.
    final sub = ApiClient.onUnauthorized.listen((_) => _expire());
    ref.onDispose(sub.cancel);
    _restore();
    return const AuthUnknown();
  }

  Future<void> _restore() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final loggedIn = await repo.isLoggedIn();
      if (state is! AuthUnknown) return; // user signed in meanwhile
      if (!loggedIn) {
        state = const AuthLoggedOut();
        return;
      }
      final result = await repo.currentUser();
      if (state is! AuthUnknown) return;
      state = await result.when(
        success: (user) async => AuthLoggedIn(user),
        failure: (failure) async {
          // Only a rejected token ends the session; being offline (with no
          // cached user) just shows the login and keeps the token.
          if (failure is UnauthorizedFailure) await repo.logout();
          return const AuthLoggedOut();
        },
      );
    } catch (e) {
      debugPrint('AuthNotifier: restore failed: $e');
      if (state is AuthUnknown) state = const AuthLoggedOut();
    }
  }

  Future<void> _expire() async {
    if (state is! AuthLoggedIn) return;
    state = const AuthLoggedOut();
    await ref.read(authRepositoryProvider).logout();
  }

  Future<Failure?> login({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email: email, password: password);
    return result.when(
      success: (user) {
        state = AuthLoggedIn(user);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthLoggedOut();
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
