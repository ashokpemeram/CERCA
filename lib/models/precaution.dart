import 'package:flutter/material.dart';
import 'zone.dart';

/// Model representing a safety precaution
class Precaution {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final ZoneType? applicableZone; // null means applies to all zones

  Precaution({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.applicableZone,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'applicableZone': applicableZone?.toString().split('.').last,
    };
  }

  // Create from JSON
  factory Precaution.fromJson(Map<String, dynamic> json) {
    ZoneType? zoneType;
    if (json['applicableZone'] != null) {
      zoneType = json['applicableZone'] == 'danger' 
          ? ZoneType.danger 
          : ZoneType.safe;
    }

    return Precaution(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: Icons.info, // Default icon
      applicableZone: zoneType,
    );
  }
}
