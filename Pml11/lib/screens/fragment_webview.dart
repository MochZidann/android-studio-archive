import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../models/global_variables.dart';

/// FragmentWebView sesuai modul PML 11 (FragmentWebView.kt & fragment_webview.xml)
/// Menampilkan halaman web menggunakan WebView dengan pengaturan JavaScript,
/// DOM storage, progress loading, dan navigasi URL http/https.
class FragmentWebView extends StatefulWidget {
  final String initialUrl;
  final VoidCallback? onClose;
  final Function(WebViewController)? onControllerCreated;

  const FragmentWebView({
    super.key,
    required this.initialUrl,
    this.onClose,
    this.onControllerCreated,
  });

  @override
  State<FragmentWebView> createState() => FragmentWebViewState();
}

class FragmentWebViewState extends State<FragmentWebView> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentTitle = '';
  String _currentDisplayUrl = '';

  WebViewController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _currentDisplayUrl = widget.initialUrl.isNotEmpty
        ? widget.initialUrl
        : GlobalVariables.url;
    _initWebSettings();
  }

  /// Inisialisasi webSettings() sesuai panduan pada modul (FragmentWebView.kt)
  void _initWebSettings() {
    final WebViewController controller = WebViewController();

    // 1. JavaScript Enabled & background
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
                _currentDisplayUrl = url;
              });
            }
          },
          onPageFinished: (String url) async {
            String? pageTitle;
            try {
              pageTitle = await controller.getTitle();
            } catch (_) {}

            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadingProgress = 100;
                _currentDisplayUrl = url;
                if (pageTitle != null && pageTitle.isNotEmpty) {
                  _currentTitle = pageTitle;
                }
              });
            }
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('WebView HTTP Error: ${error.response?.statusCode}');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description} (${error.errorCode})');
            if (mounted) {
              setState(() {
                _isLoading = false;
                // Hanya tampilkan error jika halaman utama gagal dimuat
                if (_loadingProgress < 50) {
                  _errorMessage = error.description;
                }
              });
            }
          },
          // Sesuai modul: shouldOverrideUrlLoading cek http/https
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.startsWith('http://') || url.startsWith('https://')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    // Pengaturan Android WebSettings (DOM storage & Viewport)
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    widget.onControllerCreated?.call(_controller);

    // Load initial URL
    _loadUrl(_currentDisplayUrl);
  }

  /// Memuat URL ke dalam WebView
  void _loadUrl(String url) {
    if (url.isEmpty) return;
    GlobalVariables.url = url;
    setState(() {
      _currentDisplayUrl = url;
      _errorMessage = null;
      _isLoading = true;
      _loadingProgress = 0;
    });

    try {
      _controller.loadRequest(Uri.parse(url));
    } catch (e) {
      setState(() {
        _errorMessage = 'URL tidak valid: $url';
        _isLoading = false;
      });
    }
  }

  /// Dipanggil dari luar untuk memperbarui URL
  void updateUrl(String url) {
    _loadUrl(url);
  }

  /// Cek apakah ada riwayat navigasi sebelumnya
  Future<bool> canGoBack() async {
    return await _controller.canGoBack();
  }

  /// Kembali ke halaman sebelumnya di riwayat WebView
  Future<void> goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    }
  }

  /// Muat ulang halaman
  void reload() {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    _controller.reload();
  }

  /// Memuat halaman form pesan fallback (simulasi lokal form_send_message.php)
  void _loadFallbackMessageForm() {
    const String htmlContent = '''
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kirim Pesan - Form Send Message</title>
  <style>
    * { box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
    body { background-color: #f1f5f9; margin: 0; padding: 20px; color: #1e293b; }
    .card { background: white; border-radius: 14px; padding: 24px; box-shadow: 0 4px 12px rgba(0,0,0,0.06); max-width: 480px; margin: 0 auto; }
    h2 { margin-top: 0; color: #1e293b; font-size: 20px; border-bottom: 2px solid #4f46e5; padding-bottom: 8px; }
    p.desc { font-size: 13px; color: #64748b; margin-bottom: 18px; }
    .badge { display: inline-block; background: #e0e7ff; color: #4338ca; padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; margin-bottom: 12px; }
    label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: #334155; }
    input, textarea { width: 100%; padding: 12px; border: 1.5px solid #cbd5e1; border-radius: 8px; font-size: 14px; margin-bottom: 16px; outline: none; }
    input:focus, textarea:focus { border-color: #4f46e5; box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15); }
    button { width: 100%; padding: 13px; background: #4f46e5; color: white; border: none; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; transition: 0.2s; }
    button:active { background: #4338ca; transform: scale(0.99); }
    #alert { display: none; margin-top: 16px; padding: 12px; border-radius: 8px; font-size: 13px; font-weight: 500; }
    .alert-success { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }
  </style>
</head>
<body>
  <div class="card">
    <span class="badge">Modul 11 - Webview</span>
    <h2>Form Send Message</h2>
    <p class="desc">Simulasi endpoint <code>form_send_message.php</code> di dalam WebView Android / Flutter.</p>
    <form id="msgForm" onsubmit="event.preventDefault(); submitForm();">
      <label for="name">Nama Lengkap</label>
      <input type="text" id="name" placeholder="Masukkan nama..." required value="Mahasiswa MI Polinema">

      <label for="email">Alamat Email</label>
      <input type="email" id="email" placeholder="nama@polinema.ac.id" required value="mahasiswa@polinema.ac.id">

      <label for="message">Pesan / Feedback</label>
      <textarea id="message" rows="4" placeholder="Tuliskan pesan Anda di sini..." required>Halo Pak Afta, aplikasi WebView Flutter PML Pertemuan 11 berhasil diimplementasikan dengan baik!</textarea>

      <button type="submit">Kirim Pesan Sekarang</button>
    </form>
    <div id="alert" class="alert-success">
      Pesanan/Pesan Anda berhasil dikirim ke server!
    </div>
  </div>

  <script>
    function submitForm() {
      var alertBox = document.getElementById('alert');
      alertBox.style.display = 'block';
      alertBox.scrollIntoView({ behavior: 'smooth' });
    }
  </script>
</body>
</html>
''';
    _controller.loadHtmlString(htmlContent);
    setState(() {
      _errorMessage = null;
      _currentTitle = 'Form Send Message (Simulasi)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Toolbar WebView (Info URL, Refresh & Close)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(
              bottom: BorderSide(color: Color(0xFF334155), width: 1),
            ),
          ),
          child: Row(
            children: [
              // Icon Status
              const Icon(
                Icons.public,
                color: Color(0xFF5FD4C3),
                size: 18,
              ),
              const SizedBox(width: 8),
              // URL & Title Display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_currentTitle.isNotEmpty)
                      Text(
                        _currentTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      _currentDisplayUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol Reload
              IconButton(
                icon: const Icon(Icons.refresh, size: 19, color: Colors.white70),
                tooltip: 'Muat ulang',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: reload,
              ),
              const SizedBox(width: 4),
              // Tombol Tutup / Kembali ke Home
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.white),
                  tooltip: 'Tutup WebView (Kembali ke Dashboard)',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.onClose,
                ),
            ],
          ),
        ),

        // Linear Progress Indicator saat halaman dimuat
        if (_isLoading)
          LinearProgressIndicator(
            value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            minHeight: 3,
          ),

        // WebView Content & Error State
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),

              // Jika terjadi error koneksi / host tidak ditemukan (misal: domain aftazayn.me offline)
              if (_errorMessage != null)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.wifi_off_rounded,
                              size: 48,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Gagal Memuat Halaman Web',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'URL: $_currentDisplayUrl',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Tombol Aksi
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: reload,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Coba Lagi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              if (_currentDisplayUrl.contains('form_send_message'))
                                OutlinedButton.icon(
                                  onPressed: _loadFallbackMessageForm,
                                  icon: const Icon(Icons.message_outlined, size: 18),
                                  label: const Text('Buka Simulasi Form Pesan'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF4F46E5),
                                    side: const BorderSide(color: Color(0xFF4F46E5)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
