#!/usr/bin/env bash
#
# Startet die interaktive Grünschirm-Maske (PAYUI00).
# MUSS in einem ECHTEN Terminal laufen (Terminal.app / iTerm) — NICHT im
# integrierten VS-Code-Terminal (ncurses kollidiert dort).
#
#   ENTER = Berechnung anzeigen
#   PF8 / F8 = nächster Mitarbeiter
#   PF7 / F7 = voriger Mitarbeiter
#   PF3 / F3 oder ESC = beenden
#
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ ! -x bin/PAYUI00 ]]; then
  echo "PAYUI00 nicht gebaut — starte build.sh ..."
  ./build.sh
fi

# --- GnuCOBOL screen runtime tuning to avoid flicker ---------------------
# Force a well-behaved terminal type and stable redraw behaviour.
export TERM="${TERM:-xterm-256color}"
case "$TERM" in
  dumb|unknown|"") export TERM=xterm-256color ;;
esac
export COB_SCREEN_ESC=Y          # allow ESC as a key
export COB_SCREEN_EXCEPTIONS=Y   # report function keys (PF7/PF8/PF3)
export COB_TIMEOUT_SCALE=1000    # don't busy-poll the keyboard (less flicker)

exec ./bin/PAYUI00
