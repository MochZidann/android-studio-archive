package com.example.praktik07
import android.app.AlertDialog
import android.content.ContentValues
import android.content.DialogInterface
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.fragment.app.Fragment
import com.example.praktik07.databinding.ActivityFragmentProdiBinding

class FragmentProdi : Fragment(), View.OnClickListener {

    private var vb: ActivityFragmentProdiBinding? = null
    private val binding get() = vb!!

    private lateinit var thisParent: MainActivity
    private lateinit var lsAdapter: ListAdapter
    private lateinit var dialog: AlertDialog.Builder
    private lateinit var db: SQLiteDatabase

    private var idProdi: String = ""

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        thisParent = activity as MainActivity
        vb = ActivityFragmentProdiBinding.inflate(inflater, container, false)

        db = thisParent.getDbObject()
        dialog = AlertDialog.Builder(thisParent)

        // Event Listeners
        binding.btnUpdate.setOnClickListener(this)
        binding.btnInsert.setOnClickListener(this)
        binding.btnDelete.setOnClickListener(this)
        binding.lsProdi.onItemClickListener = itemClick

        return binding.root
    }

    override fun onStart() {
        super.onStart()
        showDataProdi()
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.btnInsert -> {
                showConfirmDialog("Konfirmasi Insert", "Data yang akan dimasukkan sudah benar?", btnInsertDialog)
            }
            R.id.btnDelete -> {
                showConfirmDialog("Konfirmasi Delete", "Yakin akan menghapus data ini?", btnDeleteDialog)
            }
            R.id.btnUpdate -> {
                showConfirmDialog("Konfirmasi Update", "Data yang akan diubah sudah benar?", btnUpdateDialog)
            }
        }
    }

    private fun showConfirmDialog(title: String, message: String, positiveAction: DialogInterface.OnClickListener) {
        dialog.setTitle(title)
            .setMessage(message)
            .setIcon(android.R.drawable.ic_dialog_info)
            .setPositiveButton("Ya", positiveAction)
            .setNegativeButton("Tidak", null)
            .show()
    }

    fun showDataProdi() {
        // Query menggunakan SQLite query builder agar lebih bersih
        val cursor: Cursor = db.query(
            "prodi",
            arrayOf("nama_prodi", "id_prodi as _id"),
            null, null, null, null, "nama_prodi ASC"
        )

        lsAdapter = SimpleCursorAdapter(
            thisParent, R.layout.item_data_prodi, cursor,
            arrayOf("_id", "nama_prodi"),
            intArrayOf(R.id.txIdProdi, R.id.txNamaProdi),
            CursorAdapter.FLAG_REGISTER_CONTENT_OBSERVER
        )
        binding.lsProdi.adapter = lsAdapter
    }

    private val itemClick = AdapterView.OnItemClickListener { parent, _, position, _ ->
        val c = parent.adapter.getItem(position) as Cursor
        idProdi = c.getString(c.getColumnIndexOrThrow("_id"))
        binding.edNamaProdi.setText(c.getString(c.getColumnIndexOrThrow("nama_prodi")))
    }

    private fun insertDataProdi(namaProdi: String) {
        val cv = ContentValues().apply {
            put("nama_prodi", namaProdi)
        }
        db.insert("prodi", null, cv)
        showDataProdi()
    }

    private fun updateDataProdi(namaProdi: String, idProdi: String) {
        val cv = ContentValues().apply {
            put("nama_prodi", namaProdi)
        }
        // Menggunakan array parameter untuk keamanan (avoid SQL Injection)
        db.update("prodi", cv, "id_prodi = ?", arrayOf(idProdi))
        showDataProdi()
    }

    private fun deleteDataProdi(idProdi: String) {
        db.delete("prodi", "id_prodi = ?", arrayOf(idProdi))
        showDataProdi()
    }

    // Dialog Listeners
    private val btnInsertDialog = DialogInterface.OnClickListener { _, _ ->
        insertDataProdi(binding.edNamaProdi.text.toString())
        binding.edNamaProdi.setText("")
    }

    private val btnUpdateDialog = DialogInterface.OnClickListener { _, _ ->
        updateDataProdi(binding.edNamaProdi.text.toString(), idProdi)
        binding.edNamaProdi.setText("")
    }

    private val btnDeleteDialog = DialogInterface.OnClickListener { _, _ ->
        deleteDataProdi(idProdi)
        binding.edNamaProdi.setText("")
    }

    override fun onDestroyView() {
        super.onDestroyView()
        vb = null
    }
}