class ServiceCategory {
  final String serviceName;
  final String imageUrl;

  ServiceCategory({
    required this.serviceName,
    required this.imageUrl,
  });
}

List<ServiceCategory> serviceCategories = [
  ServiceCategory(
    serviceName: 'Plumbing',
    imageUrl: 'assets/images/plumber_icon.png',
    // route: '/plumbing',
  ),
  ServiceCategory(
    serviceName: 'AC Repair',
    imageUrl: 'assets/images/acrepair_icon.png',
    // route: '/electrical',
  ),
  ServiceCategory(
    serviceName: 'Carpentry',
    imageUrl: 'assets/images/carpenter_icon.png',
    // route: '/carpentry',
  ),
  ServiceCategory(
    serviceName: 'Pest Control',
    imageUrl: 'assets/images/pestcontrol_icon.png',
    // route: '/cleaning',
  ),
  ServiceCategory(
    serviceName: 'Painting',
    imageUrl: 'assets/images/painter_icon.png',
    // route: '/painting',
  ),
  ServiceCategory(
    serviceName: 'Security',
    imageUrl: 'assets/images/security_icon.png',
    // route: '/appliance-repair',
  ),
  ServiceCategory(
    serviceName: 'Smart Home',
    imageUrl: 'assets/images/smarthome_icon.png',
    // route: '/pest-control',
  ),
  ServiceCategory(
    serviceName: 'Salon',
    imageUrl: 'assets/images/salon_icon.png',
    // route: '/gardening',
  ),
 
];
