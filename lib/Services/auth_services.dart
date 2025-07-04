import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fuel_route/Routes/route_names.dart';
import 'package:fuel_route/Utils/utils.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Facebook Sign-In
  Future<UserCredential?> signInWithFacebook({
    required BuildContext context,
    required VoidCallback onStart,
    required VoidCallback onComplete,
  }) async {
    onStart();

    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        final credential = FacebookAuthProvider.credential(accessToken!.token);

        final res = await _auth.signInWithCredential(credential);

        Utils.flushBarErrorMessage(
          'Welcome, ${res.user?.displayName}',
          context,
          success: true,
        );

        Navigator.pushReplacementNamed(context, RouteNames.homeScreen);
        return res;
      } else {
        Utils.flushBarErrorMessage('Facebook Sign-In canceled.', context);
        return null;
      }
    } catch (e) {
      debugPrint('Facebook Sign-In error: $e');
      Utils.flushBarErrorMessage('Facebook Sign-In failed.', context);
      return null;
    } finally {
      onComplete();
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle({
    required BuildContext context,
    required VoidCallback onStart,
    required VoidCallback onComplete,
  }) async {
    onStart();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final res = await _auth.signInWithCredential(credential);

      Utils.flushBarErrorMessage(
        'Welcome, ${res.user?.displayName}',
        context,
        success: true,
      );

      Navigator.pushReplacementNamed(context, RouteNames.homeScreen);
      return res;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      Utils.flushBarErrorMessage('Google Sign-In failed.', context);
      return null;
    } finally {
      onComplete();
    }
  }

  /// Sign Up Function
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required BuildContext context,
    required VoidCallback onStart,
    required VoidCallback onComplete,
  }) async {
    try {
      onStart();

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name).catchError((e) {
          debugPrint("🔥 Display name update error: $e");
          Utils.flushBarErrorMessage("Failed to update display name.", context);
        });

        await _dbRef
            .child("users/${user.uid}")
            .set({
              'uid': user.uid,
              'email': email,
              'name': name,
              'phone': phoneNumber,
            })
            .catchError((error) {
              debugPrint("🔥 Firebase DB Error: $error");
              Utils.flushBarErrorMessage(
                "Database write failed: $error",
                context,
              );
            });

        Utils.flushBarErrorMessage(
          'Sign Up Successful',
          context,
          success: true,
        );
        Navigator.pushNamed(context, RouteNames.homeScreen);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("🔥 FirebaseAuthException: ${e.code} - ${e.message}");

      if (e.code == 'email-already-in-use') {
        Utils.flushBarErrorMessage(
          "This email is already registered.",
          context,
        );
      } else if (e.code == 'invalid-email') {
        Utils.flushBarErrorMessage("Invalid email address.", context);
      } else if (e.code == 'weak-password') {
        Utils.flushBarErrorMessage("Password is too weak.", context);
      } else {
        Utils.flushBarErrorMessage(
          e.message ?? 'Something went wrong.',
          context,
        );
      }
    } catch (e) {
      debugPrint("🔥 General error: $e");
      Utils.flushBarErrorMessage("Error: $e", context);
    } finally {
      onComplete();
    }
  }

  /// Sign In Function
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
    required VoidCallback onStart,
    required VoidCallback onComplete,
  }) async {
    try {
      onStart();

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        Utils.flushBarErrorMessage(
          'Login Successfully',
          context,
          success: true,
        );
        Utils.flushBarErrorMessage(user.email ?? '', context);
        Navigator.pushReplacementNamed(context, RouteNames.homeScreen);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.flushBarErrorMessage("No user found for this email.", context);
      } else if (e.code == 'wrong-password') {
        Utils.flushBarErrorMessage("Wrong password provided.", context);
      } else if (e.code == 'invalid-email') {
        Utils.flushBarErrorMessage("The email address is invalid.", context);
      } else {
        Utils.flushBarErrorMessage(
          e.message ?? 'Something went wrong.',
          context,
        );
      }
    } catch (e) {
      Utils.flushBarErrorMessage(e.toString(), context);
    } finally {
      onComplete();
    }
  }
}
