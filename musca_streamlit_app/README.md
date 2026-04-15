# 🪰 Musca domestica Cohort Simulation

An interactive three-temperature life-table simulation for *Musca domestica*
(house fly), built with Python and Streamlit.

[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ackuyucu/Ekoloji_Lab/blob/main/musca_streamlit_app/colab_launcher.ipynb)

---

## What it does

Simulates a laboratory cohort of house flies at 15 °C, 20 °C, and 25 °C
simultaneously, following the time-specific life-table methods of
Krebs (2014) and Henderson (2016).

**Interactive controls (sidebar)**
- Select which temperatures to compare
- Adjust per-temperature survival rates, adult lifespan, and fecundity
- Reproducible results via random seed

**Output tabs**
| Tab | Contents |
|-----|----------|
| 📈 Population plots | Six-panel figure: N♀, mₓ, eggs, lₓ, qₓ, eₓ |
| 📊 Life table | Sortable table with all standard columns |
| 🧮 Demographics | R₀, r, λ, T, Tₐ, e₀ for each temperature |
| ℹ️ About | Methods, formulae, references |

**Downloads:** Excel workbook (Comparison + Population + Nursery + Life Table
sheets) and plain-text parameter summary.

---

## Quick start

### Option A — Run in Google Colab (no install needed)

Click the badge above, or open `colab_launcher.ipynb` directly.  
You will need a free [ngrok](https://ngrok.com) account for the tunnel.

### Option B — Run locally

```bash
git clone https://github.com/ackuyucu/Ekoloji_Lab.git
cd Ekoloji_Lab/musca_streamlit_app
pip install -r requirements.txt
streamlit run app.py
```

App opens at http://localhost:8501

### Option C — Deploy to Streamlit Community Cloud (free public URL)

1. Go to https://share.streamlit.io → *New app* → select `ackuyucu/Ekoloji_Lab`
2. Set main file path to `musca_streamlit_app/app.py` → Deploy

Embed the resulting URL in any webpage:

```html
<iframe src="https://ackuyucu-ekoloji-lab-musca.streamlit.app/?embed=true"
        width="100%" height="900px" style="border:none;"></iframe>
```

---

## File structure

```
├── app.py                 Streamlit UI — sidebar, tabs, downloads
├── simulation.py          Core biology: simulation, life table, demographics
├── colab_launcher.ipynb   One-click Colab launcher with ngrok tunnel
├── requirements.txt       Python dependencies
├── deploy.md              Full deployment and embedding guide
└── README.md              This file
```

---

## Methods and references

| Source | Used for |
|--------|----------|
| Krebs CJ (2014) *Ecology* 6th ed. Ch. 8 | Life table structure |
| Henderson PA (2016) *Ecological Methods* 4th ed. §12.4 | Life table formulae |
| Flint *et al.* (2025) *J Forensic Sci* 70(1) | Stage durations at 24 °C |
| Ali *et al.* (2024) *Eur Chem Bull* 13(5) | Adult lifespan parameters |

Stage durations at untested temperatures are derived using the
**Accumulated Degree-Day (ADD) method** with lower developmental threshold
LDT = 12 °C.
