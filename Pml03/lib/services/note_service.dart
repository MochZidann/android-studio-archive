import 'package:firebase_database/firebase_database.dart';
import '../models/note_model.dart';
import '../firebase_options.dart';

/// Service untuk mengelola interaksi CRUD ke Firebase Realtime Database
/// Mengacu pada manipulasi node "Notes" pada modul PML03
class NoteService {
  // Instance database
  late final DatabaseReference _notesRef;

  NoteService() {
    // Inisialisasi referensi node "Notes"
    // Menggunakan databaseURL yang sesuai dengan konfigurasi proyek
    final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: FirebaseDatabase.instance.app,
      databaseURL: DefaultFirebaseOptions.databaseUrl,
    );
    _notesRef = database.ref('Notes');
  }

  /// Mendengarkan perubahan data "Notes" secara realtime
  /// Setiap penambahan, pengubahan, atau penghapusan akan memicu stream ini
  Stream<List<Note>> getNotesStream() {
    return _notesRef.onValue.map((event) {
      final List<Note> notes = [];
      final snapshot = event.snapshot;

      if (snapshot.exists && snapshot.children.isNotEmpty) {
        for (final child in snapshot.children) {
          final key = child.key;
          final value = child.value;

          if (key != null && value is Map) {
            notes.add(Note.fromMap(key, value));
          }
        }
      }

      // Urutkan dari yang terbaru (opsional atau sesuai key push Firebase)
      return notes;
    });
  }

  /// Menambahkan catatan baru ke Firebase Realtime Database
  /// Mirip dengan: myRef.push().setValue(...)
  Future<void> addNote({
    required String title,
    required String description,
  }) async {
    final newRef = _notesRef.push();
    final note = Note(
      key: newRef.key,
      title: title.trim(),
      description: description.trim(),
    );
    await newRef.set(note.toMap());
  }

  /// Memperbarui catatan yang sudah ada
  /// Mirip dengan: myRef.child(key).updateChildren(changedData)
  Future<void> updateNote({
    required String key,
    required String title,
    required String description,
  }) async {
    final Map<String, Object?> changedData = {
      'title': title.trim(),
      'description': description.trim(),
    };
    await _notesRef.child(key).update(changedData);
  }

  /// Menghapus catatan dari Firebase Realtime Database
  /// Mirip dengan: myRef.child(key).removeValue()
  Future<void> deleteNote(String key) async {
    await _notesRef.child(key).remove();
  }
}
