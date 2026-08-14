package com.example.tugas05

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.example.tugas05.databinding.ActivityPenjumlahanBinding
import java.text.DecimalFormat

class PenjumlahanActivity : AppCompatActivity(), View.OnClickListener {

    private lateinit var binding: ActivityPenjumlahanBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPenjumlahanBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Set Listener untuk tombol
        binding.btnJumlah.setOnClickListener(this)

        // Mengambil data dari Intent jika ada
        val paket = intent.extras
        if (paket != null) {
            binding.edX.setText(paket.getString("X"))
            binding.edY.setText(paket.getString("Y"))
        }
    }

    override fun onClick(v: View?) {
        if (v?.id == R.id.btnJumlah) {
            hitungDanKirimBalik()
        }
    }

    private fun hitungDanKirimBalik() {
        // Ambil input, gunakan 0.0 jika kosong atau bukan angka
        val x = binding.edX.text.toString().toDoubleOrNull() ?: 0.0
        val y = binding.edY.text.toString().toDoubleOrNull() ?: 0.0

        val hasil = x + y
        val hasilFormatted = DecimalFormat("#.##").format(hasil)

        // Tampilkan di TextView lokal
        binding.txHasilJumlah.text = hasilFormatted

        // Jika ingin mengirim hasil kembali ke MainActivity
        val resultIntent = Intent()
        resultIntent.putExtra("HASIL_JUMLAH", hasilFormatted)
        setResult(RESULT_OK, resultIntent)

        // Opsi: finish() jika ingin langsung tutup activity setelah hitung
        // finish()
    }
}