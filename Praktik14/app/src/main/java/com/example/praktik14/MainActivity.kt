package com.example.praktik14

import android.content.Intent
import android.location.Location
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.praktik14.databinding.ActivityMainBinding
import mumayank.com.airlocationlibrary.AirLocation
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.ItemizedIconOverlay
import org.osmdroid.views.overlay.ItemizedIconOverlay.OnItemGestureListener
import org.osmdroid.views.overlay.OverlayItem
import org.osmdroid.views.overlay.compass.CompassOverlay
import org.osmdroid.views.overlay.compass.InternalCompassOrientationProvider
import org.osmdroid.views.overlay.mylocation.GpsMyLocationProvider
import org.osmdroid.views.overlay.mylocation.MyLocationNewOverlay

class MainActivity : AppCompatActivity(), View.OnClickListener {

    lateinit var binding: ActivityMainBinding
    lateinit var map: MapView
    val arrayItemPos = ArrayList<OverlayItem>()
    var updateLokasiSekaliSaja = false
    var lat = 0.0
    var lng = 0.0

    val airLocation = AirLocation(this, object : AirLocation.Callback {
        override fun onFailure(locationFailedEnum: AirLocation.LocationFailedEnum) {}

        override fun onSuccess(locations: ArrayList<Location>) {
            lat = locations[0].latitude
            lng = locations[0].longitude
            binding.textView.text = "Latitude = " + lat.toString() + "\nLongitude = " + lng.toString()
        }
    }, isLocationRequiredOnlyOneTime = updateLokasiSekaliSaja)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // PENTING: Konfigurasi osmdroid HARUS dipanggil sebelum layout di-inflate
        Configuration.getInstance().load(this, PreferenceManager.getDefaultSharedPreferences(this))
        Configuration.getInstance().userAgentValue = packageName

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.chip.setOnClickListener(this)

        map = binding.map
        map.setTileSource(TileSourceFactory.MAPNIK)
        map.setMultiTouchControls(true)
    }

    private fun drawMap() {
        val compass = CompassOverlay(applicationContext, InternalCompassOrientationProvider(applicationContext), map)
        compass.enableCompass()
        map.overlays.add(0, compass)

        if (arrayItemPos.size > 0) {
            for (i in 1 until map.overlays.size) {
                map.overlays.removeAt(1)
            }
            arrayItemPos.clear()
        }

        val gps = GpsMyLocationProvider(applicationContext)
        val me = MyLocationNewOverlay(gps, map)
        me.enableMyLocation()
        map.overlays.add(1, me)

        val startPoint = GeoPoint(lat, lng)
        map.controller.setZoom(20.0)
        map.controller.animateTo(startPoint)

        // Marker dari modul
        arrayItemPos.add(OverlayItem("Polinema Kampus Kediri 2", "Maskumambang", GeoPoint(-7.80203, 111.97982)))
        arrayItemPos.add(OverlayItem("Polinema Kampus Kediri 1", "Semampir", GeoPoint(-7.801166, 112.008228)))

        // Tambahan 3 Marker untuk Tugas D
        a11OverlayItem("Inspirasi Coffee", "Kafe nugas", GeoPoint(-7.808500, 112.010800)))

        map.overlays.add(
            ItemizedIconOverlay<OverlayItem>(
                arrayItemPos,
                object : OnItemGestureListener<OverlayItem> {
                    override fun onItemSingleTapUp(index: Int, item: OverlayItem): Boolean {
                        Toast.makeText(applicationContext, item.title, Toast.LENGTH_SHORT).show()
                        return true
                    }

                    override fun onItemLongPress(index: Int, item: OverlayItem): Boolean {
                        Toast.makeText(applicationContext, item.snippet, Toast.LENGTH_SHORT).show()
                        return true
                    }
                }, applicationContext
            )
        )
    }

    override fun onResume() {
        super.onResume()
        map.onResume()
    }

    override fun onPause() {
        super.onPause()
        map.onPause()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        airLocation.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        airLocation.onActivityResult(requestCode, resultCode, data)
    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.chip -> {
                updateLokasiSekaliSaja = binding.chip.isChecked
                updateLokasiSekaliSaja = updateLokasiSekaliSaja.not()
                airLocation.start()
                drawMap()
            }
        }
    }
}