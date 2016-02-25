#!/usr/bin/ksh

###################################
# DOC_ID: 1623879.1 Section 11
###################################

export ORACLE_HOME=${ORACLE_HOME?}
echo $ORACLE_HOME;

$ORACLE_HOME/bin/sqlplus '/ as sysdba' <<-EOF
set echo  on
drop table sys.enabled\$indexes;
quit;
EOF
