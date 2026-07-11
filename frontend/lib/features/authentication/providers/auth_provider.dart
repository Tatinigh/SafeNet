import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User profile details representation.
class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool isGuest;

  AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.isGuest,
  });

  factory AuthUser.guest() {
    return AuthUser(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@safenetai.local',
      displayName: 'SafeNet Guest',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      isGuest: true,
    );
  }

  factory AuthUser.email(String email) {
    return AuthUser(
      uid: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@')[0],
      photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
      isGuest: false,
    );
  }
}

/// Simple state class for Auth.
class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier to manage sign-in, guest modes, and sign-out.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    
    if (email.contains('@') && password.length >= 6) {
      state = state.copyWith(
        user: AuthUser.email(email),
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid credentials. Password must be at least 6 characters.',
      );
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      user: AuthUser(
        uid: 'google_user_123',
        email: 'user@gmail.com',
        displayName: 'John Doe',
        photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
        isGuest: false,
      ),
      isLoading: false,
    );
  }

  void signInAsGuest() {
    state = state.copyWith(
      user: AuthUser.guest(),
      isLoading: false,
    );
  }

  void signOut() {
    state = state.copyWith(clearUser: true);
  }
}

/// Provider to access the auth state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
