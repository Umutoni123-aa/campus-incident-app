import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider({AuthService? service}) : _service = service ?? AuthService() {
    _authSubscription = authStateChanges.listen(_loadCurrentUserRole);
  }

  bool isLoading = false;
  bool isLoadingRole = true;
  String? errorMessage;
  String? _role;
  String? _name;

  Stream<User?> get authStateChanges => _service.authStateChanges;
  User? get currentUser => _service.currentUser;
  bool get isEmailVerified => currentUser?.emailVerified ?? false;
  String? get role => _role;
  bool get isStaff => _role == 'staff';
  String get userName {
    if (_name != null && _name!.trim().isNotEmpty) return _name!;
    if (currentUser?.displayName?.trim().isNotEmpty ?? false) {
      return currentUser!.displayName!;
    }
    return currentUser?.email?.split('@').first ?? 'there';
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _run(
      () => _service.register(name: name, email: email, password: password),
    );
  }

  Future<void> login({required String email, required String password}) async {
    await _run(() => _service.login(email: email, password: password));
  }

  Future<void> logout() async {
    await _run(_service.logout);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _run(() => _service.sendPasswordResetEmail(email.trim()));
  }

  Future<void> resendVerificationEmail() async {
    await _run(_service.resendVerificationEmail);
  }

  Future<bool> refreshVerificationStatus() async {
    var verified = false;
    await _run(() async {
      verified = await _service.reloadUser();
    });
    return verified;
  }

  Future<void> _loadCurrentUserRole(User? user) async {
    if (user == null) {
      _role = null;
      _name = null;
      isLoadingRole = false;
      notifyListeners();
      return;
    }
    isLoadingRole = true;
    notifyListeners();
    try {
      final profile = await _service.getUserProfile(user.uid);
      _role = profile?.role;
      _name = profile?.name;
    } catch (_) {
      _role = null;
    } finally {
      isLoadingRole = false;
      notifyListeners();
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      errorMessage = _friendlyMessage(error);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
