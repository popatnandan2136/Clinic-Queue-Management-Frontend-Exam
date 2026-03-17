import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/doctor_controller.dart';
import '../../utils/token.dart';

class DoctorMain extends StatelessWidget {
  const DoctorMain({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DoctorController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<List<String?>> (
            future: Future.wait([
              TokenManager.getClinicName(),
              TokenManager.getRole(),
            ]),
            builder: (context, snapshot) {
              final clinic = snapshot.data != null && snapshot.data!.isNotEmpty
                  ? (snapshot.data![0] ?? "")
                  : "";
              final role = snapshot.data != null && snapshot.data!.length > 1
                  ? (snapshot.data![1] ?? "")
                  : "";

              return Row(
                children: [
                  const Text('Clinic Queue'),
                  if (clinic.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      clinic,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                  const Spacer(),
                  if (role.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await TokenManager.logout();
                      Get.offAllNamed('/LoginScreen');
                    },
                  ),
                ],
              );
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Today's Queue"),
              Tab(text: 'Add Prescription'),
              Tab(text: 'Add Report'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DoctorQueueTab(),
            DoctorPrescriptionTab(),
            DoctorReportTab(),
          ],
        ),
      ),
    );
  }
}

class DoctorQueueTab extends StatelessWidget {
  const DoctorQueueTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DoctorController>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Today's Queue",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (c.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.queue.isEmpty) {
                return const Center(child: Text('No patients in queue'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: c.queue.length,
                itemBuilder: (_, i) {
            final item = c.queue[i];
            final token = item['tokenNumber']?.toString() ?? '-';
            final name = item['patientName']?.toString() ?? '';
            final status = item['status']?.toString() ?? '';
            final appointmentId = item['appointmentId'] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _statusColor(status),
                              child: Text(token),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name),
                                const SizedBox(height: 4),
                                Text(
                                  'Appt: $appointmentId',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            c.selectedAppointmentId.value =
                                int.tryParse(appointmentId.toString()) ?? 0;
                            DefaultTabController.of(context)?.animateTo(1);
                          },
                          child: const Text('Add Prescription'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            c.selectedAppointmentId.value =
                                int.tryParse(appointmentId.toString()) ?? 0;
                            DefaultTabController.of(context)?.animateTo(2);
                          },
                          child: const Text('Add Report'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
              );
            })
          ),
        ],
      ),
    );
  }
}

class DoctorPrescriptionTab extends StatefulWidget {
  const DoctorPrescriptionTab({super.key});

  @override
  State<DoctorPrescriptionTab> createState() => _DoctorPrescriptionTabState();
}

class _DoctorPrescriptionTabState extends State<DoctorPrescriptionTab> {
  final appointmentController = TextEditingController();
  final notesController = TextEditingController();
  final List<Map<String, String>> medicines = [];

  @override
  void dispose() {
    appointmentController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void addRow() {
    setState(() {
      medicines.add({'name': '', 'dosage': '', 'duration': ''});
    });
  }

  void removeRow(int index) {
    setState(() {
      medicines.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DoctorController>();
    return SafeArea(
      child: Obx(() {
        var selectedId = c.selectedAppointmentId.value;

        if (selectedId == 0 && c.queue.isNotEmpty) {
          selectedId = c.queue.first['appointmentId'] ?? 0;
          c.selectedAppointmentId.value = selectedId;
        }

        if (selectedId > 0) {
          appointmentController.text = selectedId.toString();
        }

        Map? current;
        if (selectedId > 0) {
          current = c.queue.firstWhereOrNull(
            (e) => e['appointmentId'] == selectedId,
          );
        }
        final patientName = current?['patientName']?.toString() ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () =>
                    DefaultTabController.of(context)?.animateTo(0),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to queue'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: appointmentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Appointment ID'),
              ),
              if (patientName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Patient: $patientName',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Medicines'),
                  TextButton(onPressed: addRow, child: const Text('Add Row')),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: medicines.length,
                itemBuilder: (_, i) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          TextField(
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            onChanged: (v) => medicines[i]['name'] = v,
                          ),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Dosage',
                            ),
                            onChanged: (v) => medicines[i]['dosage'] = v,
                          ),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Duration',
                            ),
                            onChanged: (v) => medicines[i]['duration'] = v,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => removeRow(i),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final id = int.tryParse(appointmentController.text) ?? 0;
                    final ok = await c.addPrescription(
                      id,
                      List.of(medicines),
                      notesController.text,
                    );
                    if (ok) {
                      DefaultTabController.of(context)?.animateTo(0);
                      setState(() {
                        medicines.clear();
                        notesController.clear();
                      });
                    }
                  },
                  child: const Text('Save Prescription'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class DoctorReportTab extends StatefulWidget {
  const DoctorReportTab({super.key});

  @override
  State<DoctorReportTab> createState() => _DoctorReportTabState();
}

class _DoctorReportTabState extends State<DoctorReportTab> {
  final appointmentController = TextEditingController();
  final diagnosisController = TextEditingController();
  final testsController = TextEditingController();
  final remarksController = TextEditingController();

  @override
  void dispose() {
    appointmentController.dispose();
    diagnosisController.dispose();
    testsController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DoctorController>();
    return SafeArea(
      child: Obx(() {
        var selectedId = c.selectedAppointmentId.value;

        if (selectedId == 0 && c.queue.isNotEmpty) {
          selectedId = c.queue.first['appointmentId'] ?? 0;
          c.selectedAppointmentId.value = selectedId;
        }

        if (selectedId > 0) {
          appointmentController.text = selectedId.toString();
        }

        Map? current;
        if (selectedId > 0) {
          current = c.queue.firstWhereOrNull(
            (e) => e['appointmentId'] == selectedId,
          );
        }
        final patientName = current?['patientName']?.toString() ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      DefaultTabController.of(context)?.animateTo(0),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to queue'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: appointmentController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Appointment ID'),
              ),
              if (patientName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Patient: $patientName',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: diagnosisController,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: testsController,
                decoration:
                    const InputDecoration(labelText: 'Test recommended'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remarksController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Remarks'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final id = int.tryParse(appointmentController.text) ?? 0;
                    final ok = await c.addReport(
                      id,
                      diagnosisController.text,
                      testsController.text,
                      remarksController.text,
                    );
                    if (ok) {
                      DefaultTabController.of(context)?.animateTo(0);
                      appointmentController.clear();
                      diagnosisController.clear();
                      testsController.clear();
                      remarksController.clear();
                    }
                  },
                  child: const Text('Save Report'),
                ),
              ),
            ],
          ),
        );
      }),
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
