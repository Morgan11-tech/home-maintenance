import 'package:flutter/material.dart';

class Service {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final Map<DateTime, List<TimeOfDay>> availability;
  final String? imageUrl;
  String status;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.availability,
    this.imageUrl,
    this.status = '',
  });
}