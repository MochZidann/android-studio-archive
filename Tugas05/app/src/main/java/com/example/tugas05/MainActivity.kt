package com.example.tugas05

import android.content.Intent
import android.os.Bundle
import android.view.ContextMenu
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.PopupMenu
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.example.tugas05.databinding.ActivityMainBinding
import com.google.android.material.snackbar.Snackbar

class MainActivity : AppCompatActivity(), View.OnClickListener {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Inisialisasi ViewBinding
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Mendaftarkan Context Menu pada txContextMenu (long click)
        registerForContextMenu(binding.txContextMenu)

        // Listener untuk Popup Menu
        binding.btnPopup.setOnClickListener(this)
    }

    override fun onClick(v: View?) {
        val popMenu = PopupMenu(this, v)

        // Menghubungkan menu_popup.xml dengan PopupMenu
        popMenu.menuInflater.inflate(R.menu.menu_popup, popMenu.menu)

        // Listener ketika salah satu item popup menu dipilih
        popMenu.setOnMenuItemClickListener { item ->
            when (item.itemId) {
                R.id.itemDownload -> {
                    startActivity(Intent(this, ContohActivity::class.java))
                    Toast.makeText(baseContext, "Download film", Toast.LENGTH_SHORT).show()
                    true
                }
                R.id.itemUpload -> {
                    Toast.makeText(baseContext, "Upload film", Toast.LENGTH_SHORT).show()
                    true
                }
                R.id.Penjumlahan -> {
                    val intent = Intent(this, PenjumlahanActivity::class.java)
                    startActivity(intent)
                    true
                }
                else -> false
            }
        }
        popMenu.show()
    }

    // Membuat Context Menu
    override fun onCreateContextMenu(
        menu: ContextMenu?,
        v: View?,
        menuInfo: ContextMenu.ContextMenuInfo?
    ) {
        super.onCreateContextMenu(menu, v, menuInfo)
        menuInflater.inflate(R.menu.menu_context, menu)
    }

    // Aksi ketika Context Menu dipilih
    override fun onContextItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.itemPaste -> {
                Toast.makeText(this, "Action Paste dipilih", Toast.LENGTH_SHORT).show()
                true
            }
            R.id.itemDelete -> {
                Snackbar.make(binding.main, "Action Delete dipilih", Snackbar.LENGTH_SHORT).show()
                true
            }
            R.id.itemCopy -> {
                AlertDialog.Builder(this)
                    .setTitle("Informasi")
                    .setMessage("Action Copy dipilih")
                    .setNeutralButton("OK", null)
                    .show()
                true
            }
            R.id.Perkalian -> {
                val intent = Intent(this, PerkalianActivity::class.java)
                startActivity(intent)
                true
            }
            else -> super.onContextItemSelected(item)
        }
    }

    // Membuat Options Menu
    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_option, menu)
        return true
    }

    // Aksi ketika Options Menu dipilih
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.itemPlay -> {
                Toast.makeText(this, "Playing music", Toast.LENGTH_SHORT).show()
                true
            }
            R.id.itemPause -> {
                Snackbar.make(binding.main, "Pause the music", Snackbar.LENGTH_SHORT).show()
                true
            }
            R.id.Pembagian -> {
                val intent = Intent(this, PembagianActivity::class.java)
                startActivity(intent)
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}