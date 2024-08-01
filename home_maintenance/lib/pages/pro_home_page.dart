import 'package:flutter/material.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/pages/add_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProHomePage extends StatelessWidget {
  const ProHomePage({super.key});

  Future<String?> GetProfessionalName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('name')) {
            return userData['name'];
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('Homely Professional',
              style: TextStyle(
                color: Colors.white,
              )),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String?>(
                      future: GetProfessionalName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Text(
                            'Welcome ${snapshot.data ?? 'User'}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          );
                        }
                      },
                    ),
                      const SizedBox(height: 10),
                      const Text('Ready to make some money?💰\nAdd your services below.',
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 20),
                
                
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddServiceScreen()),
                          );
                        },
                        child: Container(
                          height: 130,
                          width: MediaQuery.of(context).size.width / 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.accentColor, width: 2),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.accentColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                      child: const Icon(Icons.add,
                                          size: 30, color: Colors.white),),
                                  const SizedBox(height: 20),
                                  const Text('Add your services',
                                      style: TextStyle(fontSize: 17, color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                     
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Image.asset('assets/images/coming_soon.png'),
                Container(
                  width: double.infinity,
                ),
              
            
              ],
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("Other services 🙌🏽",
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/images/coming_soon.png'),
            Image.asset('assets/images/coming_soon2.png'),
          ],
        ),
       
        );
  }
}
