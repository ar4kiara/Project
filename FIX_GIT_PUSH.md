# 🔧 Fix Git Push Error

## Masalah
Error: `src refspec main does not match any`

## Penyebab
Branch lokal adalah `master`, tapi mencoba push ke `main`.

## Solusi

### Langkah 1: Rename Branch
Jalankan di terminal (di folder MyTagiheunApp):
```bash
git branch -M main
```

### Langkah 2: Push ke GitHub
```bash
git push -u origin main
```

## Alternatif: Push ke Branch Master

Jika repository GitHub menggunakan `master` sebagai default:

```bash
git push -u origin master
```

## Jika Masih Error

### Cek Status Git
```bash
git status
```

### Pastikan Ada Commit
```bash
git log --oneline
```

Jika belum ada commit:
```bash
git add .
git commit -m "Initial commit: MyTagiheun App"
```

### Cek Remote
```bash
git remote -v
```

Jika belum ada remote:
```bash
git remote add origin https://github.com/ar4kiara/Project.git
```

## Setelah Berhasil Push

1. Buka GitHub repository: https://github.com/ar4kiara/Project
2. Cek apakah kode sudah ter-push
3. GitHub Actions akan otomatis build APK (jika workflow sudah aktif)
4. Download APK dari tab "Actions" → "Artifacts"

