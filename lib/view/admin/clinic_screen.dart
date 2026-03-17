import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/admin_controller.dart';

class ClinicScreen extends StatelessWidget {
  const ClinicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AdminController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Clinic",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.clinicName.value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text("Clinic Code: ${c.clinicCode.value}"),
                const SizedBox(height: 10),
                Text("Users: ${c.userCount}"),
                const SizedBox(height: 5),
                Text("Appointments: ${c.appointmentCount}"),
              ],
            ),
          ),
        ],
      )),
    );
  }
}