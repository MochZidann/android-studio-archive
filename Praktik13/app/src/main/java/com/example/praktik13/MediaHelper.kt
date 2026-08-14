package com.example.praktik13 // Sesuaikan dengan package Anda

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Environment
import android.util.Base64
import androidx.core.content.FileProvider
import java.io.ByteArrayOutputStream
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class MediaHelper(var namaFile: String = "") {
    private val RC_CAMERA = 100

    fun getRcCamera(): Int = RC_CAMERA
    fun getMyFileName(): String = namaFile

    // Membuat direktori penyimpanan foto
    fun getOutputMediaFile(context: Context): File {
        val dir = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM), "Praktik13"
        )
        if (!dir.exists()) {
            dir.mkdirs()
        }
        return File(dir, namaFile)
    }

    // Membuat Uri untuk akses kamera (FileProvider)
    fun getOutputMediaFileUri(context: Context): Uri {
        val timeStamp = SimpleDateFormat("yyyyMMddHHmmss", Locale.getDefault()).format(Date())
        namaFile = "DC_$timeStamp.jpg"

        // Ambil file fisik
        val file = getOutputMediaFile(context)

        // Ubah file menjadi Uri (Uniform Resource Indentifier)
        return FileProvider.getUriForFile(context, "${context.packageName}.provider", file)
    }

    // Ubah bitmap ke string Base64 untuk dikirim ke server
    fun bitmapToString(bmp: Bitmap): String {
        // Batas max 720 px
        val resized = resizeBitmap(bmp, 720)
        // Stream sementara untuk menampung data gambar
        val stream = ByteArrayOutputStream()
        // Kompres gambar sebesar 60%
        resized.compress(Bitmap.CompressFormat.JPEG, 60, stream)
        // Ubah hasil kompres ke byte array
        val byteArray = stream.toByteArray()
        // Encode byte array ke Base64 string
        return Base64.encodeToString(byteArray, Base64.DEFAULT)
    }

    // Resize ukuran foto
    private fun resizeBitmap(image: Bitmap, maxSize: Int): Bitmap {
        val width = image.width
        val height = image.height
        // Hitung rasio gambar
        val ratio: Float = width.toFloat() / height.toFloat()
        val newWidth: Int
        val newHeight: Int

        if (ratio > 1) {
            // Landscape
            newWidth = maxSize
            newHeight = (newWidth / ratio).toInt()
        } else {
            // Portrait
            newHeight = maxSize
            newWidth = (newHeight * ratio).toInt()
        }

        // Buat bitmap baru sesuai ukuran
        return Bitmap.createScaledBitmap(image, newWidth, newHeight, true)
    }
}