import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_maintenance/loaders/animation_loader.dart';
import 'package:home_maintenance/loaders/loaders.dart';
import 'package:iconsax/iconsax.dart';



class Loaders {
  static hideSnackBar() => ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey.withOpacity(0.9),
          ),
          child: Center(
            child: Text(
              message,
              style: Theme.of(Get.context!).textTheme.labelLarge,
            ),
          ),
        ),
      ),
    );
  }

  static successSnackBar({required String title, String message = '', int duration = 3}) {
    final context = Get.context;
    if (context != null) {
      Get.snackbar(
        title,
        message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: const Color(0xFF4b68ff),
        snackPosition: SnackPosition.BOTTOM, // We can try with top too
        duration: Duration(seconds: duration),
        margin: const EdgeInsets.all(10),
        icon: const Icon(
          Icons.check, // Changed from Iconsax.check to Icons.check for simplicity
          color: Colors.white,
        ),
      );
    } else {
      // Handle the case where context is null
      debugPrint("Get.context is null. Cannot show snackbar.");
    }
  }

  static warningSnackBar({required String title, String message = ''}) {
    final context = Get.context;
    if (context != null) {
      Get.snackbar(
        title,
        message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: Colors.orange,
        snackPosition: SnackPosition.BOTTOM, // We can try with top too
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(20),
        icon: const Icon(
          Icons.warning_amber_outlined,
          color: Colors.white,
        ),
      );
    } else {
      // Handle the case where context is null
      debugPrint("Get.context is null. Cannot show snackbar.");
    }
  }

  static errorSnackBar({required String title, String message = ''}) {
    final context = Get.context;
    if (context != null) {
      Get.snackbar(
        title,
        message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: Colors.red.shade600,
        snackPosition: SnackPosition.BOTTOM, // We can try with top too
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(20),
        icon: const Icon(
          Icons.error_outline,
          color: Colors.white,
        ),
      );
    } else {
      // Handle the case where context is null
      debugPrint("Get.context is null. Cannot show snackbar.");
    }
  }
}
