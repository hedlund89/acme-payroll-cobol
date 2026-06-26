# ACME Payroll — COBOL Batch (Legacy-Testsystem)

Ein bewusst „altes" COBOL-Batch-System zur **Lohnabrechnung** (Gross-to-Net), gebaut als
Test-Eingabe für den Reverse-Engineering-Agenten. Es repräsentiert das Altlasten-Szenario:
historisch gewachsener COBOL-Code mit undokumentierten Geschäftsregeln, totem Code und
GO-TO-Kontrollfluss — die Art Code, deren Business-Logik nur verlustbehaftet rekonstruierbar ist.

**Lauffähig** über **GnuCOBOL** auf macOS/Linux (kein Mainframe nötig).

## Was es tut

Zwei Batch-Programme, gekoppelt über eine Zwischendatei und geteilte Copybooks:

```
 EMPMAST.DAT ──► PAYRUN00 ──► PAYRESULT.DAT ──► PAYRPT00 ──► PAYREGISTER.TXT
 (Stammdaten)   (Lohnlauf)   (Ergebnissätze)   (Report)     (Register-Liste)
```

- **PAYRUN00** — liest die Mitarbeiter-Stammdatei, berechnet pro Mitarbeiter Brutto,
  Zulage, Steuer und Netto, schreibt eine Ergebnisdatei. Überspringt terminierte (Status `T`).
- **PAYRPT00** — liest die Ergebnisdatei und druckt einen abteilungs-summierten
  Lohn-Register-Report.

## Struktur

| Pfad | Inhalt |
|------|--------|
| `src/PAYRUN00.cbl` | Hauptprogramm: Gross-to-Net-Berechnung |
| `src/PAYRPT00.cbl` | Report-Generator |
| `copybooks/EMPREC.cpy` | Satzlayout Mitarbeiter-Stammdaten (geteilt) |
| `copybooks/PAYREC.cpy` | Satzlayout Lohn-Ergebnis (geteilt: PAYRUN00 schreibt, PAYRPT00 liest) |
| `data/EMPMAST.DAT` | Eingabe: 7 Mitarbeiter-Sätze (80 Spalten, fixes Format) |
| `jcl/PAYJOB.jcl` | Original-Mainframe-JCL (z/OS-Job, läuft nicht lokal — Doku/Orchestrierung) |
| `build.sh` / `run.sh` | Kompilieren bzw. ausführen mit GnuCOBOL |

## Bauen & Ausführen

```bash
brew install gnu-cobol      # GnuCOBOL einmalig installieren
./build.sh                  # kompiliert PAYRUN00 + PAYRPT00 nach bin/
./run.sh                    # führt den Batch aus und zeigt den Report
```

Beispiel-Output (Auszug):
```
  EMPID  NAME            DEPT   GROSS         TAX      NET
  10001  ALICE SCHMIDT         SALE       2,169.33         247.02       2,497.70
  ...
  *** TOTALS ***                       10,374.70       1,108.94      10,948.40
```

## Geschäftsregeln (das, was der Agent rekonstruieren muss)

- **Brutto:** Stundensatz = Jahresgehalt / 52 / 40; Überstunden (> 40 h) mit Faktor 1,5.
- **Zulage nach Grade:** A 0 % · B 5 % · C 8 % · D 12 % · **E 15 % + 250 flat**.
- **Progressive Steuer** über 3 Stufen (10 % / 22 % / 35 %).
- **Terminierte** (Status `T`) werden nicht abgerechnet.

## Datensatz EMPMAST.DAT (Spalten-Layout, siehe EMPREC.cpy)

| Pos | Feld | Format |
|-----|------|--------|
| 1–5 | Mitarbeiter-ID | 9(5) |
| 6–25 | Name | X(20) |
| 26–29 | Abteilung | X(4) |
| 30 | Grade (A–E) | X(1) |
| 31–39 | Jahres-Grundgehalt | 9(7)V99 |
| 40–44 | Stunden | 9(3)V99 |
| 45 | Status (A/T/L) | X(1) |
| 46 | Familienstand (M/S) | X(1) |
| 47–48 | Dienstjahre | 9(2) |

## Hinweis zur Portierung (z/OS → GnuCOBOL)

Auf einem echten Mainframe liefen DD-Namen aus dem JCL gegen VSAM/QSAM-Datasets; hier
nutzen die `SELECT … ASSIGN`-Klauseln flache Dateien unter `data/`. Die FD-Records sind
als `PIC X(80)`-Puffer definiert, die Satzstruktur liegt in WORKING-STORAGE (`MOVE` auf
READ/WRITE) — ein verbreitetes Muster, das numerische LINE-SEQUENTIAL-Schreibfehler vermeidet.

> Für die bewusst eingebauten „Findings" (toter Code, undokumentierte Regeln, GO-TO,
> kryptische Namen) siehe die separate One-Pager-Datei.
