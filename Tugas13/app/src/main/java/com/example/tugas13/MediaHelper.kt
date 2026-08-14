package com.example.tugas13

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

    fun getOutputMediaFile(context: Context): File {
        val dir = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM), "Tugas13"
        )
        if (!dir.exists()) {
            dir.mkdirs()
        }
        return File(dir, namaFile)
    }

    fun getOutputMediaFileUri(context: Context): Uri {
        val timeStamp = SimpleDateFormat("yyyyMMddHHmmss", Locale.getDefault()).format(Date())
        namaFile = "DC_$timeStamp.jpg"
        val file = getOutputMediaFile(context)
        return FileProvider.getUriForFile(context, "${context.packageName}.provider", file)
    }

    fun bitmapToString(bmp: Bitmap): String {
        val resized = resizeBitmap(bmp, 720)
        val stream = ByteArrayOutputStream()
        resized.compress(Bitmap.CompressFormat.JPEG, 60, stream)
        val byteArray = stream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.DEFAULT)
    }

    private fun resizeBitmap(image: Bitmap, maxSize: Int): Bitmap {
        val width = image.width
        val height = image.height
        val ratio: Float = width.toFloat() / height.toFloat()
        val newWidth: Int
        val newHeight: Int

        if (ratio > 1) {
            newWidth = maxSize
            newHeight = (newWidth / ratio).toInt()
        } else {
            newHeight = maxSize
            newWidth = (newHeight * ratio).toInt()
        }

        return Bitmap.createScaledBitmap(image, newWidth, newHeight, true)
    }
}