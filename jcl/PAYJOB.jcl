//PAYJOB   JOB (ACCT),'WEEKLY PAYROLL',CLASS=A,MSGCLASS=X,
//             NOTIFY=&SYSUID,REGION=0M
//*********************************************************************
//* ACME WEEKLY PAYROLL - GROSS TO NET PLUS REGISTER REPORT          *
//* SCHEDULE: EVERY FRIDAY 18:00 VIA OPC/TWS  APPL=PAYW              *
//* CONTACT : PAYROLL OPS X4821                                       *
//*********************************************************************
//*
//* ---------------------------------------------------------------
//STEP010  EXEC PGM=PAYRUN00
//STEPLIB  DD   DSN=ACME.PAYROLL.LOADLIB,DISP=SHR
//EMPMAST  DD   DSN=ACME.PAYROLL.EMPMAST,DISP=SHR
//PAYRESLT DD   DSN=ACME.PAYROLL.RESULT(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(5,5),RLSE),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=8000)
//SYSOUT   DD   SYSOUT=*
//*
//* ---------------------------------------------------------------
//STEP020  EXEC PGM=PAYRPT00,COND=(0,LT,STEP010)
//STEPLIB  DD   DSN=ACME.PAYROLL.LOADLIB,DISP=SHR
//PAYRESLT DD   DSN=ACME.PAYROLL.RESULT(0),DISP=SHR
//PAYREG   DD   SYSOUT=*,
//             DCB=(RECFM=FB,LRECL=80)
//SYSOUT   DD   SYSOUT=*
//*
//* NOTE: ON Z/OS THE DD NAMES MAP TO THE SELECT/ASSIGN CLAUSES.
//* THE GNUCOBOL PORT USES FLAT FILES UNDER ./data INSTEAD (SEE run.sh).
//
