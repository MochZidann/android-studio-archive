package com.example.praktik04
import androidx.appcompat.app.AppCompatActivity
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import com.example.praktik04.databinding.ActivityPerkalianBinding
import java.text.DecimalFormat
class PerkalianActivity : AppCompatActivity(),
    View.OnClickListener {
    //ViewBinding untuk layout ActivityPerkalian
    private lateinit var binding: ActivityPerkalianBinding
    var x : Double = 0.0
    var y : Double = 0.0
    var hasil : Double = 0.0
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //inisialisasi binding
        binding = ActivityPerkalianBinding.inflate(layoutInflater)
        setContentView(binding.root)
        binding.btnKali.setOnClickListener(this)
        //menerima data dari MainActivity
        //intent.extras berisi data yang dikirim via putExtra()
        val paket : Bundle? = intent.extras
        //mengambil nilai X, Y, dan menampilkan Y sementara
        binding.edX.setText(paket?.getString("X"))
        binding.edY.setText(paket?.getInt("Y").toString())
        Toast.makeText(this,paket?.getInt("Y").toString(),
            Toast.LENGTH_SHORT).show()
    }
    override fun onClick(v: View?) {
        //ambil input dari EditText lalu konversi ke Double
        x = binding.edX.text.toString().toDouble()
        y = binding.edY.text.toString().toDouble()
        hasil = x * y
        //tampilkan hasil dengan format 2 angka di belakang koma
        binding.txHasilKali.text = DecimalFormat("#.##").format(hasil)
    }
    //fungsi dipanggil ketika activity ditutup
    override fun finish() {
        //intent kosong untuk membawa kembali MainActivity
        val intent= Intent()
        //mengirim haril ke activity induk
        //Key "hasilKali" harus sama dengan yang diambil di MainActivity
        intent.putExtra("hasilKali",binding.txHasilKali.text)
        //activity selesai dengan sukses (RESULT_OK)
        //dan mengirim intent yang berisi data
        setResult(Activity.RESULT_OK,intent)
        super.finish()
    }
}