import 'package:flutter_test/flutter_test.dart';
import 'package:pml04/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('Membuat UserModel dari Map dan melakukan serialisasi ke Map', () {
      final user = UserModel(
        uid: 'test_uid_123',
        email: 'admin@pml.com',
        username: 'Admin PML',
        address: 'Malang',
        phone: '08123456789',
        role: 'admin',
      );

      expect(user.uid, equals('test_uid_123'));
      expect(user.email, equals('admin@pml.com'));
      expect(user.username, equals('Admin PML'));
      expect(user.role, equals('admin'));

      final map = user.toMap();
      expect(map['email'], equals('admin@pml.com'));
      expect(map['username'], equals('Admin PML'));
      expect(map['role'], equals('admin'));

      final recreatedUser = UserModel.fromMap('test_uid_123', map);
      expect(recreatedUser.uid, equals(user.uid));
      expect(recreatedUser.email, equals(user.email));
      expect(recreatedUser.username, equals(user.username));
      expect(recreatedUser.role, equals(user.role));
    });

    test('Uji coba role pelanggan', () {
      final customer = UserModel(
        uid: 'cust_001',
        email: 'customer@pml.com',
        username: 'Pelanggan 1',
        address: 'Surabaya',
        phone: '08987654321',
        role: 'pelanggan',
      );

      expect(customer.role, equals('pelanggan'));
    });
  });
}
