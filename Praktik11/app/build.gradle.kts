package com.example.tugas11

import android.media.MediaPlayer
import android.os.Bundle
import android.widget.ArrayAdapter
import androidx.appcompat.app.AppCompatActivity
import com.example.tugas11.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private var mediaPlayer: MediaPlayer? = null

    // Data Resource (Pastikan file-file ini sudah ada di folder res)
    private val daftarLagu = intArrayOf(R.raw.musik1, R.raw.musik2, R.raw.musik3)
    private val daftarJudul = arrayOf("Music 1", "Music 2", "Music 3")
    private val daftarCover = intArrayOf(R.drawable.cover1, R.drawable.cover2, R.drawable.cover3)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Inisialisasi ViewBinding
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Setup Playlist menggunakan ListView standar
        val adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, daftarJudul)
        binding.lvPlaylist.adapter = adapter

        // Listener saat judul lagu di playlist diklik[cite: 1]
        binding.lvPlaylist.setOnItemClickListener { _, _, position, _ ->
            putarLagu(position)
        }

        // Tombol Play/Pause manual[cite: 1]
        binding.btnPlayPause.setOnClickListener {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.pause()
                } else {
                    it.start()
                }
            }
        }
    }

    private fun putarLagu(index: Int) {
        // 1. Matikan lagu yang sedang berjalan (Mutual Exclusion)[cite: 1]
        mediaPlayer?.stop()
        mediaPlayer?.release()

        // 2. Update UI: Ganti Judul dan Cover secara otomatis[cite: 1]
        binding.txtJudul.text = "Now Playing: ${daftarJudul[index]}"
        binding.imgCover.setImageResource(daftarCover[index])

        // 3. Siapkan dan jalankan lagu baru[cite: 1]
        mediaPlayer = MediaPlayer.create(this, daftarLagu[index])
        mediaPlayer?.start()
    }

    // Bersihkan memori saat aplikasi ditutup[cite: 1]
    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
        mediaPlayer = null
    }
}