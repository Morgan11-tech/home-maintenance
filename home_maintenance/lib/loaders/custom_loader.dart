import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_maintenance/loaders/animation_loader.dart';

class FullScreenLoader {
  static void openLoadingDialog(String text, String animation, {BuildContext? fallbackContext}) {
    final BuildContext? overlayContext = Get.overlayContext ?? fallbackContext;
    if (overlayContext == null) {
      // Handle null overlay context scenario
      print('Error: Get.overlayContext is null');
      return;
    }
    
    showDialog(
      context: overlayContext,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: Colors.white.withOpacity(0.5),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 250,
                ),
                AnimationLoaderWidget(text: text, animation: animation),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void stopLoading({BuildContext? fallbackContext}) {
    final BuildContext? overlayContext = Get.overlayContext ?? fallbackContext;
    if (overlayContext == null) {
      // Handle null overlay context scenario
      print('Error: Get.overlayContext is null');
      return;
    }
    
    Navigator.of(overlayContext).pop(); // Close dialog using Navigator
  }
}
