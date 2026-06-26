      ******************************************************************
      * PROGRAM   PAYRPT00                                             *
      * SYSTEM    ACME PAYROLL - PAYROLL REGISTER REPORT               *
      * FUNCTION  READS THE PAYROLL RESULT FILE PRODUCED BY PAYRUN00   *
      *           AND PRINTS A DEPARTMENT-TOTALLED REGISTER.           *
      * AUTHOR    G. HOPKINS          DATE WRITTEN 1987-05-02          *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYRPT00.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PAY-FILE   ASSIGN TO "data/PAYRESULT.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-PAY-STATUS.
           SELECT RPT-FILE   ASSIGN TO "data/PAYREGISTER.TXT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RPT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  PAY-FILE.
       01  PAY-RECORD-IO             PIC X(80).
       FD  RPT-FILE.
       01  RPT-LINE                  PIC X(80).

       WORKING-STORAGE SECTION.
       COPY PAYREC.
       01  WS-FLAGS.
           05  WS-PAY-STATUS         PIC X(02).
           05  WS-RPT-STATUS         PIC X(02).
           05  WS-EOF-FLAG           PIC X(01)   VALUE "N".
               88  END-OF-FILE                   VALUE "Y".

       01  WS-TOTALS.
           05  WS-TOT-GROSS          PIC 9(09)V99   VALUE ZERO.
           05  WS-TOT-TAX            PIC 9(09)V99   VALUE ZERO.
           05  WS-TOT-NET            PIC 9(09)V99   VALUE ZERO.
           05  WS-LINE-CNT           PIC 9(05)      VALUE ZERO.

       01  WS-DETAIL-LINE.
           05  FILLER                PIC X(02)   VALUE SPACES.
           05  DL-EMP-ID             PIC 9(05).
           05  FILLER                PIC X(02)   VALUE SPACES.
           05  DL-EMP-NAME           PIC X(20).
           05  FILLER                PIC X(02)   VALUE SPACES.
           05  DL-DEPT               PIC X(04).
           05  FILLER                PIC X(02)   VALUE SPACES.
           05  DL-GROSS              PIC ZZ,ZZZ,ZZ9.99.
           05  FILLER                PIC X(02)   VALUE SPACES.
           05  DL-TAX                PIC ZZ,ZZZ,ZZ9.99.
           05  FILLER                PIC X(02)   VALUE SPACES.
           05  DL-NET                PIC ZZ,ZZZ,ZZ9.99.

       01  WS-HEADER-LINE.
           05  FILLER  PIC X(11) VALUE "  EMPID  NA".
           05  FILLER  PIC X(20) VALUE "ME            DEPT  ".
           05  FILLER  PIC X(28) VALUE " GROSS         TAX      NET ".

       01  WS-TOTAL-LINE.
           05  FILLER                PIC X(35)
               VALUE "  *** TOTALS ***".
           05  TL-GROSS              PIC ZZ,ZZZ,ZZ9.99.
           05  FILLER                PIC X(02)   VALUE SPACES.
           05  TL-TAX                PIC ZZ,ZZZ,ZZ9.99.
           05  FILLER                PIC X(02)   VALUE SPACES.
           05  TL-NET                PIC ZZ,ZZZ,ZZ9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-INIT
           PERFORM 2000-PROCESS UNTIL END-OF-FILE
           PERFORM 9000-TERMINATE
           STOP RUN.

       1000-INIT.
           OPEN INPUT  PAY-FILE
           OPEN OUTPUT RPT-FILE
           MOVE WS-HEADER-LINE TO RPT-LINE
           WRITE RPT-LINE
           PERFORM 8000-READ-PAY.

       2000-PROCESS.
           MOVE PAY-EMP-ID    TO DL-EMP-ID
           MOVE PAY-EMP-NAME  TO DL-EMP-NAME
           MOVE PAY-DEPT      TO DL-DEPT
           MOVE PAY-GROSS     TO DL-GROSS
           MOVE PAY-TAX       TO DL-TAX
           MOVE PAY-NET       TO DL-NET
           MOVE WS-DETAIL-LINE TO RPT-LINE
           WRITE RPT-LINE
           ADD PAY-GROSS TO WS-TOT-GROSS
           ADD PAY-TAX   TO WS-TOT-TAX
           ADD PAY-NET   TO WS-TOT-NET
           ADD 1 TO WS-LINE-CNT
           PERFORM 8000-READ-PAY.

       8000-READ-PAY.
           READ PAY-FILE
               AT END
                   MOVE "Y" TO WS-EOF-FLAG
               NOT AT END
                   MOVE PAY-RECORD-IO TO PAYROLL-RECORD
           END-READ.

       9000-TERMINATE.
           MOVE WS-TOT-GROSS TO TL-GROSS
           MOVE WS-TOT-TAX   TO TL-TAX
           MOVE WS-TOT-NET   TO TL-NET
           MOVE WS-TOTAL-LINE TO RPT-LINE
           WRITE RPT-LINE
           CLOSE PAY-FILE
           CLOSE RPT-FILE
           DISPLAY "PAYRPT00 COMPLETE. LINES: " WS-LINE-CNT.
