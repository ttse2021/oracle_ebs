#!/usr/bin/ksh

export ORACLE_HOME=${ORACLE_HOME?}
echo $ORACLE_HOME;

$ORACLE_HOME/bin/sqlplus '/ as sysdba' <<-EOF
set echo  on

ALTER SESSION SET CURRENT_SCHEMA=SYS;
grant select on SYS.DBA_PROCEDURES to ctxsys;

quit;
EOF
