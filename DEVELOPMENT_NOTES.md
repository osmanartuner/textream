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

## Onaylanan logo ve doğrudan açılış — 10 Eylül 2026

- Kullanıcı koyu grafit zeminli, turkuaz teleprompter simgesini onayladı. macOS `AppIcon.appiconset` içindeki 10 boyut güncellendi; About görünümü de bu ortak simgeyi kullanır. iOS simgeleri değişmedi.
- Görsel yerleşik `image_gen` aracıyla üretildi. Özgün çıktı Codex'in generated_images alanında korundu; `sips` ile standart simge boyutlarına dönüştürüldü. Depodaki en büyük kaynak: `Textream/Textream/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png` (1024 × 1024, alfa kanallı).
- Son üretim istemi: “Create a polished macOS app icon for Textream Personal: a dark graphite rounded-square tile with a bold turquoise teleprompter glyph, three horizontal reading lines and a small pointer highlighting the middle line. Simple, centered, crisp and recognizable at small sizes; subtle depth, no letters, no words, no watermark. Square 1024 by 1024 canvas, transparent outside the rounded tile, with standard macOS icon padding.”
- Güncel kurulum yolu `/Applications/Textream Personal.app`. `script/build_and_run.sh` sonraki derlemelerde de bu konumu günceller. Bundle kimliği korunur: `dev.osmanartuner.textream.personal`.
- Bu bilgisayarda `~/Desktop/Textream Personal.app` kısayolu güncel kurulum yoluna bağlandı. Önceki `~/Applications/TextreamPersonal.app` kopyası, iki bundle kimliği doğrulandıktan ve yeni kurulum açıldıktan sonra Çöp Sepeti'ne taşındı.
- PASS — Release derlemesi tamamlandı; kurulu uygulamanın `codesign --verify --strict` kontrolü geçti. Derlenen ve kurulan `AppIcon.icns` dosyalarının SHA-256 değerleri aynı.
- PASS — Finder'da masaüstü kısayolunun yeni simgesi görüldü. Textream süreci çalışmıyorken kısayola çift tıklandı; `/Applications/Textream Personal.app/Contents/MacOS/TextreamPersonal` süreci ve ana pencere açıldı.
- PASS — Kayıtlı okuma dosyası uygulama arayüzünden yeniden açıldı. English (United States), 60 punto ve 1.3× satır aralığı yeni kurulumda doğrulandı. Uygulama bu dosya açık şekilde bırakıldı.
- Bu değişiklik simge ve kurulum konumuyla sınırlı; önceki 59 davranış kontrolü yeniden çalıştırılmadı. Betik sözdizimi ve diff kontrolü geçti.
- BEKLİYOR — Kullanıcının kaldırılmasını istediği orijinal `/Applications/Textream.app` (`dev.fka.textream`, root sahipliğinde) hâlâ mevcut. Finder üzerinden Çöp Sepeti'ne taşıma başlatıldı ve macOS yönetici doğrulaması bekleniyor. Bilgisayar kontrol aracı SecurityAgent erişimini güvenlik gerekçesiyle engelledi; kullanıcıdan Touch ID/parola doğrulamasını kendi ekranında tamamlaması istendi. Kaldırma tamamlanmış sayılmadı.

## Orijinal projeye katkılar — 10 Eylül 2026

- Kullanıcı, isim değişikliği olmadan logo ve işlevsel geliştirmelerin orijinal projeye gönderilmesini açıkça onayladı. `upstream/master` yenilendi; taban hâlâ `2c02f3eee2d8eac238c10a20d3d0e4b021465656`.
- [PR #119 — Improve speech tracking and macOS prompter readability](https://github.com/f/textream/pull/119): `contribute/macos-reading`, commit `1cedff71b754951fd5bf6e96083f43411c6ac56d`. Konuşma kurtarma, ekran dışındaki kelimelere kaydırma, kalıcı pencere, font ve satır aralığı kontrolleri; 17 dosya. İlgili açık katkılar #91, #93, #73 ve #68 açıklamada belirtildi.
- [PR #120 — Propose a refreshed macOS app icon](https://github.com/f/textream/pull/120): `contribute/macos-icon`, commit `3ad9ea8403cd740bdbec0416f04c780ce0ee7000`. Yalnızca 10 macOS simge PNG'si. Açıklamada eski/yeni görseller ve OpenAI ile üretildiği bilgisi yer alıyor.
- İki PR da `osmanartuner` hesabından `f/textream:master` hedefine, taslak olmayan OPEN durumda gönderildi ve GitHub API üzerinden doğrulandı. Bu kayıt anında kabul/merge gerçekleşmedi; CI kontrol sonucu yoktu.
- Katkı dallarında uygulama adı Textream ve bundle kimliği `dev.fka.textream`. Kişisel ad, kimlik, kurulum betiği ve Codex yapılandırması eklenmedi. Orijinal imzalama, yayın, güncelleme ve iOS dosyalarının tabanla aynı olduğu kontrol edildi.
- PASS — Katkı kodu dalında `./script/test_preferences.sh`: 59 kontrol. Her iki dal Apple Silicon macOS Release olarak, `CODE_SIGNING_ALLOWED=NO` ile başarıyla derlendi. Yalnızca kullanılmayan AppIntents metaverisi için derleyici uyarısı görüldü.
- PASS — 10 simgenin boyutu asset kataloğuyla eşleşiyor. Yeni derlenen uygulamalar Textream adı ve orijinal bundle kimliğiyle üretildi. İki dalın diff kontrolü geçti.
- Önceki kişisel sürümdeki arayüz testleri PR açıklamasında ayrı belirtildi; gerçek İngilizce ses, fiziksel harici ekran, Intel ve dağıtım imzası doğrulanmış sayılmadı. Yeni kurulum/Reset All için Floating Window ve 48 punto varsayılanı açıklamada belirtildi.
- Katkılar `.build/contribution-code` ve `.build/contribution-icon` çalışma ağaçlarında hazırlandı. Kurulu Textream Personal uygulaması bu işlemde yeniden kurulmadı; kişisel dalın uygulama kodu değiştirilmedi.
