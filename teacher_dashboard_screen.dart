import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/quick_actions_card_widget.dart';
import './widgets/recent_exams_card_widget.dart';
import './widgets/statistics_card_widget.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;

  // Mock data for teacher dashboard
  final Map<String, dynamic> teacherData = {
    "name": "Dr. Sarah Johnson",
    "email": "sarah.johnson@university.edu",
    "department": "Computer Science",
    "profileImage":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
  };

  final Map<String, dynamic> statisticsData = {
    "totalExams": 24,
    "activeStudents": 156,
    "completionRate": 87.5,
    "totalQuestions": 342,
  };

  final List<Map<String, dynamic>> recentExams = [
    {
      "id": 1,
      "name": "Data Structures Mid-Term",
      "status": "active",
      "studentsCount": 45,
      "createdDate": "12/08/2025",
      "duration": 120,
      "questionsCount": 25,
    },
    {
      "id": 2,
      "name": "Algorithm Analysis Quiz",
      "status": "completed",
      "studentsCount": 38,
      "createdDate": "10/08/2025",
      "duration": 60,
      "questionsCount": 15,
    },
    {
      "id": 3,
      "name": "Database Systems Final",
      "status": "draft",
      "studentsCount": 0,
      "createdDate": "13/08/2025",
      "duration": 180,
      "questionsCount": 40,
    },
    {
      "id": 4,
      "name": "Object-Oriented Programming",
      "status": "completed",
      "studentsCount": 52,
      "createdDate": "08/08/2025",
      "duration": 90,
      "questionsCount": 20,
    },
    {
      "id": 5,
      "name": "Software Engineering Quiz",
      "status": "active",
      "studentsCount": 31,
      "createdDate": "11/08/2025",
      "duration": 45,
      "questionsCount": 12,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dashboard data refreshed successfully'),
        backgroundColor: AppTheme.accentSuccess,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showExamContextMenu(BuildContext context, Map<String, dynamic> exam) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              exam['name'] as String? ?? 'Exam Options',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildContextMenuItem('Edit Exam', 'edit', () {
              Navigator.pop(context);
              // Navigate to edit exam
            }),
            _buildContextMenuItem('Duplicate Exam', 'content_copy', () {
              Navigator.pop(context);
              _showDuplicateSuccess();
            }),
            _buildContextMenuItem('Share Exam ID', 'share', () {
              Navigator.pop(context);
              _shareExamId(exam);
            }),
            _buildContextMenuItem('Delete Exam', 'delete', () {
              Navigator.pop(context);
              _showDeleteConfirmation(exam);
            }, isDestructive: true),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
      String title, String iconName, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color:
            isDestructive ? AppTheme.accentError : AppTheme.textSecondaryLight,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color:
              isDestructive ? AppTheme.accentError : AppTheme.textPrimaryLight,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  void _showDuplicateSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exam duplicated successfully'),
        backgroundColor: AppTheme.accentSuccess,
      ),
    );
  }

  void _shareExamId(Map<String, dynamic> exam) {
    final examId = 'EX${exam['id'].toString().padLeft(6, '0')}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exam ID: $examId copied to clipboard'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: Text(
            'Are you sure you want to delete "${exam['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExam(exam);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteExam(Map<String, dynamic> exam) {
    setState(() {
      recentExams.removeWhere((e) => e['id'] == exam['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exam['name']} deleted successfully'),
        backgroundColor: AppTheme.accentError,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildExamsTab(),
                  _buildQuestionsTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/exam-creation-screen');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                'Create Exam',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppTheme.lightTheme.primaryColor,
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: CustomImageWidget(
              imageUrl: teacherData['profileImage'] as String,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
                Text(
                  teacherData['name'] as String,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Show notifications
            },
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.textSecondaryLight,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.accentError,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.cardColor,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Dashboard'),
          Tab(text: 'Exams'),
          Tab(text: 'Questions'),
          Tab(text: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.lightTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            StatisticsCardWidget(statisticsData: statisticsData),
            RecentExamsCardWidget(
              recentExams: recentExams,
              onExamTap: (exam) {
                // Navigate to exam details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${exam['name']}...'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              onExamLongPress: (exam) {
                _showExamContextMenu(context, exam);
              },
            ),
            QuickActionsCardWidget(
              onCreateExam: () {
                Navigator.pushNamed(context, '/exam-creation-screen');
              },
              onGenerateQuestions: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        const Text('AI Question Generation - Premium Feature'),
                    backgroundColor: AppTheme.accentWarning,
                    action: SnackBarAction(
                      label: 'Upgrade',
                      textColor: Colors.white,
                      onPressed: () {
                        // Navigate to premium subscription
                      },
                    ),
                  ),
                );
              },
              onViewQuestionBank: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening Question Bank...'),
                  ),
                );
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildExamsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'quiz',
            color: AppTheme.textDisabledLight,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Exams Management',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'View and manage all your exams',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textDisabledLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'library_books',
            color: AppTheme.textDisabledLight,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Question Bank',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Manage your question library',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textDisabledLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 3.h),
          CircleAvatar(
            radius: 15.w,
            backgroundImage:
                NetworkImage(teacherData['profileImage'] as String),
          ),
          SizedBox(height: 2.h),
          Text(
            teacherData['name'] as String,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            teacherData['email'] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            teacherData['department'] as String,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textDisabledLight,
            ),
          ),
          SizedBox(height: 4.h),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'settings',
                    color: AppTheme.textSecondaryLight,
                    size: 24,
                  ),
                  title: const Text('Settings'),
                  trailing: CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: AppTheme.textDisabledLight,
                    size: 16,
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.accentWarning,
                    size: 24,
                  ),
                  title: const Text('Upgrade to Premium'),
                  trailing: CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: AppTheme.textDisabledLight,
                    size: 16,
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'help',
                    color: AppTheme.textSecondaryLight,
                    size: 24,
                  ),
                  title: const Text('Help & Support'),
                  trailing: CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: AppTheme.textDisabledLight,
                    size: 16,
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'logout',
                    color: AppTheme.accentError,
                    size: 24,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: AppTheme.accentError),
                  ),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/teacher-login-screen',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
