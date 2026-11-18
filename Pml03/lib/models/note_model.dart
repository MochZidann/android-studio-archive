/// Model representasi data Catatan (Note)
/// Diadaptasi dari kelas Note pada modul Kotlin PML03
class Note {
  final String? key;
  final String title;
  final String description;

  Note({
    this.key,
    required this.title,
    required this.description,
  });

  /// Mengubah objek Note ke bentuk Map untuk disimpan di Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
    };
  }

  /// Membuat objek Note dari Map / Snapshot Firebase Realtime Database
  factory Note.fromMap(String key, Map<dynamic, dynamic> map) {
    return Note(
      key: key,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }

  /// Duplikasi objek Note dengan perubahan tertentu
  Note copyWith({
    String? key,
    String? title,
    String? description,
  }) {
    return Note(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
