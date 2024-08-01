import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_maintenance/home.dart';
import 'package:home_maintenance/pages/login_page.dart';
import 'package:provider/provider.dart';


class Wrapper extends StatelessWidget {
  final bool onboarding;

  const Wrapper({Key? key, required this.onboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    
    // If user is authenticated, show HomePage
    if (user != null) {
      return const HomePage();
    } else {
      // If user is not authenticated, show AuthenticationScreen
      return LoginPage();
    }
  }
}