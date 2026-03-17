import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'utils/token.dart';
import 'view/login/login.dart';
import 'view/admin/admin_main.dart';
import 'view/patient/patient_main.dart';
import 'view/doctor/doctor_home.dart';
import 'view/receptionist/receptionist_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/LoginScreen',
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: '/AdminMain',
          page: () => const AdminMain(),
        ),
        GetPage(
          name: '/PatientMain',
          page: () => const PatientMain(),
        ),
        GetPage(
          name: '/DoctorMain',
          page: () => const DoctorMain(),
        ),
        GetPage(
          name: '/ReceptionMain',
          page: () => const ReceptionMain(),
        ),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await TokenManager.getToken();
    final role = await TokenManager.getRole();

    if (!mounted) return;

    if (token == null || role == null) {
      Get.offAll(() => const LoginScreen());
      return;
    }

    if (role == "admin") {
      Get.offAll(() => const AdminMain());
    } else if (role == "patient") {
      Get.offAll(() => const PatientMain());
    } else if (role == "doctor") {
      Get.offAll(() => const DoctorMain());
    } else if (role == "receptionist") {
      Get.offAll(() => const ReceptionMain());
    } else {
      await TokenManager.clear();
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
