"""
simulation.py
─────────────────────────────────────────────────────────────────────────────
Core biology and life-table functions for the Musca domestica cohort model.
Imported by app.py — contains no Streamlit code.

Methods:
  Krebs CJ (2014) Ecology 6th ed. Ch. 8
  Henderson PA (2016) Ecological Methods 4th ed. §12.4
  Stage durations: ADD method, LDT = 12°C
  Flint et al. (2025) J Forensic Sci; Ali et al. (2024) Eur Chem Bull
"""

import numpy as np
import pandas as pd

# ── ADD calibration constants ──────────────────────────────────────────────
LDT       = 12.0    # Lower Developmental Threshold (°C)
EGG_ADD   =  9.68   # Degree-days — egg stage
LARVA_ADD = 72.57   # Degree-days — larval stage
PUPA_ADD  = 81.91   # Degree-days — pupal stage
EGG_CV    = 0.122
LARVA_CV  = 0.228
PUPA_CV   = 0.191

# ── Display colours per temperature ───────────────────────────────────────
COLORS = {'15': '#1565C0', '20': '#43A047', '25': '#E53935'}
LABELS = {'15': '15°C',    '20': '20°C',    '25': '25°C'}

# ── Default biological parameters ─────────────────────────────────────────
DEFAULTS = {
    '15': dict(adult_mean=60,  adult_sd=10,  adult_min=35, adult_max=95,
               egg_surv=0.92,  larva_surv=0.980, pupa_surv=0.990,
               pre_repro=15,   peak_day=30,  fec_sigma=12, peak_eggs=5.0),
    '20': dict(adult_mean=32,  adult_sd=5.5, adult_min=18, adult_max=52,
               egg_surv=0.88,  larva_surv=0.970, pupa_surv=0.982,
               pre_repro=6,    peak_day=15,  fec_sigma=7,  peak_eggs=16.0),
    '25': dict(adult_mean=20,  adult_sd=3.5, adult_min=12, adult_max=32,
               egg_surv=0.85,  larva_surv=0.960, pupa_surv=0.975,
               pre_repro=3,    peak_day=9,   fec_sigma=4,  peak_eggs=25.0),
}


# ── Parameter builder ──────────────────────────────────────────────────────
def make_params(temp_C: int, d: dict) -> dict:
    """
    Merge user-supplied biological parameters (d) with ADD-derived stage
    durations for temperature temp_C.  Returns a single flat dict.
    """
    eff = temp_C - LDT
    if temp_C == 25:                          # Wang et al. 2018 empirical
        em, es = 18.50 / 24, 0.10
        lm = (140.40 - 18.50) / 24;  ls = lm * LARVA_CV
        pm = (297.40 - 140.40) / 24; ps = pm * PUPA_CV
    else:                                     # ADD method
        em = EGG_ADD   / eff;  es = em * EGG_CV
        lm = LARVA_ADD / eff;  ls = lm * LARVA_CV
        pm = PUPA_ADD  / eff;  ps = pm * PUPA_CV

    return dict(
        temp_C=temp_C,
        label=LABELS[str(temp_C)],
        color=COLORS[str(temp_C)],
        egg_mean=em,   egg_sd=es,
        larva_mean=lm, larva_sd=ls,
        pupa_mean=pm,  pupa_sd=ps,
        **d,
    )


# ── Stochastic helpers ─────────────────────────────────────────────────────
def truncated_normal(mean: float, sd: float,
                     low: float, high: float, size: int) -> np.ndarray:
    """Rejection-sampled truncated normal, returned as integer array."""
    if sd <= 0:
        return np.full(size, int(round(mean)), dtype=int)
    out = []
    while len(out) < size:
        s = np.random.normal(mean, sd, size * 25)
        out.extend(s[(s >= low) & (s <= high)].tolist())
    return np.round(np.array(out[:size])).astype(int)


def mx_val(age: int, pre_repro: int, peak_day: int,
           fec_sigma: float, peak_eggs: float) -> float:
    """Age-specific daily fecundity — Gaussian bell curve."""
    if age < pre_repro:
        return 0.0
    return float(np.clip(
        peak_eggs * np.exp(-0.5 * ((age - peak_day) / fec_sigma) ** 2),
        0, None
    ))


def apply_mortality(n: int, daily_surv: float, n_days: int) -> int:
    """Binomial per-day mortality over n_days days."""
    n = int(n)
    for _ in range(n_days):
        if n <= 0:
            return 0
        n = int(np.random.binomial(n, daily_surv))
    return n


# ── Main simulation ────────────────────────────────────────────────────────
def run_simulation(p: dict, sim_days: int,
                   n_females: int = 20, n_males: int = 20) -> dict:
    """
    Run a full cohort simulation for one temperature.

    Returns a dict with keys:
      p, days, n_fem, n_mal, mx, eggs, nursery (DataFrame)
    """
    f_life = truncated_normal(p['adult_mean'], p['adult_sd'],
                               p['adult_min'], p['adult_max'], n_females)
    m_life = truncated_normal(p['adult_mean'], p['adult_sd'],
                               p['adult_min'], p['adult_max'], n_males)

    days  = np.arange(sim_days + 1)
    n_fem = np.array([int(np.sum(f_life > d)) for d in days])
    n_mal = np.array([int(np.sum(m_life > d)) for d in days])
    mx    = np.array([mx_val(int(d), p['pre_repro'], p['peak_day'],
                              p['fec_sigma'], p['peak_eggs']) for d in days])
    eggs  = np.array([
        int(np.random.poisson(n_fem[i] * mx[i]))
        if (n_fem[i] > 0 and mx[i] > 0) else 0
        for i in range(len(days))
    ])

    # Nursery — track each egg batch through immature stages
    records = []
    for i, d in enumerate(days):
        ne = int(eggs[i])
        if ne == 0:
            records.append(dict(egg_day=int(d), n_eggs=0, egg_dur=0,
                                n_hatched=0, larva_dur=0, n_pupated=0,
                                pupa_dur=0, n_emerged=0,
                                emerge_day=float('nan')))
            continue
        ed = max(1, int(round(float(np.random.normal(p['egg_mean'],   p['egg_sd'])))))
        ld = max(3, int(round(float(np.random.normal(p['larva_mean'], p['larva_sd'])))))
        pd_ = max(3, int(round(float(np.random.normal(p['pupa_mean'], p['pupa_sd'])))))
        n_h = apply_mortality(ne,  p['egg_surv'],   ed)
        n_p = apply_mortality(n_h, p['larva_surv'], ld)
        n_e = apply_mortality(n_p, p['pupa_surv'],  pd_)
        records.append(dict(egg_day=int(d), n_eggs=ne, egg_dur=ed,
                            n_hatched=n_h, larva_dur=ld, n_pupated=n_p,
                            pupa_dur=pd_, n_emerged=n_e,
                            emerge_day=float(int(d) + ed + ld + pd_)))

    return dict(p=p, days=days, n_fem=n_fem, n_mal=n_mal,
                mx=mx, eggs=eggs, nursery=pd.DataFrame(records))


# ── Life table ─────────────────────────────────────────────────────────────
def build_life_table(sim: dict) -> pd.DataFrame:
    """
    Construct a time-specific life table from simulation output.

    Columns: x, Nx, lx, dx, qx, Lx, Tx, ex, mx, lx_mx, x_lx_mx
    """
    N0 = sim['n_fem'][0]
    lt = pd.DataFrame({'x': sim['days'],
                        'Nx': sim['n_fem'],
                        'mx': sim['mx']})
    lt['lx']      = lt['Nx'] / N0
    lt['dx']      = (lt['Nx'] - lt['Nx'].shift(-1).fillna(0)).clip(lower=0)
    lt['qx']      = np.where(lt['Nx'] > 0, lt['dx'] / lt['Nx'], 0.0)
    lt['Lx']      = (lt['Nx'] + lt['Nx'].shift(-1).fillna(0)) / 2
    lt['Tx']      = lt['Lx'][::-1].cumsum()[::-1]
    lt['ex']      = np.where(lt['Nx'] > 0, lt['Tx'] / lt['Nx'], 0.0)
    lt['lx_mx']   = lt['lx'] * lt['mx']
    lt['x_lx_mx'] = lt['x']  * lt['lx_mx']
    return lt


# ── Demographic parameters ─────────────────────────────────────────────────
def calc_demog(lt: pd.DataFrame, sim: dict) -> dict:
    """
    Derive standard demographic parameters from the life table.
    """
    R0    = float(lt['lx_mx'].sum())
    T_gen = float(lt['x_lx_mx'].sum() / R0) if R0 > 0 else float('nan')
    r     = float(np.log(R0) / T_gen) if (R0 > 0 and T_gen > 0) else float('nan')
    lam   = float(np.exp(r))           if not np.isnan(r) else float('nan')
    Td    = float(np.log(2) / r)       if (not np.isnan(r) and r > 0) else float('nan')
    e0    = float(lt['ex'].iloc[0])

    alive = np.where(sim['n_fem'] > 0)[0]
    max_life = int(alive[-1]) if len(alive) else 0

    tot_eggs    = int(sim['nursery']['n_eggs'].sum())
    tot_emerged = int(sim['nursery']['n_emerged'].sum())
    imm_surv    = round(100 * tot_emerged / tot_eggs, 1) if tot_eggs > 0 else 0.0

    return dict(
        R0=round(R0, 3),       R0_f=round(R0 / 2, 3),
        T_gen=round(T_gen, 2), r=round(r, 4),
        lam=round(lam, 4),     Td=round(Td, 2),
        e0=round(e0, 2),       max_life=max_life,
        tot_eggs=tot_eggs,     tot_emerged=tot_emerged,
        imm_surv=imm_surv,
    )
