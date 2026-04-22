# ─────────────────────────────────────────────────────────────────────────────
#  Musca domestica  Kohort Simülasyonu — Shiny Uygulaması (Türkçe)
#  Üç sıcaklıklı interaktif versiyon: 20 °C, 24 °C ve 37 °C
#
#  Evre süreleri:
#    24 °C ve 37 °C — Flint ve ark. (2025) J Forensic Sci 70(1) Tablo 1
#    20 °C          — Birikimli Derece-Gün (BDG) yöntemi, ADE = 12 °C
#
#  Gerekli paketler:
#    install.packages(c("shiny","bslib","ggplot2","dplyr","tidyr",
#                       "openxlsx","DT","patchwork"))
#
#  Yerel çalıştırma:  shiny::runApp("musca_shiny_app_tr")
#  Dağıtım:           rsconnect::deployApp("musca_shiny_app_tr")
# ─────────────────────────────────────────────────────────────────────────────

library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(tidyr)
library(openxlsx)
library(DT)
library(patchwork)

# ═════════════════════════════════════════════════════════════════════════════
# 1. SİMÜLASYON ÇEKİRDEĞİ
# ═════════════════════════════════════════════════════════════════════════════

# ── BDG sabitleri (20 °C için) ────────────────────────────────────────────
# Kaynak: Wang ve ark. (2018) / Flint ve ark. (2025) ADD değerleri
LDT       <- 12.0   # Alt Gelişim Eşiği (°C)
EGG_ADD   <-  9.68  # °C·gün — yumurta evresi
LARVA_ADD <- 72.57  # °C·gün — larva evresi
PUPA_ADD  <- 81.91  # °C·gün — pupa evresi
EGG_CV    <- 0.122; LARVA_CV <- 0.228; PUPA_CV <- 0.191

# ── Flint ve ark. (2025) Tablo 1 — ampirik evre süreleri ─────────────────
# Kümülatif minimum saatler (n = 18, ort ± SE):
#   24 °C: yumurta 18.67 h, pupalasma 176.89 h, erişkin çıkışı 334.44 h
#   37 °C: yumurta  9.06 h, pupalasma  84.06 h, erişkin çıkışı 172.06 h
# SD = SE × √n kullanılarak hesaplanmıştır.
EMPIRICAL <- list(
  "24" = list(em=18.67/24, es=0.095,
              lm=(176.89-18.67)/24, ls=0.861,
              pm=(334.44-176.89)/24, ps=1.254),
  "37" = list(em=9.06/24,  es=0.034,
              lm=(84.06-9.06)/24,   ls=0.661,
              pm=(172.06-84.06)/24, ps=0.797)
)

`%||%` <- function(a, b) if (!is.null(a)) a else b

truncated_normal <- function(mean, sd, low, high, size) {
  if (sd <= 0) return(rep(as.integer(round(mean)), size))
  out <- numeric(0)
  while (length(out) < size) {
    s   <- rnorm(size * 25, mean, sd)
    out <- c(out, s[s >= low & s <= high])
  }
  as.integer(round(out[seq_len(size)]))
}

mx_val <- function(age, pre, peak_day, sigma, peak) {
  if (age < pre) return(0.0)
  max(0.0, peak * exp(-0.5 * ((age - peak_day) / sigma)^2))
}

apply_mort <- function(n, daily_surv, n_days) {
  n <- as.integer(n)
  for (i in seq_len(n_days)) {
    if (n <= 0L) return(0L)
    n <- rbinom(1L, n, daily_surv)
  }
  n
}

make_p <- function(temp_C, d, label, color) {
  t_key <- as.character(temp_C)
  if (t_key %in% names(EMPIRICAL)) {
    # Flint ve ark. (2025) ampirik değerleri
    e  <- EMPIRICAL[[t_key]]
    em <- e$em; es <- e$es
    lm <- e$lm; ls <- e$ls
    pm <- e$pm; ps <- e$ps
  } else {
    # Diğer sıcaklıklar için BDG yöntemi
    eff <- temp_C - LDT
    em  <- EGG_ADD   / eff;  es <- em * EGG_CV
    lm  <- LARVA_ADD / eff;  ls <- lm * LARVA_CV
    pm  <- PUPA_ADD  / eff;  ps <- pm * PUPA_CV
  }
  list(
    label=label, color=color, temp_C=temp_C,
    egg_mean=em, egg_sd=es, larva_mean=lm, larva_sd=ls, pupa_mean=pm, pupa_sd=ps,
    adult_mean  = d$adult_mean,  adult_sd  = d$adult_sd,
    adult_min   = d$adult_min,   adult_max = d$adult_max,
    egg_surv    = d$egg_surv,    larva_surv = d$larva_surv,
    pupa_surv   = d$pupa_surv,
    pre_repro   = d$pre_repro,   peak_day  = d$peak_day,
    fec_sigma   = d$fec_sigma,   peak_eggs = d$peak_eggs
  )
}

run_sim <- function(p, sim_days, nf0 = 20L, nm0 = 20L) {
  f_life <- truncated_normal(p$adult_mean, p$adult_sd, p$adult_min, p$adult_max, nf0)
  m_life <- truncated_normal(p$adult_mean, p$adult_sd, p$adult_min, p$adult_max, nm0)
  days   <- 0L:sim_days
  n_fem  <- sapply(days, function(d) sum(f_life > d))
  n_mal  <- sapply(days, function(d) sum(m_life > d))
  mx     <- sapply(days, function(d)
    mx_val(d, p$pre_repro, p$peak_day, p$fec_sigma, p$peak_eggs))
  eggs   <- sapply(seq_along(days), function(i)
    if (n_fem[i] > 0 && mx[i] > 0) rpois(1L, n_fem[i] * mx[i]) else 0L)

  nur <- lapply(seq_along(days), function(i) {
    ne <- as.integer(eggs[i]); d <- days[i]
    if (ne == 0L) return(data.frame(egg_day=d, n_eggs=0L, egg_dur=0L,
                                    n_hatched=0L, larva_dur=0L, n_pupated=0L,
                                    pupa_dur=0L, n_emerged=0L, emerge_day=NA_real_))
    ed  <- max(1L, as.integer(round(rnorm(1, p$egg_mean,   p$egg_sd))))
    ld  <- max(3L, as.integer(round(rnorm(1, p$larva_mean, p$larva_sd))))
    pd  <- max(3L, as.integer(round(rnorm(1, p$pupa_mean,  p$pupa_sd))))
    n_h <- apply_mort(ne,  p$egg_surv,   ed)
    n_p <- apply_mort(n_h, p$larva_surv, ld)
    n_e <- apply_mort(n_p, p$pupa_surv,  pd)
    data.frame(egg_day=d, n_eggs=ne, egg_dur=ed, n_hatched=n_h,
               larva_dur=ld, n_pupated=n_p, pupa_dur=pd,
               n_emerged=n_e, emerge_day=d+ed+ld+pd)
  })
  nursery <- bind_rows(nur)
  list(p=p, days=days, n_fem=n_fem, n_mal=n_mal,
       mx=mx, eggs=eggs, nursery=nursery)
}

build_lt <- function(sim) {
  N0 <- sim$n_fem[1]
  lt <- data.frame(x=sim$days, Nx=sim$n_fem, mx=sim$mx)
  lt$lx      <- lt$Nx / N0
  lt$dx      <- pmax(c(-diff(lt$Nx), 0), 0)
  lt$qx      <- ifelse(lt$Nx > 0, lt$dx / lt$Nx, 0)
  lt$Lx      <- (lt$Nx + c(lt$Nx[-1], 0)) / 2
  lt$Tx      <- rev(cumsum(rev(lt$Lx)))
  lt$ex      <- ifelse(lt$Nx > 0, lt$Tx / lt$Nx, 0)
  lt$lx_mx   <- lt$lx * lt$mx
  lt$x_lx_mx <- lt$x  * lt$lx_mx
  lt
}

calc_dem <- function(lt, sim) {
  R0    <- sum(lt$lx_mx)
  T_gen <- if (R0 > 0) sum(lt$x_lx_mx) / R0 else NA_real_
  r     <- if (!is.na(T_gen) && T_gen > 0 && R0 > 0) log(R0) / T_gen else NA_real_
  lam   <- if (!is.na(r)) exp(r) else NA_real_
  Td    <- if (!is.na(r) && r > 0) log(2) / r else NA_real_
  alive <- which(sim$n_fem > 0)
  list(
    R0     = round(R0, 3),
    R0_f   = round(R0 / 2, 3),
    T_gen  = round(T_gen, 2),
    r      = round(r, 4),
    lam    = round(lam, 4),
    Td     = round(Td, 2),
    e0     = round(lt$ex[1], 2),
    max_life = if (length(alive)) max(alive) - 1L else 0L,
    tot_eggs     = sum(sim$nursery$n_eggs),
    tot_emerged  = sum(sim$nursery$n_emerged),
    imm_surv     = if (sum(sim$nursery$n_eggs) > 0)
                     round(100 * sum(sim$nursery$n_emerged) /
                             sum(sim$nursery$n_eggs), 1) else 0
  )
}

# ═════════════════════════════════════════════════════════════════════════════
# 2. VARSAYILAN PARAMETRELER
#
#  20 °C — BDG evre süreleri; erişkin parametreleri: Ali ve ark. (2024)
#  24 °C — Flint ve ark. (2025) Tablo 1; erişkin: Ali ve ark. (2024)
#  37 °C — Flint ve ark. (2025) Tablo 1; kısa erişkin ömrü (üst ısı stresi)
# ═════════════════════════════════════════════════════════════════════════════
DEF <- list(
  "20" = list(adult_mean=32,  adult_sd=5.5, adult_min=18, adult_max=52,
              egg_surv=0.88,  larva_surv=0.970, pupa_surv=0.982,
              pre_repro=6,   peak_day=15, fec_sigma=7.0, peak_eggs=16.0),
  "24" = list(adult_mean=22,  adult_sd=3.5, adult_min=12, adult_max=34,
              egg_surv=0.85,  larva_surv=0.960, pupa_surv=0.975,
              pre_repro=3,   peak_day=9,  fec_sigma=4.5, peak_eggs=24.0),
  "37" = list(adult_mean=10,  adult_sd=2.0, adult_min=5,  adult_max=16,
              egg_surv=0.82,  larva_surv=0.945, pupa_surv=0.960,
              pre_repro=2,   peak_day=5,  fec_sigma=2.5, peak_eggs=15.0)
)
COLS <- c("20"="#43A047", "24"="#1565C0", "37"="#E53935")
LBLS <- c("20"="20\u00b0C", "24"="24\u00b0C", "37"="37\u00b0C")

# ── Her sıcaklık için parametre paneli ────────────────────────────────────
temp_panel <- function(t) {
  d <- DEF[[t]]
  tagList(
    h6("Evre hayatta kalma oran\u0131  (g\u00fcnl\u00fck olas\u0131l\u0131k)",
       style = "color:#555; font-weight:600; margin-top:8px"),
    fluidRow(
      column(4, sliderInput(paste0("egg_surv_",   t), "Yumurta",
                            min=0.5, max=1.0, value=d$egg_surv,   step=0.005)),
      column(4, sliderInput(paste0("larva_surv_", t), "Larva",
                            min=0.5, max=1.0, value=d$larva_surv, step=0.005)),
      column(4, sliderInput(paste0("pupa_surv_",  t), "Pupa",
                            min=0.5, max=1.0, value=d$pupa_surv,  step=0.005))
    ),
    h6("Eri\u015fkin ya\u015fam s\u00fcresi (g\u00fcn)",
       style="color:#555; font-weight:600; margin-top:4px"),
    fluidRow(
      column(6, sliderInput(paste0("adult_mean_", t), "Ortalama",
                            min=5, max=120, value=d$adult_mean, step=1)),
      column(6, sliderInput(paste0("adult_sd_",   t), "SS",
                            min=1, max=30,  value=d$adult_sd,   step=0.5))
    ),
    h6("Do\u011furganlk", style="color:#555; font-weight:600; margin-top:4px"),
    fluidRow(
      column(4, sliderInput(paste0("pre_repro_",  t), "\u00dcreme \u00f6ncesi (g\u00fcn)",
                            min=1, max=30, value=d$pre_repro, step=1)),
      column(4, sliderInput(paste0("peak_eggs_",  t), "Maks. yumurta/\u2640/g\u00fcn",
                            min=1, max=60, value=d$peak_eggs, step=0.5)),
      column(4, sliderInput(paste0("fec_sigma_",  t), "Yay\u0131l\u0131m \u03c3",
                            min=1, max=20, value=d$fec_sigma, step=0.5))
    )
  )
}

# ═════════════════════════════════════════════════════════════════════════════
# 3. KULLANICI ARAYÜZÜ (UI)
# ═════════════════════════════════════════════════════════════════════════════
ui <- page_sidebar(
  title = "Musca domestica  Kohort Sim\u00fclasyonu",
  theme = bs_theme(
    bootswatch = "flatly",
    primary    = "#1D4ED8"
  ),

  sidebar = sidebar(
    width = 340,

    h5("\u2699\ufe0f  Sim\u00fclasyon Ayarlar\u0131", style = "font-weight:700"),

    checkboxGroupInput(
      "temps_sel", "Sim\u00fcle edilecek s\u0131cakl\u0131klar",
      choiceNames  = list(
        tags$span(style="color:#43A047; font-weight:600", "20\u00b0C"),
        tags$span(style="color:#1565C0; font-weight:600", "24\u00b0C"),
        tags$span(style="color:#E53935; font-weight:600", "37\u00b0C")
      ),
      choiceValues = c("20", "24", "37"),
      selected     = c("20", "24", "37")
    ),
    sliderInput("sim_days", "Sim\u00fclasyon s\u00fcresi (g\u00fcn)",
                min=20, max=100, value=60, step=5),
    numericInput("seed", "Rastgele tohum (tekrarlanabilirlik)",
                 value=42, min=1, max=99999, step=1),

    hr(),

    h5("\ud83d\udcc1  Biyolojik parametreler", style="font-weight:700"),
    tabsetPanel(
      id = "param_tabs", type = "pills",
      tabPanel("20\u00b0C", temp_panel("20")),
      tabPanel("24\u00b0C", temp_panel("24")),
      tabPanel("37\u00b0C", temp_panel("37"))
    ),

    hr(),

    actionButton("run_btn", "\u25b6  Sim\u00fclasyonu \u00c7al\u0131\u015ft\u0131r",
                 class="btn-primary btn-lg w-100"),

    br(), br(),

    h6("Sonu\u00e7lar\u0131 indir", style="font-weight:600"),
    downloadButton("dl_excel", "Excel dosyas\u0131",
                   class="btn-success w-100"),
    br(), br(),
    downloadButton("dl_txt",   "Parametre \u00f6zeti (.txt)",
                   class="btn-outline-secondary w-100")
  ),

  navset_tab(
    nav_panel(
      "\ud83d\udcc8  Pop\u00fclasyon grafikleri",
      uiOutput("plot_msg"),
      plotOutput("main_plot", height = "640px")
    ),
    nav_panel(
      "\ud83d\udcca  Ya\u015fam tablosu",
      fluidRow(
        column(4,
          selectInput("lt_temp", "Ya\u015fam tablosunu g\u00f6ster:",
                      choices  = c("20\u00b0C"="20", "24\u00b0C"="24", "37\u00b0C"="37"),
                      selected = "24")
        )
      ),
      DTOutput("lt_table")
    ),
    nav_panel(
      "\ud83e\uddee  Demografik parametreler",
      br(),
      uiOutput("demog_cards")
    ),
    nav_panel(
      "\u2139\ufe0f  Hakk\u0131nda",
      br(),
      shiny::markdown("
## Bu simülasyon hakkında

Bu uygulama, *Musca domestica* (ev sineği) laboratuvar kohortunu **20 °C**,
**24 °C** ve **37 °C**'de eş zamanlı olarak modellemektedir.
Demografik analiz Krebs (2014) ve Henderson (2016) yöntemlerine dayanmaktadır.

---

### Evre sürelerinin kaynağı

| Sıcaklık | Yöntem | Kaynak |
|----------|--------|--------|
| **20 °C** | Birikimli Derece-Gün (BDG), ADE = 12 °C | Wang *ve ark.* (2018) |
| **24 °C** | Ampirik ölçüm | Flint *ve ark.* (2025) Tablo 1 |
| **37 °C** | Ampirik ölçüm | Flint *ve ark.* (2025) Tablo 1 |

#### Flint ve ark. (2025) Tablo 1 — ampirik değerler (n = 18, ort ± SE)

| Evre | 24 °C | 37 °C |
|------|-------|-------|
| Yumurta (gün)  | 0.778 ± 0.022 | 0.378 ± 0.008 |
| Larva (gün)    | 6.593 ± 0.359 | 3.125 ± 0.276 |
| Pupa (gün)     | 6.565 ± 0.523 | 3.667 ± 0.332 |

> SE'den SD'ye dönüşüm: SD = SE × √n (n = 18)

#### BDG yöntemi — 20 °C hesaplanan değerler

| Evre | BDG (°C·gün) | 20 °C'de süre (gün) |
|------|-------------|----------------------|
| Yumurta | 9.68  | 1.21 |
| Larva   | 72.57 | 9.07 |
| Pupa    | 81.91 | 10.24 |

> Formül: süre = BDG / (T − ADE),  T = 20 °C,  ADE = 12 °C

---

### Simülasyon nasıl çalışır?

| Adım | Ne olur |
|------|---------|
| **1 — Başlatma** | 20 dişi + 20 erkek oluşturulur; her bireye kesik normal dağılımdan rastgele bir yaşam süresi atanır |
| **2 — Günlük döngü** | Hayatta kalan dişiler her gün yumurta bırakır; günlük yumurta sayısı Gauss doğurganlık eğrisine göre ölçeklendirilmiş Poisson dağılımından çekilir |
| **3 — Yetiştirme** | Her yumurta grubu **yumurta → larva → pupa** evrelerinden geçer; süre kesik normal dağılımdan rastgele belirlenir ve her gün binom ölüm uygulanır |
| **4 — Yaşam tablosu** | Standart sütunlar hesaplanır: *N*ₓ, *l*ₓ, *d*ₓ, *q*ₓ, *L*ₓ, *T*ₓ, *e*ₓ, *m*ₓ |
| **5 — Demografik parametreler** | R₀, nesil süresi *T*, içsel artış hızı *r*, sonlu artış hızı λ, ikiye katlanma süresi *T*ₐ ve yaşam beklentisi *e*₀ |

---

### Temel formüller

| Parametre | Formül |
|-----------|--------|
| Net üreme hızı R₀ | Σ(*l*ₓ · *m*ₓ) |
| Ortalama nesil süresi T | Σ(x · *l*ₓ · *m*ₓ) / R₀ |
| İçsel artış hızı r | ≈ ln(R₀) / T |
| Sonlu artış hızı λ | eʳ |
| İkiye katlanma süresi Tₐ | ln 2 / r |

---

### Kaynaklar

Flint CM *ve ark.* (2025) *J Forensic Sci* 70(1): 169–178.
*(Tablo 1 — 24 °C ve 37 °C ampirik evre süreleri)*

Ali MN *ve ark.* (2024) *Eur Chem Bull* 13(5): 10–25.
*(Erişkin ömrü parametreleri)*

Krebs CJ (2014) *Ecology* 6. baskı, Bölüm 8.

Henderson PA (2016) *Practical Methods in Ecology* 4. baskı, §12.4.
      ")
    )
  )
)

# ═════════════════════════════════════════════════════════════════════════════
# 4. SUNUCU (SERVER)
# ═════════════════════════════════════════════════════════════════════════════
server <- function(input, output, session) {

  get_d <- function(t) {
    list(
      adult_mean  = input[[paste0("adult_mean_",  t)]],
      adult_sd    = input[[paste0("adult_sd_",    t)]],
      adult_min   = DEF[[t]]$adult_min,
      adult_max   = DEF[[t]]$adult_max,
      egg_surv    = input[[paste0("egg_surv_",    t)]],
      larva_surv  = input[[paste0("larva_surv_",  t)]],
      pupa_surv   = input[[paste0("pupa_surv_",   t)]],
      pre_repro   = input[[paste0("pre_repro_",   t)]],
      peak_day    = DEF[[t]]$peak_day,
      fec_sigma   = input[[paste0("fec_sigma_",   t)]],
      peak_eggs   = input[[paste0("peak_eggs_",   t)]]
    )
  }

  results <- eventReactive(input$run_btn, {
    req(length(input$temps_sel) >= 1)
    set.seed(input$seed)
    sim_days <- input$sim_days
    out <- list()
    for (t in input$temps_sel) {
      p    <- make_p(as.numeric(t), get_d(t), LBLS[[t]], COLS[[t]])
      sim  <- run_sim(p, sim_days)
      lt   <- build_lt(sim)
      dem  <- calc_dem(lt, sim)
      out[[t]] <- list(p=p, sim=sim, lt=lt, dem=dem)
    }
    out
  }, ignoreNULL = FALSE)

  output$plot_msg <- renderUI({
    if (is.null(results()) || length(results()) == 0)
      tags$div(class="alert alert-warning",
               "L\u00fctfen en az bir s\u0131cakl\u0131k se\u00e7in ve \u00c7al\u0131\u015ft\u0131r'a bas\u0131n.")
    else NULL
  })

  make_plot <- function() {
    res <- results(); req(length(res) > 0)

    pop_df <- bind_rows(lapply(names(res), function(t) {
      r <- res[[t]]
      data.frame(day=r$sim$days, n_fem=r$sim$n_fem, n_mal=r$sim$n_mal,
                 mx=r$sim$mx, eggs=r$sim$eggs,
                 lx=r$lt$lx, qx=r$lt$qx, ex=r$lt$ex,
                 label=r$p$label, color=r$p$color)
    }))

    col_map <- setNames(
      sapply(names(res), function(t) res[[t]]$p$color),
      sapply(names(res), function(t) res[[t]]$p$label)
    )
    scale_col <- scale_color_manual(values=col_map, name=NULL)
    theme_base <- theme_bw(base_size=11) +
      theme(legend.position="bottom",
            panel.grid.minor=element_blank(),
            strip.background=element_blank(),
            plot.title=element_text(size=10, face="bold"))

    p1 <- ggplot(pop_df, aes(day, n_fem, color=label)) +
      geom_line(linewidth=0.9) + scale_col + theme_base +
      labs(title="Hayatta kalan di\u015filer (N\u2093)",
           x="Ya\u015f (g\u00fcn)", y="Di\u015fi say\u0131s\u0131")

    p2 <- ggplot(pop_df, aes(day, mx, color=label)) +
      geom_line(linewidth=0.9) + scale_col + theme_base +
      labs(title="Ya\u015fa \u00f6zg\u00fc do\u011furganlk (m\u2093)",
           x="Ya\u015f (g\u00fcn)", y="Yumurta / \u2640 / g\u00fcn")

    p3 <- ggplot(pop_df, aes(day, eggs, color=label)) +
      geom_line(linewidth=0.8, alpha=0.7) + scale_col + theme_base +
      labs(title="G\u00fcnl\u00fck toplanan yumurtalar",
           x="G\u00fcn", y="Yumurta")

    p4 <- ggplot(pop_df, aes(day, lx, color=label)) +
      geom_line(linewidth=0.9) + scale_col + theme_base +
      labs(title="Sa\u011fkal\u0131m (l\u2093)",
           x="Ya\u015f (g\u00fcn)", y="l\u2093")

    p5 <- ggplot(pop_df %>% filter(qx < 1), aes(day, qx, color=label)) +
      geom_line(linewidth=0.8) + scale_col + theme_base +
      labs(title="Ya\u015fa \u00f6zg\u00fc \u00f6l\u00fcm oran\u0131 (q\u2093)",
           x="Ya\u015f (g\u00fcn)", y="q\u2093")

    p6 <- ggplot(pop_df %>% filter(ex > 0), aes(day, ex, color=label)) +
      geom_line(linewidth=0.9) + scale_col + theme_base +
      labs(title="Ya\u015fam beklentisi (e\u2093)",
           x="Ya\u015f (g\u00fcn)", y="Kalan g\u00fcn")

    (p1 + p2 + p3) / (p4 + p5 + p6) +
      plot_layout(guides="collect") &
      theme(legend.position="bottom")
  }

  output$main_plot <- renderPlot({ make_plot() }, res=120)

  output$lt_table <- renderDT({
    res <- results(); req(length(res) > 0)
    t   <- input$lt_temp
    if (!t %in% names(res)) t <- names(res)[1]
    lt  <- res[[t]]$lt
    lt_show <- lt %>%
      select(x, Nx, lx, dx, qx, Lx, Tx, ex, mx, lx_mx, x_lx_mx) %>%
      mutate(across(where(is.double), ~ round(.x, 4)))
    colnames(lt_show) <- c("x", "N\u2093", "l\u2093", "d\u2093", "q\u2093",
                           "L\u2093", "T\u2093", "e\u2093 (g\u00fcn)",
                           "m\u2093", "l\u2093\u00b7m\u2093", "x\u00b7l\u2093\u00b7m\u2093")
    datatable(lt_show,
              options  = list(pageLength=20, scrollX=TRUE, dom="tip"),
              rownames = FALSE,
              class    = "compact hover stripe") %>%
      formatStyle(columns=1:11, fontSize="13px")
  })

  output$demog_cards <- renderUI({
    res <- results(); req(length(res) > 0)
    cards <- lapply(names(res), function(t) {
      d   <- res[[t]]$dem
      col <- res[[t]]$p$color
      lbl <- res[[t]]$p$label
      card(
        card_header(
          tags$span(style=paste0("color:", col, "; font-weight:700; font-size:1.1em"), lbl)
        ),
        tags$table(
          class="table table-sm table-striped",
          style="font-size:0.92em",
          tags$thead(tags$tr(tags$th("Parametre"), tags$th("De\u011fer"))),
          tags$tbody(
            tags$tr(tags$td("Net \u00dcreme H\u0131z\u0131  R\u2080"),
                    tags$td(d$R0)),
            tags$tr(tags$td("R\u2080  yaln\u0131zca di\u015filer  (1:1 cinsiyet oran\u0131)"),
                    tags$td(d$R0_f)),
            tags$tr(tags$td("Ortalama Nesil S\u00fcresi  T  (g\u00fcn)"),
                    tags$td(d$T_gen)),
            tags$tr(tags$td("\u0130\u00e7sel art\u0131\u015f h\u0131z\u0131  r  (/g\u00fcn)"),
                    tags$td(d$r)),
            tags$tr(tags$td("Sonlu art\u0131\u015f h\u0131z\u0131  \u03bb"),
                    tags$td(d$lam)),
            tags$tr(tags$td("Pop\u00fclasyon ikiye katlanma s\u00fcresi  T\u2090  (g\u00fcn)"),
                    tags$td(d$Td)),
            tags$tr(tags$td("Do\u011fumda ya\u015fam beklentisi  e\u2080  (g\u00fcn)"),
                    tags$td(d$e0)),
            tags$tr(tags$td("G\u00f6zlenen maks. ya\u015fam s\u00fcresi (g\u00fcn)"),
                    tags$td(d$max_life)),
            tags$tr(tags$td("Toplanan toplam yumurta"),
                    tags$td(d$tot_eggs)),
            tags$tr(tags$td("Yeti\u015ftirmeden \u00e7\u0131kan eri\u015fkinler"),
                    tags$td(d$tot_emerged)),
            tags$tr(tags$td("Olgunla\u015fmam\u0131\u015f evre hayatta kalma (%)"),
                    tags$td(d$imm_surv))
          )
        )
      )
    })
    do.call(layout_columns,
            c(cards, list(col_widths = rep(12 / max(1, length(res)), length(res)))))
  })

  output$dl_excel <- downloadHandler(
    filename = function() paste0("musca_simulasyon_", Sys.Date(), ".xlsx"),
    content  = function(file) {
      res <- results(); req(length(res) > 0)
      wb  <- createWorkbook()

      addWorksheet(wb, "Karsilastirma")
      params_names <- c(
        "Sicaklik (C)", "R0", "R0 disiler",
        "Ort. Nesil Suresi T (gun)", "r (/gun)", "lambda",
        "Ikikatlanma Suresi (gun)", "e0 (gun)", "Maks. Omur (gun)",
        "Toplam Yumurta", "Cikan Eriskinler", "Olgunlasmamis Hayatta Kalma (%)"
      )
      comp <- data.frame(Parametre=params_names)
      for (t in names(res)) {
        d <- res[[t]]$dem; p <- res[[t]]$p
        comp[[res[[t]]$p$label]] <- c(
          p$temp_C, d$R0, d$R0_f, d$T_gen, d$r, d$lam,
          d$Td, d$e0, d$max_life, d$tot_eggs, d$tot_emerged, d$imm_surv
        )
      }
      writeData(wb, "Karsilastirma", comp)

      for (t in names(res)) {
        r   <- res[[t]]
        lbl <- gsub("\u00b0", "", r$p$label)

        pop_sheet <- paste0(lbl, "_Populasyon")
        addWorksheet(wb, pop_sheet)
        pop_df <- data.frame(Gun=r$sim$days, Disiler=r$sim$n_fem,
                             Erkekler=r$sim$n_mal,
                             Toplanan_Yumurtalar=r$sim$eggs)
        writeData(wb, pop_sheet, pop_df)

        nur_sheet <- paste0(lbl, "_Yetistirme")
        addWorksheet(wb, nur_sheet)
        writeData(wb, nur_sheet, r$sim$nursery)

        lt_sheet <- paste0(lbl, "_YasamTablosu")
        addWorksheet(wb, lt_sheet)
        lt_show <- r$lt %>% mutate(across(where(is.double), ~round(.x, 5)))
        writeData(wb, lt_sheet, lt_show)
      }
      saveWorkbook(wb, file, overwrite=TRUE)
    }
  )

  output$dl_txt <- downloadHandler(
    filename = function() paste0("musca_parametreler_", Sys.Date(), ".txt"),
    content  = function(file) {
      res <- results(); req(length(res) > 0)
      lines <- c(
        strrep("=", 68),
        "  MUSCA DOMESTICA UC SICAKLIKLI KOHORT SIMULASYONU (20/24/37 C)",
        "  Karsilastirmali Yasam Tablosu Demografik Parametreleri",
        strrep("=", 68), "",
        "  Yontemler:",
        "    Krebs CJ (2014) Ecology 6. baski, Bolum 8",
        "    Henderson PA (2016) Ecological Methods 4. baski, paragraf 12.4",
        "    20 C evre sureleri: BDG yontemi (ADE = 12 derece C)",
        "    24 C ve 37 C evre sureleri: Flint ve ark. (2025) Tablo 1 (ampirik)",
        ""
      )
      for (t in names(res)) {
        r <- res[[t]]; d <- r$dem; p <- r$p
        evre_kaynak <- if (as.character(p$temp_C) %in% names(EMPIRICAL))
          "Flint ve ark. (2025) ampirik" else "BDG yontemi"
        lines <- c(lines,
          paste0("  ", p$label, "  [", evre_kaynak, "]"),
          strrep("-", 50),
          sprintf("    Net Ureme Hizi  R0                  : %8.3f  yumurta/disiler/omur", d$R0),
          sprintf("    R0 yalnizca disiler (1:1 oran)      : %8.3f  kiz/disi", d$R0_f),
          sprintf("    Ortalama Nesil Suresi  T            : %8.2f  gun", d$T_gen),
          sprintf("    Icsel artis hizi  r                 : %8.4f  /gun", d$r),
          sprintf("    Sonlu artis hizi  lambda            : %8.4f", d$lam),
          sprintf("    Ikikatlanma suresi  Td              : %8.2f  gun", d$Td),
          sprintf("    Dogumda yasam beklentisi  e0        : %8.2f  gun", d$e0),
          sprintf("    Gozlenen maks. yasam suresi         : %8d  gun", d$max_life),
          sprintf("    Toplanan toplam yumurta             : %8d", d$tot_eggs),
          sprintf("    Yetistirmeden cikan eriskinler      : %8d", d$tot_emerged),
          sprintf("    Olgunlasmamis evre hayatta kalma    : %7.1f%%", d$imm_surv),
          ""
        )
      }
      lines <- c(lines, strrep("=", 68))
      writeLines(lines, file)
    }
  )
}

# ═════════════════════════════════════════════════════════════════════════════
shinyApp(ui, server)
