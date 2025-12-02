# 🚀 Panduan Deployment MyTagiheun App

## 📋 Langkah-langkah Deployment

### 1. Persiapan Awal

#### A. Install Dependencies
```bash
cd MyTagiheunApp
flutter pub get
```

#### B. Cek Flutter Setup
```bash
flutter doctor
```
Pastikan semua tools sudah terinstall dengan benar.

### 2. Testing Aplikasi

#### A. Run di Emulator/Device
```bash
# Untuk development
flutter run

# Untuk release mode (lebih cepat)
flutter run --release
```

#### B. Test Fitur-fitur
- ✅ Mode Pengguna (dengan PIN)
- ✅ Mode Pengembang (tanpa PIN, auto clear)
- ✅ Input Pinjam/Bayar
- ✅ Edit dan Hapus data
- ✅ Export Excel, PDF, Struk
- ✅ Share ke WhatsApp
- ✅ Jatuh Tempo
- ✅ Histori

### 3. Build APK untuk Android

#### A. Build APK Debug (untuk testing)
```bash
flutter build apk --debug
```
File akan ada di: `build/app/outputs/flutter-apk/app-debug.apk`

#### B. Build APK Release (untuk production)
```bash
flutter build apk --release
```
File akan ada di: `build/app/outputs/flutter-apk/app-release.apk`

#### C. Build App Bundle (untuk Play Store)
```bash
flutter build appbundle --release
```
File akan ada di: `build/app/outputs/bundle/release/app-release.aab`

### 4. Setup GitHub untuk Deployment

#### A. Inisialisasi Git (jika belum)
```bash
cd MyTagiheunApp
git init
git add .
git commit -m "Initial commit: MyTagiheun App"
```

#### B. Buat Repository di GitHub
1. Buka https://github.com
2. Klik "New repository"
3. Nama: `mytagiheun-app` (atau sesuai keinginan)
4. Pilih Public atau Private
5. Jangan centang "Initialize with README"
6. Klik "Create repository"

#### C. Push ke GitHub
```bash
git remote add origin https://github.com/USERNAME/mytagiheun-app.git
git branch -M main
git push -u origin main
```

### 5. Setup GitHub Actions untuk Build Otomatis

File `.github/workflows/build.yml` sudah dibuat. Workflow ini akan:
- ✅ Build APK otomatis saat push ke main
- ✅ Upload APK sebagai artifact
- ✅ Membuat release otomatis

#### Cara Menggunakan:
1. Push kode ke GitHub
2. GitHub Actions akan otomatis build
3. Download APK dari tab "Actions" → "Artifacts"

### 6. Manual Build (Alternatif)

Jika GitHub Actions tidak berfungsi, build manual:

#### Windows:
```bash
flutter build apk --release
```

#### Linux/Mac:
```bash
flutter build apk --release
```

### 7. Install APK ke Device

#### Via ADB:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### Via File Manager:
1. Transfer file APK ke Android device
2. Buka file manager di device
3. Tap file APK
4. Izinkan "Install from Unknown Sources" jika diminta
5. Install aplikasi

### 8. Troubleshooting

#### Error: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

#### Error: "SDK not found"
- Pastikan Android SDK sudah terinstall
- Set environment variable `ANDROID_HOME`

#### Error: "Dependencies conflict"
```bash
flutter pub upgrade
flutter pub get
```

### 9. Update Aplikasi

Setelah melakukan perubahan:
```bash
# Update version di pubspec.yaml
version: 1.0.1+2  # versi.bangun

# Commit dan push
git add .
git commit -m "Update: versi 1.0.1"
git push origin main
```

## 📱 Informasi Aplikasi

- **Nama**: MyTagiheun
- **Package**: com.arashop.tagiheun
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: Android 15

## 🔐 Signing APK (Opsional untuk Production)

Untuk release ke Play Store, perlu signing key:

1. Generate keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Buat file `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. Update `android/app/build.gradle` untuk menggunakan keystore

## 📞 Support

Jika ada masalah, cek:
- Flutter documentation: https://flutter.dev/docs
- GitHub Issues: Buat issue di repository

---

**Selamat! Aplikasi MyTagiheun siap digunakan! 🎉**

