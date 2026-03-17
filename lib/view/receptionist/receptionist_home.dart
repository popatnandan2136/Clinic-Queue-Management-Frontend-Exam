import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/receptionist_controller.dart';
import '../../utils/token.dart';

class ReceptionMain extends StatelessWidget {
  const ReceptionMain({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ReceptionistController());

    return DefaultTabController(
      length: 2,
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
              Tab(text: 'Queue'),
              Tab(text: 'TV Display'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ReceptionQueueTab(), ReceptionTvTab()],
        ),
      ),
    );
  }
}

class ReceptionQueueTab extends StatefulWidget {
  const ReceptionQueueTab({super.key});

  @override
  State<ReceptionQueueTab> createState() => _ReceptionQueueTabState();
}

class _ReceptionQueueTabState extends State<ReceptionQueueTab> {
  DateTime? pickedDate;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReceptionistController>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Queue (manage)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => TextField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          hintText: 'Select date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: c.selectedDate.value,
                        ),
                        onTap: () async {
                          final now = DateTime.now();
                          final result = await showDatePicker(
                            context: context,
                            initialDate: pickedDate ?? now,
                            firstDate: now.subtract(const Duration(days: 30)),
                            lastDate: now.add(const Duration(days: 90)),
                          );
                          if (result != null) {
                            pickedDate = result;
                            final text = result
                                .toIso8601String()
                                .split('T')
                                .first;
                            c.setDate(text);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: c.fetchQueue,
                    child: const Text('Load'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (c.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.queue.isEmpty) {
                return const Center(child: Text('No entries'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: c.queue.length,
                itemBuilder: (_, i) {
                  final item = c.queue[i];
                  final token = item['tokenNumber']?.toString() ?? '-';

                  final appt = (item['appointment'] ?? {}) as Map;
                  final patient = (appt['patient'] ?? {}) as Map;

                  final name = patient['name']?.toString() ?? '';
                  final phone = patient['phone']?.toString() ?? '';
                  final slot = (item['timeSlot'] ?? appt['timeSlot'] ?? '')
                      .toString();
                  final status = item['status']?.toString() ?? '';
                  final id = item['id'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12, top: 4),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name),
                                      const SizedBox(height: 4),
                                      Text(
                                        phone,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        slot,
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
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (status == 'waiting') ...[
                                TextButton(
                                  onPressed: () =>
                                      c.updateStatus(id, 'in_progress'),
                                  child: const Text('In progress'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () =>
                                      c.updateStatus(id, 'skipped'),
                                  child: const Text('Skip'),
                                ),
                              ] else if (status == 'in_progress') ...[
                                TextButton(
                                  onPressed: () => c.updateStatus(id, 'done'),
                                  child: const Text('Done'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ReceptionTvTab extends StatelessWidget {
  const ReceptionTvTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReceptionistController>();

    return SafeArea(
      child: Obx(() {
        final current = c.currentEntry();
        if (current == null) {
          return const Center(child: Text('No active token'));
        }
        final token = current['tokenNumber']?.toString() ?? '-';

        final appt = (current['appointment'] ?? {}) as Map;
        final patient = (appt['patient'] ?? {}) as Map;
        final name = patient['name']?.toString() ?? '';

        return Container(
          width: double.infinity,
          color: Colors.grey.shade100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Now Serving', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    token,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(name, style: const TextStyle(fontSize: 22)),
              ],
            ),
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
