#!/bin/ksh

. $HOME/.profile

###################################################################
#
#   (C) Copyright IBM Corp. 2003 All rights reserved.
#
# This is an IBM Internal Tool developed to aid in managing
# and examining Siebel Applications.  There is no official IBM
# support.  Use at your own risk. Developed for Siebel 7.7 and v8.0
#
###################################################################
export HOME=${HOME?}
export ORACLE_HOME=${ORACLE_HOME?}
export ORACLE_SID=${ORACLE_SID?}



#*****************************************************************#
#                                                                 #
#                   Function Definitions                          #
#                                                                 #
#*****************************************************************#

# USAGE STMT
usage(){
	print stopdb - Stops up the oracle database.
	print "Usage: stopdb [-ioldh]"
	print "  -l   Dont bring down the listener service"
	print "  -d   Dont bring down the database service"
	print "  -h   Usage help"
}

isdbrunning() {
  #set -x
  check_stat=`ps -ef|grep ${ORACLE_SID}|grep pmon|wc -l`;
  oracle_num=`expr $check_stat`
  if [ $oracle_num -lt 1 ]
  then
    #echo Nope DBMS is not up and running
    return 16
  fi
  

  rm -f /tmp/check_$ORACLE_SID.$$
  #*************************************************************
  # Test to see if Oracle is accepting connections
  #*************************************************************
  $ORACLE_HOME/bin/sqlplus -s "/ as sysdba"  > /tmp/check_$ORACLE_SID.$$ << EOF
  select * from v\$database;
  exit
EOF
  check_stat=`cat /tmp/check_$ORACLE_SID.$$ | grep -i error | wc -l`;
  oracle_num=`expr $check_stat`
  if [ $oracle_num -ne 0 ]
  then
    #echo dbms is not taking connections.
    return 8
  else
   #echo dbms is up
   return 0
  fi
} 

islsnrunning() {
  #set -x
  check_stat=`ps -ef|grep ${USER}|grep tnslsnr | fgrep -v grep |wc -l`;
  oracle_num=`expr $check_stat`
  if [ $oracle_num -lt 1 ]
  then
    #echo Nope DBMS is not up and running
    return 16
  fi
} 

stop_listener() {
  #set -x
  if [ "$nolsnr" != "" ] ; then
    comp="listener"
    print "\nBYPASSING $comp \t... Option to NOT stop $comp service given;"
    return;
  else
    islsnrunning
    if [ $? != 0 ] ; then
       echo "Listener is already Stopped ..."
       return
    fi
    lsnrctl stop 
    if [ $? == 0 ] ; then
      echo "Listener has been stopped ..."
    else
      echo "Listener is already stopped ..."
    fi
  
    echo
    sleep 1
  fi
}

stop_dbms() {
  #set -x
  if [ "$nodbms" != "" ] ; then
    comp="dbms"
    print "\nBYPASSING $comp \t\t... Option to NOT stop $comp service given;"
    return 0;
  else
    isdbrunning
    DBSTATE=$?
    if [ $DBSTATE != 0 ] ; then
      case $DBSTATE in
         8) echo "ERROR:   DBMS is running and NOT taking connections"  ;;
        16) echo "DBMS is already stopped"                              ;;
         *) echo "UNKNOWN VALUE $?" ;      exit 2                       ;;
        esac
        return $DBSTATE
    fi
  
    echo "\nStopping Oracle Database ..."
    echo
    sqlplus -S "/ as sysdba" <<EOF
    shutdown immediate
    quit
EOF
  return 0;
  fi
}

#*****************************************************************#
#                                                                 #
#                           Main Program                          #
#                                                                 #
#*****************************************************************#

# SHELL OPTIONS
while getopts "ldh" arg
do
  case $arg in
     l) nolsnr="true" ;;
     d) nodbms="true" ;;
     h|*) usage
        exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

###########################################
# OK START UP THE DBMS ..
###########################################
#

  stop_dbms;

###########################################
# SHALL WE START THE LISTENER?
###########################################
#

  stop_listener;

