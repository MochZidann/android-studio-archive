import 'package:flutter/material.dart';
import '../models/global_variables.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_toast.dart';
import 'fragment_webview.dart';

/// Implementasi MainActivity.kt & activity_main.xml sesuai modul PML 11
/// Menggunakan tema Slate & Indigo dengan dukungan BottomNavigationBar,
/// 3 tombol utama (TIKTOK, YOUTUBE, SEND MESSAGE), dan WebView terintegrasi.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Daftar URL sesuai modul PML Pertemuan 11
  static const String urlTiktok = 'https://www.tiktok.com';
  static const String urlYoutube = 'https://youtube.com';
  static const String urlSendMessage =
      'https://aistudiollms.pythonanywhere.com/';
  static const String urlLocation =
      'https://www.google.com/maps/place/PSDKU+Politeknik+Negeri+Malang+di+Kota+Kediri/'
      '@-7.8037366,111.9795566,17z/data=!4m6!3m5!'
      '1s0x2e7856c8ee550497:0x3f8ff2e0bc9b9718!8m2!'
      '3d-7.8025674!4d111.9798355!16s%2Fg%2F11c6f2rzlc?entry=ttu&g_ep=EgoyMDI2MTAyOC4wIKXMDSoASAFQAw%3D%3D';
  static const String urlShop = 'https://www.shopee.co.id';
  static const String urlProfile = 'https://www.instagram.com/d3mipolinema/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FragmentWebViewState> _webViewKey =
      GlobalKey<FragmentWebViewState>();
  final TextEditingController _customUrlController = TextEditingController();

  /// Sesuai Android: visibilitas frameLayout
  bool _isWebViewVisible = false;

  /// Index aktif BottomNavigationBar (0: Home, 1: Location, 2: Shop, 3: Profile)
  int _selectedIndex = 0;

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  /// Fungsi replaceFragment(url) sesuai MainActivity.kt pada modul
  /// Mengatur GlobalVariables.url, menampilkan webview (frameLayout VISIBLE),
  /// dan memuat URL ke dalam WebView.
  void _replaceFragment(String url, {int? navIndex}) {
    GlobalVariables.url = url;

    setState(() {
      _isWebViewVisible = true;
      if (navIndex != null) {
        _selectedIndex = navIndex;
      }
    });

    // Jika WebView sudah diinisialisasi, update URL langsung
    _webViewKey.currentState?.updateUrl(url);

    CustomToast.show(
      context,
      'Membuka: ${Uri.tryParse(url)?.host ?? url}',
      isSuccess: true,
      duration: const Duration(seconds: 2),
    );
  }

  /// Sembunyikan WebView dan kembali ke tampilan Dashboard (sesuai itemHome -> View.GONE)
  void _hideWebView() {
    setState(() {
      _isWebViewVisible = false;
      _selectedIndex = 0;
    });
  }

  /// Penanganan tombol Back Android (sesuai backPressed() pada MainActivity.kt)
  Future<bool> _handleBackPressed() async {
    // Cek apakah webview sedang ditampilkan
    if (_isWebViewVisible) {
      // Cek apakah fragment aktif dan ada riwayat (canGoBack)
      final state = _webViewKey.currentState;
      if (state != null && await state.canGoBack()) {
        // Kembali ke halaman sebelumnya
        await state.goBack();
        return false;
      } else {
        // Sembunyikan webview (binding.frameLayout.visibility = View.GONE)
        _hideWebView();
        return false;
      }
    }
    // Jika tidak di WebView, izinkan keluar aplikasi (finish())
    return true;
  }

  /// Navigasi BottomNavigationBar sesuai onNavigationItemSelected pada MainActivity.kt
  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        // R.id.itemHome -> binding.frameLayout.visibility = View.GONE
        _hideWebView();
        break;
      case 1:
        // R.id.itemLoc -> replaceFragment(Google Maps)
        _replaceFragment(HomeScreen.urlLocation, navIndex: 1);
        break;
      case 2:
        // R.id.itemShop -> replaceFragment(Shopee)
        _replaceFragment(HomeScreen.urlShop, navIndex: 2);
        break;
      case 3:
        // R.id.itemProfil -> replaceFragment(Instagram D3 MI)
        _replaceFragment(HomeScreen.urlProfile, navIndex: 3);
        break;
    }
  }

  /// Buka custom URL yang diketik pengguna
  void _handleCustomUrl() {
    String input = _customUrlController.text.trim();
    if (input.isEmpty) {
      CustomToast.show(context, 'Masukkan URL terlebih dahulu', isError: true);
      return;
    }

    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'https://$input';
    }

    _replaceFragment(input);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isWebViewVisible,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.language_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pml11',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isWebViewVisible
                        ? 'WebView Mode'
                        : 'Pemrograman Mobile Lanjut - WebView',
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (_isWebViewVisible)
              IconButton(
                icon: const Icon(Icons.home_outlined, color: Colors.white),
                tooltip: 'Kembali ke Dashboard',
                onPressed: _hideWebView,
              ),
          ],
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _isWebViewVisible ? 1 : 0,
            children: [
              // Index 0: Tampilan Dashboard (3 tombol utama + custom URL card)
              _buildDashboardContent(),

              // Index 1: Tampilan WebView (FrameLayout pengganti)
              FragmentWebView(
                key: _webViewKey,
                initialUrl: GlobalVariables.url.isNotEmpty
                    ? GlobalVariables.url
                    : HomeScreen.urlYoutube,
                onClose: _hideWebView,
              ),
            ],
          ),
        ),
        // Bottom Navigation Bar sesuai menu_dashboard.xml
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  /// Widget Tampilan Dashboard sesuai Modul & Template PML
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card PML
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.web_rounded,
                    color: Color(0xFF4F46E5),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PML 11: Implementasi WebView',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pilih salah satu tombol di bawah untuk membuka halaman web di dalam aplikasi.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3 Tombol Utama Sesuai Gambar pada Modul (Halaman 2 & 7)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'PILIHAN HALAMAN WEB (MODUL 11)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Tombol btTiktok
                _buildPillButton(
                  label: 'TIKTOK',
                  icon: Icons.music_note_rounded,
                  color: const Color(0xFF5D3FD3),
                  onPressed: () => _replaceFragment(HomeScreen.urlTiktok),
                ),
                const SizedBox(height: 14),

                // 2. Tombol btYt
                _buildPillButton(
                  label: 'YOUTUBE',
                  icon: Icons.play_arrow_rounded,
                  color: const Color(0xFF4F46E5),
                  onPressed: () => _replaceFragment(HomeScreen.urlYoutube),
                ),
                const SizedBox(height: 14),

                // 3. Tombol Chatbot AI (sebelumnya Send Message)
                _buildPillButton(
                  label: 'AI CHATBOT',
                  icon: Icons.smart_toy_rounded,
                  color: const Color(0xFF0284C7),
                  onPressed: () => _replaceFragment(HomeScreen.urlSendMessage),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Card Tambahan: Custom URL Tester (Memanfaatkan CustomTextField template)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.link_rounded, size: 20, color: Color(0xFF4F46E5)),
                    SizedBox(width: 8),
                    Text(
                      'Uji Coba URL Kustom',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _customUrlController,
                  label: 'URL Web',
                  hint: 'https://polinema.ac.id atau https://flutter.dev',
                  icon: Icons.search_rounded,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _handleCustomUrl(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _handleCustomUrl,
                    icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                    label: const Text(
                      'Buka di WebView',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  /// Tombol berbentuk Pill (sudut bulat 100dp) sesuai activity_main.xml
  Widget _buildPillButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // Sesuai cornerRadius="100dp"
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// BottomNavigationBar sesuai menu_dashboard.xml dan activity_main.xml
  /// Background: #5FD4C3 (Teal/Mint), Item tint: #105B50
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF5FD4C3),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF5FD4C3), // Sesuai modul: #5FD4C3
        selectedItemColor: const Color(0xFF105B50), // Sesuai modul: #105B50
        unselectedItemColor: const Color(0xFF105B50).withValues(alpha: 0.65),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11.5,
        ),
        items: const [
          // 1. itemHome
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          // 2. itemLoc
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Location',
          ),
          // 3. itemShop
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          // 4. itemProfil
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
