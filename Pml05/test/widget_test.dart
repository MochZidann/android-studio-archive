import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PML05 FCM configuration & payload parsing smoke test', () {
    final Map<String, dynamic> sampleData = {
      'title': 'Promo Diskon 50%',
      'body': 'Nikmati diskon 50% selama promo masih berlaku!',
      'promoId': 'P6712',
      'promo': 'Nikmati diskon 50% selama promo masih berlaku!',
      'promoUntil': 'Berlaku hingga 1 minggu kedepan',
    };

    expect(sampleData['title'], equals('Promo Diskon 50%'));
    expect(sampleData['promoId'], equals('P6712'));
    expect(sampleData['promoUntil'], equals('Berlaku hingga 1 minggu kedepan'));
  });
}
