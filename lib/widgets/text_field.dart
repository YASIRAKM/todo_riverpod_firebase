import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildTextField(
    TextEditingController controller, String label, IconData icon,
    {bool obscureText = false, Function? pwdVisible, bool isBorder = false}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: obscureText
            ? IconButton(
                onPressed: () {
                  pwdVisible;
                },
                icon: Icon(obscureText
                    ? CupertinoIcons.eye_slash
                    : CupertinoIcons.eye))
            : null,
        prefixIcon: isBorder ? null : Icon(icon, color: Colors.blueAccent),
        border: isBorder
            ? const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(color: Colors.black))
            : InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    ),
  );
}
