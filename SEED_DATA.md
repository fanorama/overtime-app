# Seed Dummy Data

## Overview
Script untuk menambahkan data dummy ke Firestore untuk keperluan testing dan development.

## Dummy Employees

### Data yang akan ditambahkan:
1. **Ahmad Fauzi** (EMP001)
   - Position: Senior Technician
   - Department: Technical Support
   - Phone: 081234567890

2. **Siti Nurhaliza** (EMP002)
   - Position: Field Engineer
   - Department: Technical Support
   - Phone: 081234567891

3. **Budi Santoso** (EMP003)
   - Position: Network Administrator
   - Department: IT Infrastructure
   - Phone: 081234567892

4. **Dewi Lestari** (EMP004)
   - Position: System Analyst
   - Department: IT Infrastructure
   - Phone: 081234567893

5. **Rudi Hartono** (EMP005)
   - Position: Database Administrator
   - Department: IT Infrastructure
   - Phone: 081234567894

### Rates
Semua karyawan menggunakan rate standar:
- **Weekday Rate**: Rp 50,000/jam
- **Weekend Rate**: Rp 75,000/jam

## Cara Menggunakan

### Opsi 1: Via UI (Recommended)
1. Login sebagai **Manager**
2. Buka menu **Profile** (tab paling kanan)
3. Scroll ke section **Developer Tools** (card kuning)
4. Tap **"Seed 5 Dummy Employees"**
5. Konfirmasi dialog
6. Tunggu proses selesai

### Opsi 2: Via Code
```dart
import 'package:overtime_app/core/utils/seed_data.dart';

// Seed employees
final seedData = SeedData();
await seedData.seedEmployees();

// Clear all employees (untuk reset)
await seedData.clearEmployees();
```

## Features
- ✅ **Duplicate Check**: Otomatis skip jika employee ID sudah ada
- ✅ **Progress Log**: Menampilkan log setiap employee yang ditambahkan
- ✅ **Summary**: Total added vs skipped
- ✅ **Error Handling**: Graceful error handling dengan pesan yang jelas

## Output Example
```
✅ Added: Ahmad Fauzi (EMP001)
✅ Added: Siti Nurhaliza (EMP002)
✅ Added: Budi Santoso (EMP003)
✅ Added: Dewi Lestari (EMP004)
✅ Added: Rudi Hartono (EMP005)

📊 Summary:
   Added: 5 employees
   Skipped: 0 employees
   Total: 5 employees processed
```

## Notes
- 🔒 Developer Tools **hanya muncul untuk Manager**
- 🔄 Menjalankan seed data berkali-kali **tidak akan membuat duplikat**
- 📱 Dapat dijalankan di **semua platform** (Android, iOS, Web)
- 🗄️ Data disimpan langsung ke **Firestore**
