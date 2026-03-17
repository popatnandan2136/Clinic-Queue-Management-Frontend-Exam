import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/patient_controller.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final dateController = TextEditingController();
  String slot = "10:00-10:15";
  DateTime? selectedDate;

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PatientController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Book Appointment",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Date",
                      hintText: "Select date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: pickDate,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField(
                    value: slot,
                    items: const [
                      DropdownMenuItem(
                        value: "10:00-10:15",
                        child: Text("10:00-10:15"),
                      ),
                      DropdownMenuItem(
                        value: "10:15-10:30",
                        child: Text("10:15-10:30"),
                      ),
                      DropdownMenuItem(
                        value: "10:30-10:45",
                        child: Text("10:30-10:45"),
                      ),
                      DropdownMenuItem(
                        value: "10:45-11:00",
                        child: Text("10:45-11:00"),
                      ),
                      DropdownMenuItem(
                        value: "11:00-11:15",
                        child: Text("11:00-11:15"),
                      ),
                      DropdownMenuItem(
                        value: "11:15-11:30",
                        child: Text("11:15-11:30"),
                      ),
                      DropdownMenuItem(
                        value: "11:30-11:45",
                        child: Text("11:30-11:45"),
                      ),
                      DropdownMenuItem(
                        value: "11:45-12:00",
                        child: Text("11:45-12:00"),
                      ),
                      DropdownMenuItem(
                        value: "16:00-16:15",
                        child: Text("16:00-16:15"),
                      ),
                      DropdownMenuItem(
                        value: "16:15-16:30",
                        child: Text("16:15-16:30"),
                      ),
                      DropdownMenuItem(
                        value: "16:30-16:45",
                        child: Text("16:30-16:45"),
                      ),
                      DropdownMenuItem(
                        value: "16:45-17:00",
                        child: Text("16:45-17:00"),
                      ),
                      DropdownMenuItem(
                        value: "17:00-17:15",
                        child: Text("17:00-17:15"),
                      ),
                      DropdownMenuItem(
                        value: "17:15-17:30",
                        child: Text("17:15-17:30"),
                      ),
                      DropdownMenuItem(
                        value: "17:30-17:45",
                        child: Text("17:30-17:45"),
                      ),
                      DropdownMenuItem(
                        value: "17:45-18:00",
                        child: Text("17:45-18:00"),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          slot = v;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (dateController.text.isEmpty) {
                          Get.snackbar("Error", "Select a date");
                          return;
                        }
                        final ok = await c.book(dateController.text, slot);
                        if (ok) {
                          c.tabIndex.value = 2;
                        }
                      },
                      child: const Text("Book"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
