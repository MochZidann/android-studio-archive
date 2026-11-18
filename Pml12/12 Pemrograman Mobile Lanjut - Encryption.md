##### Pemrograman Mobile Lanjut 

###### Pertemuan 12 — Encryption 

###### A. Dasar Teori 

Kriptografi adalah ilmu dan seni mengamankan informasi dengan cara mengubahnya menjadi bentuk yang tidak dapat dipahami oleh pihak yang tidak berwenang. Dalam praktiknya, kriptografi menggunakan algoritma matematika untuk mengenkripsi (mengubah data asli menjadi bentuk yang tidak dapat dibaca) dan mendekripsi (mengembalikan data tersebut ke bentuk aslinya) informasi. Salah satu algoritma yang dapat digunakan adalah AES, atau Advanced Encryption Standard. AES merupakan algoritma kriptografi simetris yang digunakan untuk mengenkripsi data. Hal tersebut berarti bahwa kunci yang sama digunakan untuk mengenkripsi dan mendekripsi data. Beberapa fitur utama AES: 

1. Kunci Panjang: AES mendukung panjang kunci 128, 192, dan 256 bit. Semakin panjang kunci, semakin aman algoritma tersebut, tetapi juga lebih membutuhkan waktu dan sumber daya untuk diproses 

2. Blok Ukuran: Data dienkripsi dalam blok 128 bit. Ini berarti data dipecah menjadi potonganpotongan 128 bit yang kemudian diproses secara individu. 

3. Keamanan: Hingga saat ini, AES dianggap sangat aman dan belum ada serangan yang berhasil membobolnya secara praktis. Ini digunakan secara luas di banyak aplikasi termasuk enkripsi file, komunikasi aman, dan enkripsi disk penuh. 

Cipher Block Chaining (CBC) dan Initialization Vector (IV) 

Dengan menggunakan CBC dan IV, enkripsi data menjadi lebih aman, karena setiap blok data yang terenkripsi tergantung pada blok sebelumnya dan IV yang unik, sehingga lebih sulit untuk ditebak atau dipecahkan oleh pihak yang tidak berwenang. 

- a. IV (Initialization Vector) 

Initialization Vector (IV) adalah elemen penting dalam mode CBC dan beberapa mode 

operasi lainnya. Berikut beberapa poin penting mengenai IV: 

   - e Keamanan: IV harus unik dan acak untuk setiap sesi enkripsi untuk memastikan bahwa enkripsi untuk pesan yang sama tidak menghasilkan ciphertext yang sama. 

   - e Panjang: IV memiliki panjang yang sama dengan ukuran blok yang digunakan dalam algoritma enkripsi, misalnya 128 bit untuk AES. 

   - e Fungsi: IV digunakan untuk memulai proses enkripsi dari blok pertama dan memastikan bahwa blok pertama terenkripsi dengan cara yang berbeda setiap kali. 

- b. Cipher Block Chaining (CBC) 

CBC adalah salah satu mode operasi yang digunakan dalam enkripsi blok, termasuk AES. Mode ini memberikan keamanan tambahan dengan menghubungkan blok-blok data dalam proses enkripsi. Berikut adalah cara kerjanya: 

- ¢ Pembagian Data: Data yang akan dienkripsi dibagi menjadi beberapa blok yang memiliki ukuran yang sama. 

- ¢ Penerapan IV: Blok pertama data dienkripsi dengan menggunakan Initialization Vector (IV) dan kunci enkripsi. 

- e Penerapan XOR: Setiap blok data dienkripsi dengan cara melakukan XOR (exclusive OR) dengan hasil enkripsi blok sebelumnya sebelum proses enkripsi dilakukan dengan kunci enkripsi. 

- e Proses Berulang: Langkah ini diulang untuk setiap blok data, sehingga setiap blok terkait dengan blok sebelumnya. 

### | 

PEMROGRAMAN MOBILE LANJUT — D3 MANAJEMEN INFORMATIKA 

Berikut ilustrasi cara kerja IV dan CBC: 

Plaintext Block 1(P1) > IV > XOR > Encrypt ® Ciphertext Block1 (C1) | Plaintext Block2 (P2) > C1 » XOR > Encrypt > Ciphertext Block2 (C2) | Plaintext Block3 (P3) = C2 XOR > Encrypt > Ciphertext Block3 (C3) | 

...dan sebagainya 

###### B. Praktik Pembuatan Aplikasi 

- 1) Buatlah project baru dengan nama Pml12. 

- 2) Tambahkan viewBinding pada build.gradle.kts (Module: app), dan jangan lupa lakukan sinkron agar tidak menyebabkan error. 

- 3) Buat Empty Views Activity baru dengan nama MainActivity.kt serta layout activity_main.xml dengan tampilan sebagai berikut: 



<!-- Start of picture text -->
‘Masukkanteks yang akan di enkripsi<br>Component Tree @ Masukkan secretkey<br>Somain —<br>» Deardview<br>Eitineartayout verve<br>Ab edPainToxt(ulisne Tox ry Toxt teronkripsi<br>Ab edSecretKey Pain Tox) a OO<br>btnenerypt “ene a md<br>AbedEneryptedText iting Text)<br>» Bcardview<br>BLinearLayout (ver DECRYPT<br>Ab edSecretKey? (Pian Tox ry<br>Dbtndecrypt “deere rn<br>Ab edDecryptedText viiine Text) A<br><!-- End of picture text -->

<?xml version="1.0" encoding="utf-8" ?> <androidx.constraintlayout .widget.ConstraintLayout xmlns:android="http: //schemas.android.com/apk/res/android" xmlns:app="http: //schemas.android.com/apk/res-auto" xmlns:tools="http://schemas.android.com/tools" android: id="@+id/main" 

android: layout_width="match_parent" android: layout_height="match_parent" android: fitsSystemWindows="true" tools:context=".MainActivity"> <androidx.cardview. android: id="@+id/cardView"widget .CardView android: layout_width="0dp" android: layout_height="wrap_content" android: layout_marginStart="24dp" android: layout_marginTop="16dp" android: layout_marginEnd="24dp" app: cardBackgroundColor="#FFE83B" 

#### LS 

PEMROGRAMAN MOBILE LANJUT— D3 MANAJEMEN INFORMATIKA 

2 

app: cardCornerRadius="10dp" app:cardElevation="5dp" app: cardPreventCornerOverlap="true" app: layout_constraintEnd_toEndOf="parent" app: layout_constraintStart_toStartOf="parent" app: layout_constraintTop_toTopOf="parent"> <LinearLayout android: layout_width="match_parent" android: layout_height="match_parent" android: layout_marginLeft="8dp" android: layout_marginRight="8dp" android:orientation="vertical"> <EditText android: id="@+id/edPlainText" android: layout_width="match_parent" android: layout_height="90dp" android: layout_marginStart="16dp" android: layout_marginTop="16dp" android: layout_marginEnd="16dp" android: layout_weight="1" android:ems="10" android:gravity="start|top" android:hint="Masukkan teks yang akan di enkripsi" android: inputType="textMultiLine" /> <EditText android: id="@+id/edSecretKey" android: layout_width="match_parent" android: layout_height="wrap_content" android: layout_gravity="bottom" android: layout_marginStart="16dp" android: layout_marginTop="16dp" android: layout_marginEnd="16dp" android: layout_weight="1" android:ems="10" android:hint="Masukkan secret key" android: inputType="text" android:minHeight="48dp"_ /> <Button android:id="@+id/btnEncrypt" android: layout_width="wrap android: layout_height="wrap_content" android: layout_gravity="center"content" android: layout_marginStart="1l6dp" android: layout_marginTop="16dp" android: layout_marginEnd="16dp" android: layout_weight="1" android:text="Encrypt" /> <EditText android: id="@+id/edEncryptedText" android: layout_width="match_parent" android: layout_height="wrap_content" android: layout_marginLeft="16dp" android: layout_marginTop="16dp" android: layout_marginRight="16dp" android: layout_marginBottom="16dp" android: layout_weight="1" android:ems="10" 

## a 

PEMROGRAMAN MOBILE LANJUT— D3MANAJEMEN INFORMATIKA 

3 

android: gravity="start|top” android:hint="Text terenkripsi" android: inputType="textMultiLine" android:minHeight="48dp" /> </LinearLayout> </androidx.cardview.widget.CardView> <androidx.cardview.widgetandroid: layout_width="0dp".CardView android: layout_height="wrap_content" android: layout_marginTop="16dp" app: cardBackgroundColor="#00BCD4" app:cardCornerRadius="10dp" app:cardElevation="Sdp" app: cardPreventCornerOverlap="true" app: layout_constraintEnd_toEndOf="@+id/cardView" app: layout_constraintStart_toStartOf="@t+id/cardView" app: layout_constraintTop_toBottomOf="@+id/cardView"> <LinearLayout android: layout_width="match_parent" android: layout_height="match_parent" android: layout_marginLeft="8dp" android: layout_marginRight="8dp" android:orientation="vertical"> <EditText android: id="@+id/edSecretKey2" android: layout_width="match_parent" android: layout_height="wrap_content" android: layout_marginStart="16dp" android: layout_marginTop="16dp" android: layout_marginEnd="16dp" android: layout_weight="1" android:ems="10" android:hint="Masukkan secret key" android: inputType="text" android:minHeight="48dp" /> <Button android: id="@+id/btnDecrypt" android: layout_width="wrap_ content" android: layout_height="wrap_content" android: layout_gravity="center_horizontal" android: layout_marginStart="16dp" android: layout_marginTop="16dp" android: layout_marginEnd="16dp" android: layout_weight="1" android:text="Decrypt" /> <EditText android: id="@+id/edDecryptedText" android: layout_width="match_parent" android: layout _height="90dp" android: layout_marginLeft="1édp" android: layout_marginTop="16dp" android: layout_marginRight="16dp" android: layout_marginBottom="16dp" android: layout_weight="1" android:ems="10" android:gravity="start|top" 

a 

PEMROGRAMAN MOBILE LANJUT— D3MANAJEMEN INFORMATIKA 

4 

android:hint="Teks terdekripsi" android: inputType="textMultiLine" /> </LinearLayout> 

</androidx.cardview.widget.CardView> </androidx.constraintlayout.widget.ConstraintLayout> 

4) Lengkapi MainActivity.kt dengan kode program sebagai berikut: import android.os.Bundle import android.util.Base64 import android.view.View import android.widget.Toast import androidx.appcompat.app.AppCompatActivity import ac.id.polinema.pm112.databinding.ActivityMainBinding import java.security.GeneralSecurityException import java.security.SecureRandom import java.util.StringTokenizer import javax.crypto.Cipher import javax.crypto.SecretKey import javax.crypto.spec.IvParameterSpec import javax.crypto.spec.SecretKeySpec class MainActivity : AppCompatActivity(), View.OnClickListener { lateinit var binding : ActivityMainBinding val panjangKey = setOf(16, 24, 32) var wrongkey = false //data tambahan sebelum plaintext val dummyStr = "0000000000000000:;" var iv: IvParameterSpec? = null override fun onCreate(savedInstanceState: Bundle?) { super.onCreate (savedInstanceState) binding = ActivityMainBinding.inflate (layoutInflater) setContentView (binding. root) binding.btnEncrypt.setOnClickListener(this) binding. btnDecrypt.setOnClickListener(this) } override fun onClick(v: View?) { when (v?.id) { R.id.btnEncrypt -> { //ambil secretKey dari input val secretKey = generateSecretKey( binding.edSecretKey. text.toString() ) if (secretKey != null) { //buat IV baru dan simpan iv = generateInitvVect() //enkripsi plaintex binding.edEncryptedText.setText ( encrypt (binding. edPlainText.text.toString(), secretKey, iv!! ) ) } } R.id.btnDecrypt -> { //ambil secretKey dari input val secretKey = generateSecretKey( eerereeee e reer e PEMROGRAMAN MOBILE LANJUT— D3MANAJEMEN INFORMATIKA s 

binding. edSecretKey2. text. toString () ) //cek key valid dan IV ada if (secretKey != null 6& iv != null) { //dekripsi ciphertext binding.edDecryptedText.setText ( decrypt (binding.edEncryptedText. text.toString(), secretKey, iv!!) ) } else if (iv == null) { Toast.makeText (this, “"Silakan lakukan enkripsi terlebih dahulu!", Toast .LENGTH_SHORT } ) «show() } } } //puat secretKey AES dari input fun generateSecretKey(secret: String): SecretKeySpec? { val keyBytes = secret. toByteArray(Charsets.UTF_8) //periksa panjang key berdasarkan jumlah byte if (keyBytes.size !in panjangKey) { //tandai jika key tidak valid wrongKey = true Toast .makeText(this, "Panjang key harus 16/24/32 byte", Toast. LENGTH_LONG) .show() return null } //bentuk secretKey dengan algoritma AES val secretKey = SecretKeySpec (keyBytes, "AES") //tandai key valid wrongKkey = false return secretKey } //initialization vector (IV) fun generateInitVect(): IvParameterSpec { //buat array byte dengan panjang 16 val iv = ByteArray(16) val secureRandom = SecureRandom() //isi array IV dengan nilai acak secureRandom.nextBytes (iv) return IvParameterSpec(iv) } fun encrypt( plainText: String, secretKey: SecretKey?, iv: IvParameterSpec): String { if (wrongKey == false && secretKey != null) { //tentukan algoritma AES dengan mode CBC dan padding PKCS5 val cipher = Cipher.getInstance ("AES/CBC/PKCSSPADDING") //inisialisasi cipher untuk enkripsi cipher.init (Cipher. ENCRYPT MODE, secretKey, iv) //gabungkan dummyStr dengan plaintext val encryptedText = cipher.doFinal( (dummyStr + plainText) .toByteArray(Charsets.UTF_8)) //ubah hasil enkripsi menjadi teks Base64 return Base64.encodeToString (encryptedText,Base64 . DEFAULT) 

# a 

— D3MANAJEMEN INFORMATIKA 

6 

PEMROGRAMAN MOBILE LANJUT 

} else { return "" } } fun decrypt( encryptedText: String, secretKey: SecretKey?, iv: IvParameterSpec): String { if (wrongKey == false && secretKey != null) { //buat objek cipher dengan algoritma AES/CBC val cipher = Cipher.getInstance ("AES/CBC/PKCSSPADDING") //ubah ciphertext Base64 menjadi array byte val textToDecrypt = Base64.decode (encryptedText, Base64. DEFAULT) try { //inisialisasi cipher dengan secretKey dan IV yang sama cipher. init (Cipher.DECRYPT MODE, secretKey, iv) //ubah dekripsi menjadi string val tokens = StringTokenizer( String(cipher.doFinal (textToDecrypt) ,Charsets.UTF_8),":;") //lewati token pertama yang berisi dummyStr tokens .nextToken () return tokens.nextToken() } catch (e: GeneralSecurityException) { Toast .makeText (this,"Key salah!",Toast.LENGTH_SHORT) .show() return "" } } else { return "" } } } 

###### C. Uji Coba Aplikasi 

eerereeee e reer e 

PEMROGRAMAN MOBILE LANJUT — D3 MANAJEMEN INFORMATIKA 

7 

