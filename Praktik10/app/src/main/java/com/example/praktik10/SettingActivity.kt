package com.example.praktik10

import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.RadioButton
import androidx.appcompat.app.AppCompatActivity
import com.example.praktik10.databinding.ActivitySettingBinding

class SettingActivity : AppCompatActivity() {
    private lateinit var binding: ActivitySettingBinding
    private lateinit var pref: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySettingBinding.inflate(layoutInflater)
        setContentView(binding.root)

        pref = getSharedPreferences("setting", Context.MODE_PRIVATE)
        
        setSupportActionBar(binding.toolbarSetting)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        binding.toolbarSetting.setNavigationOnClickListener {
            onBackPressed()
        }

        loadCurrentSettings()

        binding.btnSimpanSetting.setOnClickListener {
            saveSettings()
        }
    }

    private fun loadCurrentSettings() {
        val defaultTitle = getString(R.string.default_movie_title)
        val defaultDetail = getString(R.string.default_movie_detail)

        // Load Title Text
        binding.etTitle.setText(pref.getString("title_text", defaultTitle))
        
        // Load Detail Text
        binding.etDetail.setText(pref.getString("detail_text", defaultDetail))

        // Load Background Color Spinner
        val bgColor = pref.getString("bg_color", "Purple")
        val colorOptions = resources.getStringArray(R.array.color_options)
        val bgIndex = colorOptions.indexOf(bgColor)
        if (bgIndex >= 0) binding.spinnerBgColor.setSelection(bgIndex)

        // Load Font Color RadioGroup
        val fontColor = pref.getString("font_color", "Black")
        when (fontColor) {
            "Blue" -> binding.rbBlue.isChecked = true
            "Yellow" -> binding.rbYellow.isChecked = true
            "Green" -> binding.rbGreen.isChecked = true
            "Black" -> binding.rbBlack.isChecked = true
            "Purple" -> binding.rbPurple.isChecked = true
        }

        // Load SeekBars
        binding.sbTitleFontSize.progress = pref.getInt("title_font_size", 18)
        binding.sbDetailFontSize.progress = pref.getInt("detail_font_size", 14)
    }

    private fun saveSettings() {
        val editor = pref.edit()

        editor.putString("title_text", binding.etTitle.text.toString())
        editor.putString("detail_text", binding.etDetail.text.toString())
        
        editor.putString("bg_color", binding.spinnerBgColor.selectedItem.toString())

        val selectedFontColorId = binding.rgFontColor.checkedRadioButtonId
        if (selectedFontColorId != -1) {
            val radioButton = findViewById<RadioButton>(selectedFontColorId)
            editor.putString("font_color", radioButton.text.toString())
        }

        editor.putInt("title_font_size", binding.sbTitleFontSize.progress)
        editor.putInt("detail_font_size", binding.sbDetailFontSize.progress)

        editor.apply()
        finish()
    }
}
