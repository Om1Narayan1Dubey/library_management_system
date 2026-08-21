import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bg_scaffold.dart';
import '../login_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import '../../utils/top_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/api_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/books_provider.dart';
import '../../providers/members_provider.dart';
import '../../providers/borrow_history_provider.dart';
import '../../providers/daily_activity_provider.dart';

// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
// 🟩🟩🟩🟩🟩             MAIN LAYOUT                   🟩🟩🟩🟩🟩
// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩

final adminTabProvider = StateProvider<int>((ref) => 0);

Color getThemeColor(String role) {
  if (role == 'LIBRARIAN') {
    return const Color(0xFF00B894);
  }
  return LoginColors.accent;
}

class StaffHomeScreen extends ConsumerStatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  ConsumerState<StaffHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<StaffHomeScreen> {
  Future<void> _signOut() async {
    final navigator = Navigator.of(context);
    await ref.read(apiProvider).logout();
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: Text(
          'Sign Out',
          style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _signOut();
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(int currentIndex) {
    final user = ref.watch(currentUserProvider);
    final email = user?['email'] ?? '';

    switch (currentIndex) {
      case 0:
        return const DashboardView();
      case 1:
        return const BooksView();
      case 2:
        return MembersView(adminEmail: email);
      case 3:
        return const ReportsView();
      default:
        return const DashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(adminTabProvider);

    return BgScaffold(
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildUnifiedTabInterface(currentIndex)),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedTabInterface(int currentIndex) {
    const double tabHeight = 70.0;

    final user = ref.watch(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = getThemeColor(role);

    return Stack(
      children: [
        Positioned.fill(
          top: tabHeight - 5,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: LoginColors.cardBase,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA3B1C6).withValues(alpha: 2.0),
                  offset: const Offset(10, 10),
                  blurRadius: 24,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-15, -15),
                  blurRadius: 24,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildCurrentView(currentIndex),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 0,
          left: 24,
          right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTabItem(
                0,
                Icons.dashboard_rounded,
                'Dashboard',
                tabHeight,
                currentIndex,
                themeColor,
              ),
              _buildTabItem(
                1,
                Icons.menu_book_rounded,
                'Books',
                tabHeight,
                currentIndex,
                themeColor,
              ),
              _buildTabItem(
                2,
                Icons.people_rounded,
                'Members',
                tabHeight,
                currentIndex,
                themeColor,
              ),
              _buildTabItem(
                3,
                Icons.bar_chart_rounded,
                'Reports',
                tabHeight,
                currentIndex,
                themeColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(
    int index,
    IconData icon,
    String label,
    double height,
    int currentIndex,
    Color themeColor,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => ref.read(adminTabProvider.notifier).state = index,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height - 10,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: LoginColors.cardBase,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? themeColor
                  : LoginColors.textDark.withValues(alpha: 0.4),
              size: isSelected ? 22 : 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? themeColor
                    : LoginColors.textDark.withValues(alpha: 0.4),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final user = ref.watch(currentUserProvider);
    final username = user?['username'] ?? 'Admin';

    final role = user?['role'] ?? 'MEMBER';

    final themeColor = getThemeColor(role);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFA3B1C6),
            offset: Offset(6, 6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: LoginColors.cardBase,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                        offset: const Offset(3, 3),
                        blurRadius: 6,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-3, -3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shield_rounded,
                      color: themeColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role == 'LIBRARIAN' ? 'Librarian Panel' : 'Admin Panel',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: LoginColors.textDark.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        username,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 17,
                          color: LoginColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: $role',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _TopBarBtn(
            icon: Icons.logout_rounded,
            color: AppColors.error,
            onTap: _confirmSignOut,
          ),
        ],
      ),
    );
  }
}

class _TopBarBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _TopBarBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: color),
    ),
  );
}

// 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨
// 🟨🟨🟨🟨🟨              1. DASHBOARD VIEW                 🟨🟨🟨🟨🟨
// 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});
  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  int _selectedStatIndex = 0;

  List<FlSpot> _getRealChartData(int index, Map<String, dynamic> stats) {
    List<dynamic> rawData = [];
    switch (index) {
      case 0:
        rawData = stats['usersChart'] ?? [];
        break;
      case 1:
        rawData = stats['booksChart'] ?? [];
        break;
      case 2:
        rawData = stats['issuedChart'] ?? [];
        break;
      case 3:
        rawData = stats['overdueChart'] ?? [];
        break;
    }

    if (rawData.isEmpty) {
      return List.generate(60, (i) => FlSpot(i.toDouble(), 0));
    }

    return List.generate(rawData.length, (i) {
      return FlSpot(i.toDouble(), (rawData[i] as num).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    final user = ref.watch(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    return statsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: themeColor)),

      error: (err, stack) => Center(
        child: Text(
          'Failed to load dashboard data.',
          style: GoogleFonts.inter(color: AppColors.error),
        ),
      ),
      data: (stats) {
        final isMobile = MediaQuery.of(context).size.width < 850;
        Widget leftSideCards = Column(
          children: [
            _SelectableStatCard(
              title: 'Total Users',
              value: stats['totalUsers'].toString(),
              icon: Icons.group,
              color: themeColor,
              isSelected: _selectedStatIndex == 0,
              onTap: () => setState(() => _selectedStatIndex = 0),
            ),
            const SizedBox(height: 20),
            _SelectableStatCard(
              title: 'Total Books',
              value: stats['totalBooks'].toString(),
              icon: Icons.library_books,
              color: themeColor,
              isSelected: _selectedStatIndex == 1,
              onTap: () => setState(() => _selectedStatIndex = 1),
            ),
            const SizedBox(height: 20),
            _SelectableStatCard(
              title: 'Issued',
              value: stats['currentlyIssued'].toString(),
              icon: Icons.bookmark,
              color: themeColor,
              isSelected: _selectedStatIndex == 2,
              onTap: () => setState(() => _selectedStatIndex = 2),
            ),
            const SizedBox(height: 20),
            _SelectableStatCard(
              title: 'Overdue',
              value: stats['overdueCount'].toString(),
              icon: Icons.warning_amber,
              color: AppColors.error,
              isAlert: (stats['overdueCount'] ?? 0) > 0,
              isSelected: _selectedStatIndex == 3,
              onTap: () => setState(() => _selectedStatIndex = 3),
            ),
          ],
        );

        Widget rightSideChart = Container(
          decoration: BoxDecoration(
            color: LoginColors.cardBase,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                offset: const Offset(8, 8),
                blurRadius: 20,
              ),
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-8, -8),
                blurRadius: 20,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getChartTitle(),
                style: GoogleFonts.inter(
                  color: LoginColors.textDark.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LineChart(
                  LineChartData(
                    clipData: const FlClipData.all(),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => LoginColors.cardBase,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final date = DateTime.now().subtract(
                              Duration(days: 59 - spot.x.toInt()),
                            );
                            return LineTooltipItem(
                              '${date.day}/${date.month}/${date.year}\n',
                              GoogleFonts.inter(
                                color: LoginColors.textDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Count: ${spot.y.toInt()}',
                                  style: GoogleFonts.inter(
                                    color: _getChartColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: LoginColors.textDark.withValues(alpha: 0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 10,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.now().subtract(
                              Duration(days: 59 - value.toInt()),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: GoogleFonts.inter(
                                  color: LoginColors.textDark.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          interval: _getSmartInterval(_selectedStatIndex),
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max || value == meta.min) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              value.toInt().toString(),
                              style: GoogleFonts.inter(
                                color: LoginColors.textDark.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getRealChartData(_selectedStatIndex, stats),
                        isCurved: true,
                        preventCurveOverShooting: true,
                        color: _getChartColor(),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: _getChartColor().withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        if (isMobile) {
          return SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'System Overview',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      color: LoginColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                leftSideCards, // The 4 stat buttons
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 400, // The chart needs a fixed height on mobile
                  child: rightSideChart,
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'System Overview',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  color: LoginColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: leftSideCards),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: rightSideChart),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  double _getSmartInterval(int index) {
    switch (index) {
      case 0:
        return 200;
      case 1:
        return 1000;
      case 2:
        return 50;
      case 3:
        return 5;
      default:
        return 10;
    }
  }

  String _getChartTitle() {
    switch (_selectedStatIndex) {
      case 0:
        return 'User Signups (Last 60 Days)';
      case 1:
        return 'Books Added (Last 60 Days)';
      case 2:
        return 'Books Issued (Last 60 Days)';
      case 3:
        return 'Overdue Books (Last 60 Days)';
      default:
        return 'Data Trend';
    }
  }

  Color _getChartColor() {
    final role = ref.read(currentUserProvider)?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    if (_selectedStatIndex == 3) {
      return AppColors.error;
    }

    return themeColor;
  }
}

class _SelectableStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isAlert;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isAlert = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isAlert ? AppColors.error : color;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: LoginColors.cardBase,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                      offset: const Offset(6, 6),
                      blurRadius: 12,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-6, -6),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? displayColor.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? displayColor
                      : LoginColors.textDark.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.dmSerifDisplay(
                        color: LoginColors.textDark,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
// 🟦🟦🟦🟦🟦               2. BOOKS VIEW               🟦🟦🟦🟦🟦
// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦

class BooksView extends ConsumerStatefulWidget {
  const BooksView({super.key});

  @override
  ConsumerState<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends ConsumerState<BooksView> {
  bool _isSubmitting = false;

  int _selectedMenuIndex = 0;

  // ── CONTROLLERS (The Digital Pens) ──
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _copiesController = TextEditingController(
    text: "1",
  );

  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        ref.read(booksProvider.notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _categoryController.dispose();
    _copiesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(booksProvider.notifier).search(_searchController.text.trim());
    });
  }

  Future<void> _submitBook() async {
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _isbnController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty) {
      TopToast.show(context, 'All fields are required!', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    bool success = await ref
        .read(apiProvider)
        .addNewBook(
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          isbn: _isbnController.text.trim(),
          category: _categoryController.text.trim(),
          copies: int.tryParse(_copiesController.text) ?? 1,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        _titleController.clear();
        _authorController.clear();
        _isbnController.clear();
        _categoryController.clear();
        _copiesController.text = "1";

        TopToast.show(context, 'Book Added Successfully!');

        ref.invalidate(booksProvider);
      } else {
        TopToast.show(
          context,
          'Failed to add book to database.',
          isError: true,
        );
      }
    }
  }

  Future<void> _showDeleteBookDialog(Map<String, dynamic> book) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LoginColors.cardBase,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Book',
          style: GoogleFonts.dmSerifDisplay(color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${book['title']}"? This action cannot be undone.',
          style: GoogleFonts.inter(
            color: LoginColors.textDark.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: LoginColors.textDark.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              bool success = await ref.read(apiProvider).deleteBook(book['id']);

              if (success && mounted) {
                ref.invalidate(booksProvider);
                TopToast.show(context, 'Book deleted successfully.');
              } else if (mounted) {
                TopToast.show(context, 'Failed to delete book.', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditBookDialog(Map<String, dynamic> book) async {
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    final editTitleController = TextEditingController(text: book['title']);
    final editAuthorController = TextEditingController(text: book['author']);
    final editIsbnController = TextEditingController(text: book['isbn'] ?? '');
    final editCategoryController = TextEditingController(
      text: book['category'],
    );
    final editCopiesController = TextEditingController(
      text: (book['totalCopies'] ?? book['copies'] ?? 1).toString(),
    );

    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: LoginColors.cardBase,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Book Details',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22,
                        color: LoginColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Book Title',
                      Icons.book,
                      editTitleController,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Author Name',
                      Icons.person_outline,
                      editAuthorController,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'ISBN Number',
                      Icons.qr_code_2,
                      editIsbnController,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Category',
                      Icons.category_outlined,
                      editCategoryController,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Total Copies',
                      Icons.numbers,
                      editCopiesController,
                      isNumber: true,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSaving
                              ? null
                              : () => Navigator.pop(dialogCtx),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: LoginColors.textDark.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  setDialogState(() => isSaving = true);
                                  bool success = await ref
                                      .read(apiProvider)
                                      .updateBook(
                                        id: book['id'],
                                        title: editTitleController.text,
                                        author: editAuthorController.text,
                                        isbn: editIsbnController.text,
                                        category: editCategoryController.text,
                                        totalCopies:
                                            int.tryParse(
                                              editCopiesController.text,
                                            ) ??
                                            1,
                                      );

                                  setDialogState(() => isSaving = false);

                                  if (success && mounted) {
                                    Navigator.pop(dialogCtx);
                                    ref.invalidate(booksProvider);
                                    TopToast.show(
                                      context,
                                      'Book updated successfully!',
                                    );
                                  } else if (mounted) {
                                    TopToast.show(
                                      context,
                                      'Failed to update book.',
                                      isError: true,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Save Changes',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    return Container(
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.inter(
          color: LoginColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: LoginColors.textDark.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(icon, color: themeColor),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.02),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAddBookUi({required bool isMobile}) {
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    Widget formContent = SingleChildScrollView(
      physics: isMobile
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Book Title', Icons.book, _titleController),
          const SizedBox(height: 20),
          _buildTextField(
            'Author Name',
            Icons.person_outline,
            _authorController,
          ),
          const SizedBox(height: 20),
          _buildTextField('ISBN Number', Icons.qr_code_2, _isbnController),
          const SizedBox(height: 20),
          _buildTextField(
            'Category (e.g., Fiction, Science)',
            Icons.category_outlined,
            _categoryController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Number of Copies',
            Icons.numbers,
            _copiesController,
            isNumber: true,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Save Book to Database',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Text(
          'Add New Book',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 22,
            color: LoginColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the details to register a new book into the library system.',
          style: GoogleFonts.inter(
            color: LoginColors.textDark.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        isMobile ? formContent : Expanded(child: formContent),
      ],
    );
  }

  Widget _buildManageBooksUi({
    required bool isMobile,
    required bool isDeleteMode,
  }) {
    final booksAsync = ref.watch(booksProvider);

    final user = ref.watch(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    Widget listContent = booksAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: themeColor)),
      error: (err, stack) => Center(
        child: Text(
          'Failed to load books.',
          style: GoogleFonts.inter(color: AppColors.error),
        ),
      ),
      data: (books) {
        if (books.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No books found.',
                style: GoogleFonts.inter(
                  color: LoginColors.textDark.withValues(alpha: 0.4),
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          controller: isMobile ? null : _scrollController,
          physics: isMobile
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          shrinkWrap: isMobile,
          padding: const EdgeInsets.only(
            bottom: 20,
            top: 4,
            left: 16,
            right: 16,
          ),
          itemCount:
              books.length + (ref.read(booksProvider.notifier).hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == books.length) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(color: themeColor),
                ),
              );
            }

            final book = books[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LoginColors.cardBase,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA3B1C6).withValues(alpha: 0.4),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 10,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.book_rounded,
                      color: themeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDeleteMode
                              ? 'Delete Books (Danger Zone)'
                              : 'Library Database',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 14,
                            color: isDeleteMode ? AppColors.error : themeColor,
                          ),
                        ),
                        Text(
                          book['title'] ?? 'Unknown Title',
                          style: GoogleFonts.inter(
                            color: LoginColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Author: ${book['author'] ?? 'Unknown'}',
                          style: GoogleFonts.inter(
                            color: LoginColors.textDark.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                book['category'] ?? 'General',
                                style: GoogleFonts.inter(
                                  color: themeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Copies: ${book['available_copies'] ?? book['copies'] ?? 1} / ${book['total_copies'] ?? book['copies'] ?? 1}',
                                style: GoogleFonts.inter(
                                  color: LoginColors.textDark.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (role == 'ADMIN' || !isDeleteMode)
                    Container(
                      decoration: BoxDecoration(
                        color: isDeleteMode
                            ? AppColors.error.withValues(alpha: 0.1)
                            : themeColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isDeleteMode
                              ? Icons.delete_forever_rounded
                              : Icons.edit_rounded,
                          color: isDeleteMode ? AppColors.error : themeColor,
                          size: 20,
                        ),
                        onPressed: () {
                          if (isDeleteMode) {
                            _showDeleteBookDialog(book);
                          } else {
                            _showEditBookDialog(book);
                          }
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: [
        _buildTextField(
          'Search by title, author, or category...',
          Icons.search,
          _searchController,
        ),
        const SizedBox(height: 24),
        Text(
          'Library Database',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            color: LoginColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        isMobile ? listContent : Expanded(child: listContent),
      ],
    );
  }

  Widget _buildRightContent(bool isMobile) {
    switch (_selectedMenuIndex) {
      case 0:
        return _buildAddBookUi(isMobile: isMobile);
      case 1:
        return _buildManageBooksUi(isMobile: isMobile, isDeleteMode: false);
      case 2:
        return _buildManageBooksUi(isMobile: isMobile, isDeleteMode: true);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── MAIN BUILD METHOD ──
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    final user = ref.watch(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';

    Widget leftMenu = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Management',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            color: LoginColors.textDark,
          ),
        ),
        const SizedBox(height: 24),

        _buildMenuButton(
          0,
          'Add New Book',
          'Register a book',
          Icons.library_add_rounded,
        ),

        _buildMenuButton(
          1,
          'Manage Books',
          'Find & view details',
          Icons.search_rounded,
        ),

        if (role == 'ADMIN')
          _buildMenuButton(
            2,
            'Delete Books',
            'Admin access only',
            Icons.delete_forever_rounded,
            isDanger: true,
          ),
      ],
    );

    Widget mainContentArea = Container(
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
            offset: const Offset(8, 8),
            blurRadius: 20,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildRightContent(isMobile),
        ),
      ),
    );

    if (isMobile) {
      return SingleChildScrollView(
        controller: _scrollController,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [leftMenu, const SizedBox(height: 24), mainContentArea],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: leftMenu),
          const SizedBox(width: 32),
          Expanded(flex: 5, child: mainContentArea),
        ],
      ),
    );
  }

  // ── UI HELPER: MENU BUTTONS ──
  Widget _buildMenuButton(
    int index,
    String title,
    String subtitle,
    IconData icon, {
    bool isDanger = false,
  }) {
    final user = ref.watch(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    final isSelected = _selectedMenuIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => setState(() => _selectedMenuIndex = index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LoginColors.cardBase,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                      offset: const Offset(4, 4),
                      blurRadius: 10,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-4, -4),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDanger
                            ? AppColors.error.withValues(alpha: 0.2)
                            : themeColor.withValues(alpha: 0.2))
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? (isDanger ? AppColors.error : themeColor)
                      : LoginColors.textDark.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? (isDanger ? AppColors.error : themeColor)
                            : LoginColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪
// 🟪🟪🟪🟪🟪                 3. MEMBERS VIEW                🟪🟪🟪🟪🟪
// 🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪

class MembersView extends ConsumerStatefulWidget {
  final String adminEmail;
  const MembersView({super.key, required this.adminEmail});

  @override
  ConsumerState<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends ConsumerState<MembersView> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();

  // OTP Verification State
  bool _isAccountCreated = false;
  bool _isVerifyingOtp = false;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  final TextEditingController _addNameController = TextEditingController();
  final TextEditingController _addEmailController = TextEditingController();
  final TextEditingController _addPasswordController = TextEditingController();
  String _addRole = 'MEMBER';
  bool _isSubmitting = false;

  int _selectedMenuIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if ((_selectedMenuIndex == 0 || _selectedMenuIndex == 2) &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50) {
        ref.read(membersProvider.notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _addNameController.dispose();
    _addEmailController.dispose();
    _addPasswordController.dispose();
    for (var c in _otpControllers) c.dispose();
    for (var f in _otpFocusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    String otp = _otpControllers.map((c) => c.text.trim()).join();
    if (otp.length < 6) return;

    setState(() => _isVerifyingOtp = true);

    bool success = false;
    try {
      final email = _addEmailController.text.trim();
      await ref.read(apiProvider).verifyOtp(email: email, otpCode: otp);
      success = true;
    } catch (e) {
      success = false;
    }

    setState(() => _isVerifyingOtp = false);

    if (!mounted) return;
    if (success) {
      TopToast.show(context, 'Account Fully Verified and Activated!');

      _addNameController.clear();
      _addEmailController.clear();
      _addPasswordController.clear();
      for (var c in _otpControllers) {
        c.clear();
      }
      setState(() {
        _addRole = 'MEMBER';
        _isAccountCreated = false;
      });
      ref.invalidate(membersProvider);
    } else {
      for (var c in _otpControllers) {
        c.clear();
      }
      _otpFocusNodes[0].requestFocus();
      TopToast.show(context, 'Invalid OTP. Please try again.', isError: true);
    }
  }

  Future<void> _changeRoleDialog(Map<String, dynamic> member) async {
    String selectedRole = member['role'] ?? 'MEMBER';
    final isSelf = member['email'] == widget.adminEmail;
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    if (isSelf) {
      if (!context.mounted) return;
      TopToast.show(context, 'You cannot change your own role.', isError: true);

      return;
    }

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (sbContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AdminColors.dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              title: Text(
                'Change Role',
                style: GoogleFonts.dmSerifDisplay(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User: ${member['name']}',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wrap the list in a RadioGroup (fixes deprecation warnings!)
                  RadioGroup<String>(
                    groupValue: selectedRole,
                    onChanged: (val) =>
                        setDialogState(() => selectedRole = val!),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ['MEMBER', 'LIBRARIAN', 'ADMIN'].map((role) {
                        return RadioListTile<String>(
                          title: Text(
                            role,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          value: role,
                          // groupValue and onChanged are completely removed from here!
                          activeColor: themeColor,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: Colors.white60),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    if (selectedRole == member['role']) return;

                    try {
                      await ref
                          .read(apiProvider)
                          .updateUserRole(member['id'], selectedRole);
                      ref.invalidate(membersProvider);

                      if (!context.mounted) return;
                      TopToast.show(context, 'Role updated successfully!');
                    } catch (e) {
                      if (!context.mounted) return;
                      TopToast.show(
                        context,
                        'Failed to update role.',
                        isError: true,
                      );
                    }
                  },
                  child: Text(
                    'Update Role',
                    style: GoogleFonts.inter(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitNewMember() async {
    if (_addNameController.text.isEmpty ||
        _addEmailController.text.isEmpty ||
        _addPasswordController.text.isEmpty)
      return;

    setState(() => _isSubmitting = true);
    try {
      final email = _addEmailController.text.trim();

      await ref
          .read(apiProvider)
          .addMember(
            _addNameController.text.trim(),
            email,
            _addPasswordController.text,
            _addRole,
          );

      await ref.read(apiProvider).sendOtp(email);

      setState(() {
        _isSubmitting = false;
        _isAccountCreated = true;
      });

      if (!mounted) return;
      TopToast.show(
        context,
        'Account Created! OTP sent to email for activation.',
      );
    } on DioException catch (e) {
      setState(() => _isSubmitting = false);

      final msg = e.response?.data['error'] ?? 'Failed to add member.';

      if (!mounted) return;
      TopToast.show(context, msg, isError: true);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      TopToast.show(context, 'Error: $e', isError: true);
    }
  }

  Future<void> _deleteMember(int id, String name) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.dialogBg,
        title: Text(
          'Delete Member',
          style: GoogleFonts.dmSerifDisplay(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to permanently delete $name? This action cannot be undone.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(apiProvider).deleteMember(id);
                ref.invalidate(membersProvider);

                if (!mounted) return;
                TopToast.show(context, 'Member deleted successfully.');
              } catch (e) {
                if (!mounted) return;
                TopToast.show(
                  context,
                  'Failed to delete member.',
                  isError: true,
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMemberInfoDialog(Map<String, dynamic> member) async {
    showDialog(
      context: context,
      builder: (ctx) {
        final user = ref.read(currentUserProvider);
        final role = user?['role'] ?? 'MEMBER';
        final themeColor = role == 'LIBRARIAN'
            ? const Color(0xFF00B894)
            : AdminColors.purple;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color:
                  LoginColors.cardBase, // Must match the background perfectly
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3. NEUMORPHIC AVATAR
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: LoginColors.cardBase,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                        offset: const Offset(6, 6),
                        blurRadius: 12,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-6, -6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (member['name'] ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.dmSerifDisplay(
                      color: themeColor,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Member Details',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 24,
                    color: LoginColors.textDark,
                  ),
                ),
                const SizedBox(height: 28),

                // Data Rows (Using your existing _buildInfoRow helper!)
                _buildInfoRow(
                  Icons.person_rounded,
                  'Full Name',
                  member['name'] ?? 'N/A',
                ),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(
                  Icons.email_rounded,
                  'Email Address',
                  member['email'] ?? 'N/A',
                ),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(
                  Icons.phone_rounded,
                  'Mobile Number',
                  member['mobile'] ?? 'Not provided',
                ),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(
                  Icons.calendar_month_rounded,
                  'Date of Joining',
                  member['joined'] ?? 'N/A',
                ),

                const SizedBox(height: 36),

                // 4. NEUMORPHIC CLOSE BUTTON
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: LoginColors.cardBase,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                          offset: const Offset(6, 6),
                          blurRadius: 12,
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-6, -6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    return Row(
      children: [
        Icon(icon, color: themeColor.withValues(alpha: 0.7), size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: LoginColors.textDark.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: LoginColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(membersProvider.notifier).search(_searchController.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── 1. MEASURE THE SCREEN ──
    final isMobile = MediaQuery.of(context).size.width < 850;

    final user = ref.watch(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;
    // ── 2. THE MENU BUTTONS ──
    Widget menuButtons = Column(
      children: [
        _MemberActionCard(
          title: 'Search Members',
          subtitle: 'Find & view user details',
          icon: Icons.search_rounded,
          color: themeColor,
          isSelected: _selectedMenuIndex == 0,
          onTap: () => setState(() => _selectedMenuIndex = 0),
        ),
        const SizedBox(height: 16),
        _MemberActionCard(
          title: 'Add New Member',
          subtitle: 'Manually register a user',
          icon: Icons.person_add_rounded,
          color: themeColor,
          isSelected: _selectedMenuIndex == 1,
          onTap: () => setState(() => _selectedMenuIndex = 1),
        ),
        const SizedBox(height: 16),
        if (role == 'ADMIN')
          _MemberActionCard(
            title: 'Delete Member',
            subtitle: 'Admin access only',
            icon: Icons.person_remove_rounded,
            color: AppColors.error,
            isSelected: _selectedMenuIndex == 2,
            onTap: () => setState(() => _selectedMenuIndex = 2),
          ),
      ],
    );

    // ── 3. THE MAIN CONTENT AREA (Right Side on Desktop, Bottom on Mobile) ──
    Widget mainContentArea = Container(
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
            offset: const Offset(8, 8),
            blurRadius: 20,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildRightContent(isMobile),
        ),
      ),
    );

    // ── 4. THE RESPONSIVE ASSEMBLY ──

    if (isMobile) {
      return SingleChildScrollView(
        controller: _scrollController,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Member Management',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  color: LoginColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            menuButtons,
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minHeight: 500),
              child: mainContentArea,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            'Member Management',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: LoginColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: menuButtons),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: mainContentArea),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightContent(bool isMobile) {
    switch (_selectedMenuIndex) {
      case 0:
        return _buildListUi(isDeleteMode: false, isMobile: isMobile);
      case 1:
        return _buildAddMemberUi(isMobile: isMobile);
      case 2:
        return _buildListUi(isDeleteMode: true, isMobile: isMobile);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildListUi({required bool isDeleteMode, required bool isMobile}) {
    final membersAsync = ref.watch(membersProvider);

    final user = ref.watch(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    Widget listContent = membersAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: themeColor)),
      error: (err, stack) => Center(
        child: Text(
          'Failed to load members.',
          style: GoogleFonts.inter(color: AppColors.error),
        ),
      ),

      data: (members) {
        if (members.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No members match your criteria.',
                style: GoogleFonts.inter(
                  color: LoginColors.textDark.withValues(alpha: 0.4),
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          controller: isMobile ? null : _scrollController,
          physics: isMobile
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          shrinkWrap: isMobile,
          padding: const EdgeInsets.only(
            bottom: 20,
            top: 4,
            left: 15,
            right: 15,
          ),
          itemCount:
              members.length +
              (ref.read(membersProvider.notifier).hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == members.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: themeColor),
                ),
              );
            }
            final member = members[index];
            final isAdmin = member['role'] == 'ADMIN';
            final isSelf = member['email'] == widget.adminEmail;

            return MouseRegion(
              cursor: isDeleteMode
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
              child: GestureDetector(
                onTap: isDeleteMode
                    ? null
                    : () => _showMemberInfoDialog(member),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: LoginColors.cardBase,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA3B1C6).withValues(alpha: 0.4),
                        offset: const Offset(4, 4),
                        blurRadius: 10,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 10,
                      ),
                    ],
                    border: isDeleteMode && !isSelf
                        ? Border.all(
                            color: AppColors.error.withValues(alpha: 0.5),
                            width: 1.5,
                          )
                        : Border.all(color: Colors.white, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isAdmin
                            ? themeColor.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.05),
                        child: Text(
                          (member['name'] ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.dmSerifDisplay(
                            color: isAdmin
                                ? themeColor
                                : LoginColors.textDark.withValues(alpha: 0.7),
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8, // Space between name and badge
                              runSpacing: 6, // Vertical space if it wraps
                              children: [
                                Text(
                                  member['name'] ?? 'Unknown Account',
                                  style: GoogleFonts.inter(
                                    color: LoginColors.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                if (!isDeleteMode)
                                  GestureDetector(
                                    onTap: role == 'ADMIN'
                                        ? () => _changeRoleDialog(member)
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAdmin
                                            ? themeColor.withValues(alpha: 0.12)
                                            : Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            member['role'] ?? 'MEMBER',
                                            style: GoogleFonts.inter(
                                              color: isAdmin
                                                  ? themeColor
                                                  : LoginColors.textDark
                                                        .withValues(alpha: 0.7),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          if (role == 'ADMIN')
                                            Icon(
                                              Icons.edit_rounded,
                                              size: 12,
                                              color: isAdmin
                                                  ? LoginColors.accent
                                                  : LoginColors.textDark
                                                        .withValues(alpha: 0.5),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member['email'] ?? '',
                              style: GoogleFonts.inter(
                                color: LoginColors.textDark.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            if (!isDeleteMode) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Joined: ${member['joined'] ?? 'N/A'}',
                                style: GoogleFonts.inter(
                                  color: LoginColors.textDark.withValues(
                                    alpha: 0.4,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Delete mode right-side icon
                      if (isDeleteMode) ...[
                        const SizedBox(width: 12),
                        if (isSelf)
                          Text(
                            'Current User',
                            style: GoogleFonts.inter(
                              color: LoginColors.textDark.withValues(
                                alpha: 0.4,
                              ),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_forever_rounded,
                                color: AppColors.error.withValues(alpha: 0.9),
                                size: 20,
                              ),
                              onPressed: () =>
                                  _deleteMember(member['id'], member['name']),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    return Column(
      key: ValueKey(isDeleteMode ? 'delete_view' : 'search_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (role == 'ADMIN' || !isDeleteMode)
          Container(
            decoration: BoxDecoration(
              color: LoginColors.cardBase,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.05),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(
                color: LoginColors.textDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: GoogleFonts.inter(
                  color: LoginColors.textDark.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(Icons.search, color: themeColor),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.02),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDeleteMode ? AppColors.error : themeColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text(
          isDeleteMode
              ? 'Select a Member to Permanently Delete'
              : 'System Database Accounts',
          style: GoogleFonts.dmSerifDisplay(
            color: isDeleteMode ? AppColors.error : LoginColors.textDark,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),

        isMobile ? listContent : Expanded(child: listContent),
      ],
    );
  }

  Widget _buildAddMemberUi({required bool isMobile}) {
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    Widget formContent = SingleChildScrollView(
      physics: isMobile
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24, left: 4, right: 4, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isAccountCreated) ...[
            _buildTextField('Full Name', Icons.person, _addNameController),
            const SizedBox(height: 20),
            _buildTextField('Email Address', Icons.email, _addEmailController),
            const SizedBox(height: 20),
            _buildTextField(
              'Password',
              Icons.lock_outline,
              _addPasswordController,
              isObscure: true,
            ),
            const SizedBox(height: 24),

            Text(
              'Account Role',
              style: GoogleFonts.inter(
                color: LoginColors.textDark.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1.5,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _addRole,
                  dropdownColor: LoginColors.cardBase,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: LoginColors.textDark.withValues(alpha: 0.5),
                  ),
                  style: GoogleFonts.inter(
                    color: LoginColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  items: ['MEMBER', 'LIBRARIAN'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => _addRole = newValue!),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitNewMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  elevation: 0,
                  shadowColor: themeColor.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        'Create & Send OTP',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      color: themeColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Created',
                          style: GoogleFonts.inter(
                            color: themeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'OTP sent to ${_addEmailController.text}',
                          style: GoogleFonts.inter(
                            color: LoginColors.textDark.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Enter 6-Digit OTP to Activate',
              style: GoogleFonts.inter(
                color: LoginColors.textDark.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: GoogleFonts.inter(
                      color: LoginColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.02),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.05),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: themeColor, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5)
                        _otpFocusNodes[index + 1].requestFocus();
                      if (value.isEmpty && index > 0)
                        _otpFocusNodes[index - 1].requestFocus();
                      if (index == 5 && value.isNotEmpty) _handleVerifyOtp();
                    },
                  ),
                );
              }),
            ),
            if (_isVerifyingOtp)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Center(
                  child: Text(
                    'Verifying OTP...',
                    style: GoogleFonts.inter(
                      color: themeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  try {
                    await ref
                        .read(apiProvider)
                        .deleteUnverifiedUser(_addEmailController.text.trim());
                  } catch (_) {}

                  setState(() {
                    _isAccountCreated = false;
                    _isVerifyingOtp = false;
                    for (var c in _otpControllers) {
                      c.clear();
                    }
                  });
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
                label: Text(
                  'Wrong email? Cancel and go back',
                  style: GoogleFonts.inter(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // 2. MAIN LAYOUT ASSEMBLY
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Text(
          'Register New Account',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 22,
            color: LoginColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fill out the details to create the account. An OTP will be sent to activate it, Scroll down for Confirmation.',
          style: GoogleFonts.inter(
            color: LoginColors.textDark.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),

        isMobile ? formContent : Expanded(child: formContent),
      ],
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isObscure = false,
    bool enabled = true,
  }) {
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    return Container(
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        borderRadius: BorderRadius.circular(16),
        // Simulated inset shadow
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        enabled: enabled,
        style: GoogleFonts.inter(
          color: enabled
              ? LoginColors.textDark
              : LoginColors.textDark.withValues(alpha: 0.5),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: LoginColors.textDark.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            icon,
            color: enabled
                ? themeColor
                : LoginColors.textDark.withValues(alpha: 0.2),
          ),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.02),
          // Soft inner fill
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _MemberActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: LoginColors.cardBase,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                      offset: const Offset(5, 5),
                      blurRadius: 10,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-5, -5),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? color
                      : LoginColors.textDark.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧
// 🟧🟧🟧🟧🟧              4. REPORTS VIEW              🟧🟧🟧🟧🟧
// 🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key});

  @override
  ConsumerState<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> {
  int _selectedMenuIndex = 0;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_selectedMenuIndex == 1) {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50) {
          ref.read(borrowHistoryProvider.notifier).fetchMore();
        }
      }
    });
  }

  String _filterAction = 'ALL';
  String _filterSort = 'LATEST';
  DateTime _filterDate = DateTime.now();

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _dailySearchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _dailySearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showFilterDialog() async {
    String tempAction = _filterAction;
    String tempSort = _filterSort;
    DateTime tempDate = _filterDate;

    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.all(24),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: LoginColors.cardBase,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Logs',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 24,
                        color: LoginColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. DATE PICKER
                    Text(
                      'Select Date',
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: themeColor,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() => tempDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.05),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: themeColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${tempDate.day}/${tempDate.month}/${tempDate.year}",
                              style: GoogleFonts.inter(
                                color: LoginColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. TRANSACTION TYPE
                    Text(
                      'Transaction Type',
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: ['ALL', 'ISSUED', 'RETURNED'].map((action) {
                        final isSelected = tempAction == action;
                        return ChoiceChip(
                          label: Text(
                            action,
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.white
                                  : LoginColors.textDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: themeColor,
                          backgroundColor: Colors.black.withValues(alpha: 0.04),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide.none,
                          ),
                          onSelected: (_) =>
                              setDialogState(() => tempAction = action),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // 3. SORT ORDER
                    Text(
                      'Sort By Time',
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: ['LATEST', 'OLDEST'].map((sort) {
                        final isSelected = tempSort == sort;
                        return ChoiceChip(
                          label: Text(
                            sort,
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.white
                                  : LoginColors.textDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: themeColor,
                          backgroundColor: Colors.black.withValues(alpha: 0.04),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide.none,
                          ),
                          onSelected: (_) =>
                              setDialogState(() => tempSort = sort),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 36),

                    // 4. APPLY BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filterAction = tempAction;
                            _filterSort = tempSort;
                            _filterDate = tempDate;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showLogDetailsDialog(Map<String, dynamic> log) async {
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    final bool isIssue = log['action'] == 'ISSUED';
    final Color actionColor = isIssue ? themeColor : const Color(0xFF00B894);
    final double fine = (log['fine'] as num?)?.toDouble() ?? 0.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: LoginColors.cardBase,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: LoginColors.cardBase,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                        offset: const Offset(6, 6),
                        blurRadius: 12,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-6, -6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    isIssue
                        ? Icons.outbox_rounded
                        : Icons.move_to_inbox_rounded,
                    color: actionColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Transaction Details',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 22,
                    color: LoginColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: actionColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    log['action'] ?? 'UNKNOWN',
                    style: GoogleFonts.inter(
                      color: actionColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Data Rows
                _buildInfoRow(
                  Icons.book_rounded,
                  'Book Title',
                  log['book_title'] ?? 'N/A',
                ),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(
                  Icons.person_rounded,
                  'Member Name',
                  log['member_name'] ?? 'N/A',
                ),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(
                  Icons.email_rounded,
                  'Email Address',
                  log['email'] ?? 'N/A',
                ),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(
                  Icons.phone_rounded,
                  'Contact Number',
                  log['contact'] ?? 'N/A',
                ),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  'Issued Date',
                  log['issued_date'] ?? 'N/A',
                ),
                const Divider(height: 24, color: Colors.black12),

                _buildInfoRow(
                  Icons.event_available_rounded,
                  'Returned Date',
                  log['returned_date'] ?? 'Pending',
                  valueColor: log['returned_date'] == 'Pending'
                      ? AppColors.error
                      : LoginColors.textDark,
                ),

                // Show Fine only if it exists
                if (fine > 0) ...[
                  const Divider(height: 24, color: Colors.black12),
                  _buildInfoRow(
                    Icons.payments_rounded,
                    'Calculated Fine',
                    '₹${fine.toStringAsFixed(2)}',
                    valueColor: AppColors.error,
                  ),
                ],

                const SizedBox(height: 36),

                // Close Button
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: LoginColors.cardBase,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                          offset: const Offset(6, 6),
                          blurRadius: 12,
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-6, -6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: themeColor.withValues(alpha: 0.7), size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: LoginColors.textDark.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: valueColor ?? LoginColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyActivityUi({required bool isMobile}) {
    String? dateString =
        "${_filterDate.year}-${_filterDate.month.toString().padLeft(2, '0')}-${_filterDate.day.toString().padLeft(2, '0')}";

    final dailyAsync = ref.watch(dailyActivityProvider(dateString));

    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    return dailyAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: themeColor)),
      error: (err, stack) => Center(
        child: Text(
          'Failed to load daily activity.',
          style: GoogleFonts.inter(color: AppColors.error),
        ),
      ),
      data: (data) {
        final todayIssuesCount = data['todayIssues'] ?? 0;
        final todayReturnsCount = data['todayReturns'] ?? 0;
        final List<dynamic> allLogs = data['logs'] ?? [];

        final query = _dailySearchController.text.toLowerCase();
        List<dynamic> filteredLogs = allLogs.where((log) {
          final book = (log['book_title'] ?? '').toString().toLowerCase();
          final member = (log['member_name'] ?? '').toString().toLowerCase();
          final action = (log['action'] ?? '').toString();

          final matchesSearch = book.contains(query) || member.contains(query);
          final matchesAction =
              _filterAction == 'ALL' || action == _filterAction;
          return matchesSearch && matchesAction;
        }).toList();

        if (_filterSort == 'OLDEST') {
          filteredLogs = filteredLogs.reversed.toList();
        }

        Widget summaryCards = Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Today\'s Issues',
                todayIssuesCount.toString(),
                themeColor,
                Icons.outbox_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Today\'s Returns',
                todayReturnsCount.toString(),
                const Color(0xFF00B894),
                Icons.move_to_inbox_rounded,
              ),
            ),
          ],
        );

        Widget searchBar = Container(
          decoration: BoxDecoration(
            color: LoginColors.cardBase,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _dailySearchController,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.inter(
              color: LoginColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search logs by book or member...',
              hintStyle: GoogleFonts.inter(
                color: LoginColors.textDark.withValues(alpha: 0.4),
              ),
              prefixIcon: Icon(Icons.search, color: themeColor),
              suffixIcon: IconButton(
                icon: Icon(Icons.tune_rounded, color: themeColor),
                onPressed: _showFilterDialog,
              ),
              // Filter Icon from wireframe
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );

        Widget listContent = filteredLogs.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No activity found.',
                    style: GoogleFonts.inter(
                      color: LoginColors.textDark.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                physics: isMobile
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                shrinkWrap: isMobile,
                padding: const EdgeInsets.only(
                  bottom: 20,
                  top: 8,
                  left: 12,
                  right: 12,
                ),
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) {
                  final log = filteredLogs[index];
                  final isIssue = log['action'] == 'ISSUED';
                  final actionColor = isIssue
                      ? themeColor
                      : const Color(0xFF00B894);

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _showLogDetailsDialog(log),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: LoginColors.cardBase,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFA3B1C6,
                              ).withValues(alpha: 0.4),
                              offset: const Offset(3, 3),
                              blurRadius: 8,
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              offset: Offset(-3, -3),
                              blurRadius: 8,
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Row(
                          children: [
                            // Status Indicator Dot
                            Container(
                              width: 5,
                              height: 40,
                              decoration: BoxDecoration(
                                color: actionColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log['book_title'] ?? '',
                                    style: GoogleFonts.inter(
                                      color: LoginColors.textDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    log['member_name'] ?? '',
                                    style: GoogleFonts.inter(
                                      color: LoginColors.textDark.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: actionColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    log['action'] ?? '',
                                    style: GoogleFonts.inter(
                                      color: actionColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  log['time'] ?? '',
                                  style: GoogleFonts.inter(
                                    color: LoginColors.textDark.withValues(
                                      alpha: 0.5,
                                    ),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Text(
              'Daily Activity Logs',
              style: GoogleFonts.dmSerifDisplay(
                color: LoginColors.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            summaryCards,
            const SizedBox(height: 24),
            searchBar,
            const SizedBox(height: 16),
            isMobile ? listContent : Expanded(child: listContent),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      // 1. Slightly reduced padding so the text has more breathing room on mobile
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA3B1C6).withValues(alpha: 0.4),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: LoginColors.textDark.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color.withValues(alpha: 0.5), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: GoogleFonts.dmSerifDisplay(color: color, fontSize: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryUi({required bool isMobile}) {
    final historyAsync = ref.watch(borrowHistoryProvider);
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    Widget listContent = historyAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: themeColor)),

      error: (err, stack) => Center(
        child: Text(
          'Failed to load history.',
          style: GoogleFonts.inter(color: AppColors.error),
        ),
      ),

      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Text(
              'No borrow history found.',
              style: GoogleFonts.inter(
                color: LoginColors.textDark.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
          );
        }
        return ListView.builder(
          controller: isMobile ? null : _scrollController,
          physics: isMobile
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          shrinkWrap: isMobile,
          padding: const EdgeInsets.only(
            bottom: 20,
            top: 14,
            left: 14,
            right: 14,
          ),
          itemCount:
              history.length +
              (ref.read(borrowHistoryProvider.notifier).hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == history.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: themeColor),
                ),
              );
            }
            final record = history[index];
            final String status = record['status'] ?? 'ACTIVE';

            Color statusColor = themeColor;
            if (status == 'OVERDUE') statusColor = AppColors.error;
            if (status == 'RETURNED')
              statusColor = LoginColors.textDark.withValues(alpha: 0.4);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LoginColors.cardBase,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA3B1C6).withValues(alpha: 0.4),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 10,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record['title'] ?? 'Title N/A',
                          style: GoogleFonts.inter(
                            color: LoginColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // New field indicating WHO borrowed it
                        Text(
                          'Borrowed by: ${record['member_name'] ?? 'Unknown'}',
                          style: GoogleFonts.inter(
                            color: LoginColors.textDark.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Issued: ${record['issued_at']}',
                              style: GoogleFonts.inter(
                                color: LoginColors.textDark.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Due: ${record['due_date']}',
                              style: GoogleFonts.inter(
                                color: status == 'OVERDUE'
                                    ? AppColors.error
                                    : LoginColors.textDark.withValues(
                                        alpha: 0.6,
                                      ),
                                fontSize: 12,
                                fontWeight: status == 'OVERDUE'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        if (status == 'RETURNED' &&
                            record['returned_at'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Returned On: ${record['returned_at']}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF00B894),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                status,
                                style: GoogleFonts.inter(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if ((record['fine_amount'] as num?) != null &&
                                (record['fine_amount'] as num) > 0)
                              Text(
                                'Fine: ₹${record['fine_amount']}',
                                style: GoogleFonts.inter(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Text(
          'Global Borrow History',
          style: GoogleFonts.dmSerifDisplay(
            color: LoginColors.textDark,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'System-wide log of all issued and returned books.',
          style: GoogleFonts.inter(
            color: LoginColors.textDark.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        isMobile ? listContent : Expanded(child: listContent),
      ],
    );
  }

  Widget _buildRightContent(bool isMobile) {
    switch (_selectedMenuIndex) {
      case 0:
        return _buildDailyActivityUi(isMobile: isMobile);
      case 1:
        return _buildHistoryUi(isMobile: isMobile);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;
    final user = ref.read(currentUserProvider);
    final role = user?['role'] ?? 'MEMBER';
    final themeColor = role == 'LIBRARIAN'
        ? const Color(0xFF00B894)
        : AdminColors.purple;

    // LEFT MENU
    Widget menuButtons = Column(
      children: [
        _ReportActionCard(
          title: 'Daily Activity Logs',
          subtitle: 'Today\'s Issues & Returns',
          icon: Icons.today_rounded,
          color: themeColor,
          isSelected: _selectedMenuIndex == 0,
          onTap: () => setState(() => _selectedMenuIndex = 0),
        ),
        const SizedBox(height: 16),

        // 2. Borrow History is now Index 1
        _ReportActionCard(
          title: 'Borrow History Log',
          subtitle: 'View all system records',
          icon: Icons.history_rounded,
          color: themeColor,
          isSelected: _selectedMenuIndex == 1,
          onTap: () => setState(() => _selectedMenuIndex = 1),
        ),
      ],
    );

    // RIGHT CONTENT AREA
    Widget mainContentArea = Container(
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
            offset: const Offset(8, 8),
            blurRadius: 20,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildRightContent(isMobile),
        ),
      ),
    );

    // RESPONSIVE ASSEMBLY
    if (isMobile) {
      return SingleChildScrollView(
        controller: _scrollController,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Reports & Logs',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  color: LoginColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            menuButtons,
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minHeight: 500),
              child: mainContentArea,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            'Reports & Logs',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: LoginColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: menuButtons),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: mainContentArea),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReportActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: LoginColors.cardBase,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                      offset: const Offset(5, 5),
                      blurRadius: 10,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-5, -5),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? color
                      : LoginColors.textDark.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: LoginColors.textDark.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
