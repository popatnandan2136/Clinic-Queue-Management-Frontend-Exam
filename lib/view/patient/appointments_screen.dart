import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/patient_controller.dart';
import 'appointment_detail.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PatientController>();

    c.fetchAppointments();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (c.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (c.appointments.isEmpty) {
            return const Center(child: Text("No appointments"));
          }

          return ListView.builder(
            itemCount: c.appointments.length,
            itemBuilder: (_, i) {
              final a = c.appointments[i];
              final queue = a["queueEntry"] ?? {};
              final status = queue["status"]?.toString() ?? "";
              final token = queue["tokenNumber"]?.toString() ?? "-";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(a["appointmentDate"] ?? ""),
                  subtitle: Text(a["timeSlot"] ?? ""),
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(status),
                    child: Text(token),
                  ),
                  trailing: Container(
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
                  onTap: () {
                    c.getDetails(a["id"]);
                    Get.to(() => const AppointmentDetail());
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

Color _statusColor(String status) {
  if (status == "waiting") return Colors.orange;
  if (status == "in_progress") return Colors.blue;
  if (status == "done") return Colors.green;
  if (status == "skipped") return Colors.grey;
  return Colors.grey;
}
