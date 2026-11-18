import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final supabase = Supabase.instance.client;
  final String bucketName = 'Mobile Lanjut'; 
  
  PlatformFile? _selectedFile;
  List<FileObject> _storageItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFilesFromStorage();
  }

  Future<void> _fetchFilesFromStorage() async {
    setState(() => _isLoading = true);
    try {
      final List<FileObject> objects = await supabase.storage.from(bucketName).list();
      setState(() {
        _storageItems = objects.where((item) => item.name != '.emptyFolderPlaceholder').toList();
      });
    } catch (e) {
      debugPrint('Error fetching files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile(FileType type, {List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );
      if (result.isNotEmpty) {
        setState(() {
          _selectedFile = result.first;
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih file terlebih dahulu')));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final file = File(_selectedFile!.path!);
      final fileName = _selectedFile!.name;
      
      await supabase.storage.from(bucketName).upload(
        fileName, 
        file, 
        fileOptions: const FileOptions(upsert: true)
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload berhasil!', style: TextStyle(color: Colors.white))));
        setState(() {
          _selectedFile = null;
        });
        _fetchFilesFromStorage();
      }
    } catch (e) {
      debugPrint('Upload failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload gagal: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFilterButton(String label, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4F46E5),
            side: const BorderSide(color: Color(0xFF4F46E5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supabase Storage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Pml07 - Praktikum',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Kontainer Atas: Pemilih File & Upload
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _buildFilterButton('IMAGE', () => _pickFile(FileType.image)),
                      _buildFilterButton('PDF', () => _pickFile(FileType.custom, allowedExtensions: ['pdf'])),
                      _buildFilterButton('WORD', () => _pickFile(FileType.custom, allowedExtensions: ['doc', 'docx'])),
                      _buildFilterButton('VIDEO', () => _pickFile(FileType.video)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      _selectedFile != null ? 'File terpilih: ${_selectedFile!.name}' : 'Belum ada file dipilih',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedFile != null ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _uploadFile,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('UPLOAD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            
            // Kontainer Bawah: List View File
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _isLoading && _storageItems.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _storageItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada file di storage',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _storageItems.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          itemBuilder: (context, index) {
                            final item = _storageItems[index];
                            final publicUrl = supabase.storage.from(bucketName).getPublicUrl(item.name);
                            
                            IconData iconData = Icons.insert_drive_file;
                            String typeText = 'File';
                            Color iconColor = const Color(0xFF64748B);
                            
                            final lowerCaseName = item.name.toLowerCase();
                            if (lowerCaseName.endsWith('.jpg') || lowerCaseName.endsWith('.png') || lowerCaseName.endsWith('.jpeg')) {
                              iconData = Icons.image;
                              typeText = 'Gambar';
                              iconColor = const Color(0xFF10B981); // Emerald
                            } else if (lowerCaseName.endsWith('.mp4') || lowerCaseName.endsWith('.mkv')) {
                              iconData = Icons.video_file;
                              typeText = 'Video';
                              iconColor = const Color(0xFFF59E0B); // Amber
                            } else if (lowerCaseName.endsWith('.pdf')) {
                              iconData = Icons.picture_as_pdf;
                              typeText = 'PDF';
                              iconColor = const Color(0xFFEF4444); // Red
                            } else if (lowerCaseName.endsWith('.doc') || lowerCaseName.endsWith('.docx')) {
                              iconData = Icons.description;
                              typeText = 'Dokumen';
                              iconColor = const Color(0xFF3B82F6); // Blue
                            }

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(iconData, size: 28, color: iconColor),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tipe: $typeText',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'URL: $publicUrl',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
