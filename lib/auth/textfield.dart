// lib/auth/textfield.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController controller;
  final bool obscureText;  // รองรับการซ่อนรหัสผ่าน
  final Widget? suffixIcon;  // สำหรับใส่ไอคอนที่ขวาของฟิลด์

  const CustomTextField({
    Key? key,
    required this.hint,
    required this.label,
    required this.controller,
    this.obscureText = false,  // ตั้งค่าสถานะเริ่มต้นเป็น false (ไม่ซ่อนรหัสผ่าน)
    this.suffixIcon,  // รองรับการใส่ไอคอน
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,  // ใส่ไอคอนที่ขวาของฟิลด์
      ),
      obscureText: obscureText,  // ใช้การซ่อนข้อความ
    );
  }
}
