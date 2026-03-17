import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/patient_controller.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PatientController>();
    c.fetchPrescriptions();

    return Scaffold(
      appBar: AppBar(title: const Text('My Prescriptions')),
      body: Obx(() {
        if (c.prescriptionLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (c.prescriptions.isEmpty) {
          return const Center(child: Text('No prescriptions'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: c.prescriptions.length,
          itemBuilder: (_, i) {
            final p = c.prescriptions[i];
            final doctor = (p['doctor'] ?? {}) as Map;
            final doctorName = doctor['name']?.toString() ?? '';
            final created = p['createdAt']?.toString() ?? '';
            final medicines = (p['medicines'] as List?) ?? [];
            final firstMed = medicines.isNotEmpty
                ? medicines.first['name']?.toString() ?? ''
                : '';
            return Card(
              child: ListTile(
                title: Text(firstMed.isNotEmpty
                    ? firstMed
                    : 'Prescription ${p['id'] ?? ''}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p['notes'] != null && p['notes'].toString().isNotEmpty)
                      Text(p['notes'].toString()),
                    if (doctorName.isNotEmpty)
                      Text('Doctor: $doctorName',
                          style: const TextStyle(fontSize: 12)),
                    if (created.isNotEmpty)
                      Text(created, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
