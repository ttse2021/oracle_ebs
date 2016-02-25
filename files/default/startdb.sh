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
    print startdb - Starts up the oracle database.
	print "Usage: startdb [-ldh]"
	print "  -l   Dont bring up the listener service"
	print "  -d   Dont bring up the database service"
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

start_listener() {
  #set -x
  if [ "$nolsnr" != "" ] ; then
    comp="listener"
    print "\nBYPASSING $comp \t... Option to NOT start $comp service given;"
    return;
  else
    islsnrunning
    if [ $? != 16 ] ; then
       echo "Listener is already Running ..."
       return
    fi
    lsnrctl start
    if [ $? == 0 ] ; then
      echo "Listener has been started ..."
    else
      echo "Listener is already Running ..."
    fi
  
    echo
    sleep 1
  fi
}


start_dbms() {
  #set -x
  if [ "$nodbms" != "" ] ; then
    comp="dbms"
    print "\nBYPASSING $comp \t\t... Option to NOT stop $comp service given;"
    return 0;
  else
    isdbrunning
    DBSTATE=$?
    if [ $DBSTATE != 16 ] ; then
      case $DBSTATE in
         0) echo "ERROR:   DBMS is already running"                             ;;
         8) echo "ERROR:   DBMS is already running and NOT taking connections"  ;;
        16) echo "DBMS is NOT running"                                        ;;
         *) echo "UNKNOWN VALUE $?" ;      exit 2                             ;;
        esac
        return $DBSTATE
    fi
  
    echo "\nStarting Oracle Database ..."
    echo
    sqlplus -S "/ as sysdba" <<EOF
    startup
    quit
EOF
    return 0;
  fi
}
function show_usage_and_exit
{
   printf "\nUsage: $0 [ -e <environment> ]\n"
   printf "\nWhere:\t-f\tDisplay full 132 column output"
   printf "\n\t-e\tEnvironment [db|fs1|fs2]" 
   exit -1
}


#*****************************************************************#
#                                                                 #
#                           Main Program                          #
#                                                                 #
#*****************************************************************#

# Check OPTIONS
while getopts :e _option $*
do
   case $_option in
      u) # Set the USER NAME we want to search for
         _user_name=$OPTARG
         ;;
      *) printf "\nInvalid Option Specified: %s\n\n" $OPTARG
         show_usage_and_exit
         ;;
   esac
done

shift $(($OPTIND - 1))

###########################################
# SHALL WE START THE LISTENER?
###########################################
#

  start_listener;


###########################################
# OK START UP THE DBMS ..
###########################################
#

  start_dbms;
