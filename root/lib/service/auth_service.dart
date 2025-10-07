// AuthService: tiny wrapper around FirebaseAuth for sign up/in/out
// Keeps auth logic in one place so UI stays simple.
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class AuthService {
  static final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  // Emits the current user whenever sign-in state changes (null when signed out)
  static Stream<fb_auth.User?> onAuthStateChanged() => _auth.authStateChanges();

  // Synchronously access the currently signed-in user (or null)
  static fb_auth.User? get currentUser => _auth.currentUser;

  // Create a new user account with email/password
  static Future<fb_auth.UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential;
  }

  // Sign into an existing account
  static Future<fb_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential;
  }

  // Sign out the current user
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}


