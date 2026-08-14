package com.example.tugas04

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.example.tugas04.databinding.ActivityPerkalianBinding
import java.text.DecimalFormat

class PerkalianActivity : AppCompatActivity(), View.OnClickListener {
    private lateinit var binding: ActivityPerkalianBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPerkalianBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnKali.setOnClickListener(this)

        val paket = intent.extras
        binding.edX.setText(paket?.getString("X"))
        binding.edY.setText(paket?.getString("Y"))
    }

    override fun onClick(v: View?) {
        val x = binding.edX.text.toString().toDoubleOrNull() ?: 0.0
        val y = binding.edY.text.toString().toDoubleOrNull() ?: 0.0
        val hasil = x * y
        binding.txHasilKali.text = DecimalFormat("#.##").format(hasil)
    }

    override fun finish() {
        val intent = Intent()
        intent.putExtra("hasilBalik", binding.txHasilKali.text.toString())
        setResult(Activity.RESULT_OK, intent)
        super.finish()
    }
}