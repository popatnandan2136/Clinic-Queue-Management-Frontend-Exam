import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../utils/keys.dart';
import '../../utils/token.dart';
import '../admin/admin_main.dart';
import '../patient/patient_main.dart';
import '../doctor/doctor_home.dart';
import '../receptionist/receptionist_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  void login() async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      Get.snackbar("Error", "Email and password are required");
      return;
    }

    final emailOk = RegExp(r'.+@.+\..+').hasMatch(email);
    if (!emailOk) {
      Get.snackbar("Error", "Enter a valid email address");
      return;
    }

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse(ApiKeys.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": pass,
        }),
      );

      setState(() => loading = false);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data["token"];
        final role = data["user"]["role"];
        String? clinicName;
        String? clinicCode;
        final clinic = data["clinic"];
        if (clinic != null) {
          clinicName = clinic["name"]?.toString();
          clinicCode = clinic["code"]?.toString();
        }

        await TokenManager.save(
          token,
          role,
          clinicName: clinicName,
          clinicCode: clinicCode,
        );

        if (role == "admin") {
          Get.offAll(() => const AdminMain());
        } else if (role == "patient") {
          Get.offAll(() => const PatientMain());
        } else if (role == "doctor") {
          Get.offAll(() => const DoctorMain());
        } else if (role == "receptionist") {
          Get.offAll(() => const ReceptionMain());
        } else {
          Get.snackbar("Error", "Unsupported role");
        }
      } else {
        try {
          final body = jsonDecode(res.body);
          final msg = body['error']?.toString();
          Get.snackbar("Error", msg ?? "Login failed");
        } catch (_) {
          Get.snackbar("Error", "Login failed");
        }
      }
    } catch (e) {
      setState(() => loading = false);
      Get.snackbar("Error", "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
