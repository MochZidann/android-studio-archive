package com.example.tugas05

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.example.tugas05.databinding.ActivityPembagianBinding
import java.text.DecimalFormat

class PembagianActivity : AppCompatActivity(), View.OnClickListener {
    private lateinit var binding: ActivityPembagianBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPembagianBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnBagi.setOnClickListener(this)

        val paket = intent.extras
        binding.edX.setText(paket?.getString("X"))
        binding.edY.setText(paket?.getString("Y"))
    }

    override fun onClick(v: View?) {
        val x = binding.edX.text.toString().toDoubleOrNull() ?: 0.0
        val y = binding.edY.text.toString().toDoubleOrNull() ?: 0.0
        val hasil = if (y != 0.0) x / y else 0.0
        binding.txHasilBagi.text = DecimalFormat("#.##").format(hasil)
    }

    override fun finish() {
        val intent = Intent()
        intent.putExtra("hasilBalik", binding.txHasilBagi.text.toString())
        setResult(Activity.RESULT_OK, intent)
        super.finish()
    }
}