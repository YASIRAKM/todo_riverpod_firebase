// ignore_for_file: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_flutter_toto_app/main.dart';
import 'package:riverpod_flutter_toto_app/view/authentication_view/login_page.dart';
import 'package:riverpod_flutter_toto_app/view/home_view.dart/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString('user_details');
  if (data != null) {
    // If user token is not null, it means the user is logged in
    return data.isNotEmpty;
  }
  return false;
});
// Import the provider

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authProvider to check the authentication status
    final authStatus = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: authStatus.when(
          data: (isLoggedIn) {
            // Navigate based on the authentication status
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isLoggedIn) {
                navKey.currentState!.pushAndRemoveUntil(
                  CupertinoPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                  (route) => false,
                );
              } else {
                navKey.currentState!.pushAndRemoveUntil(
                  CupertinoPageRoute(
                    builder: (context) => AuthScreen(),
                  ),
                  (route) => false,
                );
              }
            });
            return const CircularProgressIndicator(); // Temporary loading indicator
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
    );
  }
}
