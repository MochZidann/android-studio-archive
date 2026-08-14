package com.example.praktik09

import android.content.Intent
import android.graphics.Bitmap
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.praktik09.databinding.ActivityMainBinding
import com.google.zxing.BarcodeFormat
import com.journeyapps.barcodescanner.BarcodeEncoder
import com.google.zxing.integration.android.IntentIntegrator

class MainActivity : AppCompatActivity(), View.OnClickListener {
    private lateinit var binding: ActivityMainBinding
    private lateinit var intentIntegrator: IntentIntegrator

    private lateinit var dbHelper: DBOpenHelper

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        intentIntegrator = IntentIntegrator(this)
        dbHelper = DBOpenHelper(this)

        binding.btnGenerateQR.setOnClickListener(this)
        binding.btnScanQR.setOnClickListener(this)
        binding.btnSimpan.setOnClickListener(this)

        tampilkanDataKeList()
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.btnScanQR -> {
                intentIntegrator.setBeepEnabled(true)
                intentIntegrator.setOrientationLocked(true)
                intentIntegrator.setPrompt("Scan QR Mahasiswa")
                intentIntegrator.initiateScan()
            }
            R.id.btnGenerateQR -> {
                generateQRCode()
            }
            R.id.btnSimpan -> {
                simpanKeDatabase()
            }
        }
    }

    private fun generateQRCode() {
        val content = binding.edQrCode.text.toString()

        if (content.isNotEmpty()) {
            try {
                val barCodeEncoder = BarcodeEncoder()
                val bitmap: Bitmap = barCodeEncoder.encodeBitmap(
                    content,
                    BarcodeFormat.QR_CODE, 400, 400
                )
                binding.imV.setImageBitmap(bitmap)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        } else {
            Toast.makeText(this, "Isi teks generate terlebih dahulu!", Toast.LENGTH_SHORT).show()
        }
    }

    private fun simpanKeDatabase() {
        val nim = binding.edNim.text.toString().trim()
        val nama = binding.edNama.text.toString().trim()
        val prodi = binding.edProdi.text.toString().trim()

        if (nim.isNotEmpty() && nama.isNotEmpty() && prodi.isNotEmpty()) {
            val result = dbHelper.simpanData(nim, nama, prodi)
            if (result != -1L) {
                Toast.makeText(this, "Data Berhasil Disimpan", Toast.LENGTH_SHORT).show()

                // Reset input
                binding.edNim.text.clear()
                binding.edNama.text.clear()
                binding.edProdi.text.clear()

                // Refresh list
                tampilkanDataKeList()
            } else {
                Toast.makeText(this, "Gagal Simpan (NIM mungkin sudah ada)", Toast.LENGTH_SHORT).show()
            }
        } else {
            Toast.makeText(this, "Semua kolom (NIM, Nama, Prodi) wajib diisi!", Toast.LENGTH_SHORT).show()
        }
    }

    private fun tampilkanDataKeList() {
        val dataList = dbHelper.ambilData()

        val adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, dataList)
        binding.lvMahasiswa.adapter = adapter
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        val result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
        if (result != null) {
            if (result.contents != null) {
                val isiQR = result.contents

                if (isiQR.contains(";")) {
                    val parts = isiQR.split(";")
                    if (parts.size >= 3) {
                        binding.edNim.setText(parts[0])
                        binding.edNama.setText(parts[1])
                        binding.edProdi.setText(parts[2])
                    } else {
                        binding.edNim.setText(isiQR)
                        Toast.makeText(this, "Format QR kurang lengkap", Toast.LENGTH_SHORT).show()
                    }
                } else {
                    binding.edNim.setText(isiQR)
                    Toast.makeText(this, "Bukan format data mahasiswa (NIM;Nama;Prodi)", Toast.LENGTH_SHORT).show()
                }
            } else {
                Toast.makeText(this, "Scan dibatalkan", Toast.LENGTH_SHORT).show()
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}