package com.example.tugas13

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.android.volley.Request
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.example.tugas13.databinding.ActivityMainBinding
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import kotlin.collections.HashMap

class MainActivity : AppCompatActivity(), View.OnClickListener {
    lateinit var binding: ActivityMainBinding
    lateinit var mediaHelper: MediaHelper
    lateinit var mhsAdapter: AdapterDataMhs
    lateinit var prodiAdapter: ArrayAdapter<String>

    var daftarMhs = mutableListOf<HashMap<String, String>>()
    var daftarProdi = mutableListOf<String>()

    val urlRoot = "http://10.120.204.234"
    val url = "$urlRoot/kampus/show_data.php"
    val url2 = "$urlRoot/kampus/get_nama_prodi.php"
    val url3 = "$urlRoot/kampus/query_upd_del_ins.php"

    // Variabel tambahan untuk fungsi kamera
    var fileUri: Uri? = null
    var imStr = ""
    var namafile = ""
    var pilihProdi = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Inisialisasi MediaHelper versi Kamera tanpa parameter context di konstruktor
        mediaHelper = MediaHelper()
        mhsAdapter = AdapterDataMhs(daftarMhs, this)

        binding.listMhs.layoutManager = LinearLayoutManager(this)
        binding.listMhs.adapter = mhsAdapter

        prodiAdapter = ArrayAdapter(this, android.R.layout.simple_dropdown_item_1line, daftarProdi)
        binding.spinProdi.adapter = prodiAdapter
        binding.spinProdi.onItemSelectedListener = itemSelected

        binding.imUpload.setOnClickListener(this)
        binding.btnUpdate.setOnClickListener(this)
        binding.btnInsert.setOnClickListener(this)
        binding.btnDelete.setOnClickListener(this)
        binding.btnFind.setOnClickListener(this)
    }

    override fun onStart() {
        super.onStart()
        showDataMhs("")
        getNamaProdi()
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            // Ubah intent galeri menjadi permission request untuk kamera
            R.id.imUpload -> cameraPermission.launch(Manifest.permission.CAMERA)

            R.id.btnInsert -> queryInsertUpdateDelete("insert")
            R.id.btnDelete -> queryInsertUpdateDelete("delete")
            R.id.btnUpdate -> queryInsertUpdateDelete("update")
            R.id.btnFind -> showDataMhs(binding.edNamaMhs.text.toString().trim())
        }
    }

    private val itemSelected = object : AdapterView.OnItemSelectedListener {
        override fun onNothingSelected(parent: AdapterView<*>?) {}
        override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
            pilihProdi = daftarProdi[position]
        }
    }

    // Launcher untuk izin kamera
    private val cameraPermission =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) {
                openCamera()
            } else {
                Toast.makeText(this, "Izin kamera ditolak", Toast.LENGTH_SHORT).show()
            }
        }

    // Fungsi membuka aplikasi kamera
    private fun openCamera() {
        fileUri = mediaHelper.getOutputMediaFileUri(this)
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri)
        startActivityForResult(intent, mediaHelper.getRcCamera())
    }

    // Proses setelah foto selesai diambil
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK && requestCode == mediaHelper.getRcCamera()) {
            val uri = fileUri ?: return
            val stream = contentResolver.openInputStream(uri)
            val bmp = BitmapFactory.decodeStream(stream)
            stream?.close()

            if (bmp != null) {
                binding.imUpload.setImageBitmap(bmp)
                imStr = mediaHelper.bitmapToString(bmp)
                namafile = mediaHelper.getMyFileName()
            }
        }
    }

    fun queryInsertUpdateDelete(mode: String) {
        val request = object : StringRequest(Method.POST, url3,
            Response.Listener { response ->
                try {
                    val jsonObject = JSONObject(response)
                    if (jsonObject.getString("kode") == "000") {
                        Toast.makeText(this, "Berhasil!", Toast.LENGTH_SHORT).show()
                        showDataMhs("")
                        resetForm()
                    }
                } catch (e: Exception) {}
            },
            Response.ErrorListener {
                Toast.makeText(this, "Koneksi gagal", Toast.LENGTH_SHORT).show()
            }) {
            override fun getParams(): MutableMap<String, String> {
                val hm = HashMap<String, String>()
                val gender = if (binding.rbLaki.isChecked) "Laki-laki" else if (binding.rbPerempuan.isChecked) "Perempuan" else ""

                hm["mode"] = mode
                hm["nim"] = binding.edNim.text.toString()
                hm["nama"] = binding.edNamaMhs.text.toString()
                hm["alamat"] = binding.edAlamat.text.toString()
                hm["gender"] = gender
                hm["image"] = imStr

                // Gunakan variabel namafile yang digenerate oleh kamera, bukan buat baru
                hm["file"] = namafile
                hm["nama_prodi"] = pilihProdi

                return hm
            }
        }
        Volley.newRequestQueue(this).add(request)
    }

    private fun resetForm() {
        imStr = ""
        namafile = "" // reset namafile
        binding.edNim.setText("")
        binding.edNamaMhs.setText("")
        binding.edAlamat.setText("")
        binding.rgGender.clearCheck()
        binding.imUpload.setImageResource(android.R.drawable.ic_menu_camera)
    }

    fun getNamaProdi() {
        val request = StringRequest(Request.Method.POST, url2,
            Response.Listener { response ->
                daftarProdi.clear()
                try {
                    val jsonArray = JSONArray(response)
                    for (x in 0 until jsonArray.length()) {
                        daftarProdi.add(jsonArray.getJSONObject(x).getString("nama_prodi"))
                    }
                    prodiAdapter.notifyDataSetChanged()
                    if (daftarProdi.isNotEmpty()) pilihProdi = daftarProdi[0]
                } catch (e: Exception) {}
            },
            Response.ErrorListener { }
        )
        Volley.newRequestQueue(this).add(request)
    }

    fun showDataMhs(namaMhs: String) {
        val request = object : StringRequest(Request.Method.POST, url,
            Response.Listener { response ->
                daftarMhs.clear()
                try {
                    val jsonArray = JSONArray(response)
                    for (x in 0 until jsonArray.length()) {
                        val jsonObject = jsonArray.getJSONObject(x)
                        val mhs = HashMap<String, String>()
                        mhs["nim"] = jsonObject.optString("nim", "-")
                        mhs["nama"] = jsonObject.optString("nama", "-")
                        mhs["alamat"] = if (jsonObject.isNull("alamat") || jsonObject.optString("alamat").isEmpty()) "-" else jsonObject.getString("alamat")
                        mhs["gender"] = if (jsonObject.isNull("gender") || jsonObject.optString("gender").isEmpty()) "-" else jsonObject.getString("gender")
                        mhs["nama_prodi"] = jsonObject.optString("nama_prodi", "-")
                        mhs["foto"] = if (jsonObject.has("foto") && !jsonObject.isNull("foto")) jsonObject.getString("foto") else ""
                        daftarMhs.add(mhs)
                    }
                    mhsAdapter.notifyDataSetChanged()
                } catch (e: Exception) {}
            },
            Response.ErrorListener {
                Toast.makeText(this, "Gagal ambil data", Toast.LENGTH_SHORT).show()
            }) {
            override fun getParams(): MutableMap<String, String> {
                val hm = HashMap<String, String>()
                hm["nama"] = namaMhs
                return hm
            }
        }
        Volley.newRequestQueue(this).add(request)
    }
}