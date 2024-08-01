import 'package:flutter/material.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/models/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ServiceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> addService({
    required String name,
    required String category,
    required String description,
    required double price,
    required Map<DateTime, List<TimeOfDay>> availability,
    XFile? image,
  }) async {
    try {
      String? imageUrl;
      if (image != null) {
        final ref = _storage
            .ref()
            .child('service_images/${DateTime.now().toIso8601String()}');
        await ref.putData(await image.readAsBytes());
        imageUrl = await ref.getDownloadURL();
      }

      final availabilityMap = availability.map((date, times) {
        return MapEntry(date.toIso8601String(),
            times.map((time) => '${time.hour}:${time.minute}').toList());
      });

      await _firestore.collection('services').add({
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'availability': availabilityMap,
        'imageUrl': imageUrl,
        'professionalId': currentUser?.uid,
      });

      notifyListeners();
    } catch (e) {
      print('Error adding service: $e');
      rethrow;
    }
  }

  Stream<List<Service>> getServicesByCategory(String category) {
    return _firestore
        .collection('services')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final availabilityMap = (data['availability'] as Map<String, dynamic>)
            .map((dateString, timesList) {
          final date = DateTime.parse(dateString);
          final times = (timesList as List)
              .map((timeString) => _parseTimeOfDay(timeString))
              .toList();
          return MapEntry(date, times);
        });

        return Service(
            id: doc.id,
            name: data['name'],
            category: data['category'],
            description: data['description'],
            price: data['price'],
            imageUrl: data['imageUrl'],
            availability: availabilityMap);
      }).toList();
    });
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class AddServiceScreen extends StatefulWidget {
  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Plumbing';
  Map<DateTime, List<TimeOfDay>> _availability = {};
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  XFile? _image;

  final List<String> _categories = [
    'Plumbing',
    'Smart Home',
    'Painting',
    'Carpentry',
    'Pest Control',
    'Security',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Service')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.work,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  hintText: 'Service Name',
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service name';
                  }
                  return null;
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                      value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.category,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  hintText: 'Category',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.description,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  hintText: 'Description',
                  fillColor: Colors.white,
                  filled: true,
                ),
                maxLines: 3,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.money,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  hintText: 'Price in cedis',
                  fillColor: Colors.white,
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            GestureDetector(
              onTap: () async {
                // show date picker
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
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
                  "Select Available Date",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     final DateTime? picked = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime.now(),
            //       lastDate: DateTime.now().add(Duration(days: 365)),
            //     );
            //     if (picked != null) {
            //       setState(() {
            //         _selectedDate = picked;
            //       });
            //     }
            //   },
            //   child: Text('Select Available Date'),
            // ),
            ListTile(
              title: Text('Selected Date'),
              subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),

            SizedBox(height: 20),

            GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  if (_selectedDate == DateTime.now() &&
                      picked.hour < TimeOfDay.now().hour) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('You cannot select a past time for today')),
                    );
                    return;
                  }
                  setState(() {
                    _selectedTime = picked;
                    if (_availability[_selectedDate] == null) {
                      _availability[_selectedDate] = [];
                    }
                    _availability[_selectedDate]?.add(_selectedTime);
                  });
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
                  "Select Available Time",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     final TimeOfDay? picked = await showTimePicker(
            //       context: context,
            //       initialTime: TimeOfDay.now(),
            //     );
            //     if (picked != null) {
            //       if (_selectedDate == DateTime.now() &&
            //           picked.hour < TimeOfDay.now().hour) {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //               content:
            //                   Text('You cannot select a past time for today')),
            //         );
            //         return;
            //       }
            //       setState(() {
            //         _selectedTime = picked;
            //         if (_availability[_selectedDate] == null) {
            //           _availability[_selectedDate] = [];
            //         }
            //         _availability[_selectedDate]?.add(_selectedTime);
            //       });
            //     }
            //   },
            //   child: Text('Select Available Time'),
            // ),
            Wrap(
              children: _availability.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text('${entry.key.toLocal()}'.split(' ')[0],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      children: entry.value.map((time) {
                        return Chip(
                          label: Text(time.format(context)),
                          onDeleted: () {
                            setState(() {
                              _availability[entry.key]?.remove(time);
                              if (_availability[entry.key]?.isEmpty ?? false) {
                                _availability.remove(entry.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            GestureDetector(
              onTap: () async {
                final ImagePicker _picker = ImagePicker();
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _image = image;
                  });
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
                  "Select Image (Optional)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (_image != null) Text('Image selected: ${_image!.path}'),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () async {
            //     final ImagePicker _picker = ImagePicker();
            //     final XFile? image =
            //         await _picker.pickImage(source: ImageSource.gallery);
            //     if (image != null) {
            //       setState(() {
            //         _image = image;
            //       });
            //     }
            //   },
            //   child: Text('Select Image (Optional)'),
            // ),
            // if (_image != null) Text('Image selected: ${_image!.path}'),

            const SizedBox(height: 20),

            GestureDetector(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final serviceProvider =
                          Provider.of<ServiceProvider>(context, listen: false);
                      await serviceProvider.addService(
                        name: _nameController.text,
                        category: _selectedCategory,
                        description: _descriptionController.text,
                        price: double.parse(_priceController.text),
                        availability: _availability,
                        image: _image,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Service added successfully'),
                        backgroundColor: Colors.green,
                      ));
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to add service: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Add Service",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )),

            // ElevatedButton(
            //   onPressed: () {
            //     if (_formKey.currentState!.validate()) {
            //       final serviceProvider =
            //           Provider.of<ServiceProvider>(context, listen: false);
            //       serviceProvider.addService(
            //         name: _nameController.text,
            //         category: _selectedCategory,
            //         description: _descriptionController.text,
            //         price: double.parse(_priceController.text),
            //         availability: _availability,
            //         image: _image,
            //       );
            //       // snackbar
            //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //           content: Text('Service added successfully'),
            //           backgroundColor: Colors.green));
            //       Navigator.pop(context);
            //     }
            //   },
            //   child: Text('Add Service'),
            // ),
          ],
        ),
      ),
    );
  }
}
