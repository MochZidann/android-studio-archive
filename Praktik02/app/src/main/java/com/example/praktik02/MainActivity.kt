package com.example.praktik02

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.*

class MainActivity : AppCompatActivity() {
    val arrayKota = arrayOf("Kediri", "Jombang", "Nganjuk", "Malang", "Blitar")
    val arrayNama = arrayOf("Dimas Pratama", "Siti Rahmawati", "Dika Saputra",
        "Rina Oktaviani", "Fajar Nugroho", "Putri Maharani", "Moch. Zidan Akbar Maulana", "M Yusril Musyafak", "Shofwan ALi Santosa", "Ahmad Ubaidillah", "M Akfa Ulin")

    lateinit var arrGabungan : ArrayList<String>
    lateinit var adapterActv : ArrayAdapter<String>
    lateinit var adapterSpin : ArrayAdapter<String>
    lateinit var adapterLv : ArrayAdapter<String>

    var var1 =""; var var2 =""; var var3 =""
    var vNim =""; var vProdi =""; var vFak =""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val actv = findViewById<AutoCompleteTextView>(R.id.actv)
        val sp1 = findViewById<Spinner>(R.id.sp1)
        val lv1 = findViewById<ListView>(R.id.lv1)
        val btnSimpan = findViewById<Button>(R.id.btnSimpan)
        val textView = findViewById<TextView>(R.id.textView)

        val etNim = findViewById<EditText>(R.id.etNim)
        val etProdi = findViewById<EditText>(R.id.etProdi)
        val etFakultas = findViewById<EditText>(R.id.etFakultas)

        arrGabungan = ArrayList()

        adapterActv = ArrayAdapter(this,
            android.R.layout.simple_dropdown_item_1line, arrayNama)

        adapterSpin = ArrayAdapter(this,
            android.R.layout.simple_list_item_1, arrayKota)

        adapterLv = ArrayAdapter(this,
            android.R.layout.simple_list_item_1, arrGabungan)

        actv.setAdapter(adapterActv)
        sp1.adapter = adapterSpin
        lv1.adapter = adapterLv


        actv.threshold = 2

        actv.setOnItemClickListener { parent, view, position, id ->
            val isi = parent.getItemAtPosition(position).toString()
            Toast.makeText(this, isi, Toast.LENGTH_SHORT).show()
        }

        sp1.onItemSelectedListener = object :
            AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {}
            override fun onItemSelected(parent: AdapterView<*>?, view: View?,
                                        position: Int, id: Long) {
                Toast.makeText(baseContext, adapterSpin.getItem(position),
                    Toast.LENGTH_SHORT).show()
            }
        }

        lv1.setOnItemClickListener { parent, view, p1, id ->
            Toast.makeText(this,
                adapterLv.getItem(p1), Toast.LENGTH_SHORT).show()
        }

        btnSimpan.setOnClickListener {
            var1 = actv.text.toString()
            vNim = etNim.text.toString()
            vProdi = etProdi.text.toString()
            vFak = etFakultas.text.toString()
            var2 = sp1.selectedItem.toString()

            var3 = "NIM: $vNim\nNama: $var1\nProdi: $vProdi\nFakultas: $vFak\nAsal: $var2"

            arrGabungan.add(var3)
            adapterLv.notifyDataSetChanged()

            textView.text = var3

            Toast.makeText(this, "Berhasil simpan: $var1", Toast.LENGTH_SHORT).show()
        }
    }
}