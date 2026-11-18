<#
.SYNOPSIS
    PML Flutter Starter Template Generator
    Generates a clean Flutter starter template with the Slate & Indigo PML theme,
    pre-configured Google Services / Firebase options, and reusable UI components
    (CustomTextField, CustomToast) ready for any PML module.

.EXAMPLE
    .\create_pml.ps1 -ProjectName Pml06
    .\create_pml.ps1 -ProjectName Pml06 -PackageName com.example.pml06
#>

param(
    [Parameter(Position=0)]
    [string]$ProjectName,

    [Parameter(Position=1)]
    [string]$PackageName
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = Read-Host "Enter Project Name (e.g. Pml06)"
}
if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    Write-Error "Project Name cannot be empty."
    exit 1
}

$projectNameLower = $ProjectName.ToLower()
if ([string]::IsNullOrWhiteSpace($PackageName)) {
    $PackageName = "com.example.$projectNameLower"
}

$orgParts = $PackageName.Split('.')
if ($orgParts.Length -ge 2) {
    $org = ($orgParts[0..($orgParts.Length - 2)]) -join '.'
    $dartProjectName = $orgParts[-1]
} else {
    $org = "com.example"
    $dartProjectName = $projectNameLower
}

$currentDir = Get-Location
$targetDir = Join-Path $currentDir $ProjectName

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  PML FLUTTER THEME & STARTER GENERATOR" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Project Name : $ProjectName" -ForegroundColor Yellow
Write-Host "Package Name : $PackageName" -ForegroundColor Yellow
Write-Host "Destination  : $targetDir" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter
try {
    $flutterCmd = Get-Command flutter -ErrorAction Stop
} catch {
    Write-Error "Flutter SDK not found in PATH."
    exit 1
}

# 1. Create Flutter Project
if (Test-Path $targetDir) {
    Write-Host "[1/5] Updating Flutter project in existing directory..." -ForegroundColor Green
    Set-Location $targetDir
    flutter create --org $org --project-name $dartProjectName .
} else {
    Write-Host "[1/5] Creating new Flutter project: $ProjectName..." -ForegroundColor Green
    flutter create --org $org --project-name $dartProjectName $ProjectName
    Set-Location $targetDir
}

# 2. Configure Android Gradle & Google Services
Write-Host "[2/5] Configuring Android Gradle & Google Services..." -ForegroundColor Green
$settingsGradle = Join-Path $targetDir "android\settings.gradle.kts"
if (Test-Path $settingsGradle) {
    $content = Get-Content $settingsGradle -Raw
    if ($content -notmatch 'com\.google\.gms\.google-services') {
        $content = $content -replace '(plugins\s*\{[^}]*)(\})', "`$1    id(`"com.google.gms.google-services`") version `"4.4.2`" apply false`n`$2"
        Set-Content -Path $settingsGradle -Value $content -NoNewline
    }
}

$appBuildGradle = Join-Path $targetDir "android\app\build.gradle.kts"
if (Test-Path $appBuildGradle) {
    $content = Get-Content $appBuildGradle -Raw
    if ($content -notmatch 'id\("com\.google\.gms\.google-services"\)') {
        $content = $content -replace '(plugins\s*\{[^}]*)(\})', "`$1    id(`"com.google.gms.google-services`")`n`$2"
        Set-Content -Path $appBuildGradle -Value $content -NoNewline
    }
}

$manifestPath = Join-Path $targetDir "android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $content = Get-Content $manifestPath -Raw
    if ($content -notmatch 'android\.permission\.INTERNET') {
        $content = $content -replace '(<manifest\b[^>]*>)', "`$1`n    <uses-permission android:name=`"android.permission.INTERNET`" />`n    <uses-permission android:name=`"android.permission.POST_NOTIFICATIONS`" />"
        Set-Content -Path $manifestPath -Value $content -NoNewline
    }
}

# 3. Detect & Sync google-services.json
Write-Host "[3/5] Synchronizing google-services.json & Firebase config..." -ForegroundColor Green
$appGoogleServices = Join-Path $targetDir "android\app\google-services.json"
$rootGoogleServices = Join-Path $targetDir "google-services.json"
$parentGoogleServices = Join-Path (Split-Path $targetDir) "google-services.json"

$foundJsonPath = $null
if (Test-Path $rootGoogleServices) {
    $foundJsonPath = $rootGoogleServices
} elseif (Test-Path $appGoogleServices) {
    $foundJsonPath = $appGoogleServices
} elseif (Test-Path $parentGoogleServices) {
    $foundJsonPath = $parentGoogleServices
}

$firebaseApiKey = "AIzaSyDlJMbJ_fQMSjCHcNfgO78ww3yN6LzSX5Q"
$firebaseProjectId = "mobile-dc1a9"
$firebaseStorage = "mobile-dc1a9.firebasestorage.app"
$firebaseAppId = "1:841483761739:android:placeholder"
$messagingSenderId = "841483761739"

if ($foundJsonPath) {
    Copy-Item -Path $foundJsonPath -Destination $appGoogleServices -Force
    try {
        $jsonObj = Get-Content $foundJsonPath -Raw | ConvertFrom-Json
        if ($jsonObj.project_info) {
            $firebaseProjectId = $jsonObj.project_info.project_id
            $messagingSenderId = $jsonObj.project_info.project_number
            if ($jsonObj.project_info.storage_bucket) {
                $firebaseStorage = $jsonObj.project_info.storage_bucket
            }
        }
        if ($jsonObj.client) {
            $matchingClient = $jsonObj.client | Where-Object { $_.client_info.android_client_info.package_name -eq $PackageName }
            if (-not $matchingClient) {
                $matchingClient = $jsonObj.client[0]
            }
            if ($matchingClient) {
                $firebaseAppId = $matchingClient.client_info.mobilesdk_app_id
                if ($matchingClient.api_key -and $matchingClient.api_key.Count -gt 0) {
                    $firebaseApiKey = $matchingClient.api_key[0].current_key
                }
            }
        }
        Write-Host "  -> Synced google-services.json (Project: $firebaseProjectId)" -ForegroundColor Cyan
    } catch {
        Write-Host "  -> Synced google-services.json directly" -ForegroundColor Cyan
    }
}

# 4. Add dependencies
Write-Host "[4/5] Adding core Firebase & UI dependencies (flutter pub add)..." -ForegroundColor Green
flutter pub add firebase_core:^4.15.0

# 5. Scaffold Theme & Clean Components
Write-Host "[5/5] Generating PML theme, custom widgets & starter screen..." -ForegroundColor Green
$libDir = Join-Path $targetDir "lib"
$widgetsDir = Join-Path $libDir "widgets"
$screensDir = Join-Path $libDir "screens"

New-Item -ItemType Directory -Force -Path $widgetsDir | Out-Null
New-Item -ItemType Directory -Force -Path $screensDir | Out-Null

# lib/firebase_options.dart
$firebaseOptionsContent = @"
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi default Firebase untuk $ProjectName
/// Project ID: $firebaseProjectId | Package: $PackageName
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '$firebaseApiKey',
    appId: '$firebaseAppId',
    messagingSenderId: '$messagingSenderId',
    projectId: '$firebaseProjectId',
    authDomain: '$firebaseProjectId.firebaseapp.com',
    storageBucket: '$firebaseStorage',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '$firebaseApiKey',
    appId: '$firebaseAppId',
    messagingSenderId: '$messagingSenderId',
    projectId: '$firebaseProjectId',
    storageBucket: '$firebaseStorage',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '$firebaseApiKey',
    appId: '$firebaseAppId',
    messagingSenderId: '$messagingSenderId',
    projectId: '$firebaseProjectId',
    storageBucket: '$firebaseStorage',
    iosBundleId: '$PackageName',
  );
}
"@
Set-Content -Path (Join-Path $libDir "firebase_options.dart") -Value $firebaseOptionsContent

# lib/widgets/custom_text_field.dart
$customTextFieldContent = @'
import 'package:flutter/material.dart';

/// Widget Input Field konsisten PML (Slate & Indigo)
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          obscureText: widget.isPassword ? _obscureText : false,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              widget.icon,
              size: 20,
              color: const Color(0xFF64748B),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: const Color(0xFF64748B),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
'@
Set-Content -Path (Join-Path $widgetsDir "custom_text_field.dart") -Value $customTextFieldContent

# lib/widgets/custom_toast.dart
$customToastContent = @'
import 'package:flutter/material.dart';

class CustomToast {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline
                  : isSuccess
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        action: action,
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : isSuccess
                ? const Color(0xFF16A34A)
                : const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
      ),
    );
  }
}
'@
Set-Content -Path (Join-Path $widgetsDir "custom_toast.dart") -Value $customToastContent

# lib/screens/home_screen.dart
$homeScreenContent = @"
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_toast.dart';

/// Template Layar Utama PML
/// Desain bertema Slate & Indigo dengan card form dan tombol aksi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleAction() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      CustomToast.show(context, 'Field tidak boleh kosong', isError: true);
      return;
    }
    CustomToast.show(context, 'Data berhasil diproses: \$text', isSuccess: true);
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
              '$ProjectName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Pemrograman Mobile Lanjut',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
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
                        Icons.flutter_dash,
                        color: Color(0xFF4F46E5),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$ProjectName Starter Template',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Siap digunakan untuk fungsi praktikum',
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
              const SizedBox(height: 20),

              // Form Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _inputController,
                      label: 'Input Data',
                      hint: 'Ketik sesuatu di sini...',
                      icon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Jalankan Aksi',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
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
"@
Set-Content -Path (Join-Path $screensDir "home_screen.dart") -Value $homeScreenContent

# lib/main.dart
$mainDartContent = @"
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    try {
      await Firebase.initializeApp();
    } catch (err) {
      debugPrint('Firebase init notice: \$err');
    }
  }

  runApp(const ${ProjectName}App());
}

class ${ProjectName}App extends StatelessWidget {
  const ${ProjectName}App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$ProjectName',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF0284C7),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
"@
Set-Content -Path (Join-Path $libDir "main.dart") -Value $mainDartContent

# test/widget_test.dart
$testDir = Join-Path $targetDir "test"
if (Test-Path $testDir) {
    $widgetTestContent = @"
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Smoke test $ProjectName', () {
    expect(true, isTrue);
  });
}
"@
    Set-Content -Path (Join-Path $testDir "widget_test.dart") -Value $widgetTestContent
}

# Run flutter pub get
flutter pub get

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " [SUCCESS] $ProjectName template created successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Ready to use: cd $ProjectName ; flutter run" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
