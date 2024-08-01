import 'package:home_maintenance/models/services.dart';

class Professional {
  final String id;
  final String name;
  final String contact;
  final List<Service> services;

  Professional({
    required this.id,
    required this.name,
    required this.contact,
    required this.services,
  });
}
