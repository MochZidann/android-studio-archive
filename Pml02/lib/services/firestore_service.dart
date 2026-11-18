import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class FirestoreService {
  final CollectionReference _studentsCollection =
      FirebaseFirestore.instance.collection('students');

  // Mendapatkan stream data mahasiswa secara realtime (Snapshot listener)
  Stream<List<Student>> getStudentsStream() {
    return _studentsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return Student.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  // INSERT data mahasiswa ke Firestore
  Future<void> insertStudent(Student student) async {
    // Sesuai modul: Menyimpan dokumen dengan custom document ID (student.id)
    final docRef = student.id.isNotEmpty
        ? _studentsCollection.doc(student.id)
        : _studentsCollection.doc();

    await docRef.set(student.toMap());
  }

  // UPDATE data mahasiswa berdasarkan document ID
  Future<void> updateStudent(String docId, Student student) async {
    if (docId.isEmpty) {
      throw Exception('ID Dokumen tidak ditemukan untuk di-update');
    }
    await _studentsCollection.doc(docId).update(student.toMap());
  }

  // DELETE data mahasiswa berdasarkan document ID
  Future<void> deleteStudent(String docId) async {
    if (docId.isEmpty) {
      throw Exception('ID Dokumen tidak ditemukan untuk di-delete');
    }
    await _studentsCollection.doc(docId).delete();
  }
}
