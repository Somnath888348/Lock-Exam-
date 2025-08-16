import 'package:flutter/material.dart';
import '../presentation/student_exam_interface_screen/student_exam_interface_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/role_selection_screen/role_selection_screen.dart';
import '../presentation/premium_subscription_screen/premium_subscription_screen.dart';
import '../presentation/student_results_screen/student_results_screen.dart';
import '../presentation/ai_question_generator_screen/ai_question_generator_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String studentExamInterface = '/student-exam-interface-screen';
  static const String splash = '/splash-screen';
  static const String roleSelection = '/role-selection-screen';
  static const String premiumSubscription = '/premium-subscription-screen';
  static const String studentResults = '/student-results-screen';
  static const String aiQuestionGenerator = '/ai-question-generator-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    studentExamInterface: (context) => const StudentExamInterfaceScreen(),
    splash: (context) => const SplashScreen(),
    roleSelection: (context) => const RoleSelectionScreen(),
    premiumSubscription: (context) => const PremiumSubscriptionScreen(),
    studentResults: (context) => const StudentResultsScreen(),
    aiQuestionGenerator: (context) => const AiQuestionGeneratorScreen(),
    // TODO: Add your other routes here
  };
}
