import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Controllers untuk field input
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Focus nodes untuk navigasi form yang nyaman
  final FocusNode _idFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  // Menyimpan docId dari item yang sedang dipilih dari ListView
  String? _selectedDocId;
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _idFocus.dispose();
    _nameFocus.dispose();
    _addressFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // Mengosongkan form input
  void _clearForm() {
    setState(() {
      _idController.clear();
      _nameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _selectedDocId = null;
    });
    FocusScope.of(context).unfocus();
  }

  // Menampilkan SnackBar Toast modern
  void _showToast(
    String message, {
    bool isError = false,
    bool isSuccess = false,
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
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : isSuccess
            ? const Color(0xFF16A34A)
            : const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Operasi INSERT data mahasiswa
  Future<void> _handleInsert() async {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    if (id.isEmpty) {
      _showToast('ID / NIM mahasiswa wajib diisi!', isError: true);
      _idFocus.requestFocus();
      return;
    }
    if (name.isEmpty) {
      _showToast('Nama mahasiswa wajib diisi!', isError: true);
      _nameFocus.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final student = Student(
        docId: id,
        id: id,
        name: name,
        address: address,
        phone: phone,
      );

      await _firestoreService.insertStudent(student);
      _showToast('Data Berhasil Ditambahkan', isSuccess: true);
      _clearForm();
    } catch (e) {
      _showToast('Data Gagal Ditambahkan: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Operasi UPDATE data mahasiswa
  Future<void> _handleUpdate() async {
    if (_selectedDocId == null || _selectedDocId!.isEmpty) {
      _showToast(
        'Pilih data mahasiswa dari list terlebih dahulu!',
        isError: true,
      );
      return;
    }

    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    if (id.isEmpty || name.isEmpty) {
      _showToast('ID dan Nama mahasiswa tidak boleh kosong!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final student = Student(
        docId: _selectedDocId!,
        id: id,
        name: name,
        address: address,
        phone: phone,
      );

      await _firestoreService.updateStudent(_selectedDocId!, student);
      _showToast('Data Berhasil Diupdate', isSuccess: true);
      _clearForm();
    } catch (e) {
      _showToast('Data Gagal Diupdate: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Operasi DELETE data mahasiswa
  Future<void> _handleDelete() async {
    if (_selectedDocId == null || _selectedDocId!.isEmpty) {
      _showToast(
        'Pilih data mahasiswa dari list yang ingin dihapus!',
        isError: true,
      );
      return;
    }

    final studentName = _nameController.text.isNotEmpty
        ? _nameController.text
        : 'ID ${_idController.text}';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade700),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data "$studentName"? Data yang dihapus tidak dapat dikembalikan.',
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await _firestoreService.deleteStudent(_selectedDocId!);
      _showToast('Data Berhasil Dihapus', isSuccess: true);
      _clearForm();
    } catch (e) {
      _showToast('Data Gagal Dihapus: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Memilih item dari ListView (onItemClick)
  void _selectStudent(Student student) {
    setState(() {
      _selectedDocId = student.docId;
      _idController.text = student.id;
      _nameController.text = student.name;
      _addressController.text = student.address;
      _phoneController.text = student.phone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedDocId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pml02',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Pemrograman Mobile Lanjut 2',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        actions: [
          if (hasSelection)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber.shade300,
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset Form', style: TextStyle(fontSize: 13)),
              onPressed: _clearForm,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // PANEL FORM INPUT (Modern Card)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: hasSelection
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE2E8F0),
                  width: hasSelection ? 1.5 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Form
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5).withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.school,
                                size: 18,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'STUDENTS DATA',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        if (hasSelection)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFCD34D),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: Color(0xFFB45309),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Mode Edit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grid atau Baris Input Field
                    Row(
                      children: [
                        // Input ID
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _idController,
                            focusNode: _idFocus,
                            label: 'id',
                            hint: '101',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _nameFocus.requestFocus(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Input Name
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            label: 'name',
                            hint: 'Zidan',
                            icon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _addressFocus.requestFocus(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // Input Address
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: _addressController,
                            focusNode: _addressFocus,
                            label: 'address',
                            hint: 'Kediri',
                            icon: Icons.location_on_outlined,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _phoneFocus.requestFocus(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Input Phone
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            label: 'phone',
                            hint: '081234567890',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleInsert(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // BARIS TOMBOL: INSERT, UPDATE, DELETE
                    Row(
                      children: [
                        // INSERT BUTTON
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleInsert,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text(
                              'INSERT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // UPDATE BUTTON
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey.shade200,
                              disabledForegroundColor: Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: (_isLoading || !hasSelection)
                                ? null
                                : _handleUpdate,
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text(
                              'UPDATE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // DELETE BUTTON
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey.shade200,
                              disabledForegroundColor: Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: (_isLoading || !hasSelection)
                                ? null
                                : _handleDelete,
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text(
                              'DELETE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Color(0xFFE0E7FF),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
              ),

            // Header Daftar Mahasiswa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.format_list_bulleted,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'DAFTAR MAHASISWA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Klik item untuk Edit/Hapus',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            // DAFTAR DATA MAHASISWA (Realtime Stream)
            Expanded(
              child: StreamBuilder<List<Student>>(
                stream: _firestoreService.getStudentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_off,
                                  size: 36,
                                  color: Colors.red.shade600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Gagal Menghubungkan ke Firestore',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pastikan Firestore Database sudah dibuat di Firebase Console dan aturan Rules diset allow read, write: if true;\n\nDetail: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final students = snapshot.data ?? [];

                  if (students.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.group_outlined,
                                  size: 40,
                                  color: Colors.indigo.shade300,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada data mahasiswa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Isi formulir di atas lalu tekan tombol INSERT untuk menambahkan data pertama.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final isSelected = student.docId == _selectedDocId;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEEF2FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(6),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _selectStudent(student),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar Inisial
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isSelected
                                          ? [
                                              const Color(0xFF4F46E5),
                                              const Color(0xFF6366F1),
                                            ]
                                          : [
                                              const Color(0xFFE0E7FF),
                                              const Color(0xFFC7D2FE),
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    student.name.isNotEmpty
                                        ? student.name
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : student.id
                                              .substring(0, 1)
                                              .toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF3730A3),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Informasi Mahasiswa (ID, Name, Address, Phone)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color: const Color(0xFFCBD5E1),
                                              ),
                                            ),
                                            child: Text(
                                              student.id,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              student.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.5,
                                                color: Color(0xFF0F172A),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Alamat & Telepon
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 4,
                                        children: [
                                          if (student.address.isNotEmpty)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 13,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  student.address,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF475569),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (student.phone.isNotEmpty)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.phone_outlined,
                                                  size: 13,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  student.phone,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF475569),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Selection Indicator Icon
                                if (isSelected)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 6, top: 2),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 20,
                                      color: Color(0xFF4F46E5),
                                    ),
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.only(left: 6, top: 2),
                                    child: Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
        labelStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
      ),
    );
  }
}
