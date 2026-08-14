package com.example.praktik07

import android.app.AlertDialog
import android.content.ContentValues
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import com.example.praktik07.databinding.ActivityFragmentNilaiBinding

class FragmentNilai : Fragment() {

    private var vb: ActivityFragmentNilaiBinding? = null
    private val binding get() = vb!!
    private lateinit var thisParent: MainActivity
    private lateinit var db: SQLiteDatabase
    private lateinit var dialog: AlertDialog.Builder

    private var idNilai: String = ""
    private var selectedNim: String = ""
    private var selectedIdMatkul: Int = 0

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        thisParent = activity as MainActivity
        vb = ActivityFragmentNilaiBinding.inflate(inflater, container, false)
        db = thisParent.getDbObject()
        dialog = AlertDialog.Builder(thisParent)

        binding.btnSimpanNilai.setOnClickListener { aksiNilai("Simpan") }
        binding.btnUpdateNilai.setOnClickListener { aksiNilai("Update") }
        binding.btnDeleteNilai.setOnClickListener { aksiNilai("Delete") }

        binding.lsNilai.onItemClickListener = AdapterView.OnItemClickListener { parent, _, position, _ ->
            val c = parent.adapter.getItem(position) as Cursor
            idNilai = c.getString(c.getColumnIndexOrThrow("_id"))
            binding.edNilai.setText(c.getString(c.getColumnIndexOrThrow("nilai")))
            // Catatan: Spinner tidak otomatis berpindah posisi tanpa logika pencarian ID tambahan
        }

        setupSpinners()
        return binding.root
    }

    private fun aksiNilai(tipe: String) {
        val nilaiStr = binding.edNilai.text.toString()
        if (nilaiStr.isEmpty()) {
            Toast.makeText(thisParent, "Isi nilai terlebih dahulu", Toast.LENGTH_SHORT).show()
            return
        }

        when (tipe) {
            "Simpan" -> {
                val cv = ContentValues().apply {
                    put("nim", selectedNim)
                    put("id_matkul", selectedIdMatkul)
                    put("nilai", nilaiStr.toInt())
                }
                db.insert("nilai", null, cv)
            }
            "Update" -> {
                val cv = ContentValues().apply {
                    put("nilai", nilaiStr.toInt())
                }
                db.update("nilai", cv, "id_nilai = ?", arrayOf(idNilai))
            }
            "Delete" -> {
                db.delete("nilai", "id_nilai = ?", arrayOf(idNilai))
            }
        }
        binding.edNilai.setText("")
        showDataNilai()
    }

    private fun setupSpinners() {
        // Listener Spinner Mahasiswa
        binding.spMhs.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(p: AdapterView<*>?, v: View?, pos: Int, id: Long) {
                val c = p?.getItemAtPosition(pos) as Cursor
                selectedNim = c.getString(c.getColumnIndexOrThrow("_id"))
            }
            override fun onNothingSelected(p: AdapterView<*>?) {}
        }

        // Listener Spinner Matkul
        binding.spMatkul.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(p: AdapterView<*>?, v: View?, pos: Int, id: Long) {
                val c = p?.getItemAtPosition(pos) as Cursor
                selectedIdMatkul = c.getInt(c.getColumnIndexOrThrow("_id"))
            }
            override fun onNothingSelected(p: AdapterView<*>?) {}
        }
    }

    override fun onStart() {
        super.onStart()
        showSpinnerMhs()    // Memanggil fungsi isi data mhs
        showSpinnerMatkul() // Memanggil fungsi isi data matkul
        showDataNilai()
    }

    private fun showSpinnerMhs() {
        val sql = "SELECT nim AS _id, nama FROM mhs ORDER BY nama ASC"
        val c = db.rawQuery(sql, null)
        val adapter = SimpleCursorAdapter(
            thisParent, android.R.layout.simple_spinner_item, c,
            arrayOf("nama"), intArrayOf(android.R.id.text1), 0
        )
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        binding.spMhs.adapter = adapter
    }

    private fun showSpinnerMatkul() {
        val sql = "SELECT id_matkul AS _id, nama_matkul FROM matkul ORDER BY nama_matkul ASC"
        val c = db.rawQuery(sql, null)
        val adapter = SimpleCursorAdapter(
            thisParent, android.R.layout.simple_spinner_item, c,
            arrayOf("nama_matkul"), intArrayOf(android.R.id.text1), 0
        )
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        binding.spMatkul.adapter = adapter
    }

    private fun showDataNilai() {
        val sql = "SELECT n.id_nilai AS _id, m.nama, mk.nama_matkul, n.nilai " +
                "FROM nilai n " +
                "JOIN mhs m ON n.nim = m.nim " +
                "JOIN matkul mk ON n.id_matkul = mk.id_matkul " +
                "ORDER BY n.id_nilai DESC"
        val c = db.rawQuery(sql, null)
        val adapter = SimpleCursorAdapter(
            thisParent, R.layout.item_data_nilai, c,
            arrayOf("nama", "nama_matkul", "nilai"),
            intArrayOf(R.id.txNamaMhsNilai, R.id.txMatkulNilai, R.id.txSkorNilai),
            0
        )
        binding.lsNilai.adapter = adapter
    }

    override fun onDestroyView() {
        super.onDestroyView()
        vb = null
    }
}