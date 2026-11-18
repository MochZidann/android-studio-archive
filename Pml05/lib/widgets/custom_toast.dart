import 'package:flutter/material.dart';

/// Helper untuk menampilkan SnackBar / Toast modern melayang
/// Menggunakan palet warna konsisten PML:
/// - Sukses: Hijau (#16A34A)
/// - Error / Validasi: Merah (#DC2626)
/// - Info: Indigo (#4F46E5)
class CustomToast {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline
                  : isSuccess
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        action: action,
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : isSuccess
                ? const Color(0xFF16A34A)
                : const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
      ),
    );
  }
}
