      ******************************************************************
      * PROGRAM   PAYUI00                                              *
      * SYSTEM    ACME PAYROLL - INTERACTIVE INQUIRY (3270 STYLE)      *
      * FUNCTION  GREEN-SCREEN INQUIRY OVER THE EMPLOYEE MASTER.       *
      *           BROWSE EMPLOYEES, VIEW LIVE GROSS-TO-NET CALC.       *
      *           USES THE SAME PAY RULES AS THE BATCH (PAYRUN00).     *
      * KEYS      ENTER=CALC  PF7=PREV  PF8=NEXT  PF3=EXIT             *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYUI00.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMP-FILE   ASSIGN TO "data/EMPMAST.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-EMP-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  EMP-FILE.
       01  EMP-RECORD-IO          PIC X(80).

       WORKING-STORAGE SECTION.
       COPY EMPREC.

       01  WS-EMP-STATUS          PIC X(02).

      *    --- IN-CORE TABLE OF EMPLOYEES (LOADED AT STARTUP) ---
       01  WS-EMP-TABLE.
           05  WS-EMP-ENTRY OCCURS 100 TIMES INDEXED BY WS-IX.
               10  T-ID            PIC 9(05).
               10  T-NAME          PIC X(20).
               10  T-DEPT          PIC X(04).
               10  T-GRADE         PIC X(01).
               10  T-BASE          PIC 9(07)V99.
               10  T-HOURS         PIC 9(03)V99.
               10  T-STATUS        PIC X(01).
               10  T-MARITAL       PIC X(01).
               10  T-YEARS         PIC 9(02).
       01  WS-EMP-COUNT           PIC 9(03)   VALUE ZERO.
       01  WS-CUR                 PIC 9(03)   VALUE 1.

      *    --- CALC WORK FIELDS (SAME RULES AS PAYRUN00) ---
       01  WS-CALC.
           05  WS-HRLY-RATE       PIC 9(05)V99.
           05  WS-OT-HOURS        PIC 9(03)V99.
           05  WS-GROSS           PIC 9(07)V99.
           05  WS-ALLOW           PIC 9(06)V99.
           05  WS-TAX             PIC 9(06)V99.
           05  WS-NET             PIC 9(07)V99.
           05  WS-TAXABLE         PIC 9(07)V99.
           05  WS-RATE-PCT        PIC 9(02)V99.
       01  WS-CONST.
           05  WS-STD-HOURS       PIC 9(03)V99   VALUE 40.00.
           05  WS-OT-FACTOR       PIC 9(01)V99   VALUE 1.50.
           05  WS-WPY             PIC 9(02)       VALUE 52.
       01  WS-BRACKETS.
           05  FILLER PIC 9(07)V99 VALUE 0030000.00.
           05  FILLER PIC 9(07)V99 VALUE 0060000.00.
       01  WS-BRK-TBL REDEFINES WS-BRACKETS.
           05  WS-BRK PIC 9(07)V99 OCCURS 2 TIMES.

      *    --- SCREEN DISPLAY FIELDS (EDITED) ---
       01  WS-DISP.
           05  D-POS              PIC Z9.
           05  D-CNT              PIC Z9.
           05  D-ID               PIC 9(05).
           05  D-NAME             PIC X(20).
           05  D-DEPT             PIC X(04).
           05  D-GRADE            PIC X(01).
           05  D-STATUS           PIC X(01).
           05  D-MARITAL          PIC X(01).
           05  D-BASE             PIC ZZZ,ZZ9.99.
           05  D-HOURS            PIC ZZ9.99.
           05  D-GROSS            PIC ZZZ,ZZ9.99.
           05  D-ALLOW            PIC ZZZ,ZZ9.99.
           05  D-TAX              PIC ZZZ,ZZ9.99.
           05  D-NET              PIC ZZZ,ZZ9.99.
           05  D-MSG              PIC X(40)   VALUE SPACES.

       01  WS-KEY                 PIC 9(04)   VALUE ZERO.
       01  WS-DUMMY               PIC X(01)   VALUE SPACE.
       01  WS-CRT-STATUS          PIC 9(04)   VALUE ZERO.
           88  KEY-ENTER                      VALUE 0000.
           88  KEY-PF3                        VALUE 1003.
           88  KEY-PF7                        VALUE 1007.
           88  KEY-PF8                        VALUE 1008.

      ******************************************************************
       SCREEN SECTION.
       01  PAY-MAP.
           05  BLANK SCREEN.
           05  LINE 1  COL 1  VALUE
               "ACME PAYROLL INQUIRY              PAYUI00".
           05  LINE 1  COL 60 VALUE "EMP".
           05  LINE 1  COL 64 PIC Z9 FROM D-POS.
           05  LINE 1  COL 67 VALUE "OF".
           05  LINE 1  COL 70 PIC Z9 FROM D-CNT.
           05  LINE 2  COL 1  VALUE
               "----------------------------------------".
           05  LINE 2  COL 41 VALUE
               "---------------------------------------".

           05  LINE 4  COL 3  VALUE "EMP ID  :".
           05  LINE 4  COL 14 PIC 9(05) FROM D-ID.
           05  LINE 4  COL 35 VALUE "STATUS:".
           05  LINE 4  COL 43 PIC X(01) FROM D-STATUS.
           05  LINE 5  COL 3  VALUE "NAME    :".
           05  LINE 5  COL 14 PIC X(20) FROM D-NAME.
           05  LINE 6  COL 3  VALUE "DEPT    :".
           05  LINE 6  COL 14 PIC X(04) FROM D-DEPT.
           05  LINE 6  COL 35 VALUE "GRADE :".
           05  LINE 6  COL 43 PIC X(01) FROM D-GRADE.
           05  LINE 7  COL 3  VALUE "MARITAL :".
           05  LINE 7  COL 14 PIC X(01) FROM D-MARITAL.
           05  LINE 8  COL 3  VALUE "BASE SAL:".
           05  LINE 8  COL 14 PIC ZZZ,ZZ9.99 FROM D-BASE.
           05  LINE 9  COL 3  VALUE "HOURS   :".
           05  LINE 9  COL 14 PIC ZZ9.99 FROM D-HOURS.

           05  LINE 11 COL 1  VALUE
               "------------- PAY CALCULATION ----------".
           05  LINE 11 COL 41 VALUE
               "---------------------------------------".
           05  LINE 13 COL 5  VALUE "GROSS     :".
           05  LINE 13 COL 20 PIC ZZZ,ZZ9.99 FROM D-GROSS.
           05  LINE 14 COL 5  VALUE "ALLOWANCE :".
           05  LINE 14 COL 20 PIC ZZZ,ZZ9.99 FROM D-ALLOW.
           05  LINE 15 COL 5  VALUE "TAX       :".
           05  LINE 15 COL 20 PIC ZZZ,ZZ9.99 FROM D-TAX.
           05  LINE 16 COL 5  VALUE "NET PAY   :".
           05  LINE 16 COL 20 PIC ZZZ,ZZ9.99 FROM D-NET.

           05  LINE 22 COL 1  PIC X(40) FROM D-MSG.
           05  LINE 24 COL 1  VALUE
               "ENTER=CALC  PF7=PREV  PF8=NEXT  PF3=EXIT".
      *    Hidden input field so ACCEPT actually waits for a keypress.
           05  LINE 24 COL 50 PIC X(01) USING WS-DUMMY AUTO.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-LOAD-TABLE
           IF WS-EMP-COUNT = 0
               DISPLAY "NO EMPLOYEES LOADED." STOP RUN
           END-IF
           MOVE 1 TO WS-CUR
           PERFORM 2000-SHOW UNTIL KEY-PF3
           PERFORM 9000-BYE
           STOP RUN.

      ******************************************************************
       1000-LOAD-TABLE.
           OPEN INPUT EMP-FILE
           PERFORM UNTIL WS-EMP-STATUS NOT = "00"
               READ EMP-FILE
                   AT END
                       MOVE "10" TO WS-EMP-STATUS
                   NOT AT END
                       MOVE EMP-RECORD-IO TO EMPLOYEE-RECORD
                       ADD 1 TO WS-EMP-COUNT
                       SET WS-IX TO WS-EMP-COUNT
                       MOVE EMP-ID        TO T-ID    (WS-IX)
                       MOVE EMP-NAME      TO T-NAME  (WS-IX)
                       MOVE EMP-DEPT      TO T-DEPT  (WS-IX)
                       MOVE EMP-GRADE     TO T-GRADE (WS-IX)
                       MOVE EMP-BASE-SALARY TO T-BASE (WS-IX)
                       MOVE EMP-HOURS-WORKED TO T-HOURS (WS-IX)
                       MOVE EMP-STATUS    TO T-STATUS (WS-IX)
                       MOVE EMP-MARITAL   TO T-MARITAL (WS-IX)
                       MOVE EMP-YEARS-SERVICE TO T-YEARS (WS-IX)
               END-READ
           END-PERFORM
           CLOSE EMP-FILE.

      ******************************************************************
       2000-SHOW.
           SET WS-IX TO WS-CUR
           PERFORM 3000-CALC
           PERFORM 4000-MOVE-DISPLAY
      *    Draw the whole map once, then read one key. CRT STATUS tells
      *    us which function key was pressed (set in SPECIAL-NAMES).
           DISPLAY PAY-MAP
           ACCEPT PAY-MAP
           EVALUATE TRUE
               WHEN KEY-PF8
                   IF WS-CUR < WS-EMP-COUNT
                       ADD 1 TO WS-CUR
                   END-IF
               WHEN KEY-PF7
                   IF WS-CUR > 1
                       SUBTRACT 1 FROM WS-CUR
                   END-IF
           END-EVALUATE.

      ******************************************************************
       3000-CALC.
      *    SAME RULES AS PAYRUN00 (GROSS / ALLOWANCE / TAX / NET).
           SET WS-IX TO WS-CUR
           IF T-STATUS (WS-IX) = "T"
               MOVE 0 TO WS-GROSS WS-ALLOW WS-TAX WS-NET
               MOVE "** TERMINATED - NOT PAID **" TO D-MSG
           ELSE
               MOVE SPACES TO D-MSG
               COMPUTE WS-HRLY-RATE ROUNDED =
                   T-BASE (WS-IX) / WS-WPY / WS-STD-HOURS
               IF T-HOURS (WS-IX) > WS-STD-HOURS
                   COMPUTE WS-OT-HOURS = T-HOURS (WS-IX) - WS-STD-HOURS
                   COMPUTE WS-GROSS ROUNDED =
                       (WS-HRLY-RATE * WS-STD-HOURS)
                     + (WS-HRLY-RATE * WS-OT-FACTOR * WS-OT-HOURS)
               ELSE
                   COMPUTE WS-GROSS ROUNDED =
                       WS-HRLY-RATE * T-HOURS (WS-IX)
               END-IF
      *        GRADE ALLOWANCE - INCL. UNDOCUMENTED GRADE-E +250
               EVALUATE T-GRADE (WS-IX)
                   WHEN "B" COMPUTE WS-ALLOW = WS-GROSS * 0.05
                   WHEN "C" COMPUTE WS-ALLOW = WS-GROSS * 0.08
                   WHEN "D" COMPUTE WS-ALLOW = WS-GROSS * 0.12
                   WHEN "E" COMPUTE WS-ALLOW = (WS-GROSS * 0.15) + 250.00
                   WHEN OTHER MOVE 0 TO WS-ALLOW
               END-EVALUATE
      *        PROGRESSIVE TAX - INCL. UNDOCUMENTED MARITAL 10% RELIEF
               COMPUTE WS-TAXABLE = WS-GROSS + WS-ALLOW
               IF T-MARITAL (WS-IX) = "M"
                   COMPUTE WS-TAXABLE = WS-TAXABLE * 0.90
               END-IF
               EVALUATE TRUE
                   WHEN WS-TAXABLE <= WS-BRK (1)
                       MOVE 10.00 TO WS-RATE-PCT
                   WHEN WS-TAXABLE <= WS-BRK (2)
                       MOVE 22.00 TO WS-RATE-PCT
                   WHEN OTHER
                       MOVE 35.00 TO WS-RATE-PCT
               END-EVALUATE
               COMPUTE WS-TAX ROUNDED = WS-TAXABLE * (WS-RATE-PCT / 100)
               COMPUTE WS-NET = WS-GROSS + WS-ALLOW - WS-TAX
           END-IF.

      ******************************************************************
       4000-MOVE-DISPLAY.
           SET WS-IX TO WS-CUR
           MOVE WS-CUR              TO D-POS
           MOVE WS-EMP-COUNT        TO D-CNT
           MOVE T-ID (WS-IX)        TO D-ID
           MOVE T-NAME (WS-IX)      TO D-NAME
           MOVE T-DEPT (WS-IX)      TO D-DEPT
           MOVE T-GRADE (WS-IX)     TO D-GRADE
           MOVE T-STATUS (WS-IX)    TO D-STATUS
           MOVE T-MARITAL (WS-IX)   TO D-MARITAL
           MOVE T-BASE (WS-IX)      TO D-BASE
           MOVE T-HOURS (WS-IX)     TO D-HOURS
           MOVE WS-GROSS            TO D-GROSS
           MOVE WS-ALLOW            TO D-ALLOW
           MOVE WS-TAX              TO D-TAX
           MOVE WS-NET              TO D-NET.

      ******************************************************************
       9000-BYE.
           DISPLAY SPACE
           DISPLAY "PAYUI00 ENDED.".
