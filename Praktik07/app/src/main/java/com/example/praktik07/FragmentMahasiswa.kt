package com.example.praktik07

import android.content.ContentValues
import android.database.Cursor
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import com.example.praktik07.databinding.ActivityFragmentMahasiswaBinding

class FragmentMahasiswa : Fragment() {
    private var _vb: ActivityFragmentMahasiswaBinding? = null
    private val binding get() = _vb!!
    private lateinit var db: android.database.sqlite.SQLiteDatabase
    private var idProdiTerpilih: Int = 0

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _vb = ActivityFragmentMahasiswaBinding.inflate(inflater, container, false)
        db = (activity as MainActivity).getDbObject()

        // Tombol Aksi
        binding.btnInsertMhs.setOnClickListener { prosesMhs("Insert") }
        binding.btnUpdateMhs.setOnClickListener { prosesMhs("Update") }
        binding.btnDeleteMhs.setOnClickListener { prosesMhs("Delete") }
        binding.btnCari.setOnClickListener { tampilMhs(binding.edNamaMhs.text.toString()) }

        // PINDAHKAN DATA KE INPUT SAAT LIST DIKLIK (UNTUK UPDATE/DELETE)
        binding.lsMhs.setOnItemClickListener { parent, _, pos, _ ->
            val c = parent.adapter.getItem(pos) as Cursor
            binding.edNimMhs.setText(c.getString(c.getColumnIndexOrThrow("_id")))
            binding.edNamaMhs.setText(c.getString(c.getColumnIndexOrThrow("nama")))
            // NIM diset Enabled(false) jika tidak ingin NIM diubah saat update
            binding.edNimMhs.isEnabled = false
        }

        loadSpinnerProdi()
        tampilMhs("")
        return binding.root
    }

    private fun loadSpinnerProdi() {
        val c = db.rawQuery("SELECT id_prodi AS _id, nama_prodi FROM prodi", null)
        val adp = SimpleCursorAdapter(requireContext(), android.R.layout.simple_spinner_item, c, arrayOf("nama_prodi"), intArrayOf(android.R.id.text1), 0)
        adp.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        binding.spinner.adapter = adp
        binding.spinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(p: AdapterView<*>?, v: View?, pos: Int, id: Long) {
                val cur = p?.getItemAtPosition(pos) as Cursor
                idProdiTerpilih = cur.getInt(cur.getColumnIndexOrThrow("_id"))
            }
            override fun onNothingSelected(p: AdapterView<*>?) {}
        }
    }

    private fun prosesMhs(tipe: String) {
        val nim = binding.edNimMhs.text.toString()
        val nama = binding.edNamaMhs.text.toString()
        val cv = ContentValues().apply {
            put("nama", nama)
            put("id_prodi", idProdiTerpilih)
        }

        when (tipe) {
            "Insert" -> { cv.put("nim", nim); db.insert("mhs", null, cv) }
            "Update" -> db.update("mhs", cv, "nim=?", arrayOf(nim))
            "Delete" -> db.delete("mhs", "nim=?", arrayOf(nim))
        }

        // Reset form
        binding.edNimMhs.setText("")
        binding.edNamaMhs.setText("")
        binding.edNimMhs.isEnabled = true
        tampilMhs("")
    }

    private fun tampilMhs(cari: String) {
        val sql = "SELECT m.nim AS _id, m.nama, p.nama_prodi FROM mhs m JOIN prodi p ON m.id_prodi=p.id_prodi WHERE m.nama LIKE '%$cari%'"
        val c = db.rawQuery(sql, null)
        val adp = SimpleCursorAdapter(requireContext(), R.layout.item_data_mhs, c,
            arrayOf("_id", "nama", "nama_prodi"),
            intArrayOf(R.id.txNimMhs, R.id.txNamaMhs, R.id.txNamaPS), 0)
        binding.lsMhs.adapter = adp
    }

    override fun onDestroyView() { super.onDestroyView(); _vb = null }
}