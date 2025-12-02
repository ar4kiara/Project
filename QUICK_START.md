# ⚡ Quick Start Guide

## Langkah Cepat untuk Menjalankan Aplikasi

### 1️⃣ Install Dependencies
```bash
cd MyTagiheunApp
flutter pub get
```

### 2️⃣ Jalankan Aplikasi
```bash
flutter run
```

### 3️⃣ Build APK
```bash
# Untuk testing
flutter build apk --debug

# Untuk release
flutter build apk --release
```

## 🎯 Langkah Selanjutnya

### Opsi A: Deploy via GitHub Actions (Recommended)

1. **Buat repository di GitHub**
   - Buka https://github.com/new
   - Buat repository baru (misal: `mytagiheun-app`)

2. **Push kode ke GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/USERNAME/mytagiheun-app.git
   git push -u origin main
   ```

3. **GitHub Actions akan otomatis build**
   - Buka tab "Actions" di GitHub
   - Download APK dari "Artifacts"

### Opsi B: Build Manual

1. **Build APK langsung**
   ```bash
   flutter build apk --release
   ```

2. **File APK ada di:**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Transfer ke Android device dan install**

## 📱 Install ke Device

### Via ADB (jika device terhubung):
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Via File Manager:
1. Copy file APK ke Android device
2. Buka file manager
3. Tap file APK
4. Izinkan "Install from Unknown Sources"
5. Install

## ✅ Checklist Sebelum Deploy

- [ ] Test semua fitur aplikasi
- [ ] Build APK berhasil tanpa error
- [ ] Test install di device Android
- [ ] Verifikasi semua fitur berfungsi
- [ ] Update version di `pubspec.yaml` jika perlu

## 🐛 Troubleshooting

**Error: "Gradle build failed"**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Error: "SDK not found"**
- Install Android SDK via Android Studio
- Set environment variable `ANDROID_HOME`

**Error: "Dependencies conflict"**
```bash
flutter pub upgrade
flutter pub get
```

## 🎉 Selesai!

Aplikasi siap digunakan! 🚀

Untuk panduan lengkap, lihat [DEPLOYMENT.md](DEPLOYMENT.md)

