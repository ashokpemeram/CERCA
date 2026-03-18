import 'package:CERCA/models/admin/aid_request_admin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AidRequestAdmin', () {
    test('fromJson falls back to Citizen when requester name is missing', () {
      final request = AidRequestAdmin.fromJson({
        'id': 'AID-1',
        'priority': 'medium',
        'status': 'pending',
        'requesterName': '',
        'resources': ['Water'],
        'peopleCount': 3,
        'location': 'Test Location',
        'latitude': 12.0,
        'longitude': 77.0,
        'timestamp': DateTime(2026, 3, 18, 12).toIso8601String(),
      });

      expect(request.requesterName, 'Citizen');
      expect(request.phoneNumber, isNull);
    });

    test('toJson preserves optional phone number when provided', () {
      final request = AidRequestAdmin(
        id: 'AID-2',
        priority: AidPriority.high,
        status: AidStatus.pending,
        requesterName: 'Anita',
        phoneNumber: '9876543210',
        resources: const ['Food'],
        peopleCount: 5,
        location: 'Shelter',
        latitude: 12.0,
        longitude: 77.0,
        timestamp: DateTime(2026, 3, 18, 12),
      );

      expect(request.toJson()['phoneNumber'], '9876543210');
    });
  });
}
