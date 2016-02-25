log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:dbms_upg7                *'
log '*                                            *'
log '**********************************************'


  #########################################################
  # attributs accessed:
  #########################################################

dbowner   = node[:ebs_dbuser]
dbgroup   = node[:ebs_dbgroup]
dbhome    = node[:ebs][:db][:usr][:homedir]
dbenv        = node[:ebs][:db][:env_11204]
appuser      = node[:ebs_appuser]
appgroup     = node[:ebs_appgroup]
appenv       = node[:ebs][:app][:env]
app_home      = node[:ebs][:app][:runbase]
sid          = node[:ebs][:db][:sid]
ora_home4    = node[:ebs][:db][:orahome4]
outdb        = node[:ebs][:db][:outdir]
outapp       = node[:ebs][:app][:outdir]
hname        = node[:hostname]
tmpstage     = node[:ebs][:stage][:dir]
userAPPS      = node[:ebs][:appsuser]
apppw        = node[:ebs][:appspw]
syspw        = node[:ebs][:syspw]
ENVFS1       = node[:ebs][:app][:FS1ENVF]
ENVFS2       = node[:ebs][:app][:FS2ENVF]

  #####################################################################
  # Doc_id: 1623879.1 Section 20                                      #
  #    Grant create procedure privilege on CTXSYS                     #
  #####################################################################
  # Copy $AD_TOP/patch/115/sql/adctxprv.sql from the                  # 
  # administration server node to the database server node.           # 
  # Use SQL*Plus to connect to the database as APPS and               # 
  # run the script using the following command:                       #
  #                                                                   #
  # $ sqlplus apps/[APPS password] @adctxprv.sql\                     #
  #     [SYSTEM password] CTXSYS                                      #
  #                                                                   #
  #####################################################################

sqlf='adctxprv.sql'
srcf="#{app_home}/appl/ad/12.0.0/patch/115/sql/#{sqlf}"
outfile="#{outdb}/#{sqlf}.lst"

execute "run_#{sqlf}_script" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  command <<-EOF
    sqlplus #{userAPPS}/#{apppw} <<-EOC
      spool #{outfile}
      @#{srcf} #{syspw} CTXSYS
      spool OFF
      quit;
EOC
  fgrep "procedure successfully completed" #{outfile} > /dev/null 2>&1
  EOF
end

sqlf='CTXSYS_parameter'
outfile="#{outdb}/#{sqlf}.lst"
execute "set_CTXSYS_parameter_1" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  command <<-EOF
    sqlplus '/ as sysdba' <<-EOC
      spool #{outfile}
      exec ctxsys.ctx_adm.set_parameter('file_access_role', 'public');
      spool OFF
      quit;
EOC
    # we get this far itmust have succeeded
    fgrep "procedure successfully completed" #{outfile} > /dev/null 2>&1
  EOF
end


  #####################################################################
  # Doc_id: 1623879.1 Section 21                                      #
  #    Compile invalid objects                                        #
  #####################################################################
  # Use SQL*Plus to connect to the database as SYSDBA                 #
  # and run the $ORACLE_HOME/rdbms/admin/utlrp.sql                    #
  # script to compile invalid objects.                                #
  #                                                                   #
  # sqlplus "/ as sysdba" @$ORACLE_HOME/rdbms/admin/utlrp.sql         #
  #####################################################################

sqlf='utlrp.sql'
execute "run_#{sqlf}_script" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )

  command <<-EOF
    sqlplus '/ as sysdba' <<-EOC
      spool #{outfile}
      @$ORACLE_HOME/rdbms/admin/#{sqlf}
      spool OFF
      quit;
EOC
    # we get this far it must have succeeded. did we get success mesgs?
    cnt=`fgrep "procedure successfully completed" #{outfile} | wc -l`
    if [ $cnt == 3 ] ; then exit 0; fi
    exit 255;
  EOF
end

  #####################################################################
  # Doc_id: 1623879.1 Section 22                                      #
  #    set CTXSYS parameter                                           #
  #####################################################################
  # Use SQL*Plus to connect to the database as SYSDBA and run         #
  # the following command:                                            #
  #                                                                   #
  # $ sqlplus "/ as sysdba"                                           #
  # SQL> exec ctxsys.ctx_adm.set_parameter('file_access_role',        #
  #                    'public');                                     #
  #####################################################################

sqlf='CTXSYS_parameter'
outfile="#{outdb}/#{sqlf}.lst"
execute "set_CTXSYS_parameter" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  command <<-EOF
    sqlplus '/ as sysdba' <<-EOC
      spool #{outfile}
      exec ctxsys.ctx_adm.set_parameter('file_access_role', 'public');
      spool OFF
      quit;
EOC
    # we get this far itmust have succeeded
    fgrep "procedure successfully completed" #{outfile} > /dev/null 2>&1
  EOF
end


  #####################################################################
  # Doc_id: 1623879.1 Section 23                                      #
  #    Validate Workflow ruleset                                      #
  # On the administration server node, use SQL*Plus to connect to     #
  # the database as APPS and run the                                  #
  # $FND_TOP/patch/115/sql/wfaqupfix.sql script using                 #
  # the following command:                                            #
  #     sqlplus [APPS user]/[APPS password]                           #
  #         @wfaqupfix.sql [APPLSYS user] [APPS user]                 #
  #####################################################################

sqlf='wfaqupfix.sql'
srcf="#{app_home}/appl/fnd/12.0.0/patch/115/sql/#{sqlf}"
outfile="#{outapp}/#{sqlf}.lst"
ENVF="#{ENVFS1}"
execute "run_#{sqlf}_script" do
  user          appuser
  group         appgroup
  environment ( appenv )
  command <<-EOF
    echo ENVF       #{ENVF};
    . #{ENVF}
    sqlplus #{userAPPS}/#{apppw} <<-EOC
      spool #{outfile}
      @#{srcf} APPLSYS #{apppw}
      spool OFF
      quit;
EOC
    # we get this far itmust have succeeded
    fgrep "procedure successfully completed" #{outfile} > /dev/null 2>&1
  EOF
end

  #####################################################################
  # Doc_id: 1623879.1 Section 24                                      #
  #    Deregister the current datbase server                          #
  #####################################################################
  # If you plan to change the database port, host, SID, or database   #
  # name parameter on the database server, you must also update       #
  # AutoConfig on the database tier and deregister the current        #
  # database server node.                                             #
  # Use SQL*Plus to connect to the database as APPS and run           #
  # the following command:                                            #
  # $ sqlplus apps/[APPS password]                                    #
  # SQL> exec fnd_conc_clone.setup_clean;                             #
  #####################################################################

sqlf='fnd_conc_clone_clean'
outfile="#{outdb}/#{sqlf}.lst"
execute "#{sqlf}" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  command <<-EOF
    sqlplus #{userAPPS}/#{apppw} <<-EOC
      spool #{outfile}
      exec fnd_conc_clone.setup_clean;
      spool OFF
      quit;
EOC
    # we get this far itmust have succeeded
    fgrep "procedure successfully completed" #{outfile} > /dev/null 2>&1
  EOF
end

