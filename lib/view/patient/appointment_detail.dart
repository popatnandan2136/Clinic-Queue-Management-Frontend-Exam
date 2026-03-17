import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/patient_controller.dart';

class AppointmentDetail extends StatelessWidget {
  const AppointmentDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PatientController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details')),
      body: Obx(() {
        final d = c.selected;
        final queue = d['queueEntry'] ?? {};
        final status = queue['status']?.toString() ?? '';
        final token = queue['tokenNumber']?.toString() ?? '-';
        final prescription = d['prescription'];
        final report = d['report'];

        final rawDate = d['appointmentDate']?.toString() ?? '';
        String dateText = rawDate;
        if (rawDate.contains('T')) {
          dateText = rawDate.split('T').first;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to appointments'),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: $dateText'),
                          const SizedBox(height: 4),
                          Text('Time: ${d['timeSlot'] ?? ''}'),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Token $token'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prescription',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (prescription == null)
                        const Text(
                          'No prescription added for this appointment yet.',
                        )
                      else ...[
                        _PrescriptionView(prescription: prescription),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (report == null)
                        const Text(
                          'No report added for this appointment yet.',
                        )
                      else ...[
                        _ReportView(report: report),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _PrescriptionView extends StatelessWidget {
  final Map prescription;

  const _PrescriptionView({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final medicines = (prescription['medicines'] as List?) ?? [];
    final notes = prescription['notes']?.toString() ?? '';
    final doctor = (prescription['doctor'] ?? {}) as Map;
    final doctorName = doctor['name']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (medicines.isNotEmpty) ...[
          const Text(
            'Medicines',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          for (final m in medicines)
            Text(
              '${m['name'] ?? ''}  •  ${m['dosage'] ?? ''}  •  ${m['duration'] ?? ''}',
            ),
          const SizedBox(height: 8),
        ],
        if (notes.isNotEmpty) ...[
          const Text(
            'Notes',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(notes),
          const SizedBox(height: 8),
        ],
        if (doctorName.isNotEmpty)
          Text(
            'Prescribed by: $doctorName',
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }
}

class _ReportView extends StatelessWidget {
  final Map report;

  const _ReportView({required this.report});

  @override
  Widget build(BuildContext context) {
    final diagnosis = report['diagnosis']?.toString() ?? '';
    final tests = report['testRecommended']?.toString() ?? '';
    final remarks = report['remarks']?.toString() ?? '';
    final doctor = (report['doctor'] ?? {}) as Map;
    final doctorName = doctor['name']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (diagnosis.isNotEmpty) ...[
          const Text(
            'Diagnosis',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(diagnosis),
          const SizedBox(height: 8),
        ],
        if (tests.isNotEmpty) ...[
          const Text(
            'Tests recommended',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(tests),
          const SizedBox(height: 8),
        ],
        if (remarks.isNotEmpty) ...[
          const Text(
            'Remarks',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(remarks),
          const SizedBox(height: 8),
        ],
        if (doctorName.isNotEmpty)
          Text(
            'Reported by: $doctorName',
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }
}

Color _statusColor(String status) {
  if (status == 'waiting') return Colors.orange;
  if (status == 'in_progress') return Colors.blue;
  if (status == 'done') return Colors.green;
  if (status == 'skipped') return Colors.grey;
  return Colors.grey;
}
