import 'package:flutter/material.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/models/professionals.dart';
import 'package:home_maintenance/models/service_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_maintenance/models/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfessionalsList extends StatefulWidget {
  const ProfessionalsList({super.key, required this.serviceCategory});

  final ServiceCategory serviceCategory;

  @override
  State<ProfessionalsList> createState() => _ProfessionalsListState();
}

class _ProfessionalsListState extends State<ProfessionalsList> {
  List<Professional> professionals = [];

  Future<void> _fetchProfessionals() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('category', isEqualTo: widget.serviceCategory.serviceName)
        .get();

    final fetchedProfessionals = <Professional>[];

    for (var doc in querySnapshot.docs) {
      final serviceData = doc.data() as Map<String, dynamic>;
      final professionalId = serviceData['professionalId'];

      final professionalSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(professionalId)
          .get();

      if (professionalSnapshot.exists) {
        final professionalData =
            professionalSnapshot.data() as Map<String, dynamic>;

        final servicesQuery = await FirebaseFirestore.instance
            .collection('services')
            .where('professionalId', isEqualTo: professionalId)
            .where('category', isEqualTo: widget.serviceCategory.serviceName)
            .get();

        final services = servicesQuery.docs.map((serviceDoc) {
          final serviceData = serviceDoc.data() as Map<String, dynamic>;
          final availability =
              serviceData['availability'] as Map<String, dynamic>;
          return Service(
            id: serviceDoc.id,
            name: serviceData['name'],
            category: serviceData['category'],
            description: serviceData['description'],
            price: (serviceData['price'] as num).toDouble(),
            availability: availability.map((key, value) {
              return MapEntry(
                DateTime.parse(key),
                (value as List).map((timeString) {
                  final parts = timeString.split(':');
                  return TimeOfDay(
                      hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                }).toList(),
              );
            }),
            imageUrl: serviceData['imageUrl'],
          );
        }).toList();

        final professional = Professional(
          id: professionalId,
          name: professionalData['name'],
          contact: professionalData['contact'],
          services: services,
        );

        fetchedProfessionals.add(professional);
      }
    }

    setState(() {
      professionals = fetchedProfessionals;
    });
  }

  Future<void> _bookService(Professional professional, Service service) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to book a service')),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>;

    // Start a batch write
    final batch = FirebaseFirestore.instance.batch();

    // Add the service request
    final serviceRequestRef = FirebaseFirestore.instance.collection('service_requests').doc();
    batch.set(serviceRequestRef, {
      'professionalId': professional.id,
      'serviceId': service.id,
      'userId': user.uid,
      'userName': userData['name'],
      'userContact': userData['contact'],
      'serviceName': service.name,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Delete the service
    final serviceRef = FirebaseFirestore.instance.collection('services').doc(service.id);
    batch.delete(serviceRef);

    try {
      // Commit the batch
      await batch.commit();

      setState(() {
        // Remove the service from the professional's services list
        professional.services.remove(service);
        // If the professional has no more services, remove them from the list
        if (professional.services.isEmpty) {
          professionals.remove(professional);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request sent and service removed')),
      );
    } catch (e) {
      print('Error booking service: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while booking the service')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfessionals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      appBar: AppBar(
          title: Text('${widget.serviceCategory.serviceName} Professionals')),
      body: professionals.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/empty_state.png", height: 200),

                const Center(child: Text('No professionals available!', style: TextStyle(fontSize: 18),)),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: ListView.builder(
                itemCount: professionals.length,
                itemBuilder: (context, index) {
                  final professional = professionals[index];
                  return Card(
                    shadowColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(professional.name),
                          subtitle: Text(professional.contact),
                        ),
                        if (professional.services.isNotEmpty)
                          for (var service in professional.services)
                            Card(
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  service.imageUrl != null
                                      ? Image.network(service.imageUrl!, width: MediaQuery.of(context).size.width,
                                          height: 200, fit: BoxFit.cover,)
                                      : Image.asset('assets/images/painter.png',
                                          height: 200, fit: BoxFit.cover,),
                                  ListTile(
                                    title: Text(
                                      service.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    subtitle: Text(
                                      service.description,
                                      softWrap: true,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 16),
                                    child: Text(
                                        'Standard Price: GHS ${service.price.toStringAsFixed(2)}'),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 16),
                                    child: Text('Available Times:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  ...service.availability.entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Wrap(
                                        alignment: WrapAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3.0),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        AppColors.primaryColor),
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(entry.key
                                                  .toString()
                                                  .split(' ')[0]),
                                            ),
                                          ),
                                          ...entry.value.map((time) => Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '  ${time.format(context)}',
                                                  style: const TextStyle(
                                                      color:
                                                          AppColors.primaryColor),
                                                ),
                                              )),
                                        ],
                                      ),
                                    );
                                  }),
                                  ButtonBar(
                                    alignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.8,
                                        decoration: BoxDecoration(
                                          color: service.status == 'pending'
                                              ? Colors.grey
                                              : AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: TextButton(
                                            onPressed: service.status == 'pending'
                                                ? null
                                                : () {
                                                    _bookService(professional, service);
                                                  },
                                            child: Text(
                                              service.status == 'pending'
                                                  ? 'Pending'
                                                  : 'Book',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
