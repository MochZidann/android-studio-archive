package com.example.praktik07

import android.database.sqlite.SQLiteDatabase
import android.graphics.Color
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentTransaction
import com.example.praktik07.databinding.ActivityMainBinding
import com.google.android.material.navigation.NavigationBarView

class MainActivity : AppCompatActivity(), NavigationBarView.OnItemSelectedListener {

    private lateinit var binding: ActivityMainBinding
    private lateinit var db: SQLiteDatabase

    // Inisialisasi fragment
    private val fragProdi = FragmentProdi()
    private val fragMhs = FragmentMahasiswa()
    private val fragTes = FragmentTes()
    private val fragNilai = FragmentNilai()
    private val fragMatkul = FragmentMatkul()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Konfigurasi Bottom Navigation
        binding.bottomNavigationView.setOnItemSelectedListener(this)
        binding.bottomNavigationView.itemIconTintList = null

        // Inisialisasi Database
        db = DBOpenHelper(this).writableDatabase
    }

    /**
     * Memberikan akses database ke fragment yang membutuhkan.
     */
    fun getDbObject(): SQLiteDatabase {
        return db
    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        val ft: FragmentTransaction = supportFragmentManager.beginTransaction()

        when (item.itemId) {
            R.id.itemProdi -> {
                ft.replace(R.id.frameLayout, fragProdi).commit()
                binding.frameLayout.setBackgroundColor(Color.argb(245, 255, 255, 225))
                binding.frameLayout.visibility = View.VISIBLE
            }
            R.id.itemMhs -> {
                ft.replace(R.id.frameLayout, fragMhs).commit()
                binding.frameLayout.setBackgroundColor(Color.argb(245, 225, 255, 255))
                binding.frameLayout.visibility = View.VISIBLE
            }
            R.id.itemMatkul -> { // Tambahan Baru
                ft.replace(R.id.frameLayout, fragMatkul).commit()
                binding.frameLayout.setBackgroundColor(Color.argb(245, 230, 230, 250))
                binding.frameLayout.visibility = View.VISIBLE
            }
            R.id.itemNilai -> { // Tambahan Baru
                ft.replace(R.id.frameLayout, fragNilai).commit()
                binding.frameLayout.setBackgroundColor(Color.argb(245, 255, 240, 245))
                binding.frameLayout.visibility = View.VISIBLE
            }
            R.id.itemTes -> {
                ft.replace(R.id.frameLayout, fragTes).commit()
                binding.frameLayout.setBackgroundColor(Color.argb(255, 245, 245, 215))
                binding.frameLayout.visibility = View.VISIBLE
            }
            R.id.itemAbout -> {
                binding.frameLayout.visibility = View.GONE
            }
        }
        return true
    }
}