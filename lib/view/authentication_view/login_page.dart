import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_flutter_toto_app/main.dart';

import 'package:riverpod_flutter_toto_app/provider/auth_provider.dart';
import 'package:riverpod_flutter_toto_app/utils/error_message.dart';
import 'package:riverpod_flutter_toto_app/utils/transparent_dialoge.dart';
import 'package:riverpod_flutter_toto_app/view/home_view.dart/home_screen.dart';
import 'package:riverpod_flutter_toto_app/widgets/text_field.dart';

class AuthScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _buildAuthForm(context, authNotifier),
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context, AuthProvider authNotifier) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Welcome!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          buildTextField(emailController, "Email", Icons.email_outlined),
          const SizedBox(height: 16),
          buildTextField(passwordController, "Password", Icons.lock_outline,
              obscureText: true),
          const SizedBox(height: 24),
          authNotifier.isLogin
              ? _buildButton(
                  text: "Sign Up",
                  onPressed: () async {
                    if (emailController.text.isEmpty &&
                        passwordController.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Email and password required");
                    } else {
                      transparantDialog(context);
                      (bool, String) auth = await authNotifier.signUpWithEmail(
                        mail: emailController.text,
                        password: passwordController.text,
                      );
                      if (auth.$1) {
                        navKey.currentState!.pop();
                        navKey.currentState?.pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        navKey.currentState!.pop();
                        showErrorDialog(context, auth.$2);
                      }
                    }
                  },
                  color: Colors.blueAccent,
                )
              : _buildButton(
                  text: "Log In",
                  onPressed: () async {
                    if (emailController.text.isEmpty &&
                        passwordController.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Email and password required");
                    } else {
                      (bool, String) auth = await authNotifier.signInWithEmail(
                        mail: emailController.text,
                        password: passwordController.text,
                      );
                      if (auth.$1) {
                        navKey.currentState?.pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        showErrorDialog(context, auth.$2);
                      }
                    }
                  },
                  color: Colors.greenAccent,
                ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(authNotifier.isLogin
                  ? "Already have an account ?"
                  : "Don't have an account ?"),
              TextButton(
                  onPressed: () {
                    authNotifier.loginSignup();
                  },
                  child: Text(authNotifier.isLogin ? "Log in" : "Sign up"))
            ],
          ),
          const SizedBox(height: 12),
          _buildButton(
            text: "Sign in with Google",
            icon: Icons.g_mobiledata,
            onPressed: () => authNotifier.signInWithGoogle(),
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      {required String text,
      required VoidCallback onPressed,
      IconData? icon,
      required Color color}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: icon != null
          ? Icon(icon, color: Colors.white)
          : const SizedBox.shrink(),
      label: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
