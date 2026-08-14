package com.example.praktik07

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DBOpenHelper(context: Context) : SQLiteOpenHelper(context, "db_kampus", null, 1) {

    override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL("CREATE TABLE prodi(id_prodi INTEGER PRIMARY KEY AUTOINCREMENT, nama_prodi TEXT)")
        db?.execSQL("CREATE TABLE mhs(nim TEXT PRIMARY KEY, nama TEXT, id_prodi INTEGER)")
        db?.execSQL("CREATE TABLE matkul(id_matkul INTEGER PRIMARY KEY AUTOINCREMENT, nama_matkul TEXT, sks INTEGER)")
        db?.execSQL("CREATE TABLE nilai(id_nilai INTEGER PRIMARY KEY AUTOINCREMENT, nim TEXT, id_matkul INTEGER, nilai INTEGER)")

        db?.execSQL("INSERT INTO prodi(nama_prodi) VALUES('MI'),('AK'),('TE')")
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        db?.execSQL("DROP TABLE IF EXISTS nilai")
        db?.execSQL("DROP TABLE IF EXISTS matkul")
        db?.execSQL("DROP TABLE IF EXISTS mhs")
        db?.execSQL("DROP TABLE IF EXISTS prodi")
        onCreate(db)
    }
}