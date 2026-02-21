import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../models/aid_request.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Request Aid tab for submitting assistance requests
class RequestAidTab extends StatefulWidget {
  const RequestAidTab({super.key});

  @override
  State<RequestAidTab> createState() => _RequestAidTabState();
}

class _RequestAidTabState extends State<RequestAidTab> {
  final _formKey = GlobalKey<FormState>();
  final _numberOfPeopleController = TextEditingController();
  final _exactLocationController = TextEditingController();
  final _medicalNeedsController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  final ApiService _apiService = ApiService();

  String? _mobilityStatus;
  String? _primaryResource;
  String? _supplyDuration;
  String? _urgencyLevel;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _numberOfPeopleController.dispose();
    _exactLocationController.dispose();
    _medicalNeedsController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Card(
                  color: AppConstants.primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Row(
                      children: [
                        const Icon(Icons.help_outline, color: Colors.white, size: 28),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Request Assistance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Submit a request for resources or help',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // 1. Number of People
                Text(
                  'NUMBER OF PEOPLE',
                  style: AppConstants.subheadingStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                TextFormField(
                  controller: _numberOfPeopleController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Total people needing assistance',
                    helperText: 'Include infants, children, adults, and elderly',
                    helperMaxLines: 2,
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter number of people';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 1) {
                      return 'Must be at least 1 person';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // 2. Exact Location
                Text(
                  'EXACT LOCATION',
                  style: AppConstants.subheadingStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                TextFormField(
                  controller: _exactLocationController,
                  decoration: InputDecoration(
                    hintText: 'Building name, floor, landmarks...',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide exact location details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                // GPS Coordinates Display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.gps_fixed,
                        color: AppConstants.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Expanded(
                        child: Text(
                          locationProvider.currentPosition != null
                              ? 'GPS coordinates auto-attached: ${Helpers.formatCoordinates(
                                  locationProvider.currentPosition!.latitude,
                                  locationProvider.currentPosition!.longitude,
                                )}'
                              : 'GPS coordinates: Not available',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // 3. Mobility Status
                Text(
                  'MOBILITY STATUS',
                  style: AppConstants.subheadingStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _mobilityStatus == 'can_reach'
                              ? AppConstants.primaryColor
                              : Colors.grey[300]!,
                          width: _mobilityStatus == 'can_reach' ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        color: _mobilityStatus == 'can_reach'
                            ? AppConstants.primaryColor.withOpacity(0.05)
                            : Colors.transparent,
                      ),
                      child: RadioListTile<String>(
                        title: const Text('Can reach distribution point'),
                        subtitle: const Text('We can travel to pick up supplies'),
                        value: 'can_reach',
                        groupValue: _mobilityStatus,
                        onChanged: (value) {
                          setState(() {
                            _mobilityStatus = value;
                          });
                        },
                        activeColor: AppConstants.primaryColor,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _mobilityStatus == 'need_delivery'
                              ? AppConstants.primaryColor
                              : Colors.grey[300]!,
                          width: _mobilityStatus == 'need_delivery' ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        color: _mobilityStatus == 'need_delivery'
                            ? AppConstants.primaryColor.withOpacity(0.05)
                            : Colors.transparent,
                      ),
                      child: RadioListTile<String>(
                        title: const Text('Need delivery to location'),
                        subtitle: const Text('Cannot travel - require home delivery'),
                        value: 'need_delivery',
                        groupValue: _mobilityStatus,
                        onChanged: (value) {
                          setState(() {
                            _mobilityStatus = value;
                          });
                        },
                        activeColor: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (_mobilityStatus == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      'Please select mobility status',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: AppConstants.paddingLarge),

                // 4. Primary Resource Needed
                Text(
                  'PRIMARY RESOURCE NEEDED',
                  style: AppConstants.subheadingStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                DropdownButtonFormField<String>(
                  value: _primaryResource,
                  decoration: InputDecoration(
                    hintText: '-- Select Primary Need --',
                    prefixIcon: const Icon(Icons.inventory),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Food', child: Text('Food')),
                    DropdownMenuItem(value: 'Water', child: Text('Water')),
                    DropdownMenuItem(value: 'Medical Supplies', child: Text('Medical Supplies')),
                    DropdownMenuItem(value: 'Shelter', child: Text('Shelter')),
                    DropdownMenuItem(value: 'Hygiene Kits', child: Text('Hygiene Kits')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _primaryResource = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select primary resource needed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // 5. Supply Duration Needed
                Text(
                  'SUPPLY DURATION NEEDED',
                  style: AppConstants.subheadingStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                DropdownButtonFormField<String>(
                  value: _supplyDuration,
                  decoration: InputDecoration(
                    hintText: '-- Select Duration --',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(value: '1 Day', child: Text('1 Day')),
                    DropdownMenuItem(value: '2–3 Days', child: Text('2–3 Days')),
                    DropdownMenuItem(value: '1 Week', child: Text('1 Week')),
                    DropdownMenuItem(value: 'More than 1 Week', child: Text('More than 1 Week')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _supplyDuration = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select supply duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // 6. Urgency Level
                Text(
                  'URGENCY LEVEL',
                  style: AppConstants.subheadingStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _urgencyLevel == 'low'
                              ? Colors.green
                              : Colors.grey[300]!,
                          width: _urgencyLevel == 'low' ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        color: _urgencyLevel == 'low'
                            ? Colors.green.withOpacity(0.05)
                            : Colors.transparent,
                      ),
                      child: RadioListTile<String>(
                        title: const Text('Low Priority'),
                        subtitle: const Text('Response within 12–24 hours'),
                        value: 'low',
                        groupValue: _urgencyLevel,
                        onChanged: (value) {
                          setState(() {
                            _urgencyLevel = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _urgencyLevel == 'medium'
                              ? Colors.orange
                              : Colors.grey[300]!,
                          width: _urgencyLevel == 'medium' ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        color: _urgencyLevel == 'medium'
                            ? Colors.orange.withOpacity(0.05)
                            : Colors.transparent,
                      ),
                      child: RadioListTile<String>(
                        title: const Text('Medium Priority'),
                        subtitle: const Text('Response within 4–8 hours'),
                        value: 'medium',
                        groupValue: _urgencyLevel,
                        onChanged: (value) {
                          setState(() {
                            _urgencyLevel = value;
                          });
                        },
                        activeColor: Colors.orange,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _urgencyLevel == 'high'
                              ? Colors.red
                              : Colors.grey[300]!,
                          width: _urgencyLevel == 'high' ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        color: _urgencyLevel == 'high'
                            ? Colors.red.withOpacity(0.05)
                            : Colors.transparent,
                      ),
                      child: RadioListTile<String>(
                        title: const Text('High Priority'),
                        subtitle: const Text('Response within 2–4 hours'),
                        value: 'high',
                        groupValue: _urgencyLevel,
                        onChanged: (value) {
                          setState(() {
                            _urgencyLevel = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ),
                  ],
                ),
                if (_urgencyLevel == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      'Please select urgency level',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: AppConstants.paddingLarge),

                // 7. Medical or Special Needs
                Text(
                  'MEDICAL OR SPECIAL NEEDS',
                  style: AppConstants.subheadingStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                TextFormField(
                  controller: _medicalNeedsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'E.g., Diabetes medication, wheelchair access, infant formula, oxygen required, dialysis patient...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // 8. Additional Details
                Text(
                  'ADDITIONAL DETAILS',
                  style: AppConstants.subheadingStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                TextFormField(
                  controller: _additionalDetailsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Any other important information: dietary restrictions, allergies, accessibility issues, pregnant women, disabled persons...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => _handleSubmit(locationProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit(LocationProvider locationProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation for radio buttons
    if (_mobilityStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select mobility status'),
          backgroundColor: AppConstants.dangerColor,
        ),
      );
      return;
    }

    if (_urgencyLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select urgency level'),
          backgroundColor: AppConstants.dangerColor,
        ),
      );
      return;
    }

    final position = locationProvider.currentPosition;
    if (position == null) {
      _showErrorDialog('Location not available. Please enable location services.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = AidRequest(
        resourceType: _primaryResource!,
        description: '''
Number of People: ${_numberOfPeopleController.text}
Exact Location: ${_exactLocationController.text}
Mobility Status: ${_mobilityStatus == 'can_reach' ? 'Can reach distribution point' : 'Need delivery to location'}
Primary Resource: $_primaryResource
Supply Duration: $_supplyDuration
Urgency Level: ${_urgencyLevel?.toUpperCase()}
Medical/Special Needs: ${_medicalNeedsController.text.isEmpty ? 'None' : _medicalNeedsController.text}
Additional Details: ${_additionalDetailsController.text.isEmpty ? 'None' : _additionalDetailsController.text}
''',
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final response = await _apiService.submitAidRequest(request);

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (response.success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(response.message);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      _showErrorDialog('Failed to submit request: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppConstants.safeColor),
            SizedBox(width: 8),
            Text('Request Submitted'),
          ],
        ),
        content: const Text(
          'Your aid request has been submitted successfully. Help will be dispatched to your location.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: AppConstants.dangerColor),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _numberOfPeopleController.clear();
    _exactLocationController.clear();
    _medicalNeedsController.clear();
    _additionalDetailsController.clear();
    setState(() {
      _mobilityStatus = null;
      _primaryResource = null;
      _supplyDuration = null;
      _urgencyLevel = null;
    });
  }
}
