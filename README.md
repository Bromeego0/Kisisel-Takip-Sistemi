# Kişisel Gelişim Takibi 📚

Sınav hazırlığını kolaylaştıran, modern ve kullanıcı dostu bir Flutter uygulaması.

## ✨ Özellikler

- **📊 Gelişmiş Dashboard** - Günlük ve haftalık performans takibi
- ✅ **To-Do Sistemi** - Haftalık çalışma planı ve yapılacak listesi
- ⏱️ **Saat:Dakika Girişi** - Çalışma süresi doğru şekilde belirle
- 📝 **Custom Sınav Türleri** - TYT, AYT, LGS, ALES, KPSS ve daha fazla
- 🎨 **Modern Tasarım** - Material Design 3, Light/Dark tema
- 📖 **Konu Takibi** - Konuların öğrenme durumunu takip et
- 📈 **İstatistikler** - Detaylı raporlar ve grafikler
- 🗓️ **Takvim Görünümü** - Çalışmalarını takvimde gör

## 🚀 Başlangıç

### Gereksinimler
```bash
Flutter 3.5.4+
Dart 3.5.4+
```

### Yükleme ve Çalıştırma

```bash
# Bağımlılıkları yükle
./flutter/bin/flutter pub get

# Web'de çalıştır
./flutter/bin/flutter run -d chrome

# iOS'ta çalıştır
./flutter/bin/flutter run -d ios

# Android'te çalıştır
./flutter/bin/flutter run -d android
```

## 📱 Ekranlar

1. **Özet (Dashboard)** - Bugünün ve haftanın özeti
2. **Ajanda** - Çalışmaları takvimde görüntüle
3. **Yapılacaklar** - Haftalık görevler ve planlar
4. **Konular** - Konuların öğrenme durumu
5. **Raporlar** - Detaylı istatistikler ve grafikler

## 🏗️ Mimari

### Teknolojiler
- **State Management**: Provider
- **Veritabanı**: Hive (Local Storage)
- **Navigation**: GoRouter
- **UI**: Flutter Material Design 3

### Klasör Yapısı
```
lib/
├── screens/       # Ekranlar
├── models/        # Veri modelleri
├── providers/     # State management
├── services/      # Veritabanı servisleri
├── theme/         # Tema yapılandırması
├── widgets/       # Yeniden kullanılabilir bileşenler
├── data/          # Sabit veriler (konular vb.)
└── main.dart      # Ana dosya
```

## 📊 Veri Modelleri

- **StudySession** - Çalışma oturumları
- **ExamRecord** - Deneme sınavları
- **TopicStatus** - Konu ilerleme durumu
- **TodoItem** - Yapılacaklar
- **ExamType** - Sınav türleri

## 🎨 Tasarım Hiyerarşisi

| Öğe | Renk |
|-----|------|
| Birincil | #6C63FF (Mor) |
| İkincil | #00D4FF (Turkuaz) |
| Vurgu | #FF6B6B (Kırmızı) |
| Başarı | #51CF66 (Yeşil) |
| Uyarı | #FFD93D (Sarı) |

## 💡 Kullanım İpuçları

1. **Saat Formatı**: Çalışma süresi girerken `1:30` (saat:dakika) veya `90` (dakika) yazabilirsin
2. **Hızlı Deneme**: Yalnızca neti girmek için "Hızlı" modunu kullan
3. **Detaylı Analiz**: Ders bazında netleri girmek için "Detaylı" modunu kullan
4. **To-Do Önceliği**: Görevler renkle gösterilir (Yeşil: Düşük, Portakal: Orta, Kırmızı: Yüksek)

## 📈 Gelecek Özellikler

- [ ] Cloud senkronizasyonu
- [ ] Sosyal özellikler (arkadaş ekleme, kıyaslaş)
- [ ] AI tabanlı öneriler
- [ ] Export raporlar (PDF, Excel)
- [ ] Hatırlatıcılar ve bildirimler

## 🤝 Katkıda Bulunma

Hataları bildir ya da özellik öner!

## 📄 Lisans

Bu proje özel kullanım içindir.

---

**Versiyon**: 2.0.0  
**Tarih**: 1 Nisan 2026  

Daha fazla bilgi için [FEATURES.md](FEATURES.md) dosyasını kontrol et.
