import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/patient_controller.dart';
import '../../utils/token.dart';
import 'dashboard_screen.dart';
import 'book_screen.dart';
import 'appointments_screen.dart';

class PatientMain extends StatelessWidget {
  const PatientMain({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PatientController());

    final pages = [
      const DashboardScreen(),
      const BookScreen(),
      const AppointmentsScreen(),
    ];

    return Obx(() => Scaffold(
      appBar: AppBar(
        title: const Text("Clinic Queue"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await TokenManager.logout();
              Get.offAllNamed('/LoginScreen');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: FutureBuilder<List<String?>> (
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

              if (clinic.isEmpty && role.isEmpty) {
                return const SizedBox(height: 0);
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    if (clinic.isNotEmpty)
                      Text(
                        clinic,
                        style: const TextStyle(fontSize: 13),
                      ),
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(child: pages[c.tabIndex.value]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: c.tabIndex.value,
        onTap: (i) => c.tabIndex.value = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Book"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Appointments"),
        ],
      ),
    ));
  }
}