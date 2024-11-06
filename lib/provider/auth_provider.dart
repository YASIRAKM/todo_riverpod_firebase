import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_flutter_toto_app/utils/firebase_auth_errors.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final firebaseAuthProvider =
//     Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  // ignore: prefer_final_fields
  bool _isLogin = false;
  // ignore: prefer_final_fields
  bool _isVisible = false;
  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _errorMessage;
  AuthProvider() {
    // Initialize and listen to auth changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isVisible => _isVisible;
  bool get isLogin => _isLogin;
  String? get errorMessage => _errorMessage;

  loginSignup() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  visibilePwd() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  Future<(bool, String)> signUpWithEmail(
      {required String mail, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential cred = await _firebaseAuth.createUserWithEmailAndPassword(
          email: mail, password: password);
      _user = cred.user;
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("user_details", _user!.uid.toString());
      pref.setString("mail", _user!.email.toString());
      return (true, "success");
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.toString();
      return (false, handleAuthError(e, isSignIn: false));
    } catch (e) {
      return (false, "Something went wrong");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<(bool, String)> signInWithEmail(
      {required String mail, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserCredential cred = await _firebaseAuth.signInWithEmailAndPassword(
          email: mail, password: password);
      _user = cred.user;
      log(_user.toString());
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("user_details", _user!.uid.toString());
      pref.setString("mail", _user!.email.toString());

      return (true, "success");
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.toString();
      return (false, handleAuthError(e, isSignIn: false));
    } catch (e) {
      return (false, "Something went wrong");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(cred);
      _user = userCredential.user;
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("user_details", _user!.uid.toString());
      pref.setString("mail", _user!.email.toString());
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();

    // await FacebookAuth.instance.logOut();
    _user = null;
    notifyListeners();
  }
}

final authNotifierProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});
