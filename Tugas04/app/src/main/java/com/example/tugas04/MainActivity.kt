package com.example.tugas04

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.tugas04.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnLogin.setOnClickListener {
            val userStorage = arrayOf("zidan", "akbar")
            val passStorage = arrayOf("zidan123", "akbar123")

            val inputUser = binding.edUsername.text.toString()
            val inputPass = binding.edPassword.text.toString()

            var auth = false
            for (i in userStorage.indices) {
                if (userStorage[i] == inputUser && passStorage[i] == inputPass) {
                    auth = true
                    break
                }
            }

            if (auth) {
                startActivity(Intent(this, DashboardActivity::class.java))
                finish()
            } else {
                Toast.makeText(this, "Akses Ditolak!", Toast.LENGTH_SHORT).show()
            }
        }
    }
}