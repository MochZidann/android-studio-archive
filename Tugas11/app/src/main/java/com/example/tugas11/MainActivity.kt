package com.example.tugas11

import android.media.MediaPlayer
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ImageView
import android.widget.SeekBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.tugas11.databinding.ActivityMainBinding
import java.util.concurrent.TimeUnit

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private var mediaPlayer: MediaPlayer? = null
    private var currentIndex = 0
    private val handler = Handler(Looper.getMainLooper())

    private lateinit var daftarLagu: IntArray
    private lateinit var daftarCover: IntArray
    private lateinit var daftarJudul: Array<String>
    private lateinit var daftarArtist: Array<String>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupDynamicResources()

        val adapter = object : ArrayAdapter<String>(this, R.layout.item_playlist, R.id.tvItemJudul, daftarJudul) {
            override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
                val view = super.getView(position, convertView, parent)

                val tvJudul = view.findViewById<TextView>(R.id.tvItemJudul)
                val tvArtist = view.findViewById<TextView>(R.id.tvItemArtist)
                val imgCover = view.findViewById<ImageView>(R.id.imgItemCover)

                if (position < daftarJudul.size) tvJudul.text = daftarJudul[position]
                if (position < daftarArtist.size) tvArtist.text = daftarArtist[position]
                if (position < daftarCover.size) imgCover.setImageResource(daftarCover[position])

                return view
            }
        }
        binding.lvPlaylist.adapter = adapter

        binding.lvPlaylist.setOnItemClickListener { _, _, position, _ ->
            currentIndex = position
            putarLagu(currentIndex)
        }

        binding.btnPlay.setOnClickListener { togglePlay() }
        binding.btnNext.setOnClickListener { gantiLagu(1) }
        binding.btnPrev.setOnClickListener { gantiLagu(-1) }

        binding.seekSong.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(sb: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) mediaPlayer?.seekTo(progress)
            }
            override fun onStartTrackingTouch(sb: SeekBar?) {}
            override fun onStopTrackingTouch(sb: SeekBar?) {}
        })
    }

    private fun setupDynamicResources() {
        val listLaguTmp = mutableListOf<Int>()
        val listCoverTmp = mutableListOf<Int>()
        var i = 1

        while (true) {
            val resIdLagu = resources.getIdentifier("musik$i", "raw", packageName)
            val resIdCover = resources.getIdentifier("cover$i", "drawable", packageName)

            if (resIdLagu == 0) break

            listLaguTmp.add(resIdLagu)
            listCoverTmp.add(if (resIdCover != 0) resIdCover else android.R.drawable.ic_menu_gallery)
            i++
        }

        daftarLagu = listLaguTmp.toIntArray()
        daftarCover = listCoverTmp.toIntArray()

        daftarJudul = resources.getStringArray(R.array.daftar_judul_lagu)
        daftarArtist = resources.getStringArray(R.array.daftar_artist_lagu)
    }

    private fun putarLagu(index: Int) {
        if (daftarLagu.isEmpty()) return

        mediaPlayer?.stop()
        mediaPlayer?.release()

        binding.txJudulLagu.text = daftarJudul[index]
        binding.txArtist.text = daftarArtist[index]
        binding.imV.setImageResource(daftarCover[index])
        binding.btnPlay.setImageResource(android.R.drawable.ic_media_pause)

        mediaPlayer = MediaPlayer.create(this, daftarLagu[index])
        binding.seekSong.max = mediaPlayer?.duration ?: 0
        binding.txMaxTime.text = formatWaktu(mediaPlayer?.duration ?: 0)

        mediaPlayer?.start()
        updateSeekBar()

        mediaPlayer?.setOnCompletionListener { gantiLagu(1) }
    }

    private fun togglePlay() {
        mediaPlayer?.let {
            if (it.isPlaying) {
                it.pause()
                binding.btnPlay.setImageResource(android.R.drawable.ic_media_play)
            } else {
                it.start()
                binding.btnPlay.setImageResource(android.R.drawable.ic_media_pause)
                updateSeekBar()
            }
        } ?: putarLagu(currentIndex)
    }

    private fun updateSeekBar() {
        mediaPlayer?.let {
            binding.seekSong.progress = it.currentPosition
            binding.txCrTime.text = formatWaktu(it.currentPosition)
            if (it.isPlaying) {
                handler.postDelayed({ updateSeekBar() }, 1000)
            }
        }
    }

    private fun gantiLagu(step: Int) {
        if (daftarLagu.isEmpty()) return
        currentIndex = (currentIndex + step + daftarLagu.size) % daftarLagu.size
        putarLagu(currentIndex)
    }

    private fun formatWaktu(ms: Int): String {
        val menit = TimeUnit.MILLISECONDS.toMinutes(ms.toLong())
        val detik = TimeUnit.MILLISECONDS.toSeconds(ms.toLong()) % 60
        return String.format("%02d:%02d", menit, detik)
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
        handler.removeCallbacksAndMessages(null)
    }
}