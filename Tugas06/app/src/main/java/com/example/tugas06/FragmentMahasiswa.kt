package com.example.tugas06

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.example.tugas06.databinding.ActivityFragmentMahasiswaBinding

data class Mahasiswa(val nim: String, val nama: String, val prodi: String) {
    override fun toString(): String = "$nim - $nama ($prodi)"
}

class FragmentMahasiswa : Fragment() {
    private var _vb: ActivityFragmentMahasiswaBinding? = null
    private val vb get() = _vb!!

    // List data sementara di memori
    private val listMhs = mutableListOf<Mahasiswa>()
    private lateinit var adapter: ArrayAdapter<Mahasiswa>

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _vb = ActivityFragmentMahasiswaBinding.inflate(inflater, container, false)
        return vb.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // Isi Spinner Prodi
        val prodiArray = arrayOf("Informatika", "Sistem Informasi", "Teknik Elektro")
        vb.spinner.adapter = ArrayAdapter(requireContext(), android.R.layout.simple_spinner_dropdown_item, prodiArray)

        // Hubungkan List ke ListView via Adapter
        adapter = ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, listMhs)
        vb.lsMhs.adapter = adapter

        // --- Logika CRUD ---

        // Simpan Data
        vb.btnInsertMhs.setOnClickListener {
            val nim = vb.edNimMhs.text.toString()
            val nama = vb.edNamaMhs.text.toString()
            val prodi = vb.spinner.selectedItem.toString()

            if (nim.isNotBlank() && nama.isNotBlank()) {
                listMhs.add(Mahasiswa(nim, nama, prodi))
                adapter.notifyDataSetChanged() // Update tampilan ListView
                bersihkanInput()
            } else {
                Toast.makeText(context, "Data tidak boleh kosong!", Toast.LENGTH_SHORT).show()
            }
        }

        // Cari Data berdasarkan NIM
        vb.btnCari.setOnClickListener {
            val nimCari = vb.edNimMhs.text.toString()
            val mhs = listMhs.find { it.nim == nimCari }

            if (mhs != null) {
                vb.edNamaMhs.setText(mhs.nama)
                val pos = prodiArray.indexOf(mhs.prodi)
                vb.spinner.setSelection(pos)
            } else {
                Toast.makeText(context, "NIM $nimCari tidak ditemukan", Toast.LENGTH_SHORT).show()
            }
        }

        // Update Data
        vb.btnUpdateMhs.setOnClickListener {
            val nim = vb.edNimMhs.text.toString()
            val index = listMhs.indexOfFirst { it.nim == nim }

            if (index != -1) {
                listMhs[index] = Mahasiswa(nim, vb.edNamaMhs.text.toString(), vb.spinner.selectedItem.toString())
                adapter.notifyDataSetChanged()
                bersihkanInput()
                Toast.makeText(context, "Data diperbarui", Toast.LENGTH_SHORT).show()
            }
        }

        // Hapus Data
        vb.btnDeleteMhs.setOnClickListener {
            val nim = vb.edNimMhs.text.toString()
            if (listMhs.removeIf { it.nim == nim }) {
                adapter.notifyDataSetChanged()
                bersihkanInput()
                Toast.makeText(context, "Data dihapus", Toast.LENGTH_SHORT).show()
            }
        }

        // Klik item di list langsung masuk ke form
        vb.lsMhs.setOnItemClickListener { _, _, position, _ ->
            val data = listMhs[position]
            vb.edNimMhs.setText(data.nim)
            vb.edNamaMhs.setText(data.nama)
        }
    }

    private fun bersihkanInput() {
        vb.edNimMhs.text?.clear()
        vb.edNamaMhs.text?.clear()
        vb.spinner.setSelection(0)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _vb = null
    }
}