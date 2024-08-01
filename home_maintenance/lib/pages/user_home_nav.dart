import 'package:flutter/material.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/pages/accepted_requests_list.dart';
import 'package:home_maintenance/pages/account_page.dart';
import 'package:home_maintenance/pages/user_home_page.dart';

class HomeOwnerNavigationPage extends StatefulWidget {
  const HomeOwnerNavigationPage({super.key});

  @override
  State<HomeOwnerNavigationPage> createState() => _HomeOwnerNavigationPageState();
}

class _HomeOwnerNavigationPageState extends State<HomeOwnerNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeOwnerHomePage(),
    const AcceptedRequestsList(isProfessional: false),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Service History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}