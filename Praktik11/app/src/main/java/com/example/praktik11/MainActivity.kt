package com.example.praktik11

import android.media.MediaPlayer
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.MediaController
import android.widget.SeekBar
import androidx.appcompat.app.AppCompatActivity
import com.example.praktik11.databinding.ActivityMainBinding
import java.util.concurrent.TimeUnit

class MainActivity : AppCompatActivity(), View.OnClickListener, SeekBar.OnSeekBarChangeListener {

    private lateinit var binding: ActivityMainBinding
    private val daftarLagu = intArrayOf(R.raw.musik1, R.raw.musik2, R.raw.musik3)
    private val daftarVideo = intArrayOf(R.raw.vid1, R.raw.vid2, R.raw.vid3)
    private val daftarCover = intArrayOf(R.drawable.cover1, R.drawable.cover2, R.drawable.cover3)
    private val daftarJudul = arrayOf("Music 1", "Music 2", "Music 3")

    private var posLaguSkrg = 0
    private var posVidSkrg = 0
    private val handler = Handler(Looper.getMainLooper())
    private var updateSeekBarThread: Runnable? = null

    private var mediaPlayer: MediaPlayer? = null
    private lateinit var mediaController: MediaController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        mediaController = MediaController(this)
        binding.seekSong.setOnSeekBarChangeListener(this)

        binding.btnNext.setOnClickListener(this)
        binding.btnPrev.setOnClickListener(this)
        binding.btnStop.setOnClickListener(this)
        binding.btnPlay.setOnClickListener(this)

        // Setup VideoView
        mediaController.setPrevNextListeners(nextVid, prevVid)
        binding.videoView.setMediaController(mediaController)

        // Listener krusial agar video tidak error saat di-drag/seek
        binding.videoView.setOnPreparedListener { mp ->
            mp.setOnSeekCompleteListener {
                // Video lanjut main setelah drag selesai jika sebelumnya sedang main
                if (binding.videoView.isPlaying) binding.videoView.start()
            }
        }

        // Paksa audio mati saat video mulai diputar
        binding.videoView.setOnInfoListener { _, what, _ ->
            if (what == MediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START) {
                forceStopAudio()
            }
            false
        }

        videoSet(posVidSkrg)
        prepareAudio(posLaguSkrg)
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.btnPlay -> toggleAudioPlay()
            R.id.btnNext -> audioNext()
            R.id.btnPrev -> audioPrev()
            R.id.btnStop -> audioStop()
        }
    }

    private fun forceStopAudio() {
        mediaPlayer?.let {
            if (it.isPlaying) {
                it.pause()
                binding.btnPlay.setImageResource(android.R.drawable.ic_media_play)
            }
        }
    }

    private fun forceStopVideo() {
        if (binding.videoView.isPlaying) {
            binding.videoView.pause()
        }
    }

    private fun toggleAudioPlay() {
        forceStopVideo() // WAJIB: Matikan video sebelum audio jalan

        if (mediaPlayer == null) prepareAudio(posLaguSkrg)

        mediaPlayer?.let { mp ->
            if (mp.isPlaying) {
                mp.pause()
                binding.btnPlay.setImageResource(android.R.drawable.ic_media_play)
            } else {
                mp.start()
                binding.btnPlay.setImageResource(android.R.drawable.ic_media_pause)
                startUpdatingProgress()
            }
        }
    }

    private fun prepareAudio(pos: Int) {
        mediaPlayer?.release()
        mediaPlayer = MediaPlayer.create(this, daftarLagu[pos])
        mediaPlayer?.let { mp ->
            binding.seekSong.max = mp.duration
            binding.txMaxTime.text = milliSecondToString(mp.duration)
            binding.imV.setImageResource(daftarCover[pos])
            binding.txJudulLagu.text = daftarJudul[pos]
            mp.setOnCompletionListener { audioNext() }
        }
    }

    override fun onStartTrackingTouch(seekBar: SeekBar?) {}
    override fun onStopTrackingTouch(seekBar: SeekBar?) {
        seekBar?.let { mediaPlayer?.seekTo(it.progress) }
    }
    override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
        if (fromUser) binding.txCrTime.text = milliSecondToString(progress)
    }

    private val nextVid = View.OnClickListener {
        posVidSkrg = (posVidSkrg + 1) % daftarVideo.size
        videoSet(posVidSkrg)
        forceStopAudio()
        binding.videoView.start()
    }

    private val prevVid = View.OnClickListener {
        posVidSkrg = if (posVidSkrg > 0) posVidSkrg - 1 else daftarVideo.size - 1
        videoSet(posVidSkrg)
        forceStopAudio()
        binding.videoView.start()
    }

    private fun videoSet(pos: Int) {
        val uri = Uri.parse("android.resource://$packageName/${daftarVideo[pos]}")
        binding.videoView.setVideoURI(uri)
        binding.videoView.requestFocus()
    }

    private fun audioNext() {
        posLaguSkrg = (posLaguSkrg + 1) % daftarLagu.size
        prepareAudio(posLaguSkrg)
        toggleAudioPlay()
    }

    private fun audioPrev() {
        posLaguSkrg = if (posLaguSkrg > 0) posLaguSkrg - 1 else daftarLagu.size - 1
        prepareAudio(posLaguSkrg)
        toggleAudioPlay()
    }

    private fun audioStop() {
        mediaPlayer?.let {
            it.pause()
            it.seekTo(0)
            binding.btnPlay.setImageResource(android.R.drawable.ic_media_play)
            binding.seekSong.progress = 0
            binding.txCrTime.text = milliSecondToString(0)
        }
    }

    private fun milliSecondToString(ms: Int): String {
        val seconds = TimeUnit.MILLISECONDS.toSeconds(ms.toLong())
        return String.format("%d:%02d", seconds / 60, seconds % 60)
    }

    private fun startUpdatingProgress() {
        updateSeekBarThread?.let { handler.removeCallbacks(it) }
        updateSeekBarThread = object : Runnable {
            override fun run() {
                mediaPlayer?.let {
                    if (it.isPlaying) {
                        binding.seekSong.progress = it.currentPosition
                        binding.txCrTime.text = milliSecondToString(it.currentPosition)
                        handler.postDelayed(this, 1000)
                    }
                }
            }
        }.also { handler.post(it) }
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
        updateSeekBarThread?.let { handler.removeCallbacks(it) }
    }
}