package com.example.tugas03

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.SimpleAdapter
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.tugas03.databinding.ActivityMainBinding
import java.util.*

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val dataList = ArrayList<HashMap<String, String>>()
    private lateinit var adapter: SimpleAdapter
    private var itemCounter = 1
    private var tgl = ""
    private var jam = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val listJenis = arrayOf("Pupuk", "Obat", "Pestisida")
        binding.acJenisBarang.setAdapter(ArrayAdapter(this, android.R.layout.simple_list_item_1, listJenis))
        binding.acJenisBarang.setOnClickListener { binding.acJenisBarang.showDropDown() }

        adapter = SimpleAdapter(
            this, dataList, android.R.layout.simple_list_item_2,
            arrayOf("line1", "line2"), intArrayOf(android.R.id.text1, android.R.id.text2)
        )
        binding.lvData.adapter = adapter

        val cal = Calendar.getInstance()

        binding.btnDpd1.setOnClickListener {
            DatePickerDialog(this, { _, y, m, d ->
                tgl = "$d/${m + 1}/$y"
                binding.txDateTime.text = "Terpilih: $tgl $jam"
            }, cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.get(Calendar.DAY_OF_MONTH)).show()
        }

        binding.btnTpd1.setOnClickListener {
            TimePickerDialog(this, { _, h, min ->
                jam = String.format("%02d:%02d", h, min)
                binding.txDateTime.text = "Terpilih: $tgl $jam"
            }, cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE), true).show()
        }

        binding.btnSimpan.setOnClickListener {
            val nama = binding.etNamaProduk.text.toString().trim()
            val stok = binding.etStok.text.toString().trim()
            val jenis = binding.acJenisBarang.text.toString().trim()

            if (nama.isNotEmpty() && stok.isNotEmpty() && tgl.isNotEmpty()) {
                val map = HashMap<String, String>()
                map["line1"] = "BRG${String.format("%02d", itemCounter++)} - $nama"
                map["line2"] = "Stok: $stok | $jenis | $tgl $jam"

                dataList.add(0, map)
                adapter.notifyDataSetChanged()

                binding.etNamaProduk.text.clear()
                binding.etStok.text.clear()
                binding.acJenisBarang.setText("")
                tgl = ""; jam = ""
                binding.txDateTime.text = "Waktu belum dipilih"
                Toast.makeText(this, "Data Berhasil Disimpan", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Data tidak lengkap!", Toast.LENGTH_SHORT).show()
            }
        }
    }
}