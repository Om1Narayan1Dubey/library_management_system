import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bg_scaffold.dart';
import '../login_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩
// 🟩🟩🟩🟩🟩             MAIN ADMIN LAYOUT             🟩🟩🟩🟩🟩
// 🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩🟩

class AdminHomeScreen extends StatefulWidget {
  final String username;
  final String email;

  const AdminHomeScreen({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _api = ApiService();
  int _selectedIndex = 0;

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);
    await _api.logout();
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

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardView();
      case 1:
        return const BooksView();
      case 2:
        return MembersView(adminEmail: widget.email);
      case 3:
        return const ReportsView();
      default:
        return const DashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BgScaffold(
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildUnifiedTabInterface()),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedTabInterface() {
    const double tabHeight = 70.0;

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
                  child: _buildCurrentView(),
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
              _buildTabItem(0, Icons.dashboard_rounded, 'Dashboard', tabHeight),
              _buildTabItem(1, Icons.menu_book_rounded, 'Books', tabHeight),
              _buildTabItem(2, Icons.people_rounded, 'Members', tabHeight),
              _buildTabItem(3, Icons.bar_chart_rounded, 'Reports', tabHeight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label, double height) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
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
                  ? LoginColors.accent
                  : LoginColors.textDark.withValues(alpha: 0.4),
              size: isSelected ? 22 : 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? LoginColors.accent
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: LoginColors.cardBase, // Neumorphic base color
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          // The classic Neumorphic double-shadow
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
                      // Inset-style shadow for the icon
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
                  child: const Center(
                    child: Icon(
                      Icons.shield_rounded,
                      color: LoginColors.accent,
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
                        'Admin Panel',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: LoginColors.textDark.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.username,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 17,
                          color: LoginColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: Admin',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: LoginColors.accent,
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

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String _errorMessage = '';

  int _selectedStatIndex = 0; // 0=Users, 1=Books, 2=Issued, 3=Overdue

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      if (mounted) setState(() => _isLoading = true);

      final data = await _api.getDashboardStats();

      if (mounted) {
        setState(() {
          _stats = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load dashboard data. Check connection.';
          _isLoading = false;
        });
      }
    }
  }


  List<FlSpot> _getRealChartData(int index) {
    if (_stats == null) return [const FlSpot(0, 0)];

    List<dynamic> rawData = [];
    switch (index) {
      case 0:
        rawData = _stats!['usersChart'] ?? [];
        break;
      case 1:
        rawData = _stats!['booksChart'] ?? [];
        break;
      case 2:
        rawData = _stats!['issuedChart'] ?? [];
        break;
      case 3:
        rawData = _stats!['overdueChart'] ?? [];
        break;
    }

    if (rawData.isEmpty) {
      return List.generate(60, (i) => FlSpot(i.toDouble(), 0));
    }

    return List.generate(rawData.length, (i) {
      return FlSpot(i.toDouble(), (rawData[i] as num).toDouble());
    });
  }

  double _getSmartInterval(int index) {
    if (_stats == null) return 10;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: LoginColors.accent),
      );
    if (_errorMessage.isNotEmpty) return Center(
        child: Text(_errorMessage, style: GoogleFonts.inter(color: AppColors.error),
        ),
      );

    // ── 1. MEASURE THE SCREEN ──
    final isMobile = MediaQuery.of(context).size.width < 850;

    // ── 2. THE CARDS MODULE ──
    Widget leftSideCards = Column(
      children: [
        _SelectableStatCard(
          title: 'Total Users',
          value: _stats?['totalUsers'].toString() ?? '0',
          icon: Icons.group,
          color: AdminColors.purple,
          isSelected: _selectedStatIndex == 0,
          onTap: () => setState(() => _selectedStatIndex = 0),
        ),
        const SizedBox(height: 20),
        _SelectableStatCard(
          title: 'Total Books',
          value: _stats?['totalBooks'].toString() ?? '0',
          icon: Icons.library_books,
          color: AdminColors.purple,
          isSelected: _selectedStatIndex == 1,
          onTap: () => setState(() => _selectedStatIndex = 1),
        ),
        const SizedBox(height: 20),
        _SelectableStatCard(
          title: 'Issued',
          value: _stats?['currentlyIssued'].toString() ?? '0',
          icon: Icons.bookmark,
          color: AdminColors.purple,
          isSelected: _selectedStatIndex == 2,
          onTap: () => setState(() => _selectedStatIndex = 2),
        ),
        const SizedBox(height: 20),
        _SelectableStatCard(
          title: 'Overdue',
          value: _stats?['overdueCount'].toString() ?? '0',
          icon: Icons.warning_amber,
          color: AppColors.error,
          isAlert: (_stats?['overdueCount'] ?? 0) > 0,
          isSelected: _selectedStatIndex == 3,
          onTap: () => setState(() => _selectedStatIndex = 3),
        ),
      ],
    );

    // ── 3. THE CHART MODULE ──
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
                            color: LoginColors.textDark.withValues(alpha: 0.5),
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
                    spots: _getRealChartData(_selectedStatIndex),
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

    // ── 4. THE RESPONSIVE MAGIC ──
    if (isMobile) {
      // MOBILE VIEW: Wrap the ENTIRE page in a scroll view!
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

    // DESKTOP VIEW: Side-by-side layout (No master scrolling needed)
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
    switch (_selectedStatIndex) {
      case 0:
        return AdminColors.purple;
      case 1:
        return AdminColors.purple;
      case 2:
        return AdminColors.purple;
      case 3:
        return AppColors.error;
      default:
        return LoginColors.accent;
    }
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
    // This allows the card to shrink or grow naturally based on its text size.
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

class BooksView extends StatefulWidget {
  const BooksView({super.key});

  @override
  State<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {
  // ── STATE VARIABLES ──
  final ApiService _apiService = ApiService();
  int _selectedMenuIndex = 0;
  bool _isSubmitting = false;
  bool _isLoadingBooks = true;

  // ── CONTROLLERS (The Digital Pens) ──
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _copiesController = TextEditingController(text: "1");

  // ── PAGINATION & SEARCH VARIABLES ──
  int _currentBookPage = 0;
  bool _isFetchingMore = false;
  bool _hasMoreBooks = true;
  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allBooks = [];
  List<dynamic> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();

    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        _fetchMoreBooks();
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
      _fetchBooks();
    });
  }

  // ── API CALL: FETCH BOOKS (PAGINATED) ──
  Future<void> _fetchBooks() async {
    setState(() {
      _isLoadingBooks = true;
      _currentBookPage = 0;
      _hasMoreBooks = true;
      _allBooks.clear();
      _filteredBooks.clear();
    });

    try {
      final data = await _apiService.getAllBooks(
          page: 0,
          size: 5,
          search: _searchController.text.trim()
      );

      if (mounted) {
        setState(() {
          _allBooks = data ?? [];
          _filteredBooks = List.from(_allBooks);
          _hasMoreBooks = (data?.length ?? 0) == 5;
          _isLoadingBooks = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBooks = false);
    }
  }

  Future<void> _fetchMoreBooks() async {
    if (_isFetchingMore || !_hasMoreBooks || _isLoadingBooks) return;

    setState(() => _isFetchingMore = true);

    try {
      _currentBookPage++;
      // Changed _api to _apiService
      final data = await _apiService.getAllBooks(
          page: _currentBookPage,
          size: 5,
          search: _searchController.text.trim()
      );

      if (mounted) {
        setState(() {
          if (data != null && data.isNotEmpty) {
            _allBooks.addAll(data);
            _filteredBooks = List.from(_allBooks);
            _hasMoreBooks = data.length == 5;
          } else {
            _hasMoreBooks = false;
          }
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingMore = false);
    }
  }

  // ── API CALL: SAVE BOOK ──
  Future<void> _submitBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and Author are required!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    bool success = await _apiService.addNewBook(
      title: _titleController.text,
      author: _authorController.text,
      isbn: _isbnController.text,
      category: _categoryController.text,
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book Added Successfully!'),
            backgroundColor: LoginColors.accent,
          ),
        );
        _fetchBooks(); // Refresh list after adding
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add book to database.'),
            backgroundColor: AppColors.error,
          ),
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
              setState(() => _isLoadingBooks = true);

              bool success = await _apiService.deleteBook(book['id']);

              if (success && mounted) {
                await _fetchBooks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Book deleted successfully.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (mounted) {
                setState(() => _isLoadingBooks = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete book.'),
                    backgroundColor: AppColors.error,
                  ),
                );
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
                            bool success = await _apiService.updateBook(
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
                              _fetchBooks();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Book updated successfully!',
                                  ),
                                  backgroundColor: LoginColors.accent,
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update book.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LoginColors.accent,
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

  // ── UI HELPER: TEXT FIELD ──
  Widget _buildTextField(
      String hint,
      IconData icon,
      TextEditingController controller, {
        bool isNumber = false,
      }) {
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
          prefixIcon: Icon(icon, color: LoginColors.accent),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.02),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: LoginColors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── UI: OPTION 1 (ADD NEW BOOK) ──
  Widget _buildAddBookUi({required bool isMobile}) {
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
                backgroundColor: LoginColors.accent,
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

  // ── UI: OPTION 1 (MANAGE BOOKS) ──
  Widget _buildManageBooksUi({
    required bool isMobile,
    required bool isDeleteMode,
  }) {
    Widget listContent = _isLoadingBooks
        ? const Center(
      child: CircularProgressIndicator(color: LoginColors.accent),
    )
        : _filteredBooks.isEmpty
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'No books found.',
          style: GoogleFonts.inter(
            color: LoginColors.textDark.withValues(alpha: 0.4),
          ),
        ),
      ),
    )
        : ListView.builder(
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
      itemCount: _filteredBooks.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {

        // Draw the loading spinner at the very bottom
        if (index == _filteredBooks.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: LoginColors.accent),
            ),
          );
        }

        final book = _filteredBooks[index];
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
                  color: AdminColors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.book_rounded,
                  color: AdminColors.purple,
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
                        color: isDeleteMode
                            ? AppColors.error
                            : LoginColors.accent,
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
                        color: LoginColors.textDark.withValues(
                          alpha: 0.6,
                        ),
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
                            color: LoginColors.accent.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book['category'] ?? 'General',
                            style: GoogleFonts.inter(
                              color: LoginColors.accent,
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
              Container(
                decoration: BoxDecoration(
                  color: isDeleteMode
                      ? AppColors.error.withValues(alpha: 0.1)
                      : LoginColors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isDeleteMode
                        ? Icons.delete_forever_rounded
                        : Icons.edit_rounded,
                    color: isDeleteMode
                        ? AppColors.error
                        : LoginColors.accent,
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

  // ── ROUTER: WHICH SCREEN TO SHOW? ──
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
                      : LoginColors.accent.withValues(alpha: 0.2))
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? (isDanger ? AppColors.error : LoginColors.accent)
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
                            ? (isDanger ? AppColors.error : LoginColors.accent)
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

class MembersView extends StatefulWidget {
  final String adminEmail;
  const MembersView({super.key, required this.adminEmail});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  int _currentMemberPage = 0;
  bool _isFetchingMore = false;
  bool _hasMoreMembers = true;
  final ScrollController _scrollController = ScrollController();

  // OTP Verification State
  bool _isAccountCreated = false;
  bool _isVerifyingOtp = false;
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController(),);
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Controllers for Add Member Form
  final TextEditingController _addNameController = TextEditingController();
  final TextEditingController _addEmailController = TextEditingController();
  final TextEditingController _addPasswordController = TextEditingController();
  String _addRole = 'MEMBER';
  bool _isSubmitting = false;

  int _selectedMenuIndex = 0;
  bool _isLoadingMembers = true;

  List<dynamic> _allMembers = [];
  List<dynamic> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if ((_selectedMenuIndex == 0 || _selectedMenuIndex == 2) &&
          _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        _fetchMoreMembers();
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

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoadingMembers = true;
      _currentMemberPage = 0;
      _hasMoreMembers = true;
      _allMembers.clear();
      _filteredMembers.clear();
    });

    try {
      final data = await _api.getAllMembers(
          page: 0,
          size: 5,
          search: _searchController.text.trim()
      );

      if (mounted) {
        setState(() {
          _allMembers = data ?? [];
          _filteredMembers = List.from(_allMembers);
          _hasMoreMembers = (data?.length ?? 0) == 5;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _fetchMoreMembers() async {
    if (_isFetchingMore || !_hasMoreMembers || _isLoadingMembers) return;

    setState(() => _isFetchingMore = true);

    try {
      _currentMemberPage++;
      final data = await _api.getAllMembers(
          page: _currentMemberPage,
          size: 5,
          search: _searchController.text.trim()
      );

      if (mounted) {
        setState(() {
          if (data != null && data.isNotEmpty) {
            _allMembers.addAll(data);
            _filteredMembers = List.from(_allMembers);
            _hasMoreMembers = data.length == 5;
          } else {
            _hasMoreMembers = false;
          }
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingMore = false);
    }
  }


  Future<void> _handleVerifyOtp() async {
    String otp = _otpControllers.map((c) => c.text.trim()).join();
    if (otp.length < 6) return;

    setState(() => _isVerifyingOtp = true);

    bool success = false;
    try {
      final email = _addEmailController.text.trim();
      await _api.verifyOtp(email: email, otpCode: otp);
      success = true;
    } catch (e) {
      success = false;
    }

    setState(() => _isVerifyingOtp = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account Fully Verified and Activated!'),
          backgroundColor: AdminColors.purple,
        ),
      );

      // Reset everything for the next user
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
      await _fetchMembers(); // Refresh the list
    } else {
      for (var c in _otpControllers) {
        c.clear();
      }
      _otpFocusNodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _changeRoleDialog(Map<String, dynamic> member) async {
    String selectedRole = member['role'] ?? 'MEMBER';
    final isSelf = member['email'] == widget.adminEmail;

    if (isSelf) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot change your own role.'),
          backgroundColor: AppColors.error,
        ),
      );
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
                          activeColor: AdminColors.purple,
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
                      await _api.updateUserRole(member['id'], selectedRole);
                      await _fetchMembers();

                      // Using context.mounted fixes the async linter warning!
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Role updated successfully!'),
                          backgroundColor: AdminColors.purple,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update role.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Update Role',
                    style: GoogleFonts.inter(
                      color: AdminColors.purple,
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

      // 1. Create the user in the database FIRST (they are unverified)
      await _api.addMember(
        _addNameController.text,
        email,
        _addPasswordController.text,
        _addRole,
      );

      // 2. NOW send the OTP (The backend will successfully find the user!)
      await _api.sendOtp(email);

      setState(() {
        _isSubmitting = false;
        _isAccountCreated = true; // This switches the UI to show the OTP boxes
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account Created! OTP sent to email for activation.'),
          backgroundColor: AdminColors.purple,
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
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
                await _api.deleteMember(id);
                await _fetchMembers(); // Refresh the list

                if (!mounted) return; // <--- Prevents async crash
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Member deleted successfully.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } catch (e) {
                if (!mounted) return; // <--- Prevents async crash
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete member.'),
                    backgroundColor: AppColors.error,
                  ),
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

// ── UI: NEUMORPHIC MEMBER INFO DIALOG ──
  Future<void> _showMemberInfoDialog(Map<String, dynamic> member) async {
    showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.all(24),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: LoginColors.cardBase, // Must match the background perfectly
                borderRadius: BorderRadius.circular(32),

              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3. NEUMORPHIC AVATAR
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: LoginColors.cardBase,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: 0.5), offset: const Offset(6, 6), blurRadius: 12),
                        const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text((member['name'] ?? 'U')[0].toUpperCase(), style: GoogleFonts.dmSerifDisplay(color: LoginColors.accent, fontSize: 32)),
                  ),
                  const SizedBox(height: 20),
                  Text('Member Details', style: GoogleFonts.dmSerifDisplay(fontSize: 24, color: LoginColors.textDark)),
                  const SizedBox(height: 28),

                  // Data Rows (Using your existing _buildInfoRow helper!)
                  _buildInfoRow(Icons.person_rounded, 'Full Name', member['name'] ?? 'N/A'),
                  const Divider(height: 24, color: Colors.black12),

                  _buildInfoRow(Icons.email_rounded, 'Email Address', member['email'] ?? 'N/A'),
                  const Divider(height: 24, color: Colors.black12),

                  _buildInfoRow(Icons.phone_rounded, 'Mobile Number', member['mobile'] ?? 'Not provided'),
                  const Divider(height: 24, color: Colors.black12),

                  _buildInfoRow(Icons.calendar_month_rounded, 'Date of Joining', member['joined'] ?? 'N/A'),

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
                          BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: 0.5), offset: const Offset(6, 6), blurRadius: 12),
                          const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text('Close', style: GoogleFonts.inter(color: LoginColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  // Small helper widget just for the dialog rows
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: LoginColors.accent.withValues(alpha: 0.7), size: 20),
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
    // If the user is still typing, cancel the previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new 500ms timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Once the user stops typing for half a second, fetch Page 0 with the search query!
      _fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── 1. MEASURE THE SCREEN ──
    final isMobile = MediaQuery.of(context).size.width < 850;

    // ── 2. THE MENU BUTTONS ──
    Widget menuButtons = Column(
      children: [
        _MemberActionCard(
          title: 'Search Members',
          subtitle: 'Find & view user details',
          icon: Icons.search_rounded,
          color: LoginColors.accent,
          isSelected: _selectedMenuIndex == 0,
          onTap: () => setState(() => _selectedMenuIndex = 0),
        ),
        const SizedBox(height: 16),
        _MemberActionCard(
          title: 'Add New Member',
          subtitle: 'Manually register a user',
          icon: Icons.person_add_rounded,
          color: LoginColors.accent,
          isSelected: _selectedMenuIndex == 1,
          onTap: () => setState(() => _selectedMenuIndex = 1),
        ),
        const SizedBox(height: 16),
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
      // MOBILE VIEW: Wrap EVERYTHING (including the title) in the ScrollView
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

    // DESKTOP VIEW: Keep the title fixed at the top, and put the content side-by-side
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
    if (_isLoadingMembers)
      return const Center(
        child: CircularProgressIndicator(color: LoginColors.accent),
      );

    // ── ISOLATE THE LISTVIEW ──
    Widget listContent = _filteredMembers.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No members match your criteria.',
                style: GoogleFonts.inter(
                  color: LoginColors.textDark.withValues(alpha: 0.4),
                ),
              ),
            ),
          )
        : ListView.builder(
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
            itemCount: _filteredMembers.length+ (_isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _filteredMembers.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator(color: LoginColors.accent)),
                );
              }
              final member = _filteredMembers[index];
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
                              ? LoginColors.accent.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.05),
                          child: Text(
                            (member['name'] ?? 'U')[0].toUpperCase(),
                            style: GoogleFonts.dmSerifDisplay(
                              color: isAdmin
                                  ? LoginColors.accent
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
                              // 1. Wrap automatically drops the badge to the next line if space runs out!
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
                                      onTap: () => _changeRoleDialog(member),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isAdmin
                                              ? LoginColors.accent.withValues(
                                                  alpha: 0.12,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              member['role'] ?? 'MEMBER',
                                              style: GoogleFonts.inter(
                                                color: isAdmin
                                                    ? LoginColors.accent
                                                    : LoginColors.textDark
                                                          .withValues(
                                                            alpha: 0.7,
                                                          ),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
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
                              // 2. Added ellipsis so emails smoothly truncate instead of stacking vertically
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

                              // 3. Moved the joined date to the main column for maximum horizontal breathing room
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

    return Column(
      key: ValueKey(isDeleteMode ? 'delete_view' : 'search_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: [
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
              prefixIcon: const Icon(Icons.search, color: LoginColors.accent),
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
                  color: isDeleteMode ? AppColors.error : LoginColors.accent,
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

  // ── Block 3: Add New Member Form (With Scroll & OTP) ──
  Widget _buildAddMemberUi({required bool isMobile}) {
    // 1. ISOLATE THE FORM CONTENT (Input fields + Button)
    Widget formContent = SingleChildScrollView(
      physics: isMobile
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      // We add padding inside the scroll view so the shadow/button has room at the bottom.
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
                  items: ['MEMBER', 'LIBRARIAN', 'ADMIN'].map((String value) {
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
                  backgroundColor: LoginColors.accent,
                  elevation: 0,
                  shadowColor: LoginColors.accent.withValues(alpha: 0.5),
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
            // The OTP Success UI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: LoginColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: LoginColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: LoginColors.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: LoginColors.accent,
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
                            color: LoginColors.accent,
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
                        borderSide: const BorderSide(
                          color: LoginColors.accent,
                          width: 2,
                        ),
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
                      color: LoginColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  // Updated helper to accept an 'enabled' parameter
  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isObscure = false,
    bool enabled = true,
  }) {
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
                ? LoginColors.accent
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
            borderSide: const BorderSide(color: LoginColors.accent, width: 1.5),
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

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  int _selectedMenuIndex = 0;

  Timer? _debounce;


  bool _isLoadingHistory = true;
  List<dynamic> _borrowHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchGlobalHistory();
    _fetchDailyActivity();
    _dailySearchController.addListener(_filterDailyLogs);

    _scrollController.addListener(() {
      if (_selectedMenuIndex == 1) {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
          _fetchMoreHistory();
        }
      }
    });
  }

  String _filterAction = 'ALL';
  String _filterSort = 'LATEST';
  DateTime _filterDate = DateTime.now();

  // ── PAGINATION VARIABLES ──
  int _currentHistoryPage = 0;
  bool _isFetchingMore = false;
  bool _hasMoreHistory = true;
  final ScrollController _scrollController = ScrollController();

  // ── NEW: DAILY ACTIVITY VARIABLES ──
  bool _isLoadingDaily = true;
  int _todayIssuesCount = 0;
  int _todayReturnsCount = 0;
  List<dynamic> _allDailyLogs = [];
  List<dynamic> _filteredDailyLogs = [];
  final TextEditingController _dailySearchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _dailySearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── SEARCH & FILTER LOGIC ──
  void _filterDailyLogs() {
    // If the user is still typing, cancel the old timer.
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {

      final query = _dailySearchController.text.toLowerCase();
      setState(() {
        _filteredDailyLogs = _allDailyLogs.where((log) {
          final book = (log['book_title'] ?? '').toString().toLowerCase();
          final member = (log['member_name'] ?? '').toString().toLowerCase();
          final action = (log['action'] ?? '').toString();

          final matchesSearch = book.contains(query) || member.contains(query);
          final matchesAction = _filterAction == 'ALL' || action == _filterAction;

          return matchesSearch && matchesAction;
        }).toList();

        if (_filterSort == 'OLDEST') {
          _filteredDailyLogs = _filteredDailyLogs.reversed.toList();
        }
      });
    });
  }

  Future<void> _fetchDailyActivity() async {
    setState(() => _isLoadingDaily = true);

    try {
      final ApiService api = ApiService();
      final data = await api.getDailyActivityLogs();

      if (data != null && mounted) {
        setState(() {
          // Map the real database counts
          _todayIssuesCount = data['todayIssues'] ?? 0;
          _todayReturnsCount = data['todayReturns'] ?? 0;

          // Map the real database logs
          final List<dynamic> realLogs = data['logs'] ?? [];

          _allDailyLogs = realLogs;
          _filteredDailyLogs = realLogs;
          _isLoadingDaily = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDaily = false);
        debugPrint('Error loading daily activity: $e');
      }
    }
  }

  // Fetches the very first batch (Page 0)
  Future<void> _fetchGlobalHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _currentHistoryPage = 0;
      _hasMoreHistory = true;
      _borrowHistory.clear();
    });

    try {
      final ApiService api = ApiService();
      final data = await api.getGlobalBorrowHistory(page: 0, size: 5);

      if (mounted) {
        setState(() {
          _borrowHistory = data ?? [];
          _hasMoreHistory = (data?.length ?? 0) == 5;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _fetchMoreHistory() async {
    if (_isFetchingMore || !_hasMoreHistory || _isLoadingHistory) return;

    setState(() => _isFetchingMore = true);

    try {
      _currentHistoryPage++;
      final ApiService api = ApiService();
      final newData = await api.getGlobalBorrowHistory(page: _currentHistoryPage, size: 5);

      if (mounted) {
        setState(() {
          if (newData != null && newData.isNotEmpty) {
            _borrowHistory.addAll(newData);
            _hasMoreHistory = newData.length == 5;
          } else {
            _hasMoreHistory = false;
          }
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingMore = false);
    }
  }

  // ── UI: NEUMORPHIC FILTER DIALOG ──
  Future<void> _showFilterDialog() async {
    String tempAction = _filterAction;
    String tempSort = _filterSort;
    DateTime tempDate = _filterDate;

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
                        Text('Filter Logs', style: GoogleFonts.dmSerifDisplay(fontSize: 24, color: LoginColors.textDark)),
                        const SizedBox(height: 24),

                        // 1. DATE PICKER
                        Text('Select Date', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              builder: (context, child) => Theme(
                                data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: LoginColors.accent)),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setDialogState(() => tempDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.5)
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: LoginColors.accent, size: 20),
                                const SizedBox(width: 12),
                                Text("${tempDate.day}/${tempDate.month}/${tempDate.year}", style: GoogleFonts.inter(color: LoginColors.textDark, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. TRANSACTION TYPE
                        Text('Transaction Type', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: ['ALL', 'ISSUED', 'RETURNED'].map((action) {
                            final isSelected = tempAction == action;
                            return ChoiceChip(
                              label: Text(action, style: GoogleFonts.inter(color: isSelected ? Colors.white : LoginColors.textDark, fontSize: 12, fontWeight: FontWeight.bold)),
                              selected: isSelected,
                              selectedColor: LoginColors.accent,
                              backgroundColor: Colors.black.withValues(alpha: 0.04),
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                              onSelected: (_) => setDialogState(() => tempAction = action),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // 3. SORT ORDER
                        Text('Sort By Time', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: ['LATEST', 'OLDEST'].map((sort) {
                            final isSelected = tempSort == sort;
                            return ChoiceChip(
                              label: Text(sort, style: GoogleFonts.inter(color: isSelected ? Colors.white : LoginColors.textDark, fontSize: 12, fontWeight: FontWeight.bold)),
                              selected: isSelected,
                              selectedColor: LoginColors.accent,
                              backgroundColor: Colors.black.withValues(alpha: 0.04),
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                              onSelected: (_) => setDialogState(() => tempSort = sort),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 36),

                        // 4. APPLY BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Save selections back to the main state and run filter!
                              setState(() {
                                _filterAction = tempAction;
                                _filterSort = tempSort;
                                _filterDate = tempDate;
                              });
                              _filterDailyLogs();
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LoginColors.accent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('Apply Filters', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  // ── UI: NEUMORPHIC LOG DETAILS DIALOG ──
  Future<void> _showLogDetailsDialog(Map<String, dynamic> log) async {
    final bool isIssue = log['action'] == 'ISSUED';
    final Color actionColor = isIssue ? LoginColors.accent : const Color(0xFF00B894);
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
                            blurRadius: 12
                        ),
                        const BoxShadow(
                            color: Colors.white,
                            offset: Offset(-6, -6),
                            blurRadius: 12
                        ),
                      ],
                    ),
                    child: Icon(isIssue ? Icons.outbox_rounded : Icons.move_to_inbox_rounded, color: actionColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text('Transaction Details', style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: LoginColors.textDark)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: actionColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(log['action'] ?? 'UNKNOWN', style: GoogleFonts.inter(color: actionColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 28),

                  // Data Rows
                  _buildInfoRow(Icons.book_rounded, 'Book Title', log['book_title'] ?? 'N/A'),
                  const Divider(height: 24, color: Colors.black12),

                  _buildInfoRow(Icons.person_rounded, 'Member Name', log['member_name'] ?? 'N/A'),
                  const Divider(height: 24, color: Colors.black12),

                  _buildInfoRow(Icons.email_rounded, 'Email Address', log['email'] ?? 'N/A'),
                  const Divider(height: 24, color: Colors.black12),

                  _buildInfoRow(Icons.phone_rounded, 'Contact Number', log['contact'] ?? 'N/A'),
                  const Divider(height: 24, color: Colors.black12),

                  _buildInfoRow(Icons.calendar_today_rounded, 'Issued Date', log['issued_date'] ?? 'N/A'),
                  const Divider(height: 24, color: Colors.black12),

                  _buildInfoRow(
                      Icons.event_available_rounded,
                      'Returned Date',
                      log['returned_date'] ?? 'Pending',
                      valueColor: log['returned_date'] == 'Pending' ? AppColors.error : LoginColors.textDark
                  ),

                  // Show Fine only if it exists
                  if (fine > 0) ...[
                    const Divider(height: 24, color: Colors.black12),
                    _buildInfoRow(Icons.payments_rounded, 'Calculated Fine', '₹${fine.toStringAsFixed(2)}', valueColor: AppColors.error),
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
                          BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: 0.5), offset: const Offset(6, 6), blurRadius: 12),
                          const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text('Close', style: GoogleFonts.inter(color: LoginColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  // Small helper widget for the dialog rows
  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: LoginColors.accent.withValues(alpha: 0.7), size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.inter(color: valueColor ?? LoginColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }


  // ── UI: DAILY ACTIVITY LOGS (From Wireframe) ──
  Widget _buildDailyActivityUi({required bool isMobile}) {
    if (_isLoadingDaily) return const Center(child: CircularProgressIndicator(color: LoginColors.accent));

    // 1. The Summary Cards (Top Row)
    Widget summaryCards = Row(
      children: [
        Expanded(child: _buildSummaryCard('Today\'s Issues', _todayIssuesCount.toString(), LoginColors.accent, Icons.outbox_rounded)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard('Today\'s Returns', _todayReturnsCount.toString(), const Color(0xFF00B894), Icons.move_to_inbox_rounded)),
      ],
    );

    // 2. The Search Bar
    Widget searchBar = Container(
      decoration: BoxDecoration(
        color: LoginColors.cardBase, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
      ),
      child: TextField(
        controller: _dailySearchController,
        style: GoogleFonts.inter(color: LoginColors.textDark, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search logs by book or member...',
          hintStyle: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.4)),
          prefixIcon: const Icon(Icons.search, color: LoginColors.accent),
          suffixIcon: IconButton(icon: const Icon(Icons.tune_rounded, color: LoginColors.accent), onPressed:_showFilterDialog,), // Filter Icon from wireframe
          filled: true, fillColor: Colors.black.withValues(alpha: 0.02),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );

    // 3. The List View
    Widget listContent = _filteredDailyLogs.isEmpty
        ? Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text('No activity found.', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.4)))))
        : ListView.builder(
      physics: isMobile ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      shrinkWrap: isMobile,
      padding: const EdgeInsets.only(bottom: 20, top: 8, left: 12, right: 12),
      itemCount: _filteredDailyLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredDailyLogs[index];
        final isIssue = log['action'] == 'ISSUED';
        final actionColor = isIssue ? LoginColors.accent : const Color(0xFF00B894);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _showLogDetailsDialog(log),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LoginColors.cardBase, borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: 0.4), offset: const Offset(3, 3), blurRadius: 8),
                  const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 8),
                ],
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Row(
                children: [
                  // Status Indicator Dot
                  Container(width: 5, height: 40, decoration: BoxDecoration(color: actionColor, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log['book_title'] ?? '', style: GoogleFonts.inter(color: LoginColors.textDark, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(log['member_name'] ?? '', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.6), fontSize: 13)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: actionColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(log['action'] ?? '', style: GoogleFonts.inter(color: actionColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 6),
                      Text(log['time'] ?? '', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.5), fontSize: 11)),
                    ],
                  )
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
        Text('Daily Activity Logs', style: GoogleFonts.dmSerifDisplay(color: LoginColors.textDark, fontSize: 20)),
        const SizedBox(height: 16),
        summaryCards,
        const SizedBox(height: 24),
        searchBar,
        const SizedBox(height: 16),
        isMobile ? listContent : Expanded(child: listContent),
      ],
    );
  }

  // Helper Widget for the Top Cards
  Widget _buildSummaryCard(String title, String count, Color color, IconData icon) {
    return Container(
      // 1. Slightly reduced padding so the text has more breathing room on mobile
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.cardBase, borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: 0.4), offset: const Offset(4, 4), blurRadius: 10),
          const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
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
                      fontWeight: FontWeight.bold
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
          Text(count, style: GoogleFonts.dmSerifDisplay(color: color, fontSize: 32)),
        ],
      ),
    );
  }


  // ── UI: THE BORROW HISTORY LOG (Imported from Members) ──
  Widget _buildHistoryUi({required bool isMobile}) {
    if (_isLoadingHistory) return const Center(child: CircularProgressIndicator(color: LoginColors.accent));

    Widget listContent = _borrowHistory.isEmpty
        ? Center(child: Text('No borrow history found.', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.4), fontSize: 13)))
        : ListView.builder(
      physics: isMobile ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      shrinkWrap: isMobile,
      padding: const EdgeInsets.only(bottom: 20, top: 14, left: 14, right: 14),
      itemCount: _borrowHistory.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _borrowHistory.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: LoginColors.accent)),
          );
        }
        final record = _borrowHistory[index];
        final String status = record['status'] ?? 'ACTIVE';

        Color statusColor = LoginColors.accent;
        if (status == 'OVERDUE') statusColor = AppColors.error;
        if (status == 'RETURNED') statusColor = LoginColors.textDark.withValues(alpha: 0.4);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LoginColors.cardBase,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: 0.4), offset: const Offset(4, 4), blurRadius: 10),
              const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
            ],
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.menu_book_rounded, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record['title'] ?? 'Title N/A', style: GoogleFonts.inter(color: LoginColors.textDark, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    // New field indicating WHO borrowed it
                    Text('Borrowed by: ${record['member_name'] ?? 'Unknown'}', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.6), fontSize: 13)),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 12, runSpacing: 4,
                      children: [
                        Text('Issued: ${record['issued_at']}', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.6), fontSize: 12)),
                        Text('Due: ${record['due_date']}', style: GoogleFonts.inter(
                            color: status == 'OVERDUE' ? AppColors.error : LoginColors.textDark.withValues(alpha: 0.6),
                            fontSize: 12, fontWeight: status == 'OVERDUE' ? FontWeight.bold : FontWeight.normal
                        )),
                      ],
                    ),
                    if (status == 'RETURNED' && record['returned_at'] != null) ...[
                      const SizedBox(height: 4),
                      Text('Returned On: ${record['returned_at']}', style: GoogleFonts.inter(color: const Color(0xFF00B894), fontSize: 12, fontWeight: FontWeight.w600)),
                    ],

                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12, crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withValues(alpha: 0.2))
                          ),
                          child: Text(status, style: GoogleFonts.inter(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        if ((record['fine_amount'] as num?) != null && (record['fine_amount'] as num) > 0)
                          Text('Fine: ₹${record['fine_amount']}', style: GoogleFonts.inter(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Text('Global Borrow History', style: GoogleFonts.dmSerifDisplay(color: LoginColors.textDark, fontSize: 20)),
        const SizedBox(height: 4),
        Text('System-wide log of all issued and returned books.', style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.6), fontSize: 13)),
        const SizedBox(height: 24),
        isMobile ? listContent : Expanded(child: listContent),
      ],
    );
  }

  // ── ROUTER ──
  Widget _buildRightContent(bool isMobile) {
    switch (_selectedMenuIndex) {
      case 0: return _buildDailyActivityUi(isMobile: isMobile);
      case 1: return _buildHistoryUi(isMobile: isMobile);
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    // LEFT MENU
    Widget menuButtons = Column(
      children: [
        // 1. Daily Activity is now Index 0
        _ReportActionCard(
            title: 'Daily Activity Logs', subtitle: 'Today\'s Issues & Returns',
            icon: Icons.today_rounded, color: LoginColors.accent,
            isSelected: _selectedMenuIndex == 0, onTap: () => setState(() => _selectedMenuIndex = 0)
        ),
        const SizedBox(height: 16),

        // 2. Borrow History is now Index 1
        _ReportActionCard(
            title: 'Borrow History Log', subtitle: 'View all system records',
            icon: Icons.history_rounded, color: LoginColors.accent,
            isSelected: _selectedMenuIndex == 1, onTap: () => setState(() => _selectedMenuIndex = 1)
        ),
      ],
    );

    // RIGHT CONTENT AREA
    Widget mainContentArea = Container(
      decoration: BoxDecoration(
        color: LoginColors.cardBase, borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: 0.5), offset: const Offset(8, 8), blurRadius: 20),
          const BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 20),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: _buildRightContent(isMobile)),
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
                child: Text('Reports & Logs', style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: LoginColors.textDark))
            ),
            const SizedBox(height: 16),
            menuButtons,
            const SizedBox(height: 32),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(minHeight: 500),
                child: mainContentArea
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4.0), child: Text('Reports & Logs', style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: LoginColors.textDark))),
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
  final String title; final String subtitle; final IconData icon;
  final Color color; final bool isSelected; final VoidCallback onTap;

  const _ReportActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: LoginColors.cardBase, borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [
              BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: 0.5), offset: const Offset(5, 5), blurRadius: 10),
              const BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
            ] : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: isSelected ? color.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 22, color: isSelected ? color : LoginColors.textDark.withValues(alpha: 0.4)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: GoogleFonts.inter(color: LoginColors.textDark, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.6), fontSize: 10)),
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
