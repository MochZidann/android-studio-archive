package com.example.praktik03

import androidx.appcompat.app.AppCompatActivity
import android.app.DatePickerDialog
import android.app.Dialog
import android.app.TimePickerDialog
import android.os.Bundle
import android.view.View
import android.widget.*
import com.example.praktik03.databinding.ActivityMainBinding
import java.util.*

class MainActivity : AppCompatActivity(), View.OnClickListener {
    // lateinit view dengan binding
    // tanpa membuat banyak lateinit untuk semua view/widget
    private lateinit var binding: ActivityMainBinding

    var tahun = 0
    var bulan = 0
    var hari = 0
    var jam = 0
    var menit = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //membuat objek penghubung ke semua view di XML
        binding = ActivityMainBinding.inflate(layoutInflater)
        //menampilkan layout ke layar
        setContentView(binding.root)
        //mendapatkan instance dari kelas Kalender
        val cal: Calendar = Calendar.getInstance()
        //bulan dimulai dari 0, jadi perlu menambahkan
        // 1 agar bulan dimulai dari 1 (Januari)
        bulan = cal.get(Calendar.MONTH) + 1
        hari = cal.get(Calendar.DAY_OF_MONTH)
        tahun = cal.get(Calendar.YEAR)
        jam = cal.get(Calendar.HOUR_OF_DAY)
        menit = cal.get(Calendar.MINUTE)
        //tidak pakai findViewById lagi
        binding.txDateTime.text = "Hari ini, tanggal $hari-$bulan-$tahun, jam $jam:$menit"
        binding.tp1.setIs24HourView(true)
        binding.tp1.setOnTimeChangedListener(timeChange)
        binding.dp1.init(tahun, bulan - 1, hari, dateChange)
        binding.btnDp1.setOnClickListener(this)
        binding.btnTp1.setOnClickListener(this)
        binding.btnDpd1.setOnClickListener(this)
        binding.btnTpd1.setOnClickListener(this)
    }

    //fungsi yang dijalankan saat View diklik.
    override fun onClick(v: View?) {
        when (v?.id) {
            //menampilkan salah satu picker
            // menyembunyikan yang lain saat tombol ditekan.
            R.id.btnDp1 -> {
                if (binding.dp1.visibility == View.GONE) {
                    binding.dp1.visibility = View.VISIBLE
                    binding.tp1.visibility = View.GONE
                }
            }
            R.id.btnTp1 -> {
                if (binding.tp1.visibility == View.GONE) {
                    binding.tp1.visibility = View.VISIBLE
                    binding.dp1.visibility = View.GONE
                }
            }
            //menampilkan jendela dialog saat salah satu tombol diklik
            //100 dan 200 = id (bebas diubah)
            R.id.btnTpd1 -> showDialog(100)
            R.id.btnDpd1 -> showDialog(200)
        }
    }

    //objek yang akan dieksekusi saat pengguna mengubah waktu
    //TimePicker
    var timeChange = TimePicker.OnTimeChangedListener { _, hourOfDay, minute ->
        binding.txDateTime.text = "Hari ini, tanggal $hari-$bulan-$tahun, jam $hourOfDay:$minute"
        jam = hourOfDay
        menit = minute
    }

    //objek yang akan dieksekusi saat pengguna mengubah tanggal
    //DatePicker
    var dateChange = DatePicker.OnDateChangedListener { _, year, monthOfYear, dayOfMonth ->
        binding.txDateTime.text = "Hari ini, tanggal $dayOfMonth-${monthOfYear + 1}-$year, jam $jam:$menit"
        tahun = year
        bulan = monthOfYear + 1
        hari = dayOfMonth
    }

    //objek yang akan dieksekusi saat pengguna mengubah waktu
    //TimePickerDialog
    var timeChangeDialog = TimePickerDialog.OnTimeSetListener { _, hourOfDay, minute ->
        binding.txDateTime.text = "Hari ini, tanggal $hari-$bulan-$tahun, jam $hourOfDay:$minute"
        jam = hourOfDay
        menit = minute
    }

    //objek yang akan dieksekusi saat pengguna mengubah tanggal
    //DatePickerDialog
    var dateChangeDialog = DatePickerDialog.OnDateSetListener { _, year, month, dayOfMonth ->
        binding.txDateTime.text = "Hari ini, tanggal $dayOfMonth-${month + 1}-$year, jam $jam:$menit"
        tahun = year
        bulan = month + 1
        hari = dayOfMonth
    }

    //fungsi untuk membuat jendela dialog
    override fun onCreateDialog(id: Int): Dialog {
        return when (id) {
            100 -> TimePickerDialog(this, timeChangeDialog, jam, menit, true)
            200 -> DatePickerDialog(this, dateChangeDialog, tahun, bulan - 1, hari)
            else -> super.onCreateDialog(id)
        }
    }
}