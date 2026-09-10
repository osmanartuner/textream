# Textream Personal — 10 Eylül 2026

## İstenen kapsam

İngilizce konuşmayı takip eden macOS teleprompter penceresini büyük ekranda serbestçe taşıma, boyutlandırma ve yazıları büyütme. Konum, boyut ve yazı tercihleri korunmalı. Yanlış okunan veya atlanan kelimelerden sonra konuşma devam ediyorsa takip yeniden yakalanmalı; durunca metin beklemeli. Satır aralığı kullanıcı tarafından açılabilmeli.

## Başlangıç ve çalışma

- Upstream: `f/textream`, master `2c02f3eee2d8eac238c10a20d3d0e4b021465656`, sürüm 1.7.1.
- Fork: `https://github.com/osmanartuner/textream`.
- Yerel proje: `/Users/osmanartuner/Desktop/osmanartuner/Dev/Projects/textream`.
- Çalışma dalı: `personal-teleprompter`.
- SwiftUI + AppKit kullanan mevcut macOS hedefi geliştirildi. iOS hedefi değiştirilmedi.

## Uygulanan değişiklikler

- Yüzen pencere varsayılan oldu. İlk boyut 720 × 420; 500 punto genişlik sınırı kaldırıldı.
- Üstte taşıma alanı, sağ altta boyutlandırma tutamacı eklendi. AppKit kenarlarıyla boyutlandırma da kullanılabilir.
- Konum ve boyut hareket, boyut değişimi ve kapanışta kaydedilir. Ekran kaldırıldığında veya çözünürlük değiştiğinde kayıt görünür alana uyarlanır.
- Yazı boyutu 14–200 punto arasında sayısal bir tercih oldu; yeni kurulumlarda 48. Eski XS/SM/LG/XL kaydı sayısal boyuta aktarılır.
- Satır aralığı 1.0–2.5× arasında ayarlanabilir; 1.0× önceki aralığı korur. Ayarlar ve canlı pencere aynı `PrompterTextControls` bileşenini ve `NotchSettings` kaydını kullanır.
- Tam ekran görünümü de ortak yazı tipi, punto ve aralık tercihini kullanır.
- Büyük puntoda veya bir ifadeyi atlayınca ekran dışında kalan kelimenin konumu bulunamadığı için kaydırmanın durması düzeltildi. `PrompterLineGeometry`, görünmeyen satırların koordinatlarını sağlar; yalnızca görünür metnin çizilmesi sürer.
- Yazı tipi, punto ve satır aralığı değişirken okunan kelimeye yeniden hizalanır. Görünür satırlar belgenin başı sanılarak konumun bozulması önlendi.
- Apple Speech motoru korundu. `SpeechRecoveryMatcher`, yanlış okumadan sonra yakındaki en az üç net kelimeyle takip konumunu yeniden yakalar. 24 kelimeyi aşan gecikmelerde en az beş net kelime gerekir; arama 80 kelimeyle sınırlıdır. Belirsiz tekrarlanan ifadeler ve tek/iki kelimelik rastlantısal eşleşmeler bu kurtarmayı başlatmaz.
- Kurtarma sonrası eski konuşma metni yeni konuma tekrar uygulanmaz; sonraki kelimeyle normal takip sürer. Sessizlikte zamanlayıcıyla ilerleme eklenmedi.
- Ortak sözcük bölme kodu değiştirilmeden `SpeechTextAlignment.swift` dosyasına taşındı; gerçek takip kodu mikrofonsuz test edilebilir hale getirildi.
- Yüzen görünümde ayarları örten çentik önizlemesi kaldırıldı. Cam opaklığındaki kayıtlı sıfırın açılışta 0.15'e dönmesi düzeltildi.
- Uygulama adı, bundle kimliği, URL şeması ve güncelleme kaynağı kişisel fork için ayrıldı. Orijinal uygulama değiştirilmedi.
- Yerel derleme/kurulum/çalıştırma betiği ve Codex Run eylemi eklendi. Upstream GitHub yayın iş akışı kişisel forkta devre dışıdır.

## Doğrulama

- PASS — Apple Silicon macOS Release derlemesi, Xcode 26.1.1; son kaynak derlenip kuruldu.
- PASS — `~/Applications/TextreamPersonal.app` yerel imza kontrolü ve süreç açılışı.
- PASS — `script/test_preferences.sh`: 59 kontrol; 37 tercih/pencere/satır geometrisi, 22 konuşma kurtarma kontrolü. Gerçek `SpeechRecognizer` koduyla kısa ve uzun takılmadan sonra devam, aynı kısmi sonucun tekrarı, sessizlik ve sonraki ilk kelimenin ilerlemesi test edildi. Ses kaydı veya Speech hizmeti bu testlerde başlatılmaz.
- PASS — Ayrı süreçte tercihler yeniden okundu: punto, satır aralığı, İngilizce dil seçimi, Word Tracking, yazı tipi, konum/boyut ve sıfır opaklık korunuyor. Bozuk/eski kayıtlar ve değişen ekran geometrisi test edildi.
- PASS — Uygulama arayüzünde English (United States) ve Word Tracking doğrulandı.
- PASS — Canlı pencere 760 × 1057 boyutundan 710 × 997 boyutuna tutamaçla küçültüldü. Uygulama tamamen kapatılıp açıldığında 710 × 997, 60 punto ve 1.3× aralık korundu. Pencere testten önceki 760 × 1057 boyutuna döndürüldü.
- PASS — Metnin ilerleyen bölümünde bir kelime seçilip punto 60 → 96 → 60 değiştirildi; okunan kelime görünür kaldı. Canlı menüde ortak punto ve satır aralığı kontrolleri görüldü.
- PASS — Görsel kontrol için geçici kapatılan Hide from Screen Sharing tekrar açıldı ve arayüzde doğrulandı.
- PASS — Açık okuma metni uygulama içinden ayrı bir `.textream` dosyasına kaydedilip güncellemeden sonra yeniden açıldı. Metin kaynak kod deposuna eklenmedi.
- NOT VERIFIED — Son düzeltmelerin kullanıcının gerçek İngilizce sesi/aksanıyla doğruluğu; otomatik metin testleri mikrofon üzerinden uçtan uca kabul sayılmaz. Harici ekran donanımı, Intel ve notarize dağıtım test edilmedi.

## Komutlar

- `./script/build_and_run.sh --verify`: yerel derleme, kurulum ve açılış kontrolü.
- `./script/build_and_run.sh --build`: yerel derleme ve kurulum; açmaz.
- `./script/test_preferences.sh`: mikrofonsuz tercih, geometri ve takip testleri. Yalnızca kendine ait geçici UserDefaults alanını kullanır.
- Derleme günlüğü: `.build/personal/build.log`.
- İsteğe bağlı universal DMG betiği: `Textream/build.sh`; bu çalışmada kullanılmadı.
