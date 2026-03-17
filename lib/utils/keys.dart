class ApiKeys {
  static const String baseUrl="https://cmsback.sampaarsh.cloud";

  static const String login="$baseUrl/auth/login";
  static const String health="$baseUrl/health";

  static const String appointments="$baseUrl/appointments";
  static const String myAppointments="$baseUrl/appointments/my";

  static String appointmentById(int id){
    return "$baseUrl/appointments/$id";
  }

  static const String queue="$baseUrl/queue";

  static String updateQueue(int id){
    return "$baseUrl/queue/$id";
  }

  static const String doctorQueue="$baseUrl/doctor/queue";

  static const String myPrescriptions="$baseUrl/prescriptions/my";

  static String addPrescription(int appointmentId){
    return "$baseUrl/prescriptions/$appointmentId";
  }

  static const String myReports="$baseUrl/reports/my";

  static String addReport(int appointmentId){
    return "$baseUrl/reports/$appointmentId";
  }

  static const String clinicInfo="$baseUrl/admin/clinic";
  static const String users="$baseUrl/admin/users";
}