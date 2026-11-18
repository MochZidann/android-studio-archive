class Student {
  final String docId;
  final String id;
  final String name;
  final String address;
  final String phone;

  Student({
    required this.docId,
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
  });

  // Convert Student object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
    };
  }

  // Create Student object from Firestore Document snapshot / map
  factory Student.fromFirestore(String docId, Map<String, dynamic> data) {
    return Student(
      docId: docId,
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
    );
  }
}
