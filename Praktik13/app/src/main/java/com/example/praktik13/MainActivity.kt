package com.example.praktik13 // Sesuaikan dengan package Anda

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.example.praktik13.databinding.ActivityMainBinding
import org.json.JSONObject

class MainActivity : AppCompatActivity(), View.OnClickListener {
    lateinit var binding: ActivityMainBinding

    // Helper untuk file foto
    lateinit var mediaHelper: MediaHelper
    var fileUri: Uri? = null
    var imstr = ""
    var namafile = ""

    // Sesuaikan dengan IP server Apache Anda
    val url = "http://10.120.204.234/kampus/upload.php"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Inisialisasi MediaHelper
        mediaHelper = MediaHelper()
        binding.btnCamera.setOnClickListener(this)
        binding.btnSend.setOnClickListener(this)
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.btnCamera -> cameraPermission.launch(Manifest.permission.CAMERA)
            R.id.btnSend -> uploadFile()
        }
    }

    private val cameraPermission =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) {
                openCamera()
            } else {
                Toast.makeText(this, "Izin kamera ditolak", Toast.LENGTH_SHORT).show()
            }
        }

    fun openCamera() {
        // Buat file Uri untuk hasil foto
        fileUri = mediaHelper.getOutputMediaFileUri(this)
        // Intent buka kamera bawaan
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        // Lokasi penyimpanan hasil foto
        intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri)
        startActivityForResult(intent, mediaHelper.getRcCamera())
    }

    // Hasil setelah foto diambil
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // Cek hasil kamera
        if (resultCode == Activity.RESULT_OK && requestCode == mediaHelper.getRcCamera()) {
            // Ambil uri file hasil foto
            val uri = fileUri ?: return
            // Baca file dari uri menjadi stream
            val stream = contentResolver.openInputStream(uri)
            // Ubah stream menjadi bitmap
            val bmp = BitmapFactory.decodeStream(stream)
            stream?.close()

            if (bmp != null) {
                // Tampilkan gambar ke ImageView
                binding.imv.setImageBitmap(bmp)
                // Ubah bitmap menjadi string (Base64)
                imstr = mediaHelper.bitmapToString(bmp)
                // Ambil nama foto
                namafile = mediaHelper.getMyFileName()
            }
        }
    }

    fun uploadFile() {
        // Buat request POST ke server menggunakan Volley
        val request = object : StringRequest(
            Method.POST, url,
            Response.Listener { response ->
                val jsonObject = JSONObject(response)
                val kode = jsonObject.getString("kode")

                // Cek hasil upload dari server
                if (kode == "000") {
                    Toast.makeText(this, "Upload foto sukses", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(this, "Upload foto gagal", Toast.LENGTH_SHORT).show()
                }
            },
            Response.ErrorListener {
                Toast.makeText(this, "Tidak dapat terhubung ke server", Toast.LENGTH_SHORT).show()
            }
        ) {
            // Data yang dikirim ke PHP server
            override fun getParams(): MutableMap<String, String> {
                return hashMapOf(
                    "imstr" to imstr,
                    "namafile" to namafile
                )
            }
        }
        // Jalankan request ke server
        Volley.newRequestQueue(this).add(request)
    }
}