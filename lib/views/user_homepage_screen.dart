import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laporin_app/controllers/user_homepage_controller.dart';
import 'package:laporin_app/views/login_screen.dart';
import 'package:laporin_app/views/user_list_screen.dart';
import 'package:laporin_app/views/profile_google_screen.dart';
import 'package:laporin_app/views/user_profile_screen.dart';

class UserHomepageScreen extends StatefulWidget {
  const UserHomepageScreen({super.key});

  @override
  State<UserHomepageScreen> createState() => _UserHomepageScreenState();
}

class _UserHomepageScreenState extends State<UserHomepageScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late UserHomepageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<UserHomepageController>()
        ? Get.find<UserHomepageController>()
        : Get.put(UserHomepageController());
  }

  Future<void> _logout() async {
    await controller.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onBottomNavTap(int index) {
    controller.setCurrentIndex(index);

    if (index == 0) {
      // Beranda - already here
    } else if (index == 1) {
      // Laporin - disabled/decorative button
    } else if (index == 2) {
      // Laporan - go to user list
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UserListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Action Grid
                    _buildQuickActionGrid(),
                    const SizedBox(height: 24),

                    // Laporan Masyarakat Section
                    _buildLaporanSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F55C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'LaporinAja',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F55C7),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      // Cek login method
                      final loginMethod = await controller.authPrefs.getLogin();
                      if (loginMethod == 'google') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileGoogleScreen(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileScreen(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F55C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Menu Items
            const SizedBox(height: 16),

            // Beranda
            ListTile(
              leading: const Icon(
                Icons.home_outlined,
                color: Color(0xFF4C4B4B),
              ),
              title: Text(
                'Beranda',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF4C4B4B),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF4C4B4B)),
              title: Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF4C4B4B),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F55C7), Color(0xFF3B7DE8)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Menu Button
                IconButton(
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),

                // Right Icons
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // Cek login method
                        final loginMethod = await controller.authPrefs
                            .getLogin();
                        if (loginMethod == 'google') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileGoogleScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfileScreen(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF0F55C7),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Welcome Text
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 40,
              top: 8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(
                () => Text(
                  'Selamat Datang User\n${controller.username.value}',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem(Icons.campaign, 'Pengumuman'),
        _buildQuickActionItem(Icons.flash_on, 'F.zz', isText: true),
        _buildQuickActionItem(Icons.phone_android, 'Pulsa'),
        _buildQuickActionItem(Icons.grid_view_rounded, 'Menu', isMain: true),
      ],
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label, {
    bool isMain = false,
    bool isText = false,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isMain ? const Color(0xFF0F55C7) : const Color(0xFF0F55C7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isText
                ? Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildLaporanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F55C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Laporan Masyarakat',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // News Cards
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildNewsCard('Judul Berita', Colors.blue.shade800),
              const SizedBox(width: 12),
              _buildNewsCard('Judul Berita', Colors.orange.shade700),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String title, Color color) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: color.withValues(alpha: 0.8),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 60,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Beranda
                GestureDetector(
                  onTap: () => _onBottomNavTap(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: controller.currentIndex.value == 0
                            ? const Color(0xFF0F55C7)
                            : Colors.grey.shade400,
                      ),
                      Text(
                        'Beranda',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: controller.currentIndex.value == 0
                              ? const Color(0xFF0F55C7)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Laporin (Camera - decorative)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F55C7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F55C7).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                // Laporan
                GestureDetector(
                  onTap: () => _onBottomNavTap(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        color: controller.currentIndex.value == 2
                            ? const Color(0xFF0F55C7)
                            : Colors.grey.shade400,
                      ),
                      Text(
                        'Laporan',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: controller.currentIndex.value == 2
                              ? const Color(0xFF0F55C7)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
