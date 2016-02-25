log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:dbms_upg6                *'
log '*                                            *'
log '**********************************************'


  #########################################################
  # attributs accessed:
  #########################################################

dbowner   = node[:ebs_dbuser]
dbgroup   = node[:ebs_dbgroup]
dbhome    = node[:ebs][:db][:usr][:homedir]
dbenv        = node[:ebs][:db][:env_11204]
ora_home4    = node[:ebs][:db][:orahome4]
sid          = node[:ebs][:db][:sid]
hname        = node[:hostname]
binapp       = node[:ebs][:app][:bin]
bindb        = node[:ebs][:db][:bin]
outapp       = node[:ebs][:app][:outdir]
outdb        = node[:ebs][:db][:outdir]
post_install = node[:ebs][:stage][:post_patches_11204]
tmpstage     = node[:ebs][:stage][:dir]
app_home      = node[:ebs][:app][:runbase]
appusr       = node[:ebs][:appsuser]
appgroup     = node[:ebs_appgroup]
apppw        = node[:ebs][:appspw]
syspw        = node[:ebs][:syspw]
appenv       = node[:ebs][:app][:env]

  #####################################################################
  # Doc_id: 1623879.1 Section 15                                      #
  #    Perform patch post-install instructions                        #
  #####################################################################

template "#{bindb}/patch_20523280.sql" do
  source "patch_20523280.sql.erb"
  owner dbowner
  group dbgroup
  mode '0755'
end


  # These we have no way of knowing if they have been applied before. So
  # we use touch files for showing progress
  #
post_install.each do |patchnum|
  execute "postinstall_#{patchnum}" do
    user          dbowner
    group         dbgroup
    environment ( dbenv )
    command "echo exit | sqlplus '/ as sysdba' "\
            "@#{ora_home4}/sqlpatch/#{patchnum}/postinstall.sql && "\
            "touch #{outdb}/t.postinstall_#{patchnum}"
    creates       "#{outdb}/t.postinstall_#{patchnum}"
  end
end

execute "postinstall_20523280" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  command "sqlplus '/ as sysdba' @#{bindb}/patch_20523280.sql "\
                        "> #{outdb}/out.patch_20523280 2>&1"
    creates               "#{outdb}/out.patch_20523280"
end

  #####################################################################
  # Doc_id: 1623879.1 Section 16                                      #
  #    Revoke ORA$BASE grant                                          #
  #####################################################################
  # N/A. ORA$BASE is already the default edition.
  # If the ORA$BASE edition is not the default edition, a grant 
  # has to be revoked.  To see the default edition, use SQL*Plus
  # to connect to the database as SYSDBA and run the following 
  # command: 
  #     select * from database_properties 
  #              where property_name='DEFAULT_EDITION';
  # If ORA$BASE is not returned by the query, use SQL*Plus to 
  # connect to the database as SYSDBA and run the following command:
  #    revoke use on edition ora$base from public;
  #####################################################################
  # N/A - already default
  #####################################################################


  #####################################################################
  # Doc_id: 1623879.1 Section 17                                      #
  #    Natively compile PL/SQL code (optional)                        #
  #####################################################################
  # You can choose to run Oracle E-Business Suite 12 PL/SQL database
  # objects in natively compiled mode with Oracle Database 11g. 
  # See the "Compiling PL/SQL Program Units for Native Execution" 
  # section of Chapter 12 of Oracle Database PL/SQL Language 
  # Reference 11g Release 2 (11.2). 
  #####################################################################
  # N/A. Skipped.
  #####################################################################


  #####################################################################
  # Doc_id: 1623879.1 Section 18                                      #
  #    Start the new database listener                                #
  #####################################################################
  # N/A. started it earlier
  # If the Oracle Net listener for the database instance in the new 
  # Oracle home has not been started, you must start it now. Since
  # AutoConfig has not yet been implemented, start the listener 
  # with the lsnrctl executable (UNIX/Linux) or Services (Windows). 
  # See the Oracle Database Net Services Administrator's Guide, 
  # 11g Release 2 (11.2) for more information.
  # 
  # Attention: Set the TNS_ADMIN environment variable to the 
  # directory where you created your listener.ora and 
  # tnsnames.ora files. 
  #####################################################################
  # N/A. started it earlier
  #####################################################################


  #####################################################################
  # Doc_id: 1623879.1 Section 19                                      #
  #    Run adgrants.sql                                               #
  #####################################################################
  # Copy $APPL_TOP/admin/adgrants.sql from the administration server
  # node to the database server node. Use SQL*Plus to connect to the
  # database as SYSDBA and run the script using the following
  # command: 
  #
  # sqlplus "/ as sysdba" @adgrants.sql [APPS schema name]
  #
  # Note: since we copied the 11.2.0.3 appsutil direcotry over
  # to 11.2.0.4, we dont have to copy from the appllication user.
  #####################################################################

  log '***************************************************'
  log '* Running latest adgrants.sql. takes 10 minutes   *'
  log '***************************************************'

execute "run_adgrants" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  command "sqlplus '/ as sysdba' @#{ora_home4}/appsutil/sql/adgrants.sql APPS"\
          " > #{outdb}/out.adgrants 2>&1"
end

