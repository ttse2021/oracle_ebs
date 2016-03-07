log '
     **********************************************
     *                                            *
     *        EBS Recipe:dbms_upg9                *
     *                                            *
     **********************************************
    '


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
tmpstage     = node[:ebs][:stage][:dir]
app_home      = node[:ebs][:app][:runbase]
userAPPS      = node[:ebs][:appsuser]
apppw        = node[:ebs][:appspw]
syspw        = node[:ebs][:syspw]
appuser      = node[:ebs_appuser]
appgroup     = node[:ebs_appgroup]
appenv       = node[:ebs][:app][:env]
fs1base      = node[:ebs][:app][:runbase]
fs2base      = node[:ebs][:app][:patchhome]
contxtfs1    = node[:ebs][:app][:contxtfs1]
contxtfs2    = node[:ebs][:app][:contxtfs2]
outdb        = node[:ebs][:db][:outdir]
outapp       = node[:ebs][:app][:outdir]
binapp       = node[:ebs][:app][:bin]
ENVFS1       = node[:ebs][:app][:FS1ENVF]
ENVFS2       = node[:ebs][:app][:FS2ENVF]
ENVDB        = node[:ebs][:db][:DBENVF]
contxtdb     = "#{node[:ebs][:db][:orahome4]}/appsutil/#{node[:ebs][:sid_hname]}.xml"


  #####################################################################
  # Doc_id: 1623879.1 Section 26                                      #
  #    Gather statistics for SYS schema                               #
  ##################################################################### 
  # Copy $APPL_TOP/admin/adstats.sql from the administration server   #
  # node to the database server node. Note that adstats.sql has to    #
  # be run in restricted mode. Use SQL*Plus to connect to the         #
  # database as SYSDBA and use the following commands to run          #
  # adstats.sql in restricted mode:                                   #
  #####################################################################

sqlf='adstats.sql'
fpsqlf="#{fs1base}/appl/admin/#{sqlf}"
outfile="#{outdb}/out.#{sqlf}"
touchf="#{outdb}/t.#{sqlf}.passed"
cmd="sqlplus '/ as sysdba'"

execute "run #{sqlf}_to_update_stats" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  command <<-EOF
    echo "Running #{sqlf} on DBMS"
    .    #{ENVDB} 
    echo ${CHEF_ENV?} | fgrep "11204" > /dev/null 2>&1
    if  [ $? != 0 ] ; then echo "Cannot source $ENVDB. Aborting..."; exit 255; fi

    #{cmd} > #{outfile} 2>&1 <<-EOC
      alter system enable restricted session;
      @#{fpsqlf}
      quit;
EOC
    #{cmd} >> #{outfile} 2>&1 <<-EOC
      alter system disable restricted session;
      quit;
EOC
    fgrep 'procedure successfully completed' #{outfile}
    if  [ $? != 0 ] ; then echo "sql: #{sqlf} Failed. Aborting..."; exit 255; fi
    touch   #{touchf}
  EOF
  creates  "#{touchf}"
end

  #####################################################################
  # Doc_id: 1623879.1 Section 27                                      #
  #     Create Demantra privileges (conditional)                      #
  #####################################################################
  # If you are using Demantra, perform the steps in document          #
  # 730883.1 on My Oracle Support.                                    #
  #####################################################################
  # N/A                                                               #
  #####################################################################

  #####################################################################
  # Doc_id: 1623879.1 Section 28                                      #
  #     Re-create custom database links (conditional)                 #
  #####################################################################   
  #                                                                   #
  # If the Oracle Net listener in the 11.2.0 Oracle home is           #
  # defined differently than the one used by the old Oracle home,     #
  # you must re-create any custom self-referential database links     #
  # that exist in the Applications database instance. To check        #
  # for the existence of database links, use SQL*Plus on the          #
  # database server node to connect to the Applications               #
  # database instance as APPS and run the following query:            #
  #                                                                   #
  # sqlplus apps/[apps password]                                      #
  #     select db_link from all_db_links;                             #
  #####################################################################
  # SQL> select db_link from all_db_links;                            #
  #                                                                   #
  # DB_LINK                                                           #
  # ----------------------------------------------------------------  #
  # APPS_TO_APPS                                                      #
  # APPS_TO_APPS.PBM.IHOST.COM                                        #
  # APPS_TO_APPS.US.ORACLE.COM                                        #
  # EDW_APPS_TO_WH                                                    #
  # EDW_APPS_TO_WH.PBM.IHOST.COM                                      #
  # EDW_APPS_TO_WH.US.ORACLE.COM                                      #
  # SA0252                                                            #
  # sanjay said these are for testing and to ignore them.             #
  #####################################################################

  #####################################################################
  # Doc_id: 1623879.1 Section 29                                      #
  #      Re-create grants and synonyms                                #
  #####################################################################   
  #                                                                   #
  # Oracle Database 11g Release 2 (11.2) contains new                 #
  # functionality for grants and synonyms compared to previous        #        
  # database releases. As a result, you must re-create the            #   
  # grants and synonyms in the APPS schema. On the administration     #         
  # server node, as the owner of the Applications file system,        #     
  # run AD Administration and select the "Recreate grants and         #   
  # synonyms for APPS schema" task from the Maintain Applications     #      
  # Database Objects menu.                                            #
  #####################################################################   

cookbook_file "#{binapp}/chk_adadmin.pl" do
  owner appuser
  group appgroup
  mode '0755'
end

rspf="adadmin.rsp"
tgtf="#{node[:ebs][:app][:runbase]}/appl/admin/#{sid}/#{rspf}"

template "#{tgtf}" do
  source "adadmin.rsp.erb"
  owner appuser
  group appgroup
  mode '0755'
end


fpcmd="#{fs1base}/appl/ad/12.0.0/bin/adadmin"
outfile="#{outapp}/out.#{rspf}"
respfile="#{node[:ebs][:app][:runbase]}/appl/admin/#{sid}/#{rspf}"
logfile="#{node[:ebs][:vg][:app_fs_nam]}/fs_ne/inst/"\
        "#{node[:ebs][:sid_hname]}/logs/appl/conc/log/ADUtilityName.log"
touchf="#{outapp}/t.#{sqlf}.passed"

  #################################################
  # logfile doesnt refresh between runs.
  #
execute "run #{rspf}to_update_stats" do
  user          appuser
  group         appgroup
  environment ( appenv )
  command <<-EOF
     . #{ENVFS1}
     rm -f #{logfile}
     #{fpcmd} defaultsfile=#{respfile} interactive=n workers=5 \
         menu_option=CREATE_GRANTS restart=y > #{outfile} 2>&1
  EOF
  creates  "#{touchf}"
end

execute "Check_for_success_msgs_in_#{outfile}" do
  user          appuser
  group         appgroup
  environment ( appenv )
  command "#{binapp}/chk_adadmin.pl -f #{outfile} && "\
          "touch   #{touchf}"
  creates  "#{touchf}"
end

  #####################################################################
  # Doc_id: 1623879.1 Section 30                                      #
  #      Restart Applications server processes                        #
  #####################################################################   
  #                                                                   #
  # Restart all the Application tier server processes that you shut   #
  # down previously. Remember that the Oracle Net listener for the    #
  # database instance, as well as the database instance itself,       #
  # need to be started in the 11.2 Oracle home. Users may return      #
  # to the system.                                                    #
  #####################################################################   
  # Action: We ignore this option  for now as we are going to         #
  # continue patching, and will wait until required by patches.       #
  #####################################################################   


  #####################################################################
  # Doc_id: 1623879.1 Section 31                                      #
  #      Synchronize Workflow views                                   #
  #####################################################################   
  #                                                                   #
  # Log onto Oracle E-Business Suite with the "System Administrator"  #
  # responsibility. Click Requests > Run > Single Request and the     #
  # OK button. Enter the following parameters:                        #
  #                                                                   #
  # Request Name = Workflow Directory Services User/Role Validation   #
  # Batch Size = 10000                                                #
  # Fix dangling users = Yes                                          #
  # Add missing user/role assignments = Yes                           #
  # Update WHO columns in WF tables = No                              #
  # Click "OK" and "Submit".                                          #
  #####################################################################   
  # Action: Use this step as final test of correct install. Wait      #
  #####################################################################   

