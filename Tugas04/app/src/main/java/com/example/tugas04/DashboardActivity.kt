package com.example.tugas04

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.tugas04.databinding.ActivityDashboardBinding

class DashboardActivity : AppCompatActivity() {
    private lateinit var binding: ActivityDashboardBinding
    private val REQ_CODE = 100

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityDashboardBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnPolinema.setOnClickListener {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://www.polinema.ac.id/")))
        }

        binding.btnGallery.setOnClickListener {
            val it = Intent(Intent.ACTION_GET_CONTENT).apply { type = "image/*" }
            startActivity(Intent.createChooser(it, "Pilih Gambar"))
        }

        binding.btnPerkalian.setOnClickListener {
            kirimData(PerkalianActivity::class.java)
        }

        binding.btnPembagian.setOnClickListener {
            kirimData(PembagianActivity::class.java)
        }
    }

    private fun kirimData(tujuan: Class<*>) {
        val intent = Intent(this, tujuan)
        intent.putExtra("X", binding.edX.text.toString())
        intent.putExtra("Y", binding.edY.text.toString())
        startActivityForResult(intent, REQ_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQ_CODE && resultCode == Activity.RESULT_OK) {
            binding.txHasil.text = data?.getStringExtra("hasilBalik")
        }
    }
}