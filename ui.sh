#!/usr/bin/env bash
#
# Startet die interaktive Grünschirm-Maske (PAYUI00).
# MUSS in einem echten Terminal laufen (braucht ein TTY).
#
#   ENTER = Berechnung anzeigen
#   PF8   = nächster Mitarbeiter   (auf vielen Macs: F8, ggf. mit fn-Taste)
#   PF7   = voriger Mitarbeiter
#   PF3   = beenden                (F3; alternativ ESC)
#
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ ! -x bin/PAYUI00 ]]; then
  echo "PAYUI00 nicht gebaut — starte build.sh ..."
  ./build.sh
fi

exec ./bin/PAYUI00
