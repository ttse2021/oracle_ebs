log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:dbms_11204_prep          *'
log '*                                            *'
log '**********************************************'


dbowner        = node[:ebs_dbuser]
dbgroup        = node[:ebs_dbgroup]
dbhome         = node[:ebs][:db][:usr][:homedir]
dbenv          = node[:ebs][:db][:env_11203]
bindb          = node[:ebs][:db][:bin]


# we cant mix 1123 and 1124 environments. Use 1123 until
# this file is created.
unless File.file?("#{bindb}/1124.env")
    ######################################################
    # need this for the fix and preparations
    #
  cookbook_file "#{node[:ebs][:db][:bin]}/grant_select.sh" do
    owner dbowner
    group dbgroup
    mode '0755'
  end
  
  cookbook_file "#{node[:ebs][:db][:bin]}/prep_drop_table.sh" do
    owner dbowner
    group dbgroup
    mode '0755'
  end
  
  
  ######################################################
  # startup  the dbms in 11.2.0.3
  #
  execute "startdb_for_fix" do
    user        dbowner
    group       dbgroup
    environment dbenv
    command "#{node[:ebs][:db][:bin]}/startdb.sh"
  end
  
  #########################################################
  # Doc_id: 1623879.1 Section 11
  #    Drop SYS.ENABLED$INDEXES (conditional)
  #########################################################
  execute "drop_table_sys.enabled$indexes" do
    user        dbowner
    group       dbgroup
    environment dbenv
    command "#{node[:ebs][:db][:bin]}/prep_drop_table.sh "\
              "> #{node[:ebs][:db][:outdir]}/out.prep_drop_table 2>&1"
    creates     "#{node[:ebs][:db][:outdir]}/out.prep_drop_table"
  end
  
  
  #########################################################
  #                                                       #
  # the 11.2.0.3 upgrade to 11.2.0.4 produces an issue.   #
  # the issue is described in Doc_ID: 1906873.1.          #
  # The fix I use is to grant the select prior to the     #
  # upgrade, rather than use the fix afterwards.          #
  #                                                       #
  #########################################################
  
  ######################################################
  # this fixes the failure of "Oracle Text" on the upgrade
  #
  execute "Grant_select to ctxsys" do
    user        dbowner
    group       dbgroup
    environment dbenv
    command "#{node[:ebs][:db][:bin]}/grant_select.sh "\
              "> #{node[:ebs][:db][:outdir]}/out.grant_select 2>&1"
    creates     "#{node[:ebs][:db][:outdir]}/out.grant_select"
  end
  
  ######################################################
  # we are done, stop the 11.2.0.3 dbms
  #
  execute "stop_dbms_to_fix_issue_2" do
    user        dbowner
    group       dbgroup
    environment dbenv
    command "#{node[:ebs][:db][:bin]}/stopdb.sh"
  end
end
