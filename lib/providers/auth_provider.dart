import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Check initial session — only admit verified users
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      _user = UserModel(
        name: currentUser.displayName ?? 'FitTrack User',
        email: currentUser.email ?? '',
      );
    }

    // Listen to real-time auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null && firebaseUser.emailVerified) {
        _user = UserModel(
          name: firebaseUser.displayName ?? 'FitTrack User',
          email: firebaseUser.email ?? '',
        );
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  // ── Email / Password Login ─────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Block unverified email/password accounts
      if (credential.user != null && !credential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        _errorMessage =
            'Email not verified. Please check your inbox and click the verification link.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyAuthError(e.code) ?? e.message ?? 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Email / Password Sign Up ───────────────────────────────────────────────
  // Returns the registered email on success so the UI can show the verification
  // screen, or null if signup failed.
  Future<String?> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        // Send verification email before doing anything else
        await credential.user!.sendEmailVerification();
        // Sign out immediately — user must verify email before accessing the app
        await FirebaseAuth.instance.signOut();
      }

      _isLoading = false;
      notifyListeners();
      return email; // Signal success with the registered email
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyAuthError(e.code) ?? e.message ?? 'An error occurred during signup';
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Web: use Firebase Auth popup — no google_sign_in package needed
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Mobile: use google_sign_in package
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // User cancelled
          _isLoading = false;
          notifyListeners();
          return false;
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Google sign-in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Resend Verification Email ──────────────────────────────────────────────
  // Temporarily signs in to resend the verification link, then signs out again.
  Future<bool> resendVerificationEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null && !credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
      }
      await FirebaseAuth.instance.signOut();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────────────
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Failed to send reset email.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateProfileName(String newName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        _user = UserModel(name: newName, email: user.email ?? '');
        notifyListeners();
      }
    } catch (_) {}
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String? _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return null;
    }
  }
}
