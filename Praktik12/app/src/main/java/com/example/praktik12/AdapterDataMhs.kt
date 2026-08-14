package com.example.praktik12

import android.graphics.Color
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.praktik12.databinding.RowMhsBinding
import com.squareup.picasso.Picasso

class AdapterDataMhs(
    val dataMhs: List<HashMap<String, String>>,
    val mainActivity: MainActivity
) : RecyclerView.Adapter<AdapterDataMhs.HolderDataMhs>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): HolderDataMhs {
        val binding = RowMhsBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return HolderDataMhs(binding)
    }

    override fun getItemCount(): Int = dataMhs.size

    override fun onBindViewHolder(holder: HolderDataMhs, position: Int) {
        val data = dataMhs[position]

        // Warna selang-seling biar simple tapi rapi
        if (position % 2 == 0) {
            holder.binding.cLayout.setBackgroundColor(Color.parseColor("#F5FDFB"))
        } else {
            holder.binding.cLayout.setBackgroundColor(Color.WHITE)
        }

        // Tampilkan data ke TextView dengan LABEL biar jelas semua kolom muncul biarpun isinya NULL
        holder.binding.txNim.text = "NIM: ${data["nim"]}"
        holder.binding.txNama.text = data["nama"]
        holder.binding.txProdi.text = "Prodi: ${data["nama_prodi"]}"
        holder.binding.txAlamat.text = "Alamat: ${data["alamat"]}"
        holder.binding.txGender.text = "Gender: ${data["gender"]}"

        // PERBAIKAN: Gunakan key "foto" sesuai di database kamu
        var imageUrl = data["foto"] ?: ""
        if (imageUrl.isNotEmpty() && !imageUrl.startsWith("http")) {
            // Arahkan ke folder images/ di server Laragon
            imageUrl = "${mainActivity.urlRoot}/kampus/images/$imageUrl"
        }

        if (imageUrl.isNotEmpty()) {
            Picasso.get()
                .load(imageUrl)
                .placeholder(android.R.drawable.ic_menu_gallery)
                .error(android.R.drawable.ic_menu_report_image) // Muncul icon ini jika link error
                .into(holder.binding.imageView)
        } else {
            holder.binding.imageView.setImageResource(android.R.drawable.ic_menu_gallery)
        }

        // Saat item diklik, isi form di MainActivity
        holder.binding.cLayout.setOnClickListener {
            mainActivity.binding.edNim.setText(data["nim"])
            mainActivity.binding.edNamaMhs.setText(data["nama"])
            mainActivity.binding.edAlamat.setText(if (data["alamat"] == "-") "" else data["alamat"])

            // Set Gender
            if (data["gender"] == "Laki-laki") {
                mainActivity.binding.rbLaki.isChecked = true
            } else if (data["gender"] == "Perempuan") {
                mainActivity.binding.rbPerempuan.isChecked = true
            } else {
                mainActivity.binding.rgGender.clearCheck()
            }

            // Set Spinner Prodi
            val pos = mainActivity.daftarProdi.indexOf(data["nama_prodi"])
            if (pos != -1) mainActivity.binding.spinProdi.setSelection(pos)

            // Preview gambar di form atas
            if (imageUrl.isNotEmpty()) {
                Picasso.get().load(imageUrl)
                    .placeholder(android.R.drawable.ic_menu_camera)
                    .error(android.R.drawable.ic_menu_camera)
                    .into(mainActivity.binding.imUpload)
            } else {
                mainActivity.binding.imUpload.setImageResource(android.R.drawable.ic_menu_camera)
            }
        }
    }

    inner class HolderDataMhs(val binding: RowMhsBinding) : RecyclerView.ViewHolder(binding.root)
}
