import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/custom_toast.dart';

/// Data model untuk marker pada peta sesuai praktikum OSM
class MarkerItem {
  final int id;
  final LatLng point;
  final String title;
  final String snippet;

  MarkerItem({
    required this.id,
    required this.point,
    required this.title,
    required this.snippet,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Map Controller
  final MapController _mapController = MapController();

  // Top Location Text Controller (sesuai editText pada modul)
  final TextEditingController _locationController = TextEditingController(
    text: 'Lokasi...',
  );

  // Default coordinate (sesuai koordinat modul: Kediri / sekitarnya)
  static const LatLng _defaultCenter = LatLng(-7.801926, 111.979965);

  // State variabel
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLiveUpdateActive = false;
  bool _isGoogleHybrid = false;

  // Nomor urut penanda (sesuai nomorLokasi = 1 pada modul)
  int _nomorLokasi = 1;

  // Daftar Marker (markerList = ArrayList<Marker>())
  final List<MarkerItem> _markerList = [];
  int? _activeMarkerId; // ID marker yang info window-nya sedang terbuka

  // Overlay Polylines, Polygons, Circles
  final List<Polyline> _polylines = [];
  final List<Polygon> _polygons = [];
  final List<CircleMarker> _circles = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Memeriksa dan meminta izin lokasi (checkLocationPermission)
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        CustomToast.show(
          context,
          'Layanan lokasi (GPS) tidak aktif',
          isError: true,
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          CustomToast.show(context, 'Izin lokasi ditolak', isError: true);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        CustomToast.show(
          context,
          'Izin lokasi ditolak permanen, aktifkan di pengaturan',
          isError: true,
        );
      }
      return;
    }

    _setupLocationTracking();
  }

  /// Menyiapkan penyedia lokasi (setupMap / provider / runOnFirstFix)
  Future<void> _setupLocationTracking() async {
    try {
      // Ambil lokasi awal (runOnFirstFix)
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final initialLatLng = LatLng(
        initialPosition.latitude,
        initialPosition.longitude,
      );

      setState(() {
        _currentLocation = initialLatLng;
        _locationController.text =
            'Lat: ${initialPosition.latitude}, Lng: ${initialPosition.longitude}';
      });

      _mapController.move(initialLatLng, 15.0);

      // Listener pembaruan lokasi (onLocationChanged)
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen((Position position) {
            final newLatLng = LatLng(position.latitude, position.longitude);

            setState(() {
              _currentLocation = newLatLng;
              _locationController.text =
                  'Lat: ${position.latitude}, Lng: ${position.longitude}';
            });

            // Jika Live Update aktif, ikuti lokasi (enableFollowLocation)
            if (_isLiveUpdateActive) {
              _mapController.move(newLatLng, _mapController.camera.zoom);
            }
          });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  /// Tambah Marker saat Long Press (longpress menambah marker)
  void _addMarker(LatLng geoPoint) {
    final newMarker = MarkerItem(
      id: _nomorLokasi,
      point: geoPoint,
      title: 'Lokasi ke-$_nomorLokasi',
      snippet: 'Lat: ${geoPoint.latitude}, Lng: ${geoPoint.longitude}',
    );

    setState(() {
      _markerList.add(newMarker);
      _activeMarkerId = newMarker.id; // Tampilkan info window saat baru dibuat
      _nomorLokasi++;
    });
  }

  /// Tambah Marker dengan Catatan (addMarkerWithNote)
  void _addMarkerWithNote(LatLng geoPoint, String note) {
    final newMarker = MarkerItem(
      id: _nomorLokasi,
      point: geoPoint,
      title: note,
      snippet: 'Lat: ${geoPoint.latitude}, Lng: ${geoPoint.longitude}',
    );

    setState(() {
      _markerList.add(newMarker);
      _activeMarkerId = newMarker.id;
      _nomorLokasi++;
    });
  }

  /// Dialog Tambah Catatan (fabMap3)
  void _showAddNoteDialog() {
    final noteController = TextEditingController();
    final centerPoint = _mapController.camera.center;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Tambah Catatan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1E293B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan nama lokasi ini:',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Contoh: Rumah Teman, Tempat Makan...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final catatan = noteController.text.trim();
              if (catatan.isNotEmpty) {
                _addMarkerWithNote(centerPoint, catatan);
                Navigator.pop(ctx);
                CustomToast.show(
                  context,
                  'Pin berhasil disimpan!',
                  isSuccess: true,
                );
              } else {
                CustomToast.show(
                  context,
                  'Catatan tidak boleh kosong',
                  isError: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  /// Gambar Polyline (fabMapDrawPolyline)
  void _drawPolyline() {
    final points = [
      const LatLng(-7.802619, 111.979866),
      const LatLng(-7.741580, 112.107998),
    ];

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(points: points, color: Colors.blue, strokeWidth: 5.0),
      );
    });

    _mapController.move(points[0], 15.0);
  }

  /// Gambar Polygon (fabMapDrawPolygon)
  void _drawPolygon() {
    final points = [
      const LatLng(-7.803260, 111.980559),
      const LatLng(-7.802957, 111.979245),
      const LatLng(-7.800884, 111.979825),
      const LatLng(-7.801266, 111.981086),
    ];

    setState(() {
      _polygons.clear();
      _polygons.add(
        Polygon(
          points: points,
          color: const Color.fromARGB(75, 0, 255, 255),
          borderColor: Colors.black,
          borderStrokeWidth: 2.0,
        ),
      );
    });

    _mapController.move(points[0], 15.0);
  }

  /// Gambar Lingkaran (fabMapDrawCircle)
  void _drawCircle() {
    final center = _currentLocation ?? _defaultCenter;

    setState(() {
      _circles.clear();
      _circles.add(
        CircleMarker(
          point: center,
          radius: 1000.0,
          useRadiusInMeter: true,
          color: const Color.fromARGB(50, 0, 255, 0),
          borderColor: Colors.green,
          borderStrokeWidth: 2.0,
        ),
      );
    });

    _mapController.move(center, 14.0);
  }

  /// Switch ke Peta Standar OSM (fabMap1)
  void _switchToStandardMap() {
    setState(() {
      _isGoogleHybrid = false;
    });
  }

  /// Switch ke Peta Google Satelit / Hybrid (fabMap2)
  void _switchToGoogleHybrid() {
    setState(() {
      _isGoogleHybrid = true;
    });
    CustomToast.show(context, 'Mode Google Satelit', isSuccess: true);
  }

  /// Toggle Live Update (chip)
  void _toggleLiveUpdate(bool value) {
    setState(() {
      _isLiveUpdateActive = value;
    });

    if (value) {
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, _mapController.camera.zoom);
      }
      CustomToast.show(context, 'Live Update Aktif', isSuccess: true);
    } else {
      CustomToast.show(context, 'Live Update Mati');
    }
  }

  /// Pusatkan ke Lokasi Saya (fab)
  void _moveToMyLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 16.0);
    } else {
      _checkLocationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pml10',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Pemrograman Mobile Lanjut - OSM Lanjut',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. OpenStreetMap View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 15.0,
              onLongPress: (tapPosition, point) {
                _addMarker(point);
              },
              onTap: (_, _) {
                // Tutup info window jika klik area kosong peta
                if (_activeMarkerId != null) {
                  setState(() {
                    _activeMarkerId = null;
                  });
                }
              },
            ),
            children: [
              // Tile Layer (Standard OSM atau Google Hybrid)
              TileLayer(
                urlTemplate: _isGoogleHybrid
                    ? 'https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: _isGoogleHybrid
                    ? const ['0', '1', '2', '3']
                    : const ['a', 'b', 'c'],
                userAgentPackageName: 'ac.id.polinema.pml10',
                maxZoom: 20,
              ),

              // Polyline Layer
              if (_polylines.isNotEmpty) PolylineLayer(polylines: _polylines),

              // Polygon Layer
              if (_polygons.isNotEmpty) PolygonLayer(polygons: _polygons),

              // Circle Layer
              if (_circles.isNotEmpty) CircleLayer(circles: _circles),

              // Markers Layer
              MarkerLayer(
                markers: [
                  // Current user location marker
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Pin markers on map
                  ..._markerList.map((m) {
                    final isSelected = _activeMarkerId == m.id;
                    return Marker(
                      point: m.point,
                      width: 180,
                      height: 90,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          // Toggle info window saat diklik (m.isInfoWindowShown)
                          setState(() {
                            _activeMarkerId = isSelected ? null : m.id;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Info Window (Callout Bubble)
                            if (isSelected)
                              Positioned(
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 175,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        m.snippet,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          color: Color(0xFF64748B),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Marker Icon
                            Positioned(
                              bottom: 0,
                              child: Icon(
                                Icons.location_on,
                                size: 36,
                                color: isSelected
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // 2. Top Location Bar (sesuai editText pada modul)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.my_location,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      readOnly: true,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Lokasi...',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Right Floating Action Buttons Stack (sesuai FAB di modul)
          Positioned(
            top: 65,
            right: 12,
            child: Column(
              children: [
                // fabMap1: Peta (Standar OSM)
                _buildMiniFab(
                  icon: Icons.map_outlined,
                  tooltip: 'Peta',
                  onPressed: _switchToStandardMap,
                  isActive: !_isGoogleHybrid,
                ),
                const SizedBox(height: 8),

                // fabMap2: Gambar (Google Hybrid Satelit)
                _buildMiniFab(
                  icon: Icons.satellite_alt_outlined,
                  tooltip: 'Gambar',
                  onPressed: _switchToGoogleHybrid,
                  isActive: _isGoogleHybrid,
                ),
                const SizedBox(height: 8),

                // fabMap3: Penanda (Tambah Catatan)
                _buildMiniFab(
                  icon: Icons.add_location_alt_outlined,
                  tooltip: 'Penanda',
                  onPressed: _showAddNoteDialog,
                ),
                const SizedBox(height: 8),

                // fabMapDrawPolyline: Gambar garis
                _buildMiniFab(
                  icon: Icons.timeline,
                  tooltip: 'Gambar garis',
                  onPressed: _drawPolyline,
                ),
                const SizedBox(height: 8),

                // fabMapDrawPolygon: Gambar poligon
                _buildMiniFab(
                  icon: Icons.polyline_outlined,
                  tooltip: 'Gambar poligon',
                  onPressed: _drawPolygon,
                ),
                const SizedBox(height: 8),

                // fabMapDrawCircle: Gambar lingkaran
                _buildMiniFab(
                  icon: Icons.radio_button_unchecked,
                  tooltip: 'Gambar lingkaran',
                  onPressed: _drawCircle,
                ),
              ],
            ),
          ),

          // 4. Zoom Controls di kiri bawah (seperti kontrol osmdroid default)
          Positioned(
            bottom: 20,
            left: 12,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                ),
                const SizedBox(height: 4),
                _buildZoomButton(
                  icon: Icons.remove,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom - 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                ),
              ],
            ),
          ),

          // 5. Bottom Right: Live Update Chip & My Location FAB
          Positioned(
            bottom: 20,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chip Live Update
                FilterChip(
                  label: const Text(
                    'Live Update',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  selected: _isLiveUpdateActive,
                  onSelected: _toggleLiveUpdate,
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFEADDFF),
                  checkmarkColor: const Color(0xFF6750A4),
                  labelStyle: TextStyle(
                    color: _isLiveUpdateActive
                        ? const Color(0xFF6750A4)
                        : const Color(0xFF475569),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFF79747E)),
                  ),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                ),
                const SizedBox(width: 8),

                // FAB My Location (Aksi utama)
                FloatingActionButton.small(
                  onPressed: _moveToMyLocation,
                  backgroundColor: const Color(0xFFEADDFF),
                  foregroundColor: const Color(0xFF6750A4),
                  elevation: 3,
                  tooltip: 'Aksi utama',
                  child: const Icon(Icons.near_me, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper Mini FAB sesuai tema XML (#EADDFF background, #6750A4 tint)
  Widget _buildMiniFab({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: FloatingActionButton(
        heroTag: tooltip,
        onPressed: onPressed,
        mini: true,
        elevation: 3,
        tooltip: tooltip,
        backgroundColor: isActive
            ? const Color(0xFF6750A4)
            : const Color(0xFFEADDFF),
        foregroundColor: isActive ? Colors.white : const Color(0xFF6750A4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20),
      ),
    );
  }

  /// Helper tombol Zoom (+ / -)
  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, size: 18, color: const Color(0xFF334155)),
          ),
        ),
      ),
    );
  }
}
