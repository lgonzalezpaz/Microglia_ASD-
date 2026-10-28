# Microglia execute but do not specify

Analysis code and derived results for:

> **Microglia execute but do not specify: target-encoded autism risk and the developmental timing of complement-dependent synaptic pruning in human cortex**
> [AUTHOR]. *Manuscript.*

This repository reproduces every number, figure and table in the manuscript from openly
available human data. No restricted-access data use agreement is required at any step.

---

## What the study does

Microglial synaptic over-pruning is a leading mechanistic account of idiopathic autism, but
two questions have stayed open: whether the microglial phenotype is a **primary immune
lesion or a reaction** to neurons that are already mis-specified, and **why** defective
pruning preferentially affects cortex serving language and social cognition.

We treat synapse elimination as a three-layer control system acting on a substrate:

| Layer | Symbol | Role | Example genes | Measured ownership |
|---|---|---|---|---|
| Opsonin tag | **O** | marks synapses for removal | *C1QA/B/C*, *C3*, *C4A/B*, *NPTX1/2* | 67% neuronal, 33% microglial |
| Checkpoint | **K** | protects synapses | *CD47*, *SIRPA*, *CD200*, *SRPX2*, *CSMD1* | 52% neuronal |
| Microglial effector | **E** | executes engulfment | *ITGAM/ITGB2*, *TREM2*, *MERTK*, *CD68* | 48% microglial |
| Synaptic substrate | **S** | the target | *SYN1*, *DLG4*, *SHANK3*, *GRIN2B* | 83% neuronal |

Modules are defined **a priori** in `data/modules/pruning_axis_modules.csv`, one supporting
reference per gene, before any outcome data are touched. Cellular ownership is *measured*
from Allen human cortical single-nucleus data, not asserted.

### Headline findings

1. All three regulatory layers rise steeply along the sensorimotor→association hierarchy
   while the synaptic substrate is spatially flat; opsonin and checkpoint layers are
   **co-regulated**, so their per-cell ratio is conserved across cortex.
2. A biophysical model with homeostatic matching yields an **exact structural result**:
   microglial effector capacity *E* cancels identically from fractional synapse loss
   (verified symbolically). Microglial abundance or activation alone therefore cannot
   specify regional vulnerability.
3. Autism genetic risk concentrates on the **synaptic substrate** (SFARI 77% vs 19%
   matched null, *z* = 9.0) and is **absent** from microglial effector machinery
   (Open Targets genetic score 0.000, bootstrap 95% CI [0.000, 0.000]). Schizophrenia
   risk instead implicates the **checkpoint** layer.
4. Adult expression gradients **do not** predict autism cortical thickness once spatial
   autocorrelation is respected (best *P*_spatial = 0.069). Reported as an informative
   negative, with explicit power bounds.
5. What does separate vulnerable from spared cortex is **timing**: the microglial effector
   programme peaks at 0.9–1.6 postnatal years in primary cortex versus 2.7–7.5 years in
   association cortex (exact permutation *P* = 0.003, family FDR *q* = 0.018).

---

## Quick start

```bash
git clone https://github.com/[GITHUB_USER]/[REPO].git
cd [REPO]
./run_all.sh          # ~1–2 h, ~6 GB disk, downloads all public data
```

Outputs land in `figures/`, `tables/`, `results/` and `manuscript/`.

### Requirements

- **Python 3.13** for all analyses *except* the Allen atlas step
- **Python 3.11** for the Allen atlas step — `abagen` 0.1.3 predates pandas 2.x removals
  (`groupby(axis=1)`, `set_axis(inplace=)`), so it needs a pinned interpreter. `run_all.sh`
  builds this environment automatically.
- **Node.js** (for the `.docx` build) and **pandoc**
- ~6 GB free disk (the Allen microarray download alone is ~4 GB)

---

## Repository layout

```
scripts/      numbered pipeline, run in order
data/modules/ a priori module definitions (gene → layer, with evidence DOI)
results/      shipped snapshot of every derived statistic and QC record
figures/      Figures 1–6 as vector PDF and 600 dpi PNG
tables/       Tables 1–6 as CSV and Markdown
manuscript/   source with citation keys, rendered Markdown, styled DOCX, citation map
```

`results/` is the archived snapshot of the run that produced the manuscript. A fresh run
writes to `out/`; to re-derive downstream outputs from the shipped snapshot without
refetching anything, `cp -r results out` first. Paths resolve relative to the repository
root, or to `$PRUNING_AXIS_ROOT` if set.

### Pipeline

| Script | Purpose |
|---|---|
| `00_fetch_ahba.py` | Allen Human Brain Atlas microarray, 6 donors |
| `00b_fetch_other_data.sh` | BrainSpan, Allen cell types, SFARI, gnomAD, ENIGMA |
| `01_ahba_expression.py` | abagen → Desikan–Killiany regional expression |
| `02_opentargets.py` | Open Targets genetic-association scores (genetic evidence only) |
| `03_verify_refs.py` | machine verification of every DOI against Crossref + PubMed |
| `05_regional_modules.py` | module scores, donor reliability, cell-type ownership, PC1 axis |
| `06_composition_control.py` | extensive vs per-cell gradients; leave-one-gene-out stability |
| `07_dynamical_model.py` | model equilibria, homeostatic matching, bifurcation scan |
| `08_vulnerability_metrics.py` | the three candidate vulnerability metrics + 432-point sweep |
| `09_validate_enigma.py` | spatial validation with variogram-matched nulls |
| `10_genetic_partition.py` | risk partition against length/constraint/expression-matched nulls |
| `11_brainspan_development.py` | developmental trajectories, exact permutation, donor bootstrap |
| `12_robustness.py` | symbolic proof, circularity control, power bounds, family FDR |
| `13_figures.py` · `14_tables.py` | publication outputs |
| `15`–`17` | manuscript assembly (Markdown → AST → styled DOCX) |

---

## Methodological commitments

These are the choices that most affect whether the results are trustworthy.

- **A priori module definitions.** Gene→layer assignment and its evidence were fixed
  before any outcome analysis and are version-controlled in this repository.
- **Spatial autocorrelation is respected.** Cortical maps are smooth, so naive permutation
  is anticonservative. All spatial inference uses 10,000 variogram-matched surrogates.
  Parcels missing from a target map are dropped *before* surrogate construction — missing
  values silently deflate surrogate *P* values, and an earlier version of this analysis was
  wrong for exactly that reason.
- **Confound-matched genetic nulls.** Risk genes are longer, more constrained and more
  brain-expressed. Enrichment is tested against backgrounds stratified on all three.
- **Circularity control.** Several canonical synaptic genes are famous autism genes, so the
  substrate enrichment is re-tested after removing them.
- **Literature evidence excluded from genetic scores.** Only the Open Targets
  `genetic_association` datatype is used; text-mining would reward well-studied microglial
  genes and manufacture the result.
- **Exact tests where possible.** With 11 regions split 4/7, the developmental contrast is
  tested over all 330 label assignments rather than by approximation.
- **Pre-specified families.** The developmental timing family is six tests; everything else
  in that analysis is labelled exploratory.
- **Negative results reported.** The spatial validation did not succeed; it is reported with
  the detectability bound that says what the failure does and does not license.
- **Every reference machine-verified.** `03_verify_refs.py` resolves all 57 DOIs against
  Crossref and PubMed and emits the Vancouver strings used in the manuscript. Three DOIs
  that resolved to unrelated articles were caught this way and removed.

### Known limitations

- The Allen atlas has six adult neurotypical donors and no autistic tissue.
- *C4A*, *C4B* and *SRPX2* are **missing from the processed expression matrix** (*C4B* is not
  on the array; the others fall below the intensity-filtering threshold) — precisely the genes with
  the strongest prior links to complement-mediated psychiatric risk and to language. They
  inform the framework but not the regional statistics.
- Transcript abundance is an imperfect proxy for pathway activity, and for synaptic
  structural genes it is not a density proxy at all; developmental inference is therefore
  restricted to the regulatory layers.
- 34 cortical parcels gives limited power for spatial correlation (|ρ| ≈ 0.59 needed).
- The model treats parcels as independent and omits astrocytic elimination and
  synapse-type selectivity.

---

## Data sources

All public, all open access. Scripts download from source; nothing upstream is
redistributed here.

| Resource | Content | Citation |
|---|---|---|
| [Allen Human Brain Atlas](https://human.brain-map.org) | adult cortical microarray, 6 donors | Hawrylycz et al. 2012, *Nature* |
| [BrainSpan](https://www.brainspan.org) | developmental RNA-seq, 8 pcw–40 y | Kang et al. 2011, *Nature* |
| [Allen cell types](https://portal.brain-map.org) | cortical SMART-seq, 121 cell types | Hodge et al. 2019, *Nature* |
| [ENIGMA Toolbox](https://github.com/MICA-MNI/ENIGMA) | case–control cortical thickness | Larivière et al. 2021, *Nat Methods*; van Rooij et al. 2018, *Am J Psychiatry* |
| [SFARI Gene](https://gene.sfari.org) | curated autism risk genes | Abrahams et al. 2013, *Mol Autism* |
| [Open Targets](https://platform.opentargets.org) | target–disease genetic association | Ochoa et al. 2023, *NAR* |
| [gnomAD v2.1.1](https://gnomad.broadinstitute.org) | constraint, coding length | Karczewski et al. 2020, *Nature* |

Processing of the Allen atlas follows `abagen` (Markello et al. 2021, *eLife*) and the
imaging-transcriptomics guidance of Arnatkevičiūtė et al. 2019, *NeuroImage*. Spatial nulls
follow Burt et al. 2020, *NeuroImage*.

---

## Reproducibility

- Random seeds fixed (`20261025`).
- `CHECKSUMS.sha256` covers every released file.
- Pinned environments: `requirements.txt`, `requirements-abagen.txt`, `environment.yml`.
- Upstream resources are live services; `results/references_verified.csv` records the
  bibliography as resolved at build time, and SFARI/Open Targets contents may change with
  their release cycles. Re-running will refresh them.

## Licence

Code: MIT (`LICENSE`). Derived data, figures and tables: CC BY 4.0 (`LICENSE-DATA`).
Upstream datasets retain their own terms.

## Citation

See `CITATION.cff`. Archived releases receive a Zenodo DOI.
