import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_maintenance/pages/login_page.dart';
import 'package:home_maintenance/wrapper/wrapper.dart';

class NavigationDecision extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final prefs = snapshot.data!;
          final onboarding = prefs.getBool('onboarding') ?? false;

          if (onboarding) {
            return Wrapper(onboarding: onboarding);
          } else {
            return const LoginPage();
          }
        } else {
          // While waiting for SharedPreferences, you could show a loading indicator
          return const CircularProgressIndicator();
        }
      },
    );
  }
}