import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/pages/chat_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptedRequestsList extends StatelessWidget {
  final bool isProfessional;

  const AcceptedRequestsList({super.key, required this.isProfessional});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.accentColor,
      appBar: AppBar(
        title: Text(isProfessional ? 'Chats' : 'My Services'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('service_requests')
            .where(isProfessional ? 'professionalId' : 'userId',
                isEqualTo: user?.uid)
            .where('status', isEqualTo: 'accepted')
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
                const Center(
                    child: Text(
                  'No accepted requests',
                  style: TextStyle(fontSize: 18),
                )),
              ],
            );
          }

          // Group the requests by user or professional ID
          Map<String, Map<String, dynamic>> uniqueUsers = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final userId =
                isProfessional ? data['userId'] : data['professionalId'];
            if (!uniqueUsers.containsKey(userId)) {
              uniqueUsers[userId] = data;
            }
          }

          return ListView.builder(
            itemCount: uniqueUsers.length,
            itemBuilder: (context, index) {
              final userId = uniqueUsers.keys.elementAt(index);
              final data = uniqueUsers[userId]!;

              if (isProfessional) {
                return _buildListTile(context, data, isProfessional);
              } else {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(data['professionalId'])
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(title: Text('Loading...'));
                    }

                    if (userSnapshot.hasError || !userSnapshot.hasData) {
                      return ListTile(
                          title: Text('Error loading professional data'));
                    }

                    final professionalData =
                        userSnapshot.data!.data() as Map<String, dynamic>?;
                    final updatedData = {
                      ...data,
                      'professionalName':
                          professionalData?['name'] ?? 'Professional',
                      'professionalContact':
                          professionalData?['contact'] ?? 'N/A',
                    };

                    return _buildListTile(context, updatedData, isProfessional);
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, Map<String, dynamic> data, bool isProfessional) {
    final String userName = isProfessional
        ? (data['userName'] as String? ?? 'User')
        : (data['professionalName'] as String? ?? 'Professional');
    final String userContact = isProfessional
        ? (data['userContact'] as String? ?? 'N/A')
        : (data['professionalContact'] as String? ?? 'N/A');
    final String serviceName = data['serviceName'] as String? ?? 'Service';
    final String userId = isProfessional
        ? (data['userId'] as String? ?? '')
        : (data['professionalId'] as String? ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isProfessional
                        ? '$serviceName\nContact: $userContact'
                        : 'Service: $serviceName\nContact: $userContact',
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                onPressed: userId.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              otherUserId: userId,
                              otherUserName: userName,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Chat',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 5),
              // call button
              ElevatedButton(
                onPressed: () async {
                  final number = userContact;
                  final Uri uri = Uri(scheme: 'tel', path: number);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    // Handle the error, e.g., show a snackbar or dialog
                    print('Could not launch $uri');
                  }
                },
                child: const Icon(Icons.call),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

























// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:home_maintenance/constants/colors.dart';
// import 'package:home_maintenance/pages/chat_page.dart';

// class AcceptedRequestsList extends StatelessWidget {
//   final bool isProfessional;

//   const AcceptedRequestsList({Key? key, required this.isProfessional}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       backgroundColor: AppColors.accentColor,
//       appBar: AppBar(
//         title: Text(isProfessional ? 'Chats' : 'My Services'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('service_requests')
//             .where(isProfessional ? 'professionalId' : 'userId', isEqualTo: user?.uid)
//             .where('status', isEqualTo: 'accepted')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No accepted requests'));
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final request = snapshot.data!.docs[index];
//               final data = request.data() as Map<String, dynamic>;

//               if (isProfessional) {
//                 return _buildListTile(context, data, isProfessional);
//               } else {
//                 return FutureBuilder<DocumentSnapshot>(
//                   future: FirebaseFirestore.instance
//                       .collection('users')
//                       .doc(data['professionalId'])
//                       .get(),
//                   builder: (context, userSnapshot) {
//                     if (userSnapshot.connectionState == ConnectionState.waiting) {
//                       return ListTile(title: Text('Loading...'));
//                     }

//                     if (userSnapshot.hasError || !userSnapshot.hasData) {
//                       return ListTile(title: Text('Error loading professional data'));
//                     }

//                     final professionalData = userSnapshot.data!.data() as Map<String, dynamic>?;
//                     final updatedData = {
//                       ...data,
//                       'professionalName': professionalData?['name'] ?? 'Professional',
//                       'professionalContact': professionalData?['contact'] ?? 'N/A',
//                     };

//                     return _buildListTile(context, updatedData, isProfessional);
//                   },
//                 );
//               }
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildListTile(BuildContext context, Map<String, dynamic> data, bool isProfessional) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
//       child: Card(
//         child: ListTile(
//           title: Text(isProfessional ? data['userName'] ?? 'User' : data['serviceName'] ?? 'Service',
//             style: TextStyle(fontSize: 18.0),
//           ),
//           subtitle: Text(isProfessional 
//             ? '${data['serviceName'] ?? 'Service'}\nContact: ${data['userContact'] ?? 'N/A'}'
//             : 'Professional: ${data['professionalName'] ?? 'Professional'}\nContact: ${data['professionalContact'] ?? 'N/A'}'
//           ),
//           trailing: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryColor,
//             ),
//             child: const Text('Chat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ChatPage(
//                     otherUserId: isProfessional ? data['userId'] : data['professionalId'],
//                     otherUserName: isProfessional 
//                       ? (data['userName'] ?? 'User')
//                       : (data['professionalName'] ?? 'Professional'),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }