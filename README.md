# 📱 MyTagiheun - Aplikasi Pencatat Hutang

Aplikasi pencatat hutang modern untuk Android dengan fitur lengkap untuk mengelola pinjaman dan pembayaran.

## ✨ Fitur Utama

### 🔐 Dua Mode Aplikasi
- **Mode Pengguna**: Menggunakan PIN untuk keamanan, data tersimpan permanen
- **Mode Pengembang**: Tanpa PIN, data otomatis terhapus saat aplikasi ditutup (untuk testing)

### 📝 Manajemen Hutang
- ✅ Input Pinjam dan Bayar
- ✅ Edit dan Hapus data
- ✅ Keterangan untuk setiap transaksi
- ✅ Jatuh Tempo (dapat diatur untuk 1 bulan atau lebih)
- ✅ Indikator jatuh tempo yang cerdas:
  - 🔴 Merah: Terlambat
  - 🟠 Orange: Jatuh tempo dalam 7 hari
  - 🔵 Biru: Masih lama

### 📊 Dashboard Cerdas
- Total Pinjam dan Total Bayar
- Sisa Hutang dengan indikator warna
- Histori transaksi yang terorganisir
- Card design yang modern dan cantik

### 📤 Export & Share
- **Export ke Excel** (.xlsx)
- **Export ke PDF** (.pdf)
- **Struk Gambar** dengan watermark "ARA SHOP"
- **Share ke WhatsApp** (file atau teks)

### 🎨 UI/UX Modern
- Animasi halus dan transisi yang smooth
- Dark mode support
- Design yang clean dan modern
- Responsive layout

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.5.3 atau lebih tinggi)
- Android Studio / VS Code dengan Flutter extension
- Android SDK (min SDK 21)

### Installation

1. **Clone repository**
```bash
git clone <repository-url>
cd MyTagiheunApp
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run aplikasi**
```bash
flutter run
```

### Build APK

**Debug APK:**
```bash
flutter build apk --debug
```

**Release APK:**
```bash
flutter build apk --release
```

**App Bundle (untuk Play Store):**
```bash
flutter build appbundle --release
```

## 📦 Dependencies

- `flutter_riverpod` - State management
- `go_router` - Navigation
- `sqflite` - Local database
- `flutter_secure_storage` - Secure PIN storage
- `share_plus` - Share functionality
- `syncfusion_flutter_xlsio` - Excel export
- `pdf` - PDF generation
- `intl` - Date & currency formatting
- `google_fonts` - Beautiful fonts

## 📱 Screenshots

*Screenshots akan ditambahkan setelah build*

## 🛠️ Development

### Project Structure
```
lib/
├── main.dart
└── src/
    ├── app.dart
    ├── core/
    │   ├── enums/
    │   ├── providers/
    │   └── theme/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   ├── repositories/
    │   └── services/
    ├── features/
    │   ├── home/
    │   ├── onboarding/
    │   └── pin/
    ├── router/
    └── utils/
```

### Architecture
- **Clean Architecture** dengan separation of concerns
- **Riverpod** untuk state management
- **Repository Pattern** untuk data layer
- **Provider Pattern** untuk dependency injection

## 📋 Cara Penggunaan

1. **Pilih Mode**
   - Pilih "Menu Pengguna" untuk penggunaan sehari-hari
   - Pilih "Menu Pengembang" untuk testing

2. **Setup PIN** (Mode Pengguna)
   - Masukkan PIN 6 digit
   - Konfirmasi PIN

3. **Catat Hutang**
   - Tap tombol "Catat"
   - Pilih Pinjam atau Bayar
   - Isi nama kontak, nominal, keterangan (opsional)
   - Atur jatuh tempo (opsional)
   - Simpan

4. **Export Data**
   - Tap icon share di AppBar
   - Pilih format export (Excel, PDF, atau Struk)
   - File akan tersimpan dan bisa dibagikan

## 🔒 Keamanan

- PIN disimpan dengan enkripsi SHA-256
- Data lokal tersimpan dengan aman
- Mode developer tidak menyimpan data permanen

## 📄 License

Private project - All rights reserved

## 👨‍💻 Developer

Dibuat untuk Ara Shop

## 📞 Support

Untuk bantuan deployment, lihat [DEPLOYMENT.md](DEPLOYMENT.md)

---

**Made with ❤️ using Flutter**
