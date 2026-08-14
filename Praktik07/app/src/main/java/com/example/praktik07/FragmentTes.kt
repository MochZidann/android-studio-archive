package com.example.praktik07
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.example.praktik07.databinding.ActivityFragmentTesBinding
class FragmentTes : Fragment() {
    lateinit var thisParent: MainActivity
    private var vb: ActivityFragmentTesBinding? = null
    override fun onCreateView(inflater:LayoutInflater, container:ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        thisParent = activity as MainActivity
        vb = ActivityFragmentTesBinding.inflate(inflater, container, false)
        return vb!!.root
    }
}
