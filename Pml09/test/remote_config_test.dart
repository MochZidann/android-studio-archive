import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pml09/screens/remote_config_screen.dart';

void main() {
  testWidgets('RemoteConfigScreen renders initial UI components correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RemoteConfigScreen(),
      ),
    );

    // Verifikasi teks 'Testing!' ada
    expect(find.text('Testing!'), findsOneWidget);

    // Verifikasi tombol 'Refresh Remote Config' ada
    expect(find.text('Refresh Remote Config'), findsOneWidget);

    // Verifikasi informasi parameter sesuai modul ada
    expect(find.text('font_color'), findsOneWidget);
    expect(find.text('font_size'), findsOneWidget);

    // Verifikasi tombol simulasi modul ada
    final simulateBtn = find.text('Simulasi Nilai Modul (#ff0000, size 30)');
    expect(simulateBtn, findsOneWidget);

    // Klik tombol simulasi
    await tester.tap(simulateBtn);
    await tester.pump();

    // Verifikasi nilai parameter berubah sesuai simulasi
    expect(find.text('font_size: 30'), findsOneWidget);
    expect(find.text('font_color: #ff0000'), findsOneWidget);
  });
}
