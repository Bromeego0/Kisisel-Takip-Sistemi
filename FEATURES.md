http://localhost:XXXX
(Chrome otomatik açılacak)# Kişisel Gelişim Takibi - Yeni Özellikler

## 📱 Geliştirilen Özellikler

### 1. **Gelişmiş Dashboard** 📊
- Bugünkü performans istatistikleri (saat:dakika formatında gösterim)
- Haftalık özet (toplam çalışma saati, tamamlanan görevler, deneme sayısı)
- Son çalışmalar ve denemeler listesi
- Gradyan arka planı ve modern tasarım

### 2. **To-Do / Yapılacaklar Sistemi** ✅
- Haftalık çalışma planı oluştur
- İçin:
  - Başlık ekle
  - Ders ve konu seç
  - Öncelik belirle (Düşük, Orta, Yüksek)
  - Due date ayarla
- Tamamladıkça tik at
- Haftalık ilerleme göstergesi
- Renkli öncelik gösterimi

### 3. **Saat:Dakika Format Girişi** ⏱️
- Ders çalışması eklerken saat ve dakika girebilirsin
  - Format: `1:30` (1 saat 30 dakika) veya `90` (90 dakika)
- Ana ekranda saat olarak gösterim (örn: "1s 30d")
- Daha doğal zaman takibi

### 4. **Deneme Sınavı Sistemi Iyileştirmesi** 📝
- **Hızlı Mod**: Sadece genel neti gir
- **Detaylı Mod**: Ders bazında netleri gir
- **Custom Sınav Türleri**:
  - TYT
  - AYT
  - LGS
  - ALES
  - KPSS
  - Diğer

### 5. **Custom Sınav ve Konu Desteği** 🎓
- Kendi sınav türlerini oluştur (LGS, ALES, vb.)
- Her sınava özgü konular ekle
- Tüm sınav türleri için tam istatistik desteği

### 6. **Tasarım Iyileştirmeleri** 🎨
- **Modern Tema**:
  - Mor ana renk (#6C63FF)
  - Turkuaz ikincil renk (#00D4FF)
  - Kırmızı vurgu renk (#FF6B6B)
  
- **Material Design 3** uyumlu
- **Light ve Dark Tema** tam desteği
- **Renkli Gradientler** ve shadow efektleri
- **Yumuşak Şekiller** (BorderRadius: 16px)
- **Responsive Design**

### 7. **Navigation Bar** 🧭
5 sekme ile tam özelleştirilmiş:
1. **Özet** - Dashboard
2. **Ajanda** - Takvim görünümü
3. **Yapılacaklar** - To-do liste
4. **Konular** - Konu takibi
5. **Raporlar** - İstatistikler

## 🎯 Özellik Karşılaştırması

| Özellik | Eski | Yeni |
|---------|-----|-----|
| Dashboard | Basit | Gelişmiş (hafta istatistikleri) |
| To-Do Sistemi | ❌ | ✅ Tam sistem |
| Zaman Girişi | Dakika | Saat:Dakika |
| Sınav Türleri | Sabit (TYT/AYT) | Custom |
| Tema | Standart | Modern gradient |
| Deneme Modu | Tek şekil | Hızlı + Detaylı |

## 📊 Veri Modelleri

### Yeni Models
- `todo_item.dart` - Yapılacaklar
- `exam_type.dart` - Custom sınav türleri

### Yeni Providers  
- `ExamTypeProvider` - Sınav türü yönetimi
- `TodoProvider` - Yapılacak yönetimi

## 🎮 Kullanım Örnekleri

### To-Do Ekleme
```
1. "Yapılacaklar" sekmesine git
2. "+" butonuna tıkla
3. Başlık gir (örn: "Türkçe - Sözcük Anlamı çalış")
4. Ders ve konu seç
5. Tarih ve öncelik belirle
6. "Ekle" butonuna tıkla
```

### Deneme Sınav Ekleme (Hızlı Mod)
```
1. "+" butonundan "Deneme Sınavı Ekle" seç
2. "Hızlı" modunu seç
3. Deneme adı gir
4. Sınav türünü seç (örn: ALES)
5. Tarih seç
6. Genel neti gir (örn: 180.5)
7. "Kaydet"
```

### Ders Çalışması Ekleme
```
1. "+" butonundan "Ders Çalışması Ekle" seç
2. Tarih seç
3. Ders ve konu seç
4. Çalışma süresini gir (1:30 veya 90)
5. Doğru/Yanlış/Boş sayısını gir
6. Notlar ekle (isteğe bağlı)
7. "Kaydet"
```

## 🚀 Başlangıç

### Requirements
- Flutter 3.5.4+
- Dart 3.5.4+

### Çalıştırma
```bash
# Web'de
./flutter/bin/flutter run -d chrome

# iOS'ta
./flutter/bin/flutter run -d ios

# Android'te
./flutter/bin/flutter run -d android

# macOS'ta
./flutter/bin/flutter run -d macos
```

## 📝 Notlar

- Tüm veriler yerel olarak Hive veritabanında saklanır
- İnternete bağlantı gerekmez
- Dark tema otomatik sistem ayarlarına göre değişir

## 🎨 Renkler

- **Birincil**: `#6C63FF` (Mor)
- **İkincil**: `#00D4FF` (Turkuaz)
- **Vurgu**: `#FF6B6B` (Kırmızı)
- **Başarı**: `#51CF66` (Yeşil)
- **Uyarı**: `#FFD93D` (Sarı)

---

**Versiyon**: 2.0.0  
**Son Güncelleme**: 1 Nisan 2026
