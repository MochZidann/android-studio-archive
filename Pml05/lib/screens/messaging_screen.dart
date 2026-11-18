import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_toast.dart';

/// Halaman Messaging (FCM & In-App Messaging)
/// Mengimplementasikan alur dari modul PML Pertemuan 5 (MessagingActivity.kt):
/// 1. Berlangganan ke topik "INFO_DISKON_DAN_PROMO"
/// 2. Mengambil Token FCM perangkat (edToken)
/// 3. Mengambil Firebase Installation ID (FID) untuk In-App Messaging
/// 4. Menerima payload Notification (title & body)
/// 5. Menerima payload Data (promoId, promo, promoUntil)
/// Menggunakan tema Slate & Indigo konsisten PML.
class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  // Topik sesuai modul
  static const String topic = 'INFO_DISKON_DAN_PROMO';

  // Controller untuk field-field input (sesuai activity_messaging.xml)
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _promoIdController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _promoUntilController = TextEditingController();

  bool _isSubscribed = false;
  bool _isLoadingToken = true;
  String? _installationId;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _promoIdController.dispose();
    _promoController.dispose();
    _promoUntilController.dispose();
    super.dispose();
  }

  /// Inisialisasi Firebase Cloud Messaging & In-App Messaging
  Future<void> _initializeFCM() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Inisialisasi Firebase In-App Messaging
    try {
      await FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(
        true,
      );
      debugPrint('Firebase In-App Messaging diaktifkan');
    } catch (e) {
      debugPrint('Error init In-App Messaging: $e');
    }

    // Mengambil Firebase Installation ID (FID) untuk In-App Messaging
    try {
      final String id = await FirebaseInstallations.instance.getId();
      _installationId = id;
      debugPrint('\n======================================================');
      debugPrint('🔥 [FIREBASE IN-APP MESSAGING] INSTALLATION ID (FID):');
      debugPrint('👉 $id');
      debugPrint('======================================================\n');
    } catch (e) {
      debugPrint('Gagal mengambil FID: $e');
    }

    // 1. Izin notifikasi (sesuai askNotificationPermission di modul)
    try {
      final NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM AuthorizationStatus: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }

    // 2. Berlangganan ke topik INFO_DISKON_DAN_PROMO
    try {
      await messaging.subscribeToTopic(topic);
      if (mounted) {
        setState(() => _isSubscribed = true);
      }
      debugPrint('Berhasil subscribe ke topik: $topic');
    } catch (e) {
      debugPrint('Gagal subscribe ke topik: $e');
    }

    // 3. Mengambil Device Token (sesuai Firebase.messaging.token di modul)
    try {
      final String? token = await messaging.getToken();
      if (token != null && mounted) {
        setState(() {
          _tokenController.text = token;
          _isLoadingToken = false;
        });
        debugPrint('FCM Token: $token');
      } else if (mounted) {
        setState(() => _isLoadingToken = false);
      }
    } catch (e) {
      debugPrint('Gagal mengambil token: $e');
      if (mounted) {
        setState(() => _isLoadingToken = false);
      }
    }

    // Listener token refresh
    messaging.onTokenRefresh.listen((newToken) {
      if (mounted) {
        setState(() {
          _tokenController.text = newToken;
        });
      }
    });

    // 4. Cek pesan saat aplikasi dibuka dari keadaan Terminated (Initial Message)
    final RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _applyMessageData(initialMessage, source: 'Initial Message');
    }

    // 5. Listener saat menerima pesan di Foreground (aplikasi aktif)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _applyMessageData(message, source: 'Foreground');
      if (mounted) {
        final title =
            message.notification?.title ??
            message.data['title'] ??
            'Pesan Baru';
        CustomToast.show(context, 'Pesan Diterima: $title', isSuccess: true);
      }
    });

    // 6. Listener saat notifikasi di-klik di background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _applyMessageData(message, source: 'Opened from Background');
      if (mounted) {
        CustomToast.show(
          context,
          'Membuka pesan dari notifikasi',
          isSuccess: true,
        );
      }
    });
  }

  /// Ekstraksi data pesan dan pemetaan ke Controller sesuai modul
  void _applyMessageData(RemoteMessage message, {required String source}) {
    debugPrint('Menerima FCM dari ($source): ${message.data}');

    final notification = message.notification;
    final data = message.data;

    if (!mounted) return;

    setState(() {
      // 1. Notification (Title & Body)
      if (notification?.title != null) {
        _titleController.text = notification!.title!;
      } else if (data.containsKey('title')) {
        _titleController.text = data['title'].toString();
      }

      if (notification?.body != null) {
        _bodyController.text = notification!.body!;
      } else if (data.containsKey('body')) {
        _bodyController.text = data['body'].toString();
      }

      // 2. Data payload (promoId, promo, promoUntil)
      // Mendukung variasi huruf kapital maupun lowercase
      if (data.containsKey('promoId')) {
        _promoIdController.text = data['promoId'].toString();
      } else if (data.containsKey('promoid')) {
        _promoIdController.text = data['promoid'].toString();
      }

      if (data.containsKey('promo')) {
        _promoController.text = data['promo'].toString();
      }

      if (data.containsKey('promoUntil')) {
        _promoUntilController.text = data['promoUntil'].toString();
      } else if (data.containsKey('promountil')) {
        _promoUntilController.text = data['promountil'].toString();
      }
    });
  }

  /// Menyalin token ke clipboard untuk uji coba di Firebase Console
  void _copyToken() {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      CustomToast.show(context, 'Token belum tersedia', isError: true);
      return;
    }
    Clipboard.setData(ClipboardData(text: token));
    CustomToast.show(
      context,
      'Token berhasil disalin ke Clipboard!',
      isSuccess: true,
    );
  }

  /// Menyalin Firebase Installation ID (FID) ke clipboard untuk uji coba di Firebase In-App Messaging
  void _copyFid() {
    final fid = _installationId?.trim() ?? '';
    if (fid.isEmpty) {
      CustomToast.show(context, 'FID belum tersedia', isError: true);
      return;
    }
    Clipboard.setData(ClipboardData(text: fid));
    CustomToast.show(
      context,
      'FID (In-App Messaging) berhasil disalin ke Clipboard!',
      isSuccess: true,
    );
  }

  /// Mengosongkan form
  void _resetFields() {
    setState(() {
      _titleController.clear();
      _bodyController.clear();
      _promoIdController.clear();
      _promoController.clear();
      _promoUntilController.clear();
    });
    CustomToast.show(context, 'Field form telah dikosongkan');
  }

  /// Fungsi simulasi data untuk kemudahan testing
  void _simulateSamplePromo() {
    setState(() {
      _titleController.text = 'Promo Diskon 50%';
      _bodyController.text = 'Nikmati diskon 50% selama promo masih berlaku!';
      _promoIdController.text = 'P6712';
      _promoController.text = 'Nikmati diskon 50% selama promo masih berlaku!';
      _promoUntilController.text = 'Berlaku hingga 1 minggu kedepan';
    });
    CustomToast.show(
      context,
      'Contoh payload promo berhasil dimuat!',
      isSuccess: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pml05',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Firebase Cloud Messaging (Pertemuan 5)',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Token',
            onPressed: () {
              setState(() => _isLoadingToken = true);
              _initializeFCM();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Banner "INCOMING MESSAGE" bergaya Slate & Indigo
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_outlined,
                        color: Color(0xFF4F46E5),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INCOMING MESSAGE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0284C7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isSubscribed
                                      ? const Color(0xFF16A34A)
                                      : Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _isSubscribed
                                      ? 'Subscribed: $topic'
                                      : 'Menghubungkan ke $topic...',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bagian Token / Application ID
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Token / Application ID',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                        if (_isLoadingToken)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Row(
                            children: [
                              InkWell(
                                onTap: _copyToken,
                                borderRadius: BorderRadius.circular(6),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.copy,
                                        size: 14,
                                        color: Color(0xFF4F46E5),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Salin Token',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4F46E5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: _copyFid,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.perm_identity,
                                        size: 14,
                                        color: Color(0xFF0284C7),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Salin',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0284C7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tokenController,
                      readOnly: true,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: _isLoadingToken
                            ? 'Mengambil token FCM...'
                            : 'FCM Token belum tersedia',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gunakan token ini untuk "Send test message" di Firebase Console',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bagian Notification Payload
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFF0284C7),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Notification',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Title notifikasi',
                      icon: Icons.title_outlined,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _bodyController,
                      label: 'Body',
                      hint: 'Isi teks notifikasi',
                      icon: Icons.text_snippet_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bagian Data Payload
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.data_object_outlined,
                          color: Color(0xFF0284C7),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Data',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _promoIdController,
                      label: 'Promo Id',
                      hint: 'ID Promo (cth: P6712)',
                      icon: Icons.confirmation_number_outlined,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _promoController,
                      label: 'Promo',
                      hint: 'Keterangan promo',
                      icon: Icons.discount_outlined,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _promoUntilController,
                      label: 'Promo valid until',
                      hint:
                          'Masa berlaku (cth: Berlaku hingga 1 minggu kedepan)',
                      icon: Icons.date_range_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tombol Aksi Bawah
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetFields,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _simulateSamplePromo,
                      icon: const Icon(Icons.play_arrow_outlined, size: 18),
                      label: const Text('Simulasi Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
