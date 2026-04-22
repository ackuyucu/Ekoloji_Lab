# 🪰 Musca domestica Kohort Simülasyonu — Shiny Uygulaması (Türkçe)

*Musca domestica* (ev sineği) için 20 °C, 24 °C ve 37 °C'de eş zamanlı kohort
simülasyonu. R ve Shiny ile geliştirilmiştir.

---

## Ne yapar?

Üç farklı sıcaklıkta laboratuvar kohortunu simüle eder. 24 °C ve 37 °C için evre
süreleri doğrudan **Flint ve ark. (2025)** *J Forensic Sci* 70(1) **Tablo 1**'den
alınmıştır. 20 °C için Birikimli Derece-Gün (BDG) yöntemi kullanılmıştır
(ADE = 12 °C). Demografik analiz Krebs (2014) ve Henderson (2016) yöntemlerine
dayanmaktadır.

**Evre sürelerinin kaynağı**

| Sıcaklık | Yöntem | Kaynak |
|----------|--------|--------|
| 20 °C | BDG yöntemi (ADE = 12 °C) | Wang *ve ark.* (2018) |
| 24 °C | Ampirik ölçüm | Flint *ve ark.* (2025) Tablo 1 |
| 37 °C | Ampirik ölçüm | Flint *ve ark.* (2025) Tablo 1 |

**Kenar çubuğu kontrolleri**
- Simüle edilecek sıcaklıkları seçin (bir veya birkaç)
- Sıcaklığa özgü hayatta kalma oranları, erişkin ömrü ve doğurganlığı ayarlayın
- Rastgele tohum ile tekrarlanabilir sonuçlar

**Çıktı sekmeleri**

| Sekme | İçerik |
|-------|--------|
| 📈 Popülasyon grafikleri | Altı panelli grafik: N♀, mₓ, yumurta, lₓ, qₓ, eₓ |
| 📊 Yaşam tablosu | Tüm standart sütunlar: x, Nₓ, lₓ, dₓ, qₓ, Lₓ, Tₓ, eₓ, mₓ |
| 🧮 Demografik parametreler | R₀, r, λ, T, Tₐ, e₀ — her sıcaklık için |
| ℹ️ Hakkında | Yöntemler, formüller, kaynaklar |

**İndirme:** Excel çalışma kitabı (Karşılaştırma + Popülasyon + Yetiştirme +
Yaşam Tablosu sayfaları) ve düz metin parametre özeti.

---

## Hızlı başlangıç

### Seçenek A — Yerel çalıştırma

```r
# Gerekli paketleri yükleyin (bir kez)
install.packages(c("shiny", "bslib", "ggplot2", "dplyr", "tidyr",
                   "openxlsx", "DT", "patchwork"))

# Uygulamayı başlatın
shiny::runApp("musca_shiny_app_tr")
```

Uygulama http://localhost:XXXX adresinde açılır.

### Seçenek B — shinyapps.io'ya dağıtım (ücretsiz kalıcı URL)

```r
install.packages("rsconnect")
rsconnect::setAccountInfo(name="<hesabiniz>",
                          token="<tokeniniz>",
                          secret="<sireniz>")
rsconnect::deployApp("musca_shiny_app_tr")
```

Ayrıntılar için `deploy.md` dosyasına bakın.

### Seçenek C — Shiny Server / Posit Connect

```bash
cp -r musca_shiny_app_tr /srv/shiny-server/
```

---

## Dosya yapısı

```
musca_shiny_app_tr/
├── app.R          Shiny uygulaması — UI + sunucu + simülasyon çekirdeği
├── README.md      Bu dosya
└── deploy.md      Dağıtım kılavuzu
```

---

## Yöntemler ve kaynaklar

| Kaynak | Kullanım amacı |
|--------|----------------|
| Flint CM *ve ark.* (2025) *J Forensic Sci* 70(1): 169–178 | 24 °C ve 37 °C ampirik evre süreleri (Tablo 1) |
| Ali MN *ve ark.* (2024) *Eur Chem Bull* 13(5): 10–25 | Erişkin ömrü parametreleri |
| Krebs CJ (2014) *Ecology* 6. baskı, Bölüm 8 | Yaşam tablosu yapısı |
| Henderson PA (2016) *Practical Methods in Ecology* 4. baskı, §12.4 | Yaşam tablosu formülleri |

---

## İlgili uygulamalar

| Uygulama | Dil | Sıcaklıklar |
|----------|-----|-------------|
| `musca_shiny_app/` | R / Shiny | 15 °C, 20 °C, 25 °C (BDG yöntemi) |
| `musca_shiny_app_tr/` | R / Shiny | **20 °C (BDG) · 24 °C · 37 °C (Flint 2025)** |
| `musca_streamlit_app/` | Python / Streamlit | 15 °C, 20 °C, 25 °C |
