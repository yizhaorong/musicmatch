import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static void showToast(String message) {
    toastification.show(
      alignment: Alignment.center,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }
}
