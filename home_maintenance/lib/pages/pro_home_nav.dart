import 'package:flutter/material.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/pages/accepted_requests_list.dart';
import 'package:home_maintenance/pages/pro_home_page.dart';
import 'package:home_maintenance/pages/service_request_list.dart';
import 'package:home_maintenance/pages/service_request_tab_view.dart';

class ProHomeNav extends StatefulWidget {
  const ProHomeNav({super.key});

  @override
  State<ProHomeNav> createState() => _ProHomeNavState();
}

class _ProHomeNavState extends State<ProHomeNav> {
   int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ProHomePage(),
    // const ChatPage(),
    // const AccountPage(),
    const ServiceRequestTabView(),
    const AcceptedRequestsList(isProfessional: true),
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
            icon: Icon(Icons.checklist_outlined),
            label: 'Service Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}