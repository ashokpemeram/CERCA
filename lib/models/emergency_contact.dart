import 'package:flutter/material.dart';

/// Model representing an emergency contact
class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final IconData icon;
  final String category;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.icon,
    required this.category,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'category': category,
    };
  }

  // Create from JSON
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      icon: Icons.phone, // Default icon
      category: json['category'] as String,
    );
  }
}
