#!/usr/bin/env bash
#
# Kompiliert die ACME-Payroll-COBOL-Programme mit GnuCOBOL.
# Voraussetzung: cobc (GnuCOBOL) im PATH  (brew install gnu-cobol).
#
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
mkdir -p bin

echo "==> PAYRUN00 (Lohnlauf)"
cobc -x -I copybooks -o bin/PAYRUN00 src/PAYRUN00.cbl

echo "==> PAYRPT00 (Register-Report)"
cobc -x -I copybooks -o bin/PAYRPT00 src/PAYRPT00.cbl

echo "==> PAYUI00 (Grünschirm-Inquiry)"
cobc -x -I copybooks -o bin/PAYUI00 src/PAYUI00.cbl

echo "Fertig. Batch: ./run.sh   |   Grünschirm-UI: ./ui.sh"
