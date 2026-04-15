# Deployment Guide — Musca domestica Streamlit App

---

## 1. Run locally

```bash
git clone https://github.com/ackuyucu/Ekoloji_Lab.git
cd Ekoloji_Lab/musca_streamlit_app
pip install -r requirements.txt
streamlit run app.py
```

Opens at http://localhost:8501

---

## 2. Add to the existing GitHub repo (ackuyucu/Ekoloji_Lab)

The simulation lives as a subfolder inside the existing repo.
Run these commands from your local clone of Ekoloji_Lab:

```bash
# If you don't have the repo locally yet:
git clone https://github.com/ackuyucu/Ekoloji_Lab.git
cd Ekoloji_Lab

# Copy the musca_streamlit_app folder in, then commit and push:
git add musca_streamlit_app/
git commit -m "Add Musca domestica Streamlit simulation"
git push
```

---

## 3. Run in Google Colab

Open `colab_launcher.ipynb` in Colab (or click the badge in README.md).

**What the notebook does:**

| Cell | Action |
|------|--------|
| 1 | Clones ackuyucu/Ekoloji_Lab and installs dependencies |
| 2 | Configures your free ngrok auth token |
| 3 | Starts Streamlit + opens a public tunnel → prints the URL |
| 4 | Shuts everything down when you're finished |

**Getting a free ngrok token:**
1. Sign up at https://ngrok.com (no credit card)
2. Go to Dashboard → *Your Authtoken*
3. Copy the token and paste it into Cell 2

The tunnel URL looks like `https://xxxx.ngrok-free.app` and stays live
for as long as your Colab session is running (up to ~2 hours on free tier).

**No ngrok account?** Use the localtunnel fallback code shown in the
notebook's Troubleshooting section — no signup required.

---

## 4. Deploy to Streamlit Community Cloud (free permanent URL)

1. Make sure the repo is pushed to GitHub (step 2 above)
2. Go to https://share.streamlit.io and sign in with GitHub
3. Click **New app** → select `ackuyucu/Ekoloji_Lab`
4. Set **Main file path** to `musca_streamlit_app/app.py`
5. Click **Deploy** — live in ~2 minutes

---

## 5. Embed in a website

```html
<!-- After deploying to Streamlit Community Cloud: -->
<iframe
  src="https://ackuyucu-ekoloji-lab-musca.streamlit.app/?embed=true"
  width="100%"
  height="900px"
  style="border:none; border-radius:8px; box-shadow:0 2px 12px rgba(0,0,0,0.12);">
</iframe>
```

The `?embed=true` parameter hides the Streamlit toolbar for a cleaner look.

**Responsive wrapper** (fills container width at any screen size):

```html
<div style="position:relative; padding-bottom:80%; height:0; overflow:hidden;">
  <iframe
    src="https://ackuyucu-ekoloji-lab-musca.streamlit.app/?embed=true"
    style="position:absolute; top:0; left:0; width:100%; height:100%; border:none;"
    allowfullscreen>
  </iframe>
</div>
```

---

## File structure inside the repo

```
Ekoloji_Lab/
└── musca_streamlit_app/
    ├── app.py                 Streamlit UI — sidebar, tabs, downloads
    ├── simulation.py          Core biology: simulation, life table, demographics
    ├── colab_launcher.ipynb   One-click Google Colab launcher
    ├── requirements.txt       Python dependencies (5 packages)
    ├── .gitignore             Git ignore rules
    ├── README.md              GitHub landing page with Colab badge
    └── deploy.md              This file
```
