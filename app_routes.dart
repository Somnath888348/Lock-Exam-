import 'package:flutter/material.dart';
import '../presentation/exam_taking_screen/exam_taking_screen.dart';
import '../presentation/teacher_dashboard_screen/teacher_dashboard_screen.dart';
import '../presentation/exam_creation_screen/exam_creation_screen.dart';
import '../presentation/camera_permission_screen/camera_permission_screen.dart';
import '../presentation/teacher_login_screen/teacher_login_screen.dart';
import '../presentation/student_name_entry_screen/student_name_entry_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String examTaking = '/exam-taking-screen';
  static const String teacherDashboard = '/teacher-dashboard-screen';
  static const String examCreation = '/exam-creation-screen';
  static const String cameraPermission = '/camera-permission-screen';
  static const String teacherLogin = '/teacher-login-screen';
  static const String studentNameEntry = '/student-name-entry-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const TeacherLoginScreen(),
    examTaking: (context) => const ExamTakingScreen(),
    teacherDashboard: (context) => const TeacherDashboardScreen(),
    examCreation: (context) => const ExamCreationScreen(),
    cameraPermission: (context) => const CameraPermissionScreen(),
    teacherLogin: (context) => const TeacherLoginScreen(),
    studentNameEntry: (context) => const StudentNameEntryScreen(),
    // TODO: Add your other routes here
  };
}
