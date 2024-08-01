import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/loaders/loaders.dart';
import 'package:home_maintenance/pages/login_page.dart';
import 'package:home_maintenance/services/auth_services.dart';

enum UserType { homeowner, professional }

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserType _selectedUserType = UserType.homeowner;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String email = '';
  String password = '';
  String name = '';
  String contact = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 70.0),
                    Text(
                      "Register",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Welcome! Please enter your details to continue.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 74, 84, 88),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 16),
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.person_2_outlined,
                                  color: Colors.grey,
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15.0),
                                hintText: 'Name',
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              validator: (val) {
                                if (val!.contains(RegExp(r'[0-9]'))) {
                                  return 'Name should not contain numbers';
                                }
                                if (val.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                              onChanged: (val) => setState(() => name = val),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 16),
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.mail_outlined,
                                  color: Colors.grey,
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15.0),
                                hintText: 'Email',
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(val)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              onChanged: (val) => setState(() => email = val),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 16),
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.grey,
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15.0),
                                hintText: 'Password',
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (val.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                              onChanged: (val) =>
                                  setState(() => password = val),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 16),
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: Colors.grey,
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15.0),
                                hintText: 'Contact Number',
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              validator: (val) {
                                if (val!.length != 10) {
                                  return 'Contact number should be 10 digits long';
                                }
                                if (val.isEmpty) {
                                  return 'Please enter your contact number';
                                }
                                return null;
                              },
                              onChanged: (val) => setState(() => contact = val),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  "Please indicate whether you are a \n   homeowner or a professional"),
                            ],
                          ),
                          DropdownButton<UserType>(
                            value: _selectedUserType,
                            onChanged: (UserType? newValue) {
                              setState(() {
                                _selectedUserType = newValue!;
                              });
                            },
                            items: UserType.values.map((UserType type) {
                              return DropdownMenuItem<UserType>(
                                value: type,
                                child: Text(type.toString().split('.').last),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => isLoading = true);
                                try {
                                  dynamic result = await _auth.signUp(
                                    email: email,
                                    password: password,
                                    name: name,
                                    contact: contact,
                                    userType: _selectedUserType
                                        .toString()
                                        .split('.')
                                        .last,
                                  );

                                  if (result != null) {
                                    // Navigate to home page or show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Account Created Successfully\nPlease login to continue'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Could not sign in with those credentials\nPlease try again'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'email-already-in-use') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Failed to Register\nThis email is already registered'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'An error occurred. Please try again.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'An error occurred. Please try again.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  setState(() => isLoading = false);
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already a user?",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()));
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                          // Text(
                          //   error,
                          //   style: TextStyle(color: Colors.red, fontSize: 14.0),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
