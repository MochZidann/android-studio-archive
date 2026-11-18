import 'package:flutter_test/flutter_test.dart';
import 'package:pml02/models/student_model.dart';

void main() {
  test('Student model toMap and fromFirestore test', () {
    final student = Student(
      docId: '101',
      id: '101',
      name: 'Afia Ramadhan Zayn',
      address: 'Kediri',
      phone: '081123457891',
    );

    final map = student.toMap();
    expect(map['id'], '101');
    expect(map['name'], 'Afia Ramadhan Zayn');
    expect(map['address'], 'Kediri');
    expect(map['phone'], '081123457891');

    final reconstructed = Student.fromFirestore('101', map);
    expect(reconstructed.docId, '101');
    expect(reconstructed.id, '101');
    expect(reconstructed.name, 'Afia Ramadhan Zayn');
    expect(reconstructed.address, 'Kediri');
    expect(reconstructed.phone, '081123457891');
  });
}
