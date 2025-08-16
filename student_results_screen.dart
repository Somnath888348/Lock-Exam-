import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/exam_results_card.dart';
import './widgets/results_analytics_chart.dart';
import './widgets/results_filter_bar.dart';
import './widgets/results_search_bar.dart';

class StudentResultsScreen extends StatefulWidget {
  const StudentResultsScreen({Key? key}) : super(key: key);

  @override
  State<StudentResultsScreen> createState() => _StudentResultsScreenState();
}

class _StudentResultsScreenState extends State<StudentResultsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isPremium = false; // Mock premium status

  // Mock exam data with student attempts
  final List<Map<String, dynamic>> _examData = [
    {
      'id': 1,
      'name': 'Mathematics Final Exam - Calculus & Algebra',
      'duration': 120,
      'totalQuestions': 50,
      'status': 'active',
      'createdAt': '2025-08-10',
      'attempts': [
        {
          'id': 1,
          'studentName': 'Arjun Sharma',
          'score': 92.0,
          'timeTaken': '95 min',
          'status': 'completed',
          'submittedAt': '2025-08-14 10:30 AM',
        },
        {
          'id': 2,
          'studentName': 'Priya Patel',
          'score': 78.0,
          'timeTaken': '110 min',
          'status': 'completed',
          'submittedAt': '2025-08-14 11:15 AM',
        },
        {
          'id': 3,
          'studentName': 'Rahul Kumar',
          'score': 0.0,
          'timeTaken': '25 min',
          'status': 'terminated',
          'submittedAt': '2025-08-14 09:45 AM',
        },
        {
          'id': 4,
          'studentName': 'Sneha Gupta',
          'score': 85.0,
          'timeTaken': '105 min',
          'status': 'completed',
          'submittedAt': '2025-08-14 12:00 PM',
        },
      ],
    },
    {
      'id': 2,
      'name': 'Physics Chapter Test - Mechanics',
      'duration': 90,
      'totalQuestions': 30,
      'status': 'active',
      'createdAt': '2025-08-12',
      'attempts': [
        {
          'id': 5,
          'studentName': 'Vikram Singh',
          'score': 88.0,
          'timeTaken': '75 min',
          'status': 'completed',
          'submittedAt': '2025-08-14 02:30 PM',
        },
        {
          'id': 6,
          'studentName': 'Anita Reddy',
          'score': 0.0,
          'timeTaken': 'N/A',
          'status': 'in_progress',
          'submittedAt': 'In Progress',
        },
      ],
    },
    {
      'id': 3,
      'name': 'Chemistry Organic Compounds Quiz',
      'duration': 60,
      'totalQuestions': 25,
      'status': 'completed',
      'createdAt': '2025-08-08',
      'attempts': [
        {
          'id': 7,
          'studentName': 'Deepak Joshi',
          'score': 76.0,
          'timeTaken': '55 min',
          'status': 'completed',
          'submittedAt': '2025-08-13 04:15 PM',
        },
        {
          'id': 8,
          'studentName': 'Kavya Nair',
          'score': 82.0,
          'timeTaken': '48 min',
          'status': 'completed',
          'submittedAt': '2025-08-13 03:30 PM',
        },
        {
          'id': 9,
          'studentName': 'Rohit Agarwal',
          'score': 90.0,
          'timeTaken': '52 min',
          'status': 'completed',
          'submittedAt': '2025-08-13 05:00 PM',
        },
      ],
    },
    {
      'id': 4,
      'name': 'English Literature Assessment',
      'duration': 75,
      'totalQuestions': 20,
      'status': 'completed',
      'createdAt': '2025-08-05',
      'attempts': [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredExams {
    List<Map<String, dynamic>> filtered = _examData;

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered =
          filtered.where((exam) => exam['status'] == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((exam) {
        final examName = (exam['name'] as String).toLowerCase();
        final searchLower = _searchQuery.toLowerCase();

        // Search in exam name
        if (examName.contains(searchLower)) return true;

        // Search in student names
        final attempts = exam['attempts'] as List;
        return attempts.any((attempt) {
          final studentName =
              ((attempt as Map<String, dynamic>)['studentName'] as String)
                  .toLowerCase();
          return studentName.contains(searchLower);
        });
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildResultsTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Student Results',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showBulkExportDialog,
          icon: CustomIconWidget(
            iconName: 'download',
            size: 24,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'refresh':
                _refreshResults();
                break;
              case 'settings':
                _showSettingsDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'refresh',
                    size: 18,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 3.w),
                  Text('Refresh Results'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'settings',
                    size: 18,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 3.w),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'assignment',
                  size: 20,
                  color: _tabController.index == 0
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 2.w),
                Text('Results'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'analytics',
                  size: 20,
                  color: _tabController.index == 1
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 2.w),
                Text('Analytics'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    return Column(
      children: [
        ResultsSearchBar(
          searchQuery: _searchQuery,
          onSearchChanged: (query) => setState(() => _searchQuery = query),
          onClear: () => setState(() => _searchQuery = ''),
        ),
        ResultsFilterBar(
          selectedFilter: _selectedFilter,
          onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
          onDateFilter: _showDateRangeDialog,
          onScoreFilter: _showScoreRangeDialog,
        ),
        Expanded(
          child: _isLoading
              ? _buildLoadingIndicator()
              : _filteredExams.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshResults,
                      child: ListView.builder(
                        itemCount: _filteredExams.length,
                        itemBuilder: (context, index) {
                          final exam = _filteredExams[index];
                          return ExamResultsCard(
                            examData: exam,
                            onExport: () => _exportExamResults(exam),
                            onViewDetails: () => _viewExamAnalytics(exam),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          ResultsAnalyticsChart(
            examData: _examData,
            isPremium: _isPremium,
          ),
          if (_isPremium) ...[
            _buildOverallStats(),
            _buildTopPerformers(),
          ],
          SizedBox(height: 10.h), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    final totalAttempts =
        _examData.expand((exam) => exam['attempts'] as List).length;
    final completedAttempts = _examData
        .expand((exam) => exam['attempts'] as List)
        .where((attempt) =>
            (attempt as Map<String, dynamic>)['status'] == 'completed')
        .length;
    final averageScore = completedAttempts > 0
        ? _examData
                .expand((exam) => exam['attempts'] as List)
                .where((attempt) =>
                    (attempt as Map<String, dynamic>)['status'] == 'completed')
                .map((attempt) =>
                    (attempt as Map<String, dynamic>)['score'] as double)
                .fold(0.0, (sum, score) => sum + score) /
            completedAttempts
        : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Statistics',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Attempts',
                  totalAttempts.toString(),
                  'people',
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completedAttempts.toString(),
                  'check_circle',
                  AppTheme.lightTheme.colorScheme.tertiary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Avg Score',
                  '${averageScore.toStringAsFixed(1)}%',
                  'trending_up',
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            size: 24,
            color: color,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    final allAttempts = _examData
        .expand((exam) => exam['attempts'] as List)
        .where((attempt) =>
            (attempt as Map<String, dynamic>)['status'] == 'completed')
        .map((attempt) => attempt as Map<String, dynamic>)
        .toList();

    allAttempts
        .sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    final topPerformers = allAttempts.take(5).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'emoji_events',
                size: 24,
                color: Colors.amber,
              ),
              SizedBox(width: 3.w),
              Text(
                'Top Performers',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...topPerformers.asMap().entries.map((entry) {
            final index = entry.key;
            final performer = entry.value;
            return _buildPerformerItem(index + 1, performer);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPerformerItem(int rank, Map<String, dynamic> performer) {
    Color rankColor = rank == 1
        ? Colors.amber
        : rank == 2
            ? Colors.grey
            : Colors.brown;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: rankColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: rankColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performer['studentName'] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Score: ${performer['score']}% • Time: ${performer['timeTaken']}',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: rank <= 3 ? 'star' : 'trending_up',
            size: 20,
            color: rankColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading results...',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'assignment',
              size: 64,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            SizedBox(height: 3.h),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results found'
                  : 'No exam results yet',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Create an exam and students will start taking it',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 3.h),
              TextButton(
                onPressed: () => setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'all';
                }),
                child: Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showBulkExportDialog,
      icon: CustomIconWidget(
        iconName: 'download',
        size: 20,
        color: AppTheme.lightTheme.colorScheme.onPrimary,
      ),
      label: Text('Export All'),
    );
  }

  Future<void> _refreshResults() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
  }

  void _showDateRangeDialog() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    ).then((range) {
      if (range != null) {
        // Apply date filter
      }
    });
  }

  void _showScoreRangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Score Range Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select score range to filter results'),
            SizedBox(height: 2.h),
            // Score range slider would go here
            Text('0% - 100%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showBulkExportDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Options',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'table_chart',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              title: Text('Export as CSV'),
              subtitle: Text('Spreadsheet format for analysis'),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'picture_as_pdf',
                size: 24,
                color: Colors.red,
              ),
              title: Text('Export as PDF'),
              subtitle: Text('Formatted report for printing'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Results Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Auto-refresh results'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text('Show terminated attempts'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportExamResults(Map<String, dynamic> exam) {
    // Implementation for exporting specific exam results
  }

  void _viewExamAnalytics(Map<String, dynamic> exam) {
    // Implementation for viewing detailed exam analytics
  }

  void _exportAsCSV() {
    // Implementation for CSV export
  }

  void _exportAsPDF() {
    // Implementation for PDF export
  }
}
