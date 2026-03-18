class SimulationSmsStatus {
  final String status;
  final String message;
  final String? recipient;

  const SimulationSmsStatus({
    required this.status,
    required this.message,
    this.recipient,
  });

  factory SimulationSmsStatus.fromAssessmentPayload(
    Map<String, dynamic>? payload,
  ) {
    if (payload == null) {
      return const SimulationSmsStatus(
        status: 'unavailable',
        message:
            'Simulation started, but the backend did not return an SMS status.',
      );
    }

    final smsStatus = payload['sms_status'];
    if (smsStatus is Map<String, dynamic>) {
      return SimulationSmsStatus(
        status: (smsStatus['status'] as String?) ?? 'unavailable',
        message:
            (smsStatus['detail'] as String?) ??
            'Simulation started, but no SMS detail was provided.',
        recipient: smsStatus['recipient'] as String?,
      );
    }

    if ((payload['message'] as String?) == 'Area is safe') {
      return const SimulationSmsStatus(
        status: 'not_needed',
        message: 'Simulation started, but no SMS alert was needed.',
      );
    }

    return const SimulationSmsStatus(
      status: 'unavailable',
      message: 'Simulation started, but the SMS status was unavailable.',
    );
  }

  String get title {
    switch (status) {
      case 'sent':
        return 'SMS Alert Sent';
      case 'failed':
        return 'SMS Alert Failed';
      case 'skipped':
        return 'SMS Alert Skipped';
      case 'not_needed':
        return 'No SMS Needed';
      default:
        return 'SMS Status Unavailable';
    }
  }

  bool get isSuccess => status == 'sent';
}
