# shellcheck shell=bash
#
# Output and preflight helpers for scripts/deploy_stores.sh — sourced, never run on its own.

# ---------------------------------------------------------------- output ----
if [[ -t 1 ]]; then
  B=$'\033[1m'; R=$'\033[31m'; G=$'\033[32m'; Y=$'\033[33m'; C=$'\033[36m'; N=$'\033[0m'
else
  B=""; R=""; G=""; Y=""; C=""; N=""
fi
step() { echo; echo "${B}${C}==>${N} ${B}$*${N}"; }
info() { echo "    $*"; }
ok()   { echo "    ${G}✓${N} $*"; }
warn() { echo "    ${Y}!${N} $*" >&2; }
die()  { echo; echo "${R}✗ $*${N}" >&2; exit 1; }

# ── Preflight problem collector ──────────────────────────────────────────────
# Preflight records problems instead of exiting on the first one, so ONE run
# tells you everything that is wrong — every check takes milliseconds, and
# discovering them one re-run at a time wastes round-trips.
PROBLEM_COUNT=0
PROBLEMS=()
fail() {
  PROBLEMS+=("$*")
  PROBLEM_COUNT=$(( PROBLEM_COUNT + 1 ))
  # Headline inline, in context; the gate reprints the full text below.
  echo "    ${R}✗${N} ${1%%$'\n'*}" >&2
}

# Records a missing tool as a problem and returns non-zero, so the caller can
# skip checks that depend on it instead of reporting cascading noise.
need() {
  command -v "$1" >/dev/null 2>&1 && return 0
  fail "'$1' is not installed. $2"
  return 1
}

# The gate. NOTHING is built or uploaded until this passes — a normal run and
# `--check` take the exact same path to here, so `--check` is a true dry run.
# There is deliberately no bypass flag: every check guards something
# unrecoverable (a burned Play version code, a debug-signed AAB, a release
# whose symbols never reached Crashlytics).
enforce_preflight() {
  if (( PROBLEM_COUNT == 0 )); then
    if (( CHECK_ONLY )); then
      echo
      echo "${G}Preflight passed.${N} Nothing was built and nothing was uploaded."
      exit 0
    fi
    step "Preflight passed — building"
    return 0
  fi

  echo >&2
  echo "${R}${B}✗ Preflight failed — ${PROBLEM_COUNT} problem(s).${N}" >&2
  echo "${R}  Nothing was built, and nothing was uploaded.${N}" >&2
  local i=1 p
  for p in "${PROBLEMS[@]}"; do
    echo >&2
    echo "${R}  ${i})${N} ${p}" >&2
    i=$(( i + 1 ))
  done
  echo >&2
  echo "  Fix the above and run again." >&2
  echo "  To re-check without building anything: ${B}$0 --check${N}" >&2
  exit 1
}
