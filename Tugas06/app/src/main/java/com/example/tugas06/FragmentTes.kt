package com.example.tugas06

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.example.tugas06.databinding.ActivityFragmentTesBinding
import java.text.DecimalFormat

class FragmentTes : Fragment(), View.OnClickListener {
    private var _vb: ActivityFragmentTesBinding? = null
    private val vb get() = _vb!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _vb = ActivityFragmentTesBinding.inflate(inflater, container, false)
        return vb.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        vb.btnKali.setOnClickListener(this)

        arguments?.let {
            vb.edX.setText(it.getString("X"))
            vb.edY.setText(it.getString("Y"))
        }
    }

    override fun onClick(v: View?) {
        val x = vb.edX.text.toString().toDoubleOrNull() ?: 0.0
        val y = vb.edY.text.toString().toDoubleOrNull() ?: 0.0
        val hasil = x * y
        vb.txHasilKali.text = DecimalFormat("#.##").format(hasil)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _vb = null
    }
}