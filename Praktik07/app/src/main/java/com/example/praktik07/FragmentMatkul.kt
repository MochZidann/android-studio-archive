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
import com.example.praktik07.databinding.ActivityFragmentMatkulBinding

class FragmentMatkul : Fragment(), View.OnClickListener {

    private var vb: ActivityFragmentMatkulBinding? = null
    private val binding get() = vb!!
    private lateinit var thisParent: MainActivity
    private lateinit var db: SQLiteDatabase
    private lateinit var dialog: AlertDialog.Builder
    private var idMatkul: String = ""

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        thisParent = activity as MainActivity
        vb = ActivityFragmentMatkulBinding.inflate(inflater, container, false)
        db = thisParent.getDbObject()
        dialog = AlertDialog.Builder(thisParent)

        binding.btnInsertMatkul.setOnClickListener(this)
        binding.btnUpdateMatkul.setOnClickListener(this)
        binding.btnDeleteMatkul.setOnClickListener(this)

        binding.lsMatkul.onItemClickListener = AdapterView.OnItemClickListener { parent, _, position, _ ->
            val c = parent.adapter.getItem(position) as Cursor
            idMatkul = c.getString(c.getColumnIndexOrThrow("_id"))
            binding.edNamaMatkul.setText(c.getString(c.getColumnIndexOrThrow("nama_matkul")))
            binding.edSks.setText(c.getString(c.getColumnIndexOrThrow("sks")))
        }

        return binding.root
    }

    override fun onStart() {
        super.onStart()
        showDataMatkul()
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.btnInsertMatkul -> konfirmasiSimpan("Tambah")
            R.id.btnUpdateMatkul -> konfirmasiSimpan("Ubah")
            R.id.btnDeleteMatkul -> konfirmasiSimpan("Hapus")
        }
    }

    private fun konfirmasiSimpan(aksi: String) {
        dialog.setTitle("Konfirmasi $aksi")
            .setMessage("Apakah Anda yakin ingin $aksi data ini?")
            .setPositiveButton("Ya") { _, _ ->
                val nama = binding.edNamaMatkul.text.toString()
                val sks = binding.edSks.text.toString()

                when (aksi) {
                    "Tambah" -> {
                        val cv = ContentValues().apply {
                            put("nama_matkul", nama)
                            put("sks", sks.toInt())
                        }
                        db.insert("matkul", null, cv)
                    }
                    "Ubah" -> {
                        val cv = ContentValues().apply {
                            put("nama_matkul", nama)
                            put("sks", sks.toInt())
                        }
                        db.update("matkul", cv, "id_matkul = ?", arrayOf(idMatkul))
                    }
                    "Hapus" -> {
                        db.delete("matkul", "id_matkul = ?", arrayOf(idMatkul))
                    }
                }
                resetInput()
            }.setNegativeButton("Tidak", null).show()
    }

    private fun resetInput() {
        binding.edNamaMatkul.setText("")
        binding.edSks.setText("")
        idMatkul = ""
        showDataMatkul()
    }

    private fun showDataMatkul() {
        val c = db.rawQuery("SELECT id_matkul AS _id, nama_matkul, sks FROM matkul ORDER BY nama_matkul ASC", null)
        val adapter = SimpleCursorAdapter(
            thisParent, R.layout.item_data_matkul, c,
            arrayOf("nama_matkul", "sks"),
            intArrayOf(R.id.txNamaMatkul, R.id.txSks), 0
        )
        binding.lsMatkul.adapter = adapter
    }

    override fun onDestroyView() {
        super.onDestroyView()
        vb = null
    }
}