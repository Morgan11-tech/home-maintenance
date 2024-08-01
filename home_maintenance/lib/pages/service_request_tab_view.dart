import 'package:flutter/material.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/pages/accepted_request_list_only.dart';
import 'package:home_maintenance/pages/accepted_requests_list.dart';
import 'package:home_maintenance/pages/service_request_list.dart';

class ServiceRequestTabView extends StatelessWidget {
  const ServiceRequestTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.accentColor,
        appBar: AppBar(
          title: const Text('Service Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ServiceRequestsList(),
            AcceptedRequestsListOnly(isProfessional: true),
          ],
        ),
      ),
    );
  }
}