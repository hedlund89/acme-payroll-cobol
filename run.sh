#!/usr/bin/env bash
#
# Führt den ACME-Payroll-Batch aus (entspricht dem JCL-Job PAYJOB in jcl/PAYJOB.jcl):
#   STEP010  PAYRUN00  - liest EMPMAST.DAT, schreibt PAYRESULT.DAT
#   STEP020  PAYRPT00  - liest PAYRESULT.DAT, schreibt PAYREGISTER.TXT
#
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ ! -x bin/PAYRUN00 || ! -x bin/PAYRPT00 ]]; then
  echo "Programme nicht gebaut — starte build.sh ..."; ./build.sh
fi

echo "=== STEP010  PAYRUN00 (Gross-to-Net) ==="
./bin/PAYRUN00

echo ""
echo "=== STEP020  PAYRPT00 (Payroll Register) ==="
./bin/PAYRPT00

echo ""
echo "=== Report: data/PAYREGISTER.TXT ==="
cat data/PAYREGISTER.TXT
