package com.example.praktik01

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.*

class MainActivity : AppCompatActivity() {
    //deklarasi tipe data variabel secara implisit
    var var1 = ""
    var var2 = ""

    //deklarasi tipe data variabel secara eksplisit
    var var3: String = ""
    var var4: String = ""
    var var5: String = ""
    var varFinal: String = ""

    //deklarasi variabel yang tidak bisa diubah
    val var6 = "hello world"
    val phi = 3.14
    var vi = 6.7

    //pembuatan fungsi
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val rg1 = findViewById<RadioGroup>(R.id.rg1)
        val btn1 = findViewById<Button>(R.id.btn1)
        val cb1 = findViewById<CheckBox>(R.id.cb1)
        val cb2 = findViewById<CheckBox>(R.id.cb2)
        val cb3 = findViewById<CheckBox>(R.id.cb3)
        val edt1 = findViewById<EditText>(R.id.edt1)
        val tx1 = findViewById<TextView>(R.id.tx1)

        rg1.setOnCheckedChangeListener { group, checkedId ->
            when (checkedId) {
                R.id.rbSd -> var4 = "SD"
                R.id.rbSmp -> var4 = "SMP"
                R.id.rbSma -> var4 = "SMA"
            }
        }

        btn1.setOnClickListener {
            if (cb1.isChecked) var1 = "Tinggi" else var1 = "Pendek"
            if (cb2.isChecked) var2 = "Gondrong" else var2 = "Gundul"
            if (cb3.isChecked) var3 = "WNI" else var3 = "Non-WNI"
            var5 = edt1.text.toString()
            varFinal = "$var1 $var2 $var3 $var4 $var5 ITULAH ISINYA"
            tx1.setText(varFinal)
        }
    }
}