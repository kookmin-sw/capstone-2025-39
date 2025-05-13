import 'package:flutter/material.dart';

class InfoTextField extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final TextEditingController controller;

  const InfoTextField({
    super.key,
    required this.hintText,
    this.icon, // 아이콘은 선택적으로 전달
    required this.controller,
  });

  // 로그인 , 정보 입력 부분
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB), // 밝은 회색 배경
        // 아이콘은 있을 경우에만 표시
        suffixIcon:
            icon != null
                ? Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA), // 초록색 버튼
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Color(0xFF5E8360), size: 22),
                )
                : null, // 아이콘이 없으면 null
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
