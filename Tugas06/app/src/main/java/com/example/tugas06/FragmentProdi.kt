package com.example.tugas06

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.example.tugas06.databinding.ActivityFragmentProdiBinding

class FragmentProdi : Fragment() {
    private var _vb: ActivityFragmentProdiBinding? = null
    private val vb get() = _vb!!

    private val listProdi = ArrayList<String>()
    private lateinit var adapter: ArrayAdapter<String>
    private var selectedPosition: Int = -1

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _vb = ActivityFragmentProdiBinding.inflate(inflater, container, false)
        return vb.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        adapter = ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, listProdi)
        vb.lsProdi.adapter = adapter

        vb.btnInsert.setOnClickListener {
            val namaProdi = vb.edNamaProdi.text.toString()
            if (namaProdi.isNotEmpty()) {
                listProdi.add(namaProdi)
                adapter.notifyDataSetChanged()
                clearInput()
            } else {
                Toast.makeText(context, "Masukkan nama prodi!", Toast.LENGTH_SHORT).show()
            }
        }

        vb.btnUpdate.setOnClickListener {
            val namaBaru = vb.edNamaProdi.text.toString()
            if (selectedPosition != -1 && namaBaru.isNotEmpty()) {
                listProdi[selectedPosition] = namaBaru
                adapter.notifyDataSetChanged()
                clearInput()
                selectedPosition = -1
            } else {
                Toast.makeText(context, "Pilih data di list dahulu!", Toast.LENGTH_SHORT).show()
            }
        }

        vb.btnDelete.setOnClickListener {
            if (selectedPosition != -1) {
                listProdi.removeAt(selectedPosition)
                adapter.notifyDataSetChanged()
                clearInput()
                selectedPosition = -1
            } else {
                Toast.makeText(context, "Pilih data di list dahulu!", Toast.LENGTH_SHORT).show()
            }
        }

        vb.lsProdi.setOnItemClickListener { _, _, position, _ ->
            selectedPosition = position
            vb.edNamaProdi.setText(listProdi[position])
        }
    }

    private fun clearInput() {
        vb.edNamaProdi.text?.clear()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _vb = null
    }
}