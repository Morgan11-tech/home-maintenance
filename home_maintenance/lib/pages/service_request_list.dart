import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_maintenance/constants/colors.dart';

class ServiceRequestsList extends StatelessWidget {
  const ServiceRequestsList({Key? key}) : super(key: key);

 Future<void> _updateRequestStatus(
  BuildContext context,
  String requestId,
  String status,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('No authenticated user found');
  }

  // Get the professional's data
  final professionalDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  
  if (!professionalDoc.exists) {
    throw Exception('Professional data not found');
  }

  final professionalData = professionalDoc.data() as Map<String, dynamic>;

  // Update the request status and add professional's info
  await FirebaseFirestore.instance
      .collection('service_requests')
      .doc(requestId)
      .update({
    'status': status,
    'professionalName': professionalData['name'],
    'professionalContact': professionalData['contact'],
  });

  // Get the updated request data
  final updatedRequest = await FirebaseFirestore.instance
      .collection('service_requests')
      .doc(requestId)
      .get();

  if (!updatedRequest.exists) {
    throw Exception('Updated request not found');
  }

  final requestData = updatedRequest.data() as Map<String, dynamic>;
  final userId = requestData['userId'] as String?;

  if (userId == null) {
    throw Exception('User ID not found in request data');
  }

  // Send notification to the user
  await FirebaseFirestore.instance.collection('notifications').add({
    'userId': userId,
    'message': 'Your service request has been $status',
    'timestamp': FieldValue.serverTimestamp(),
  });

  if (status == 'accepted') {
    // Remove the service from the services collection
    final querySnapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('professionalId', isEqualTo: requestData['professionalId'])
        .where('name', isEqualTo: requestData['serviceName'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(querySnapshot.docs.first.id)
          .delete();
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('service_requests')
            .where('professionalId', isEqualTo: user?.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/empty_state.png", height: 200),

                Center(child: Text('No pending requests', style: TextStyle(fontSize: 18),)),
              ],
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final request = snapshot.data!.docs[index];
              final data = request.data() as Map<String, dynamic>;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  children: [
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(data['userName'],
                            style:
                                const TextStyle(fontSize: 18.0)),
                        subtitle: Text(
                            '${data['serviceName']}\nContact: ${data['userContact']}',
                            maxLines: 2),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => _updateRequestStatus(
                                  context, request.id, 'accepted'),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => _updateRequestStatus(
                                  context, request.id, 'rejected'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      
    );
  }
}
