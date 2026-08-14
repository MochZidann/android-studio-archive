package com.example.praktik09

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DBOpenHelper(context: Context) : SQLiteOpenHelper(context, "Praktik09", null, 1) {

    override fun onCreate(db: SQLiteDatabase) {
        val createTable = "CREATE TABLE mahasiswa (" +
                "nim TEXT PRIMARY KEY, " +
                "nama TEXT, " +
                "prodi TEXT)"
        db.execSQL(createTable)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS mahasiswa")
        onCreate(db)
    }

    fun simpanData(nim: String, nama: String, prodi: String): Long {
        val db = this.writableDatabase
        val values = ContentValues().apply {
            put("nim", nim)
            put("nama", nama)
            put("prodi", prodi)
        }

        return db.insertWithOnConflict("mahasiswa", null, values, SQLiteDatabase.CONFLICT_REPLACE)
    }

    fun ambilData(): List<String> {
        val list = mutableListOf<String>()
        val db = this.readableDatabase
        val cursor = db.rawQuery("SELECT * FROM mahasiswa", null)

        if (cursor.moveToFirst()) {
            do {
                val data = "${cursor.getString(0)}\n${cursor.getString(1)}\n${cursor.getString(2)}"
                list.add(data)
            } while (cursor.moveToNext())
        }
        cursor.close()
        return list
    }

    fun hapusSemuaData() {
        val db = this.writableDatabase
        db.execSQL("DELETE FROM mahasiswa")
    }
}