      ******************************************************************
      * PROGRAM   PAYRUN00                                             *
      * SYSTEM    ACME PAYROLL - WEEKLY GROSS-TO-NET CALCULATION       *
      * FUNCTION  READS EMPLOYEE MASTER, COMPUTES GROSS, ALLOWANCE,    *
      *           TAX AND NET PAY, WRITES PAYROLL RESULT FILE.         *
      * AUTHOR    G. HOPKINS          DATE WRITTEN 1987-04-11          *
      * REMARKS   MAINT 1994 R.K. - ADDED GRADE 'E' EXEC BONUS         *
      *           MAINT 2003 J.M. - Y2K CLEANUP, LEFT OLD PARA IN      *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYRUN00.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMP-FILE   ASSIGN TO "data/EMPMAST.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-EMP-STATUS.
           SELECT PAY-FILE   ASSIGN TO "data/PAYRESULT.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-PAY-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  EMP-FILE.
       01  EMP-RECORD-IO          PIC X(80).
       FD  PAY-FILE.
       01  PAY-RECORD-IO          PIC X(80).

       WORKING-STORAGE SECTION.
      *    RECORD STRUCTURES LIVE IN WORKING-STORAGE; THE FD HOLDS A
      *    FLAT 80-BYTE BUFFER. MOVE BETWEEN THE TWO ON READ / WRITE.
       COPY EMPREC.
       COPY PAYREC.

       01  WS-FILE-STATUS-FLAGS.
           05  WS-EMP-STATUS          PIC X(02).
           05  WS-PAY-STATUS          PIC X(02).
           05  WS-EOF-FLAG            PIC X(01)   VALUE "N".
               88  END-OF-FILE                    VALUE "Y".

       01  WS-COUNTERS.
           05  WS-READ-CNT            PIC 9(05)   VALUE ZERO.
           05  WS-WRITE-CNT           PIC 9(05)   VALUE ZERO.
           05  WS-SKIP-CNT            PIC 9(05)   VALUE ZERO.

      *    --- WORK FIELDS.  NAMES ARE HISTORICAL, DO NOT RENAME. ---
       01  WS-CALC-FIELDS.
           05  WS-HRLY-RATE          PIC 9(05)V99   COMP-3.
           05  WS-OT-HOURS           PIC 9(03)V99   COMP-3.
           05  WS-GROSS              PIC 9(07)V99   COMP-3.
           05  WS-ALLOW              PIC 9(06)V99   COMP-3.
           05  WS-TAX                PIC 9(06)V99   COMP-3.
           05  WS-NET                PIC 9(07)V99   COMP-3.
           05  WS-TAXABLE            PIC 9(07)V99   COMP-3.
           05  WS-X7                 PIC 9(07)V99   COMP-3.
           05  WS-RATE-PCT           PIC 9(02)V99   COMP-3.

       01  WS-CONSTANTS.
           05  WS-STD-HOURS          PIC 9(03)V99   VALUE 40.00.
           05  WS-OT-FACTOR          PIC 9(01)V99   VALUE 1.50.
      *    STANDARD WORK WEEK = 40 HOURS, OVERTIME PAID AT 1.5X
           05  WS-WEEKS-PER-YEAR     PIC 9(02)      VALUE 52.

      *    TAX BRACKET TABLE - SEE 4000-CALC-TAX
       01  WS-TAX-BRACKETS.
           05  FILLER  PIC 9(07)V99 COMP-3 VALUE 0030000.00.
           05  FILLER  PIC 9(07)V99 COMP-3 VALUE 0060000.00.
           05  FILLER  PIC 9(07)V99 COMP-3 VALUE 0099999.99.
       01  WS-TAX-BRACKET-TBL REDEFINES WS-TAX-BRACKETS.
           05  WS-BRACKET           PIC 9(07)V99 COMP-3 OCCURS 3 TIMES.

       PROCEDURE DIVISION.
      ******************************************************************
       0000-MAIN.
           PERFORM 1000-INIT
           PERFORM 2000-PROCESS UNTIL END-OF-FILE
           PERFORM 9000-TERMINATE
           STOP RUN.

      ******************************************************************
       1000-INIT.
           OPEN INPUT  EMP-FILE
           OPEN OUTPUT PAY-FILE
           IF WS-EMP-STATUS NOT = "00"
               DISPLAY "PAYRUN00 - CANNOT OPEN EMPMAST, STATUS "
                       WS-EMP-STATUS
               MOVE "Y" TO WS-EOF-FLAG
           END-IF
           PERFORM 8000-READ-EMP.

      ******************************************************************
       2000-PROCESS.
      *    SKIP TERMINATED EMPLOYEES - THEY ARE NOT PAID.
           IF EMP-STATUS = "T"
               ADD 1 TO WS-SKIP-CNT
           ELSE
               PERFORM 3000-CALC-GROSS
               PERFORM 3500-CALC-ALLOWANCE
               PERFORM 4000-CALC-TAX
               COMPUTE WS-NET = WS-GROSS + WS-ALLOW - WS-TAX
               PERFORM 5000-WRITE-PAY
           END-IF
           PERFORM 8000-READ-EMP.
       2000-EXIT.
           EXIT.

      ******************************************************************
       3000-CALC-GROSS.
      *    HOURLY RATE DERIVED FROM ANNUAL BASE / 52 / 40
           COMPUTE WS-HRLY-RATE ROUNDED =
               EMP-BASE-SALARY / WS-WEEKS-PER-YEAR / WS-STD-HOURS
           IF EMP-HOURS-WORKED > WS-STD-HOURS
               COMPUTE WS-OT-HOURS = EMP-HOURS-WORKED - WS-STD-HOURS
               COMPUTE WS-GROSS ROUNDED =
                   (WS-HRLY-RATE * WS-STD-HOURS)
                 + (WS-HRLY-RATE * WS-OT-FACTOR * WS-OT-HOURS)
           ELSE
               COMPUTE WS-GROSS ROUNDED =
                   WS-HRLY-RATE * EMP-HOURS-WORKED
           END-IF.

      ******************************************************************
       3500-CALC-ALLOWANCE.
      *    ALLOWANCE BY GRADE.  GRADE 'E' BONUS ADDED 1994.
           EVALUATE EMP-GRADE
               WHEN "A"
                   MOVE 0 TO WS-ALLOW
               WHEN "B"
                   COMPUTE WS-ALLOW = WS-GROSS * 0.05
               WHEN "C"
                   COMPUTE WS-ALLOW = WS-GROSS * 0.08
               WHEN "D"
                   COMPUTE WS-ALLOW = WS-GROSS * 0.12
               WHEN "E"
      *            UNDOCUMENTED: EXEC GRADE ALSO GETS FLAT 250 ON TOP
      *            OF THE 15% - ADDED BY R.K. 1994, NEVER IN THE SPEC
                   COMPUTE WS-ALLOW = (WS-GROSS * 0.15) + 250.00
               WHEN OTHER
                   MOVE 0 TO WS-ALLOW
           END-EVALUATE.

      ******************************************************************
       4000-CALC-TAX.
           COMPUTE WS-TAXABLE = WS-GROSS + WS-ALLOW
           PERFORM 4100-MARITAL-ADJUST
           PERFORM 4200-PICK-RATE THRU 4200-EXIT
           COMPUTE WS-TAX ROUNDED = WS-TAXABLE * (WS-RATE-PCT / 100).

      ******************************************************************
      *  4200-PICK-RATE - BRACKET SELECTION USES GO TO.  ORIGINAL      *
      *  1987 STYLE, NEVER REWRITTEN TO EVALUATE.  THRU 4200-EXIT.     *
      ******************************************************************
       4200-PICK-RATE.
           IF WS-TAXABLE <= WS-BRACKET (1)
               GO TO 4200-LOW
           END-IF
           IF WS-TAXABLE <= WS-BRACKET (2)
               GO TO 4200-MID
           END-IF
           MOVE 35.00 TO WS-RATE-PCT
           GO TO 4200-EXIT.
       4200-LOW.
           MOVE 10.00 TO WS-RATE-PCT
           GO TO 4200-EXIT.
       4200-MID.
           MOVE 22.00 TO WS-RATE-PCT.
       4200-EXIT.
           EXIT.

      ******************************************************************
       4100-MARITAL-ADJUST.
      *    MARRIED EMPLOYEES GET A 10% REDUCTION ON TAXABLE BASE.
      *    THIS RULE IS NOT IN ANY CURRENT REQUIREMENTS DOCUMENT.
           IF EMP-MARITAL = "M"
               COMPUTE WS-TAXABLE = WS-TAXABLE * 0.90
           END-IF.

      ******************************************************************
       5000-WRITE-PAY.
           INITIALIZE PAYROLL-RECORD
           MOVE EMP-ID        TO PAY-EMP-ID
           MOVE EMP-NAME      TO PAY-EMP-NAME
           MOVE EMP-DEPT      TO PAY-DEPT
           MOVE WS-GROSS      TO PAY-GROSS
           MOVE WS-ALLOW      TO PAY-ALLOWANCE
           MOVE WS-TAX        TO PAY-TAX
           MOVE WS-NET        TO PAY-NET
           MOVE "OK"          TO PAY-RUN-CODE
           MOVE PAYROLL-RECORD TO PAY-RECORD-IO
           WRITE PAY-RECORD-IO
           ADD 1 TO WS-WRITE-CNT.

      ******************************************************************
      *  8500-CALC-BONUS - LEGACY ANNUAL BONUS ROUTINE.               *
      *  NO LONGER CALLED SINCE THE 2003 MAINTENANCE. KEPT 'JUST IN   *
      *  CASE'.  THIS PARAGRAPH IS DEAD CODE.                         *
      ******************************************************************
       8500-CALC-BONUS.
           COMPUTE WS-X7 = EMP-BASE-SALARY * 0.025
           COMPUTE WS-X7 = WS-X7 * EMP-YEARS-SERVICE
           MOVE WS-X7 TO WS-ALLOW.

      ******************************************************************
       8000-READ-EMP.
           READ EMP-FILE
               AT END
                   MOVE "Y" TO WS-EOF-FLAG
               NOT AT END
                   MOVE EMP-RECORD-IO TO EMPLOYEE-RECORD
                   ADD 1 TO WS-READ-CNT
           END-READ.

      ******************************************************************
       9000-TERMINATE.
           CLOSE EMP-FILE
           CLOSE PAY-FILE
           DISPLAY "PAYRUN00 COMPLETE."
           DISPLAY "  RECORDS READ    : " WS-READ-CNT
           DISPLAY "  PAYSLIPS WRITTEN: " WS-WRITE-CNT
           DISPLAY "  SKIPPED (TERM)  : " WS-SKIP-CNT.
