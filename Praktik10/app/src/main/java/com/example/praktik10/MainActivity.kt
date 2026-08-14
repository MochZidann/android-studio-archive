package com.example.praktik10

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.example.praktik10.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private lateinit var pref: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setSupportActionBar(binding.toolbar)

        pref = getSharedPreferences("setting", Context.MODE_PRIVATE)
        
        applySettings()
    }

    override fun onResume() {
        super.onResume()
        applySettings()
    }

    private fun applySettings() {
        val defaultTitle = getString(R.string.default_movie_title)
        val defaultDetail = getString(R.string.default_movie_detail)

        val titleText = pref.getString("title_text", defaultTitle)
        val detailText = pref.getString("detail_text", defaultDetail)
        val bgColorStr = pref.getString("bg_color", "Purple")
        val fontColorStr = pref.getString("font_color", "Black")
        val titleFontSize = pref.getInt("title_font_size", 18)
        val detailFontSize = pref.getInt("detail_font_size", 14)

        binding.tvTitle.text = titleText
        binding.tvDetail.text = detailText
        
        binding.tvTitle.textSize = titleFontSize.toFloat()
        binding.tvDetail.textSize = detailFontSize.toFloat()

        // Set Background Color
        val bgColor = when (bgColorStr) {
            "Purple" -> ContextCompat.getColor(this, R.color.purple_500)
            "Blue" -> Color.BLUE
            "Yellow" -> Color.YELLOW
            "Green" -> Color.GREEN
            "Black" -> Color.BLACK
            else -> ContextCompat.getColor(this, R.color.purple_500)
        }
        binding.tvTitle.setBackgroundColor(bgColor)

        // Set Font Color
        val fontColor = when (fontColorStr) {
            "Purple" -> ContextCompat.getColor(this, R.color.purple_500)
            "Blue" -> Color.BLUE
            "Yellow" -> Color.YELLOW
            "Green" -> Color.GREEN
            "Black" -> Color.BLACK
            else -> Color.WHITE
        }
        binding.tvTitle.setTextColor(fontColor)
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.main_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_setting -> {
                startActivity(Intent(this, SettingActivity::class.java))
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}
