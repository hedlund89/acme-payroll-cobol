      ******************************************************************
      * PAYREC  - PAYROLL RESULT RECORD LAYOUT                          *
      * SHARED COPYBOOK - WRITTEN BY PAYRUN00, READ BY PAYRPT00         *
      * RECORD LENGTH 80 - DISPLAY NUMERICS (FLAT FILE)                 *
      ******************************************************************
       01  PAYROLL-RECORD.
           05  PAY-EMP-ID             PIC 9(05).
           05  PAY-EMP-NAME           PIC X(20).
           05  PAY-DEPT               PIC X(04).
           05  PAY-GROSS              PIC 9(07)V99.
           05  PAY-ALLOWANCE          PIC 9(06)V99.
           05  PAY-TAX                PIC 9(06)V99.
           05  PAY-NET                PIC 9(07)V99.
           05  PAY-RUN-CODE           PIC X(02).
           05  FILLER                 PIC X(15).
