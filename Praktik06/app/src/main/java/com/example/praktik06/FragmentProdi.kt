package com.example.praktik06
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.example.praktik06.databinding.ActivityFragmentProdiBinding
class FragmentProdi : Fragment() {
    lateinit var thisParent: MainActivity
    private var vb: ActivityFragmentProdiBinding? = null
    override fun onCreateView(inflater:LayoutInflater, container:ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        thisParent = activity as MainActivity
        vb = ActivityFragmentProdiBinding.inflate(inflater, container, false)
        return vb!!.root
    }
}