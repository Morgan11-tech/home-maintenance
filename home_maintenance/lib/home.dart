import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: TextButton(onPressed: ()async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding', false);
        }, child: const Text('enable onboarding')),
        
      ),
    );
  }
}
