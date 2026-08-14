package com.example.praktik04
import androidx.appcompat.app.AppCompatActivity
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import com.example.praktik04.databinding.ActivityMainBinding
class MainActivity : AppCompatActivity(), View.OnClickListener {
    //ViewBinding untuk menghubungkan layout dengan kode Kotlin
    private lateinit var binding: ActivityMainBinding
    //"requestCode" untuk membedakan hasil dari Activity yang berbeda
    //kode akan dikirim saat memanggil startActivityForResult()
    //digunakan kembali saat menerima hasil di onActivityResult()
    //yang telah dikirim dari PerkalianActivity
    val RC_PERKALIAN_SUKSES : Int = 11
    //belum terpakai di program ini
    val RC_PEMBAGIAN_SUKSES : Int = 22
    val RC_TAMBAH_SUKSES : Int = 33
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //inisialisasi binding
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        //set listener menggunakan binding
        binding.btnDetik.setOnClickListener(this)
        binding.btnGallery.setOnClickListener(this)
        binding.btnPerkalian.setOnClickListener(this)
    }
    override fun onClick(v: View?) {
        when(v?.id){
            //membuka galeri (Implicit Intent)
            R.id.btnGallery ->{
                val intentGal = Intent()
                //mengambil file dari device
                intentGal.setAction(Intent.ACTION_GET_CONTENT)
                //hanya menampilkan file dengan tipe MIME (Extensions) image/*
                intentGal.setType("image/*")
//createChooser untuk memilih aplikasi galeri yang digunakan
                startActivity(Intent.createChooser(intentGal,
                    "Pilih Gambar ..."))
            }
            //membuka web (Implicit Intent)
            R.id.btnDetik ->{
                val webUri = "https://detik.com"
                //membuka data berupa URL
                val intentInternet = Intent(Intent.ACTION_VIEW,
                    Uri.parse(webUri))
                startActivity(intentInternet)
            }
            //membuka PerkalianActivity (Explicit Intent)
            R.id.btnPerkalian ->{
                val intent = Intent(this,PerkalianActivity::class.java)
                //mengirim nilai “X” ke activity perkalian
                intent.putExtra("X",binding.edHasil.text.toString())
                //mengirim nilai Y dalam bentuk Int
                intent.putExtra("Y", 10)
                //mengirim nilai awal hasil (opsional)
                intent.putExtra("hasil",0)
                //startActivityForResult digunakan karena
//membutuhkan hasil kembali dari PerkalianActivity
                startActivityForResult(intent,RC_PERKALIAN_SUKSES)
            }
        }
    }
    //dipanggil ketika Activity lain mengirimkan hasil kembali
    override fun onActivityResult(requestCode: Int, resultCode: Int,
                                  data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        //pastikan Activity yang dipanggil selesai dengan RESULT_OK
        if(resultCode == Activity.RESULT_OK){
            //cek "requestCode" untuk memastikan
            //hasil berasal dari PerkalianActivity
            if(requestCode == RC_PERKALIAN_SUKSES)
            //ambil data dari Intent yang dikirim balik
            //key "hasilKali" harus sama
            //dengan yang dikirim dari PerkalianActivity
                binding.edHasil.setText(data?.extras?.getString("hasilKali"))
            //contoh jika ada Activity Pembagian
            if(requestCode == RC_PEMBAGIAN_SUKSES)
                binding.edHasil.setText(data?.extras?.getString("hasilBagi"))
        }
    }
}