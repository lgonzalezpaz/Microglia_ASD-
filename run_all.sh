#!/usr/bin/env bash
# Reproduce every number, table and figure from raw public data.
# Requires: python3.13 (main env), python3.11 (abagen env), node, pandoc, ~6 GB disk.
set -euo pipefail
cd "$(dirname "$0")"

PY_MAIN=${PY_MAIN:-python3}
PY_ABAGEN=${PY_ABAGEN:-./.venv_abagen/bin/python}

echo "== 0. environments =="
$PY_MAIN -m pip install -q -r requirements.txt
if [ ! -x "$PY_ABAGEN" ]; then
  python3.11 -m venv .venv_abagen
  ./.venv_abagen/bin/pip install -q --upgrade pip
  ./.venv_abagen/bin/pip install -q -r requirements-abagen.txt
fi

echo "== 1. fetch public data (~4 GB; Allen Human Brain Atlas) =="
$PY_ABAGEN scripts/00_fetch_ahba.py
bash scripts/00b_fetch_other_data.sh

echo "== 2. regional expression (Python 3.11 / abagen) =="
$PY_ABAGEN scripts/01_ahba_expression.py

echo "== 3. external gene-level resources =="
$PY_MAIN scripts/02_opentargets.py

echo "== 4. bibliography verification =="
$PY_MAIN scripts/03_verify_refs.py data/modules/doi_final.txt

echo "== 5. analyses =="
$PY_MAIN scripts/05_regional_modules.py
$PY_MAIN scripts/06_composition_control.py
$PY_MAIN scripts/07_dynamical_model.py
$PY_MAIN scripts/08_vulnerability_metrics.py
$PY_ABAGEN scripts/09_validate_enigma.py
$PY_MAIN scripts/10_genetic_partition.py
$PY_MAIN scripts/11_brainspan_development.py
$PY_MAIN scripts/12_robustness.py

echo "== 6. outputs =="
$PY_MAIN scripts/13_figures.py
$PY_MAIN scripts/14_tables.py
$PY_MAIN scripts/15_build_manuscript.py
$PY_MAIN scripts/16_md_to_ast.py
node scripts/17_build_docx.js

echo "== done: see figures/, tables/, results/, manuscript/ =="
