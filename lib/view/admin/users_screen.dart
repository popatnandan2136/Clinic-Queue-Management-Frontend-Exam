import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/admin_controller.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AdminController>();

    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final phone = TextEditingController();

    var role = "patient".obs;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(labelText: "Name"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: email,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: password,
                        decoration: const InputDecoration(
                          labelText: "Password",
                        ),
                      ),
                      const SizedBox(height: 10),

                      Obx(
                        () => DropdownButtonFormField(
                          value: role.value,
                          decoration: const InputDecoration(labelText: "Role"),
                          items: const [
                            DropdownMenuItem(
                              value: "patient",
                              child: Text("Patient"),
                            ),
                            DropdownMenuItem(
                              value: "doctor",
                              child: Text("Doctor"),
                            ),
                            DropdownMenuItem(
                              value: "receptionist",
                              child: Text("Receptionist"),
                            ),
                          ],
                          onChanged: (v) => role.value = v!,
                        ),
                      ),

                      const SizedBox(height: 10),
                      TextField(
                        controller: phone,
                        decoration: const InputDecoration(labelText: "Phone"),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (name.text.trim().isEmpty ||
                                email.text.trim().isEmpty ||
                                password.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Name, email and password are required',
                              );
                              return;
                            }

                            final emailReg = RegExp(r'.+@.+\..+');
                            final emailOk =
                              emailReg.hasMatch(email.text.trim());
                            if (!emailOk) {
                              Get.snackbar(
                                'Error',
                                'Enter a valid email address',
                              );
                              return;
                            }

                            c.addUser(
                              name.text,
                              email.text,
                              password.text,
                              role.value,
                              phone.text,
                            );
                          },
                          child: const Text("Add User"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              flex: 3,
              child: Obx(() {
                if (c.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (c.users.isEmpty) {
                  return const Center(child: Text("No users"));
                }

                return ListView.builder(
                  itemCount: c.users.length,
                  itemBuilder: (_, i) {
                    final u = c.users[i];

                    return Card(
                      child: ListTile(
                        title: Text(u["name"] ?? ""),
                        subtitle: Text(u["email"] ?? ""),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(u["role"]?.toString() ?? ""),
                            const SizedBox(height: 2),
                            Text(
                              u["phone"]?.toString() ?? "",
                              style: const TextStyle(fontSize: 12),
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
      ),
    );
  }
}
