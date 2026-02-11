# 📊 ExpenseTracker — iOS App

ExpenseTracker adalah aplikasi iOS berbasis **SwiftUI + Core Data** yang digunakan untuk mencatat, mengelola, dan menganalisis pemasukan (Income) serta pengeluaran (Expense) secara **offline-first** dengan tampilan modern dan dukungan **Dark Mode**.
Aplikasi ini dirancang untuk membantu pengguna memahami kondisi keuangan mereka melalui pencatatan transaksi yang rapi, filter yang fleksibel, serta tampilan ringkasan (Summary) yang informatif.

## ✨ Fitur Utama

### 1. Manajemen Transaksi
- Tambah transaksi **Income** dan **Expense**
  
![Uploading Screenshot 2026-02-11 at 22.49.20.png…]()
- Edit transaksi yang sudah dibuat
- Hapus transaksi dengan **konfirmasi**
- **Multiple delete** (pilih banyak transaksi sekaligus)
- **Undo Delete** (single & multiple)

### 2. Summary & Analisis Keuangan
- Ringkasan:
  - Total Income
  - Total Expense
  - Balance
  - Jumlah transaksi
- Grafik (Bar Chart) yang **auto-update**
- Filter berdasarkan:
  - Rentang waktu (Hari ini, 7 hari, 30 hari, Bulan lalu, Semua)
  - Kategori Income
  - Kategori Expense
- Mendukung kombinasi filter (date + category)

---

### 3. Offline First
- Semua data disimpan secara lokal menggunakan **Core Data**
- Aplikasi tetap berjalan **tanpa koneksi internet**
- Struktur siap dikembangkan untuk sinkronisasi online di masa depan

---

### 4. Dark Mode Support
- Mengikuti sistem (Light / Dark Mode)
- Warna adaptif
- Kontras tetap terjaga pada semua komponen:
  - Summary
  - Filter
  - Form
  - Chart
