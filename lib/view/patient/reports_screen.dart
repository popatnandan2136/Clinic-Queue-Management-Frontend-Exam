import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/patient_controller.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PatientController>();
    c.fetchReports();

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: Obx(() {
        if (c.reportLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (c.reports.isEmpty) {
          return const Center(child: Text('No reports'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: c.reports.length,
          itemBuilder: (_, i) {
            final r = c.reports[i];
            final doctor = (r['doctor'] ?? {}) as Map;
            final doctorName = doctor['name']?.toString() ?? '';
            final created = r['createdAt']?.toString() ?? '';
            return Card(
              child: ListTile(
                title: Text(r['diagnosis']?.toString() ?? 'Report'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r['testRecommended'] != null &&
                        r['testRecommended'].toString().isNotEmpty)
                      Text(
                        'Tests: ${r['testRecommended']}',
                      ),
                    if (r['remarks'] != null &&
                        r['remarks'].toString().isNotEmpty)
                      Text(r['remarks'].toString()),
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
