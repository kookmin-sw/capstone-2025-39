import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 382,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, // Gradient를 위해 내부 패딩 제거
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // radius 100으로 변경
          ),
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment(1.00, 0.51),
              end: Alignment(0.00, 0.49),
              colors: [Color(0xFF5D825F), Color(0xFF90A891)], // 그라데이션 색상
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Container(
            height: 55,
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.6,
                letterSpacing: 0.2,
                fontFamily: 'Urbanist', // 필요하면 폰트 추가
              ),
            ),
          ),
        ),
      ),
    );
  }
}
