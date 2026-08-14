package com.example.praktik06

import android.graphics.Color
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentTransaction
import com.example.praktik06.databinding.ActivityMainBinding
import com.google.android.material.navigation.NavigationBarView
class MainActivity : AppCompatActivity(),
    NavigationBarView.OnItemSelectedListener {
    //ViewBinding untuk menghubungkan layout dengan kode Kotlin
    lateinit var binding: ActivityMainBinding
    //deklarasi object fragment
    lateinit var fragProdi: FragmentProdi
    lateinit var fragMhs: FragmentMahasiswa
    lateinit var fragTes: FragmentTes
    //untuk melakukan operasi pada fragment
    lateinit var ft: FragmentTransaction
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        binding.bottomNavigationView.setOnItemSelectedListener(this)
        binding.bottomNavigationView.itemIconTintList = null
//inisialisasi masing-masing fragment
        fragProdi = FragmentProdi()
        fragMhs = FragmentMahasiswa()
        fragTes = FragmentTes()
    }
    override fun onNavigationItemSelected(p0: MenuItem): Boolean {
//supportFragmentManager digunakan untuk melakukan
//'transaksi' pada fragment
//yang meliputi menghapus, menambah dan mengganti fragment
//sedangkan frameLayout digunakan untuk menampilkan fragment
        when (p0.itemId) {
            R.id.itemProdi -> {
//supportFragmentManager sekali pakai
                ft = supportFragmentManager.beginTransaction()
//menampilkan FragmentProdi ke dalam FrameLayout
                ft.replace(R.id.frameLayout, fragProdi).commit()
                binding.frameLayout.setBackgroundColor(
                    Color.argb(245, 255, 255, 225)
                )
                binding.frameLayout.visibility = View.VISIBLE
            }
            R.id.itemMhs -> {
                ft = supportFragmentManager.beginTransaction()
                ft.replace(R.id.frameLayout, fragMhs).commit()
                binding.frameLayout.setBackgroundColor(
                    Color.argb(245, 225, 255, 255)
                )

                binding.frameLayout.visibility = View.VISIBLE

            }
            R.id.itemTes -> {
                ft = supportFragmentManager.beginTransaction()
                ft.replace(R.id.frameLayout, fragTes).commit()
                binding.frameLayout.setBackgroundColor(
                    Color.argb(255, 245, 245, 215)
                )
                binding.frameLayout.visibility = View.VISIBLE
            }
                    R.id.itemAbout -> {
//menyembunyikan FrameLayout (tidak menampilkan fragment)
                binding.frameLayout.visibility = View.GONE
            }
        }
        return true
    }
}