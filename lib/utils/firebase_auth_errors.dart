import 'package:firebase_auth/firebase_auth.dart';

String handleAuthError(FirebaseAuthException e, {required bool isSignIn}) {
  String errorMessage;

  switch (e.code) {
    case 'invalid-email':
      errorMessage = 'The email address is badly formatted.';
      break;
    case 'user-disabled':
      errorMessage = 'This user account has been disabled.';
      break;
    case 'user-not-found':
      errorMessage = isSignIn
          ? 'No user found for this email.'
          : 'Account does not exist. Please sign up.';
      break;
    case 'wrong-password':
      errorMessage = 'Incorrect password, please try again.';
      break;
    case 'email-already-in-use':
      errorMessage = isSignIn
          ? 'Email is already registered.'
          : 'The account already exists for that email.';
      break;
    case 'weak-password':
      errorMessage = 'The password provided is too weak.';
      break;
    case 'operation-not-allowed':
      errorMessage = 'Email/Password accounts are not enabled.';
      break;
    default:
      errorMessage = 'An unknown error occurred. Please try again later.';
  }

  return errorMessage;
}
