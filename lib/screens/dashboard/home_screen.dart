import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/cycle_calculator.dart';
import '../../services/firestore_service.dart';
import '../../models/cycle_model.dart';
import '../../models/user_model.dart';

import '../cycle/cycle_calendar_screen.dart';
import '../doctor_sync/doctor_list_screen.dart';
import '../fertility/ovulation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DashboardTab(),
    const CycleCalendarScreen(),
    const DoctorListScreen(),
    const OvulationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: "Period",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: "Doctor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brightness_5),
            label: "Ovulation",
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [_profileAction(context)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg.png'),
            fit: BoxFit.cover,
            opacity:
                0.15, // Make background subtle so it doesn't distract from text
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _welcomeCard(),
                const SizedBox(height: 24),
                _sectionTitle("Cycle Overview"),
                const SizedBox(height: 12),
                _cycleOverviewCard(),
                const SizedBox(height: 24),
                _sectionTitle("Quick Actions"),
                const SizedBox(height: 12),
                _quickActionsGrid(context),

                const SizedBox(height: 40), // bottom space
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chatbot'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  // ---------------- PROFILE ACTION ----------------
  Widget _profileAction(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return FutureBuilder<UserModel?>(
      future: FirestoreService().getUser(user.uid),
      builder: (context, snapshot) {
        String initial = "?";
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final name = snapshot.data!.name.trim();
          if (name.isNotEmpty) {
            initial = name[0].toUpperCase();
          }
        } else {
          final email = user.email ?? "";
          if (email.isNotEmpty) {
            initial = email[0].toUpperCase();
          }
        }

        return PopupMenuButton<String>(
          offset: const Offset(0, 50),
          onSelected: (value) async {
            if (value == 'logout') {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            } else if (value == 'profile') {
              Navigator.pushNamed(context, '/profile');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              radius: 18,
              child: Text(
                initial,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('My Profile'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------- WELCOME CARD ----------------
  Widget _welcomeCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildWelcomeBox("Welcome 👋"); // Fallback if logged out
    }

    return FutureBuilder<UserModel?>(
      future: FirestoreService().getUser(user.uid),
      builder: (context, snapshot) {
        String greeting = "Welcome 👋";
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final userName = snapshot.data!.name.split(' ')[0]; // Grab first name
          greeting = "Welcome, $userName 👋";
        }
        return _buildWelcomeBox(greeting);
      },
    );
  }

  Widget _buildWelcomeBox(String greeting) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Track your cycle, fertility & health\nall in one place",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/welcome_illus.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ---------------- QUICK ACTIONS GRID ----------------
  Widget _quickActionsGrid(BuildContext context) {
    final gridItems = [
      _actionTile(
        icon: Icons.calendar_month,
        label: "Log Period",
        onTap: () => Navigator.pushNamed(context, '/cycle-calendar'),
      ),
      _actionTile(
        icon: Icons.read_more_rounded,
        label: "Symptoms",
        onTap: () => Navigator.pushNamed(context, '/symptoms'),
      ),
      _actionTile(
        icon: Icons.history,
        label: "History",
        onTap: () => Navigator.pushNamed(context, '/symptom-history'),
      ),
      _actionTile(
        icon: Icons.medical_services_outlined,
        label: "Doctor",
        onTap: () => Navigator.pushNamed(context, '/doctor'),
      ),
      _actionTile(
        icon: Icons.bar_chart,
        label: "Analytics",
        onTap: () => Navigator.pushNamed(context, '/analytics'),
      ),
      _actionTile(
        icon: Icons.alarm_add_outlined,
        label: "Reminder",
        onTap: () => Navigator.pushNamed(context, '/reminders'),
      ),
      _actionTile(
        icon: Icons.warning_amber_rounded,
        label: "Emergency",
        onTap: () {
          Navigator.pushNamed(context, '/emergency');
        },
      ),
      _actionTile(
        icon: Icons.brightness_5_outlined,
        label: "Ovulation",
        onTap: () {
          Navigator.pushNamed(context, '/ovulation');
        },
      ),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth =
        (screenWidth - 32 - 14) / 2; // Account for padding and spacing
    final itemHeight = itemWidth / 1.3; // Based on childAspectRatio
    final rowCount = (gridItems.length / 2)
        .ceil(); // Calculate rows based on actual item count
    final gridHeight =
        (itemHeight * rowCount) + (14 * (rowCount - 1)); // Height + spacing

    return SizedBox(
      height: gridHeight,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
        children: gridItems,
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CYCLE OVERVIEW ----------------
  Widget _cycleOverviewCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _emptyOverviewCard("Log in to see cycle prediction.");
    }

    return StreamBuilder<List<CycleModel>>(
      stream: FirestoreService().streamCycles(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _emptyOverviewCard("Error loading data.");
        }

        final cycles = snapshot.data ?? [];
        if (cycles.isEmpty) {
          return _emptyOverviewCard(
            "Log a cycle to get predictions.",
            actionRequired: true,
            context: context,
          );
        }

        // Get most recent cycle
        final cyclesSorted = List.from(cycles)
          ..sort((a, b) => b.startDate.compareTo(a.startDate)); // descending
        final latestCycle = cyclesSorted.first;

        final avgCycleLength = CycleCalculator.calculateAverageCycleLength(
          cycles,
        );

        final nextPeriodDate = CycleCalculator.predictNextPeriod(
          latestCycle.startDate,
          cycleLength: avgCycleLength,
        );

        final ovulationDate = CycleCalculator.predictOvulation(
          latestCycle.startDate,
          avgCycleLength,
        );

        final fertilityWindow = CycleCalculator.getFertilityWindow(
          ovulationDate,
        );

        final today = DateTime.now();
        // Calculate days until next period
        final daysUntilPeriod = nextPeriodDate
            .difference(DateTime(today.year, today.month, today.day))
            .inDays;

        String periodText;
        if (daysUntilPeriod > 0) {
          periodText = "In $daysUntilPeriod Days";
        } else if (daysUntilPeriod == 0) {
          periodText = "Today";
        } else {
          periodText = "${daysUntilPeriod.abs()} Days Late";
        }

        final shortFormat = DateFormat('d MMM');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Next Period",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                periodText,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              if (daysUntilPeriod < -3) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Your period is ${daysUntilPeriod.abs()} days late. Consider logging symptoms or consulting your doctor if this irregularity continues.",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                "Ovulation Window",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                "${shortFormat.format(fertilityWindow['start']!)} – ${shortFormat.format(fertilityWindow['end']!)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyOverviewCard(
    String message, {
    bool actionRequired = false,
    BuildContext? context,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionRequired && context != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/cycle-calendar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Log a Cycle"),
            ),
          ],
        ],
      ),
    );
  }
}
