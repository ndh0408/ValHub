<!-- assets/legal/tr/ klasöründen otomatik olarak oluşturulan dosya. Elle düzenlemeyin: JSON içeriğini düzenleyin, ardından `dart run tool/export_legal_docs.dart` komutunu çalıştırın. -->

# Gizlilik Politikası

**ValHub** · Sürüm 1.2 · Yürürlük tarihi: 04/10/2026

Bu Politika, ValHub'ın kişisel verilerinizi nasıl topladığını, kullandığını, sakladığını ve koruduğunu, ayrıca bu verilere ilişkin haklarınızı açıklar. Politika, Vietnam'ın kişisel verilerin korunmasına ilişkin mevzuatına (13/2023/NĐ-CP sayılı Kararname (Nghị định 13/2023/NĐ-CP)) göre hazırlanmıştır ve yaşadığınız yerde yararlanabileceğiniz GDPR, UK GDPR, CCPA/CPRA veya LGPD gibi düzenlemeleri de dikkate alır ("Yaşadığınız yerin hukukuna göre haklarınız" bölümüne bakın). ValHub, her ülkedeki VALORANT oyuncuları içindir.

> Özet: Verilerinizin büyük kısmı yalnızca cihazınızda bulunur. Riot giriş verileriniz işletim sisteminizin güvenli depolama alanında saklanır ve ValHub sunucusunda yalnızca açık rızanızdan sonra şu amaçlarla kullanılır: Topluluk'a bağlandığınızda Riot ID'nizi doğrulamak ve bir inceleme kaydettiğinizde kaplama sahipliğini kontrol etmek. Erişim belirteci her doğrulamadan sonra imha edilir. Sunucu PUUID'nizi (oyuncu kimliğinizi) saklamaz. ValHub'da reklam yoktur; ValHub analiz veya izleme araçları kullanmaz ve verilerinizi satmaz.

## 1. Veri sorumlusu ve veri işleyen

Nguyễn Đức Huy ("biz"), ValHub'da kişisel verilerin işlenme amaçlarını ve araçlarını belirleyen taraftır (kişisel verilerin hem sorumlusu hem de işleyeni). İletişim bilgileri bu Politika'nın son bölümünde yer alır.

## 2. Kapsam

Bu Politika, Topluluk özellikleri dahil olmak üzere her ülkede iOS ve Android'deki ValHub uygulaması için geçerlidir. Politika; Riot Games, valorant-api.com, Apple, Google veya diğer üçüncü tarafların hizmetleri için geçerli değildir. Bu tarafların her biri verileri kendi politikasına göre işler.

## 3. Cihazınızda işlenen veriler

Aşağıdaki veriler uygulamayı kullandığınızda oluşturulur veya indirilir ve yalnızca cihazınızda saklanır. Bu verileri biz almayız.

- **Riot giriş verileri:** Riot'un resmî sayfasında giriş yaptıktan sonra Riot'un uygulamaya verdiği veriler; erişim belirteci (access token), sahiplik belirteci (entitlement token) ve giriş çerezleri (Riot'un giriş yaptığınızı hatırlamasını sağlayan dosyalar) bunlara dahildir. Bu veriler Keychain'de (iOS) veya Keystore ile korunan şifreli depolama alanında (Android) saklanır. ValHub, Riot'un sayfasına girdiğiniz şifreyi asla görmez.
- **Kayıtlı giriş bilgileri (isteğe bağlı):** daha hızlı yeniden giriş yapmak için Riot kullanıcı adınızı ve şifrenizi kaydetmeyi kendiniz seçerseniz, bu bilgiler yalnızca cihazınızdaki güvenli depolama alanında kalır. Talep ettiğinizde Riot'un resmî giriş sayfasına doldurulması dışında hiçbir zaman hata raporlarına yazılmaz veya herhangi bir yere gönderilmez.
- **Hesap listesi:** eklediğiniz hesapların Riot ID'si (ad#etiket), oyuncu kimliği (PUUID), bölgesi, platformu, Oyuncu Kartı, seviyesi ve rütbesi. Uygulama bunları hesap listesini göstermek ve hesaplar arasında geçiş yapmak için kullanır.
- **Oyun verileri:** mağaza, cüzdan, koleksiyon, kuşanım, Savaş Bileti, kontratlar, maç geçmişi, rütbe, mevcut maç, arkadaş listesi, çevrim içi durumu ve sohbet mesajları. Uygulama bunları Riot girişinizi kullanarak doğrudan Riot'un sunucularından okur ve çevrim dışıyken görüntüleyebilmeniz için geçici bir kopyasını saklayabilir.
- **İstek listesi ve ayarlar:** istek listesi, görünüm tercihleri, bildirim ayarları ve platform.
- **Geçici veriler:** valorant-api.com'dan alınan öğe, ajan ve harita adları ve görselleri ile indirilen görseller; uygulamanın daha hızlı çalışması için geçici olarak saklanır.
- **Hata raporları:** uygulamanın yaptığı işlemlere ilişkin cihazınızdaki teknik kayıt (gönderilen isteklerin adları, sonuçları ve süreleri); hataları bulmak için kullanılır. Kayıt; şifreleri, Riot giriş verilerini veya hesap kimliklerini içermeyecek şekilde filtrelenir ve yalnızca Ayarlar > Gelişmiş bölümünde "ValHub'a hata raporu gönder" seçeneğini kendiniz seçtiğinizde cihazınızdan çıkar.

## 4. Topluluk sunucusunda işlenen veriler

Topluluk sunucusu, yayıncının kendisinin işlettiği bir sunucudur. Veriler bu sunucunun diskindeki veritabanında ve dosyalarda saklanır. Uygulama'dan bu sunucuya yapılan bağlantılar Cloudflare'in ağı üzerinden geçer; Cloudflare yalnızca bağlantıları iletir. Aşağıdaki veriler yalnızca Topluluk özelliklerini kullandığınızda bu sunucuya gönderilir ve burada saklanır:

- **Topluluk profili:** Uygulama tarafından gönderilen Riot ID (ad ve etiket), bölge, Oyuncu Kartı, rütbe ve uygulama dili. Bu bilgiler Topluluk'taki diğer kullanıcılara açıktır.
- **Ülke:** Riot Hesabınızın ülkesi (doğrulama sırasında Riot tarafından sağlanır, sizin tarafınızdan düzenlenemez); Topluluk'u ülkeye göre göstermek için kullanılır.
- **Kullanıcı kimliği:** PUUID'nizden oluşturulan tek yönlü bir özet değeri (hash); bu değerden PUUID'nize geri ulaşılamaz. Sunucu PUUID'nizi saklamaz ve geri döndürmez.
- **Gönderiler ve yorumlar:** gönderi içeriği, yüklediğiniz görseller, paylaşmayı seçtiğiniz mağaza veya Gece Pazarı bilgileri, yorumlar, beğeniler ve paylaşım zamanı.
- **Kaplama incelemeleri:** yıldız puanı, inceleme metni ve başkalarının incelemelerine verdiğiniz "Faydalı" oyları. Bu bilgiler Riot ID'nizle birlikte herkese açık olarak gösterilir. Sunucu, kaplama sahipliğinin kontrol edildiği zamanı saklar; doğrulanmamış eski incelemeler açıkça belirtilir ve sıralama puanına dahil edilmez.
- **Takım arkadaşı ilanları:** grup kodu, oyun modu, bölge, rütbe sınırı, aranan roller, mikrofon gerekip gerekmediği, dil, grup büyüklüğü, boş yer sayısı, not, durum (açık, dolu, oyunda), gruba yapılan dokunma sayısı ve ilan açıkken Uygulama'nın düzenli olarak gönderdiği "hâlâ aktif" sinyali. İlanın süresi son sinyalden 30 dakika sonra otomatik olarak dolar. Her kişinin yalnızca bir aktif ilanı olabilir.
- **Oylar ve beğeniler:** oy verdiğiniz kaplamalar, beğeniler ve bunların yapıldığı zaman; en sevilen kaplamaları sıralamak için kullanılır.
- **İhlal bildirimleri:** bildirilen içerik, gerekçe ve bildiren kişi (kullanıcı kimliği biçiminde); moderasyon için kullanılır.
- **Sunucu erişim kayıtları:** sunucu, işletim ve hata bulma amacıyla her isteğin türünü, yolunu, sonucunu ve işlenme süresini kaydeder. IP adresleri yalnızca istek gönderme sıklığını sınırlamak için tuzlanmış özet değeri (rastgele bir dize eklenmiş tek yönlü özet) biçiminde kullanılır ve okunabilir biçimde kaydedilmez. Cloudflare, bağlantıları iletirken IP adreslerini kendi politikasına göre işleyebilir.
- **Yüklenen görseller:** paylaştığınız görseller Topluluk sunucusunun diskinde dosya olarak saklanır ve herkese açık bir bağlantı üzerinden açılabilir. Görsellerin nasıl silineceği "Verilerin silinmesi" bölümünde açıklanmıştır.
- **Yedekleme:** sunucu her gün yedeklenir; yedekler yayıncının sunucusunda 14 gün saklanır.

## 5. Riot erişim belirteci ve Riot ID doğrulaması

Riot giriş verileriniz (erişim belirteci, sahiplik belirteci ve çerezler) ValHub sunucusunda yalnızca aşağıda açıklanan doğrulama durumlarında kullanılır. Giriş çerezleri ve şifreler Topluluk sunucusuna gönderilmez:

- Riot'a giriş yaptıktan sonra, hesap özelliklerini kullanmaya devam etmeden önce bilgilendirmeyi okumanız ve onay vermeyi seçmeniz gerekir. Kararınız her hesap ve her politika sürümü için ayrı olarak saklanır. Onay vermezseniz o hesaptan çıkış yapabilirsiniz. Onay vermeyi seçmek kendiliğinden herhangi bir Riot belirteci göndermez; uygulama erişim belirtecini HTTPS üzerinden yalnızca Topluluk'a yeniden bağlanırken veya bir kaplama incelemesini kendiniz kaydettiğinizde gönderir.
- Sunucu, kimliğinizi (PUUID ve Riot ID) Riot'a sorar. Bir inceleme kaydettiğinizde sunucu ayrıca kaplama sahipliğinizi Riot'tan okur ve bu hesabın Topluluk'a giriş yapmış kişiyle eşleştiğini kontrol eder. Geçici erişim belirteci ve sahiplik belirteci saklanmaz veya kayıtlara yazılmaz; sunucu bunları isteği işledikten sonra imha eder.
- Sunucu, Uygulama'ya 30 gün geçerli, ayrı bir Topluluk giriş belirteci verir. Bu belirteç cihazınızdaki güvenli depolama alanında saklanır ve hesaptan çıkış yaptığınızda silinir.
- Topluluk sunucusu bu doğrulamalar için yalnızca kimlik bilgilerini ve kaplama sahipliğini okur; öğe satın almaz, kuşanımı değiştirmez veya Riot Hesabınızda değişiklik yapmaz.

## 6. İşleme amaçları

- Hesap bilgilerini, mağazayı, koleksiyonu, maçları ve talep ettiğiniz özellikleri göstermek.
- Etkinleştirmeniz hâlinde mağaza, istek listesi ve Gece Pazarı hakkında doğrudan cihazınızda bildirim göndermek.
- Topluluk'u işletmek: paylaşım yapan kişinin Riot ID'nin sahibi olduğunu doğrulamak; gönderileri, yorumları, takım arkadaşı ilanlarını ve kaplama sıralamalarını göstermek.
- Güvenliği sağlamak: spam, kötüye kullanım ve dolandırıcılığı önlemek; bildirilen içeriği denetlemek; belirli bir süre içinde gönderilebilecek istek sayısını sınırlamak.
- ValHub'a kendi isteğinizle hata raporu gönderdiğinizde hataları bulmak ve düzeltmek.
- Mevzuattan kaynaklanan yükümlülüklere uymak.

Verilerinizi reklam için kullanmayız, davranış profili oluşturmayız ve kişisel verileri satmaz, kiralamaz veya takas etmeyiz.

## 7. Hukuki sebepler

- **Rızanız:** giriş yaptıktan sonra bu Politika'ya açıkça onay vermeyi seçersiniz; bildirimleri etkinleştirirken veya giriş bilgilerini kaydederken de ayrıca onay verirsiniz. Rızanızı Ayarlar'dan dilediğiniz zaman geri çekebilirsiniz; bu durumda hesap özelliklerini kullanmaya devam etmek için yeniden onay vermeniz veya çıkış yapmanız gerekir.
- **Sözleşmenin ifası:** Kullanım Koşulları kapsamında talep ettiğiniz özellikleri sunmak için gerekli olan işleme.
- **Meşru menfaat:** Topluluk'u spam, kötüye kullanım ve dolandırıcılığa karşı korumak, bildirilen içeriği denetlemek ve sunucunun güvenliğini sağlamak; bunun için gereken asgari düzeyde veriyle.
- **Hukuki yükümlülük:** mevzuatın gerektirdiği hâllerde, örneğin yetkili kamu kurumlarının hukuka uygun taleplerine yanıt verirken.

## 8. Veri paylaşımı

Verileri yalnızca aşağıdaki durumlarda paylaşırız:

- **Riot Games:** Uygulama, hesap verilerini okumak ve talep ettiğiniz işlemleri gerçekleştirmek için Riot girişinizi kullanarak doğrudan Riot Games sunucularına bağlanır.
- **valorant-api.com:** Uygulama, öğelere ilişkin herkese açık verileri indirir; hesap bilgilerinizi göndermez.
- **Herkese açık dosyalar:** Uygulama, Riot'un herkese açık sunucu durumunu ve ValHub'ın genel yapılandırma dosyasını indirebilir; bu istekler kişisel veri içermez.
- **Cloudflare, Inc.:** Topluluk sunucusuna yapılan bağlantıları ileten ağı sağlar. Cloudflare, Topluluk verilerimizi saklamaz ancak IP adresi gibi teknik verileri kendi politikasına göre işleyebilir.
- **Diğer kullanıcılar:** Topluluk profiliniz, gönderileriniz, görselleriniz, yorumlarınız ve takım arkadaşı ilanlarınız diğer ValHub kullanıcılarına görünür. Paylaşılan görseller herkese açık bir bağlantı üzerinden açılabilir.
- **Yetkili kamu kurumları:** yayıncıya uygulanan mevzuat uyarınca hukuka uygun bir talep olduğunda.

## 9. Verilerin yurt dışına aktarılması

Topluluk sunucusu yayıncının kendisi tarafından işletilir. Bu sunucuya yapılan bağlantılar Cloudflare, Inc.'in küresel ağı üzerinden geçer; bu nedenle veriler birden fazla ülkeden geçebilir. Paylaştığınız Topluluk verileri her yerdeki ValHub kullanıcılarına görünür. Uygulama'yı kullandığınızda cihazınız ayrıca doğrudan Riot Games sunucularına bağlanır. Vietnam mevzuatı ve, karşılık gelen düzenlemelerin bulunduğu bir yerde yaşıyorsanız, yaşadığınız yerin hukuku uyarınca uygun koruma önlemlerini uygular ve kişisel verilerin yurt dışına aktarılmasına ilişkin yükümlülükleri yerine getiririz.

## 10. Saklama süreleri

- **Cihazınızdaki veriler:** ilgili hesaptan çıkış yapana, geçici verileri temizleyene veya Uygulama'yı kaldırana kadar saklanır. Geçici olarak saklanan görseller yaklaşık 30 gün sonra otomatik olarak yenilenir.
- **Takım arkadaşı ilanları:** son "hâlâ aktif" sinyalinden 30 dakika sonra süreleri otomatik olarak dolar ve gösterilmez; süresi dolan veriler düzenli aralıklarla silinir.
- **Gönderiler, incelemeler, yorumlar, oylar:** siz silene, ihlal nedeniyle biz kaldırana veya Topluluk verilerinizin silinmesini talep edene kadar saklanır.
- **İhlal bildirimleri:** ihlalleri ele almak ve kötüye kullanımı önlemek için en fazla 12 ay saklanır, ardından sunucu tarafından otomatik olarak silinir. Silinmiş içeriğe ilişkin bildirimler de silinir; kendi gönderdiğiniz bildirimler ise Topluluk verilerinizi sildiğinizde anonim hâle getirilir.
- **Sunucu erişim kayıtları:** istek gönderme sıklığını sınırlamak için yalnızca (IP adresinin) tuzlanmış özet değeri saklanır; teknik kayıtlar yalnızca hata bulma ve güvenlik için gerekli olan süre boyunca saklanır.
- **Yedekler:** 14 gün saklanır, ardından üzerine yazılır; bu nedenle silinen içerik en fazla 14 gün boyunca yedeklerde kalabilir.
- **Topluluk giriş belirteci:** 30 gün sonra geçerliliğini yitirir, çıkış yaptığınızda cihazdan silinir ve ağ bağlantısı olduğunda sunucuda iptal edilir.

## 11. Verilerin silinmesi

### Cihazınızda

- Ayarlar'da bir hesaptan çıkış yapmak; o hesabın Riot giriş verilerini (erişim belirteci ve çerezler), kayıtlı giriş bilgilerini, Topluluk giriş belirtecini, geçici verilerini ve planlanmış bildirimlerini cihazdan siler. İstek listesi, kuşanım setleri ile RR, maç ve mağaza geçmişi de silinir; ancak yeniden giriş yaptığınızda kullanmak üzere onay penceresinde yerel verileri saklamayı seçerseniz bunlar silinmez.
- Ayarlar > Gelişmiş bölümündeki "Geçici verileri temizle" seçeneği; görselleri, çevrim dışı görüntüleme için indirilen verileri, aranan oyuncu adlarını ve cihazda kaydedilen hata raporlarını siler. Kendi geçmişiniz korunur.
- "Yerel verileri sil" seçeneği, çıkış yapılmış hesapların geçmişini, kuşanım setlerini ve saklanan verilerini siler. Giriş yapılmış hesabın istek listesi kalır; bunu İstek listesi bölümünden kendiniz silebilirsiniz.
- Uygulama'yı kaldırmak, Uygulama'nın cihazdaki tüm verilerini siler.

### Topluluk sunucusunda

- Gönderilerinizi, incelemelerinizi, yorumlarınızı ve takım arkadaşı ilanlarınızı doğrudan Uygulama içinden kendiniz silebilir, oylarınızı geri alabilirsiniz.
- Riot ID'nize bağlı tüm Topluluk verilerini silmek için Ayarlar > "Topluluk verilerin" > "Topluluk verilerimi sil" yolunu izleyin. Sunucu gönderilerinizi, yorumlarınızı, incelemelerinizi, beğenilerinizi, oylarınızı, takım arkadaşı ilanlarınızı, görsellerinizi ve Topluluk hesabınızı kalıcı olarak siler. Bu işlem geri alınamaz. Riot ID'nizi belirterek ndh0408@gmail.com adresine e-posta da gönderebilirsiniz; hesabın sahibi olduğunuzu doğrulamanızı isteyebiliriz ve talebi 30 gün içinde sonuçlandırırız.
- Görseller: görsel dosyaları gönderiyle veya hesapla birlikte silinir. Bildirildiği için gizlenen içeriğe ait görsellere artık herkese açık olarak erişilemez ve bu görseller 30 gün sonra silinir; yüklenen ancak kullanılmayan görseller 24 saat sonra silinir. Bir görsel yüklediğinizde sunucu, konum bilgisini ve görseldeki diğer gizli verileri (EXIF meta verileri) kaldırır.
- Silinen içerik, üzerine yazılmadan önce en fazla 14 gün boyunca yedeklerde kalabilir.
- Not: Uygulama'dan çıkış yapmak, Topluluk sunucusunda paylaştığınız içeriği otomatik olarak silmez.

## 12. Bildirimler ve arka plan görevleri

ValHub yalnızca yerel bildirimler, yani doğrudan cihazınızın oluşturduğu bildirimler kullanır. Anlık bildirim (push) sunucusu işletmeyiz ve cihaz belirteçleri toplamayız. Uygulama, Riot girişinizin geçerliliğini korumak ve, etkinleştirdiyseniz, istek listenizdeki veya Gece Pazarı'ndaki kaplamalar hakkında sizi uyarmak üzere mağazayı doğrudan Riot'tan okumak için işletim sistemine, doğrudan cihazda düzenli aralıklarla çalışan bir arka plan görevi kaydeder. Bildirimleri Uygulama ayarlarından veya işletim sistemi ayarlarından kapatabilirsiniz.

## 13. Cihaz üzerinde içerik çevirisi

Topluluk içeriğini çevirmeyi seçtiğinizde ValHub, Google'ın cihaz üzerinde çalışan ML Kit çeviri aracını kullanır. Gerekli dil paketi henüz yoksa ValHub, paketi Google'dan indirmeden önce size sorar (paket başına yaklaşık 30 MB). İndirme işlemi ağ bağlantısı gerektirir ve Google, kendi politikası uyarınca IP adresi gibi bağlantıya ilişkin teknik bilgileri alabilir. Gönderi içeriği cihaz üzerinde çevrilir; çeviri için Google'a gönderilmez. Bu özelliği kullanmamayı tercih edebilirsiniz; ValHub sohbet botu veya yapay zekâ ile içerik üreten hizmetler kullanmaz.

## 14. Analiz, reklam ve izleme

ValHub; üçüncü taraf analiz araçları, otomatik çökme raporlama araçları, reklam veya izleme araçları içermez. ValHub reklam kimliklerini kullanmaz ve sizi uygulamalar veya web siteleri arasında izlemez. Bu durum gelecekte değişirse bu Politika'yı güncelleriz ve mevzuatın gerektirdiği hâllerde rızanızı alırız.

## 15. Veri güvenliği

- Gizli bilgiler (Riot giriş verileri, kayıtlı giriş bilgileri, Topluluk giriş belirteci) yalnızca işletim sisteminin güvenli depolama alanında (Keychain veya Keystore) saklanır ve Uygulama yeniden yüklendiğinde silinir.
- Tüm ağ bağlantıları şifrelenir (HTTPS/TLS).
- Hata raporları; Riot giriş verilerini, şifreleri ve hesap kimliklerini çıkarmak için otomatik olarak filtrelenir.
- Topluluk sunucusu PUUID'nin yalnızca tek yönlü özet değerini saklar; istek gönderme sıklığını (IP adresinin tuzlanmış özet değerine dayanarak) sınırlar; yalnızca kendi içeriğinizi silmenize izin verir; gizli anahtarları kaynak kodda değil, sunucunun özel yapılandırmasında tutar.
- Yalnızca özelliklerin gerektirdiği asgari düzeyde veri toplarız.

Hiçbir önlem mutlak güvenlik sağlamaz. Bir kişisel veri ihlali meydana gelirse, mevzuatın öngördüğü şekilde yetkili makamlara ve etkilenen kullanıcılara bildirimde bulunuruz.

## 16. Çocuklar

Uygulama 13 yaşın altındaki çocuklara yönelik değildir. Mevzuatın veri işlenmesine kendi başına rıza verebilmek için daha yüksek bir asgari yaş öngördüğü yerlerde (örneğin bazı Avrupa Birliği ülkelerinde 16 yaş), Uygulama'yı ve özellikle Topluluk özelliklerini yalnızca o yaşa ulaştığınızda veya ebeveyninizin ya da yasal vasinizin rızası ve gözetimiyle kullanabilirsiniz. Ebeveynseniz ve çocuğunuzun rıza olmaksızın Topluluk'a veri sağladığını düşünüyorsanız, bu verileri silebilmemiz için lütfen bizimle iletişime geçin.

## 17. Haklarınız

Vietnam'ın kişisel verilerin korunmasına ilişkin mevzuatı (13/2023/NĐ-CP sayılı Kararname dahil) uyarınca aşağıdaki haklara sahipsiniz:

- **Bilgi edinme hakkı:** verilerinizin işlenmesi hakkında bilgilendirilmek;
- **Rıza hakkı:** verilerinizin işlenmesine rıza vermek veya vermemek;
- **Erişim hakkı:** verilerinizi görüntülemek, düzeltmek veya düzeltilmesini talep etmek;
- **Rızayı geri çekme hakkı:** verdiğiniz rızayı geri çekmek;
- **Silme hakkı:** verilerinizin silinmesini talep etmek;
- **İşlemeyi kısıtlama hakkı:** verilerinizin işlenmesinin kısıtlanmasını talep etmek;
- **Verilerin sağlanmasını talep etme hakkı:** verilerinizin size sağlanmasını talep etmek;
- **İşlemeye itiraz hakkı:** verilerinizin istenmeyen amaçlarla işlenmesine itiraz etmek;
- **Şikâyet ve tazminat hakkı:** mevzuata uygun olarak şikâyette ve ihbarda bulunmak, dava açmak ve zararın tazminini talep etmek;
- **Kendini koruma hakkı:** kendi kişisel verilerinizi korumak.

Verilerin büyük kısmı cihazınızdadır ve bunları doğrudan Uygulama içinde kendiniz görüntüleyebilir veya silebilirsiniz. Topluluk sunucusundaki veriler için talebinizi ndh0408@gmail.com adresine gönderin. Talepleri 30 gün içinde sonuçlandırırız ve bundan önce kimliğinizi doğrulamamız gerekebilir. Ayrıca Topluluk verilerinizin bir kopyasını (JSON dosyası) Ayarlar > "Topluluk verilerin" > "Verilerimi indir" bölümünden kendiniz indirebilir ve bu verileri aynı yerden kendiniz silebilirsiniz.

## 18. Yaşadığınız yerin hukukuna göre haklarınız

Yaşadığınız yere bağlı olarak yerel mevzuat size ek haklar tanıyabilir. Nerede olursanız olun, aşağıdaki pratik haklarınızı ndh0408@gmail.com adresine e-posta göndererek kullanabilirsiniz; talepleri 30 gün içinde sonuçlandırırız ve haklarınızı kullandığınız için size ayrımcılık yapmayız.

- **Erişim:** hakkınızda hangi verileri tuttuğumuzu öğrenmek ve bir kopyasını almak;
- **Silme:** Riot ID'nize bağlı Topluluk verilerinin silinmesini talep etmek ("Verilerin silinmesi" bölümüne bakın);
- **Düzeltme:** yanlış verileri düzeltmek (Topluluk profiliniz her bağlandığınızda Riot hesabınızdan yenilenir);
- **Veri taşınabilirliği:** verilerinizi yaygın olarak kullanılan bir biçimde almak;
- **İtiraz, kısıtlama ve rızanın geri çekilmesi:** işlemeye itiraz etmek veya işlemenin kısıtlanmasını talep etmek ve rızanızı dilediğiniz zaman geri çekmek;
- **Şikâyet:** yaşadığınız yerdeki yetkili veri koruma otoritesine şikâyette bulunmak.

Size uygulanabilecek mevzuata bazı örnekler:

- **GDPR / UK GDPR:** Avrupa Birliği'nde, Avrupa Ekonomik Alanı'nda veya Birleşik Krallık'ta bulunuyorsanız: erişim, düzeltme, silme, kısıtlama, veri taşınabilirliği, itiraz ve rızayı geri çekme haklarının yanı sıra yaşadığınız ülkedeki veri denetim otoritesine şikâyette bulunma hakkına sahipsiniz. İşlemenin hukuki sebepleri "Hukuki sebepler" bölümünde belirtilmiştir.
- **CCPA / CPRA:** California'da ikamet ediyorsanız: verileri öğrenme, silme ve düzeltme hakkına ve verilerin "satılmasını" veya "paylaşılmasını" reddetme hakkına sahipsiniz. ValHub kişisel verileri satmaz ve bağlamlar arası davranışsal reklamcılık için paylaşmaz.
- **LGPD:** Brezilya'da bulunuyorsanız: erişim, düzeltme, anonimleştirme, silme, veri taşınabilirliği ve veri paylaşımı hakkında bilgi alma haklarına sahipsiniz.
- **PIPL ve benzeri yasalar:** Çin Anakarası'nda veya benzer yasaların bulunduğu bir yerde bulunuyorsanız: verileri bilme, karar verme, kısıtlama, reddetme, erişme, kopyalama, düzeltme ve silme haklarına ve işleme hakkında açıklama talep etme hakkına sahipsiniz.
- **13/2023/NĐ-CP sayılı Kararname:** Vietnam'da bulunuyorsanız: yukarıdaki "Haklarınız" bölümünde belirtilen haklar.

Gerekenden fazla veri toplamayız ve sizin üzerinizde hukuki sonuç doğuran otomatik kararlar almayız. Yanıtımızdan memnun kalmazsanız, yaşadığınız yerdeki yetkili makama şikâyette bulunma hakkına sahipsiniz.

## 19. Politika değişiklikleri

Uygulama veya mevzuat değiştiğinde bu Politika'yı güncelleyebiliriz. Sürüm ve yürürlük tarihi her zaman belgenin başında yer alır. Verilerin işlenme biçimine ilişkin önemli değişikliklerde sizi Uygulama içinde bilgilendirir ve gerektiğinde rızanızı yeniden alırız.

## 20. İletişim

Gizlilik ve kişisel verilerle ilgili her türlü soru veya talebiniz için lütfen iletişime geçin:

- **Veri sorumlusu:** Nguyễn Đức Huy
- **E-posta:** ndh0408@gmail.com

---

© 2026 Nguyễn Đức Huy. Tüm hakları saklıdır.
