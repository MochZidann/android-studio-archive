package com.example.praktik06
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.example.praktik06.databinding.ActivityFragmentMahasiswaBinding
class FragmentMahasiswa : Fragment() {
    //menyimpan referensi ke Activity MainActivity
    lateinit var thisParent: MainActivity
    //ViewBinding (nullable mengikuti siklus Fragment)
    private var vb: ActivityFragmentMahasiswaBinding? = null
    //membuat tampilan dari Fragment
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
//mengambil referensi tempat menampilkan fragment
        thisParent = activity as MainActivity
//inisialisasi ViewBinding dengan meng-inflate layout XML
        vb = ActivityFragmentMahasiswaBinding.inflate(inflater, container,
            false)
        return vb!!.root
    }
}