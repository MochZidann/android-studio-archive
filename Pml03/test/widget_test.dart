import 'package:flutter_test/flutter_test.dart';
import 'package:pml03/models/note_model.dart';

void main() {
  test('Note model serialization and deserialization test', () {
    final note = Note(
      key: 'test_key_123',
      title: 'Judul Catatan',
      description: 'Deskripsi Catatan',
    );

    final map = note.toMap();
    expect(map['title'], 'Judul Catatan');
    expect(map['description'], 'Deskripsi Catatan');

    final parsed = Note.fromMap('test_key_123', map);
    expect(parsed.key, 'test_key_123');
    expect(parsed.title, 'Judul Catatan');
    expect(parsed.description, 'Deskripsi Catatan');
  });
}
