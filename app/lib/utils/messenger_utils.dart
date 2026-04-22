import 'package:flutter/material.dart';
import 'package:masstodo/ui/app_styles.dart';

class Messenger {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showSnackbar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    SnackBarAction? action,
  }) {
    final state = scaffoldMessengerKey.currentState;
    if (state == null) return;

    state.hideCurrentSnackBar();

    Color backgroundColor = AppColors.primary;
    if (isError) backgroundColor = AppColors.error;
    if (isSuccess) backgroundColor = AppColors.success;

    state.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        action: action,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusM),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
