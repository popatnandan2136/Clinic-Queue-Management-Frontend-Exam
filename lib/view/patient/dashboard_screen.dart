import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/patient_controller.dart';
import 'book_screen.dart';
import 'appointments_screen.dart';
import 'prescriptions_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PatientController>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text("Manage your visits and records"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _DashboardButton(
                    label: "Book",
                    icon: Icons.add_circle_outline,
                    onTap: () => c.tabIndex.value = 1,
                  ),
                  _DashboardButton(
                    label: "Appointments",
                    icon: Icons.calendar_today,
                    onTap: () => c.tabIndex.value = 2,
                  ),
                  _DashboardButton(
                    label: "Prescriptions",
                    icon: Icons.medical_services_outlined,
                    onTap: () => Get.to(() => const PrescriptionsScreen()),
                  ),
                  _DashboardButton(
                    label: "Reports",
                    icon: Icons.insert_drive_file_outlined,
                    onTap: () => Get.to(() => const ReportsScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}
