# 📊 ExpenseTracker — iOS App

ExpenseTracker adalah aplikasi iOS berbasis **SwiftUI + Core Data** yang digunakan untuk mencatat, mengelola, dan menganalisis pemasukan (Income) serta pengeluaran (Expense) secara **offline-first** dengan tampilan modern dan dukungan **Dark Mode**.
Aplikasi ini dirancang untuk membantu pengguna memahami kondisi keuangan mereka melalui pencatatan transaksi yang rapi, filter yang fleksibel, serta tampilan ringkasan (Summary) yang informatif.

## ✨ Fitur Utama

### 1. Manajemen Transaksi
- Tambah transaksi **Income** dan **Expense**
- Edit transaksi yang sudah dibuat
- Hapus transaksi dengan **konfirmasi**
- **Multiple delete**
- **Swipe to delete**
- **Hold to delete**
- **Undo Delete** (single & multiple)

---

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

## 📸 Screenshoots Aplikasi

### 1. Transactions
<img src="https://github.com/gedeastu/ExpenseTracker/blob/6eefa942a32d229682ec35a6b4adaf7dd84093b5/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202026-02-13%20at%2001.48.40.png" width="250"/>

### 2. Summary
<img src="https://github.com/gedeastu/ExpenseTracker/blob/003d09e713687cd80d26a41124b5b94629a1d9de/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202026-02-13%20at%2001.48.26.png" width="250"/>

### 3. Form Transaction
<img src="https://github.com/gedeastu/ExpenseTracker/blob/53de750b6f826542c44051261199e1039871a008/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202026-02-13%20at%2001.48.34.png" width="250"/>

## ⚙️ Cara menjalankan aplikasi

### 1. Clone Repository
```bash
https://github.com/gedeastu/ExpenseTracker.git

### 2. Input URL Repository pada XCode
<img src="https://github.com/gedeastu/ExpenseTracker/blob/7dd8a396d91190128b89a78c76c40060d2399943/Screenshot%202026-02-13%20at%2021.17.42.png" width="250"/>
<br>
<img src="" width="250"/>

### 3. Pastikan target iOS 16+

### 4. Build & Run di simulator atau device
