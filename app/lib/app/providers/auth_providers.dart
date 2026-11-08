import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failure.dart';
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
    _restore();
    return const AuthUnknown();
  }

  Future<void> _restore() async {
    final repo = ref.read(authRepositoryProvider);
    final loggedIn = await repo.isLoggedIn();
    if (!loggedIn) {
      state = const AuthLoggedOut();
      return;
    }
    final result = await repo.currentUser();
    state = result.when(
      success: AuthLoggedIn.new,
      failure: (_) => const AuthLoggedOut(),
    );
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
