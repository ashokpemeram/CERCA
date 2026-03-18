import 'package:flutter_test/flutter_test.dart';
import 'package:CERCA/models/admin/aid_request_admin.dart';
import 'package:CERCA/models/admin/disaster_area.dart';
import 'package:CERCA/models/admin/sos_request.dart';
import 'package:CERCA/providers/admin_provider.dart';
import 'package:CERCA/services/disaster_area_service.dart';

SosRequest _sos(String id, double lat, double lon) {
  return SosRequest(
    id: id,
    status: SosStatus.pending,
    callerName: 'Caller $id',
    phoneNumber: '9999999999',
    address: 'Test Address',
    latitude: lat,
    longitude: lon,
    timestamp: DateTime(2026, 3, 14, 12),
  );
}

AidRequestAdmin _aid(String id, AidPriority priority, double lat, double lon) {
  return AidRequestAdmin(
    id: id,
    priority: priority,
    status: AidStatus.pending,
    requesterName: 'Requester $id',
    resources: const ['Water'],
    peopleCount: 5,
    location: 'Test Location',
    latitude: lat,
    longitude: lon,
    timestamp: DateTime(2026, 3, 14, 12),
  );
}

void main() {
  group('Geometry', () {
    test('weighted centroid', () {
      final areas = DisasterAreaService.computeAreas(
        [
          _sos('s1', 0.0, 0.0),
          _sos('s2', 0.0, 0.002),
        ],
        [
          _aid('a1', AidPriority.low, 0.002, 0.0),
        ],
        existingAreaIds: {},
      );

      expect(areas, hasLength(1));
      final area = areas.first;

      const totalWeight = 7.0; // SOS 3 + SOS 3 + AidLow 1
      final expectedLat = (0.0 * 3 + 0.0 * 3 + 0.002 * 1) / totalWeight;
      final expectedLon = (0.0 * 3 + 0.002 * 3 + 0.0 * 1) / totalWeight;

      expect((area.centerLat - expectedLat).abs(), lessThan(0.0001));
      expect((area.centerLon - expectedLon).abs(), lessThan(0.0001));
    });

    test('red < warning < green < controllable', () {
      final areas = DisasterAreaService.computeAreas(
        [
          _sos('s1', 19.0760, 72.8777),
          _sos('s2', 19.0765, 72.8782),
          _sos('s3', 19.0755, 72.8770),
        ],
        [
          _aid('a1', AidPriority.medium, 19.0770, 72.8785),
          _aid('a2', AidPriority.low, 19.0750, 72.8765),
          _aid('a3', AidPriority.high, 19.0775, 72.8790),
        ],
        existingAreaIds: {},
      );

      final area = areas.first;
      expect(area.redRadiusM, lessThan(area.warningRadiusM));
      expect(area.warningRadiusM, lessThan(area.greenRadiusM));
      expect(area.greenRadiusM, lessThan(area.controllableRadiusM));
    });

    test('controllable == warning × 2', () {
      final areas = DisasterAreaService.computeAreas(
        [
          _sos('s1', 19.0760, 72.8777),
          _sos('s2', 19.0765, 72.8782),
          _sos('s3', 19.0755, 72.8770),
        ],
        [
          _aid('a1', AidPriority.medium, 19.0770, 72.8785),
        ],
        existingAreaIds: {},
      );

      final area = areas.first;
      expect(area.controllableRadiusM, closeTo(area.warningRadiusM * 2.0, 0.001));
    });

    test('green clamped within warning..controllable', () {
      final areas = DisasterAreaService.computeAreas(
        [
          _sos('s1', 19.0760, 72.8777),
          _sos('s2', 19.0762, 72.8780),
          _sos('s3', 19.0764, 72.8783),
        ],
        [
          _aid('a1', AidPriority.high, 19.0768, 72.8788),
        ],
        existingAreaIds: {},
      );

      final area = areas.first;
      expect(area.greenRadiusM, greaterThanOrEqualTo(area.warningRadiusM + 100));
      expect(area.greenRadiusM, lessThanOrEqualTo(area.controllableRadiusM - 100));
    });
  });

  group('ID generation', () {
    test('format AREA-YYYYMMDD-XXXX', () {
      final ids = <String>{};
      final id = DisasterAreaService.generateAreaId(
        ids,
        now: DateTime(2026, 3, 14),
      );
      expect(RegExp(r'^AREA-20260314-[A-Z0-9]{4}$').hasMatch(id), isTrue);
    });

    test('uniqueness over 100 iterations', () {
      final ids = <String>{};
      for (var i = 0; i < 100; i++) {
        DisasterAreaService.generateAreaId(
          ids,
          now: DateTime(2026, 3, 14),
        );
      }
      expect(ids.length, 100);
    });
  });

  group('Routing', () {
    test('point inside controllable → insideControllable=true', () {
      final area = DisasterArea(
        id: 'AREA-20260314-TEST',
        centerLat: 0,
        centerLon: 0,
        redRadiusM: 100,
        warningRadiusM: 200,
        greenRadiusM: 300,
        controllableRadiusM: 400,
        createdAt: DateTime(2026, 3, 14),
      );

      final result =
          DisasterAreaService.routeToArea(0.0, 0.0001, [area]);
      expect(result.areaId, area.id);
      expect(result.insideControllable, isTrue);
    });

    test('point outside all areas → nearest area, insideControllable=false', () {
      final area = DisasterArea(
        id: 'AREA-20260314-TEST',
        centerLat: 0,
        centerLon: 0,
        redRadiusM: 100,
        warningRadiusM: 200,
        greenRadiusM: 300,
        controllableRadiusM: 400,
        createdAt: DateTime(2026, 3, 14),
      );

      final result =
          DisasterAreaService.routeToArea(0.02, 0.02, [area]);
      expect(result.areaId, area.id);
      expect(result.insideControllable, isFalse);
    });
  });

  group('Ownership', () {
    test('loginToArea rejects second area for same admin', () {
      final provider = AdminProvider();
      final areaA = DisasterArea(
        id: 'AREA-20260314-AAAA',
        centerLat: 0,
        centerLon: 0,
        redRadiusM: 100,
        warningRadiusM: 200,
        greenRadiusM: 300,
        controllableRadiusM: 400,
        createdAt: DateTime(2026, 3, 14),
      );
      final areaB = DisasterArea(
        id: 'AREA-20260314-BBBB',
        centerLat: 1,
        centerLon: 1,
        redRadiusM: 100,
        warningRadiusM: 200,
        greenRadiusM: 300,
        controllableRadiusM: 400,
        createdAt: DateTime(2026, 3, 14),
      );

      provider.overrideAreasForTesting(active: [areaA, areaB]);

      expect(provider.loginToArea('admin@example.com', areaA.id), isTrue);
      expect(provider.loginToArea('admin@example.com', areaB.id), isFalse);
    });

    test('loginToArea rejects second admin for same area', () {
      final provider = AdminProvider();
      final areaA = DisasterArea(
        id: 'AREA-20260314-CCCC',
        centerLat: 0,
        centerLon: 0,
        redRadiusM: 100,
        warningRadiusM: 200,
        greenRadiusM: 300,
        controllableRadiusM: 400,
        createdAt: DateTime(2026, 3, 14),
      );

      provider.overrideAreasForTesting(active: [areaA]);

      expect(provider.loginToArea('admin1@example.com', areaA.id), isTrue);
      expect(provider.loginToArea('admin2@example.com', areaA.id), isFalse);
    });

    test('loginToArea rejects closed area', () {
      final provider = AdminProvider();
      final areaA = DisasterArea(
        id: 'AREA-20260314-DDDD',
        centerLat: 0,
        centerLon: 0,
        redRadiusM: 100,
        warningRadiusM: 200,
        greenRadiusM: 300,
        controllableRadiusM: 400,
        createdAt: DateTime(2026, 3, 14),
      );

      provider.overrideAreasForTesting(active: [areaA]);
      provider.closeAreaLocallyForTesting(areaA.id);

      expect(provider.loginToArea('admin@example.com', areaA.id), isFalse);
    });
  });
}
