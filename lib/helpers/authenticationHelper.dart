import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Signs in a user with Google using Firebase Authentication.
  /// This method triggers the Google sign-in flow and handles the user interaction.
  /// If the user successfully signs in with Google, it retrieves the necessary credentials
  /// and signs the user in with Firebase Authentication.
  /// Returns:
  ///   A [Future] that resolves to the signed-in [User] object if successful,
  ///   or null if the user cancels the sign-in flow or an error occurs.
  /// Throws:
  ///   [FirebaseAuthException] if an error occurs during the Firebase Authentication process.
  ///   This exception contains a code and message to help diagnose the issue.
  ///   [Exception] if an unexpected error occurs.
  Future<User?> signInWithGoogle() async {
    try {

      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // Obtain the GoogleSignInAuthentication object
        final GoogleSignInAuthentication googleSignInAuthentication =  await googleSignInAccount.authentication;
        // print(googleSignInAuthentication.accessToken);

        // Create a new credential
        final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential userCredential =
        await _auth.signInWithCredential(googleAuthCredential);

        return userCredential.user;
      } else {
        // User cancelled the Google sign-in flow
        debugPrint('Google sign-in cancelled');
        return null;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Error signing in with Google: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error signing in with Google: $e');
      return null;
    }
  }

  /// Signs out the currently authenticated user from Firebase Authentication.
  /// This method calls the signOut method on the FirebaseAuth instance to
  /// end the current user session.
  /// Returns:
  ///   A [Future] that completes the sign-out operation (no return value).
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get the current user
  User? get currentUser => _auth.currentUser;
}
