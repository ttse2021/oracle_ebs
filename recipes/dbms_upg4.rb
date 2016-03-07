log '
     **********************************************
     *                                            *
     *        EBS Recipe:dbms_upg4                *
     *                                            *
     **********************************************
    '


dbowner = node[:ebs_dbuser]
dbgroup = node[:ebs_dbgroup]
dbhome  = node[:ebs][:db][:usr][:homedir]
dbenv   = node[:ebs][:db][:env_11204]

  #######################################
  # FIRST TIME WE ARE BOOTING UP 11204
  #
  #
execute "Start_the_DBMS_in_upgrade_mode" do
  user  dbowner
  group dbgroup
  cwd   dbhome
  environment ( dbenv )
  command "ksh #{node[:ebs][:db][:bin]}/dbms_upgrade.sh > "\
              "#{node[:ebs][:db][:outdir]}/out.dbms_upgrade 2>&1"
end

execute "Check_the_DBMS_start_for_errors" do
  user  dbowner
  group dbgroup
  cwd   dbhome
  environment ( dbenv )
  command "#{node[:ebs][:db][:bin]}/chk_upgrade.pl -f #{node[:ebs][:db][:outdir]}/out.dbms_upgrade"
end


  #####################################################################
  # Doc_id: 1623879.1 Section 13                                      #
  #    Upgrade the database Instance.                                 #
  #   Note: I also downloaded the Pre-Upgrade Information Tool        #
  #       ran it. Came back clean. with no need to drop DMSYS schema  #
  #####################################################################

execute "UPGRADE_OF_THE_11204_DBMS" do
  user  dbowner
  group dbgroup
  environment ( dbenv )
  command "ksh #{node[:ebs][:db][:bin]}/dbua.sh > #{node[:ebs][:db][:outdir]}/out.dbua 2>&1"
  creates         "#{node[:ebs][:db][:outdir]}/t.done.dbua"
end

execute "Check_if_the_dbua_was_successful" do
  user  dbowner
  group dbgroup
  environment ( dbenv )
  command "#{node[:ebs][:db][:bin]}/dbua_chk.pl -f #{node[:ebs][:db][:outdir]}/out.dbua && "\
            "touch #{node[:ebs][:db][:outdir]}/t.done.dbua"
  creates         "#{node[:ebs][:db][:outdir]}/t.done.dbua"
end

execute "Stop_the_DBMS_afterwards" do
  user  dbowner
  group dbgroup
  cwd   dbhome
  environment ( dbenv )
  command "ksh #{node[:ebs][:db][:bin]}/stopdb.sh"
end

