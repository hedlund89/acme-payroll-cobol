      ******************************************************************
      * EMPREC  - EMPLOYEE MASTER RECORD LAYOUT                         *
      * SHARED COPYBOOK - USED BY PAYRUN00 AND PAYRPT00                 *
      * RECORD LENGTH 80 - DISPLAY NUMERICS (FLAT FILE, KEYABLE)        *
      ******************************************************************
       01  EMPLOYEE-RECORD.
           05  EMP-ID                 PIC 9(05).
           05  EMP-NAME               PIC X(20).
           05  EMP-DEPT               PIC X(04).
           05  EMP-GRADE              PIC X(01).
      *        GRADE DRIVES THE ALLOWANCE TABLE - SEE PAYRUN00 3500-PARA
           05  EMP-BASE-SALARY        PIC 9(07)V99.
           05  EMP-HOURS-WORKED       PIC 9(03)V99.
           05  EMP-STATUS             PIC X(01).
      *        A=ACTIVE  T=TERMINATED  L=LEAVE
           05  EMP-MARITAL            PIC X(01).
      *        M=MARRIED S=SINGLE  (AFFECTS TAX - 4100-PARA)
           05  EMP-YEARS-SERVICE      PIC 9(02).
           05  FILLER                 PIC X(32).
