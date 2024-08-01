import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AcceptedRequestsListOnly extends StatelessWidget {
  final bool isProfessional;

  const AcceptedRequestsListOnly({Key? key, required this.isProfessional}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .where(isProfessional ? 'professionalId' : 'userId', isEqualTo: user?.uid)
          .where('status', isEqualTo: 'accepted')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No accepted requests'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final request = snapshot.data!.docs[index];
            final data = request.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Card(
                child: ListTile(
                  title: Text(isProfessional ? data['userName'] ?? 'User' : data['serviceName'] ?? 'Service',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isProfessional 
                        ? '${data['serviceName'] ?? 'Service'}\nContact: ${data['userContact'] ?? 'N/A'}'
                        : 'Professional: ${data['professionalName'] ?? 'Professional'}\nContact: ${data['professionalContact'] ?? 'N/A'}'
                      ),
                      Text(data['timestamp'] != null ? data['timestamp'].toDate().toString() : 'N/A',
                    style: TextStyle(
                      color: Colors.grey,
                    ),),
                    ],
                  ),
                  
                ),
              ),
            );
          },
        );
      },
    );
  }
}