# Dağıtım Kılavuzu — Musca domestica Shiny Uygulaması (Türkçe)

---

## 1. Yerel çalıştırma

### Adım 1 — Gerekli paketleri yükleyin (bir kez yapılır)

```r
install.packages(c("shiny", "bslib", "ggplot2", "dplyr", "tidyr",
                   "openxlsx", "DT", "patchwork"))
```

### Adım 2 — Uygulamayı başlatın

```r
shiny::runApp("musca_shiny_app_tr")
```

Veya doğrudan:

```r
shiny::runApp("/tam/yol/musca_shiny_app_tr")
```

Uygulama http://localhost:XXXX adresinde açılır. Durdurmak için R konsolunda `Ctrl + C` basın.

---

## 2. GitHub'a ekle (ackuyucu/Ekoloji_Lab)

Simülasyon mevcut reponun alt klasörü olarak yer alır.
Ekoloji_Lab'ın yerel klonundan şu komutları çalıştırın:

```bash
# Reponuz henüz yerel olarak yoksa:
git clone https://github.com/ackuyucu/Ekoloji_Lab.git
cd Ekoloji_Lab

# musca_shiny_app_tr klasörünü ekleyin, commit yapın ve push edin:
git add musca_shiny_app_tr/
git commit -m "Musca domestica Shiny uygulamasi (Turkce, 20/24/37 C) eklendi"
git push
```

---

## 3. shinyapps.io'ya dağıtım (ücretsiz kalıcı URL)

### Adım 1 — rsconnect paketini yükleyin

```r
install.packages("rsconnect")
```

### Adım 2 — Hesap bilgilerinizi ayarlayın

[shinyapps.io](https://www.shinyapps.io) adresine giriş yapın →
**Account → Tokens → Show → Show Secret → Copy to clipboard**

```r
rsconnect::setAccountInfo(
  name   = "<shinyapps-kullanici-adiniz>",
  token  = "<tokeniniz>",
  secret = "<sireniz>"
)
```

### Adım 3 — Uygulamayı dağıtın

```r
rsconnect::deployApp("musca_shiny_app_tr")
```

Yaklaşık 2 dakika içinde canlıya alınır. Uygulama URL'si şu biçimde olacaktır:

```
https://<kullanici-adiniz>.shinyapps.io/musca_shiny_app_tr/
```

---

## 4. Web sitesine gömme

Shinyapps.io'ya dağıttıktan sonra herhangi bir web sayfasına gömmek için:

```html
<iframe
  src="https://<kullanici-adiniz>.shinyapps.io/musca_shiny_app_tr/?showcase=0"
  width="100%"
  height="900px"
  style="border:none; border-radius:8px; box-shadow:0 2px 12px rgba(0,0,0,0.12);">
</iframe>
```

**Duyarlı sarmalayıcı** (her ekran boyutunda genişliği doldurur):

```html
<div style="position:relative; padding-bottom:80%; height:0; overflow:hidden;">
  <iframe
    src="https://<kullanici-adiniz>.shinyapps.io/musca_shiny_app_tr/?showcase=0"
    style="position:absolute; top:0; left:0; width:100%; height:100%; border:none;"
    allowfullscreen>
  </iframe>
</div>
```

---

## 5. Shiny Server (kendi sunucunuz)

Uygulamayı sunucudaki Shiny uygulamaları dizinine kopyalayın:

```bash
sudo cp -r musca_shiny_app_tr /srv/shiny-server/
```

Uygulama şu adreste erişilebilir olacaktır:

```
http://<sunucu-ip-adresi>:3838/musca_shiny_app_tr/
```

Shiny Server kurulumu için: https://posit.co/download/shiny-server/

---

## 6. Posit Connect (kurumsal)

```r
rsconnect::deployApp(
  appDir  = "musca_shiny_app_tr",
  server  = "<connect-sunucu-adresiniz>",
  account = "<hesabiniz>"
)
```

---

## Sorun giderme

| Hata | Çözüm |
|------|-------|
| `exit status 1` (shinyapps.io) | Tüm paketlerin yüklü olduğundan emin olun; `app.R` içinde `font_google()` veya harici dosya referansı olmadığını kontrol edin |
| Paket bulunamadı | `install.packages(c("shiny","bslib","ggplot2","dplyr","tidyr","openxlsx","DT","patchwork"))` komutunu çalıştırın |
| Uygulama başlamıyor | R konsolunda `shiny::runApp("musca_shiny_app_tr")` komutu ile hata mesajını görün |
| shinyapps.io log | Pano → Uygulamalar → uygulama adı → **Logs** |

---

## Repo içindeki dosya yapısı

```
Ekoloji_Lab/
└── musca_shiny_app_tr/
    ├── app.R          Shiny uygulaması (UI + sunucu + simülasyon çekirdeği)
    ├── README.md      GitHub açılış sayfası
    └── deploy.md      Bu dosya
```
