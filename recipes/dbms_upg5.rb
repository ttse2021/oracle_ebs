log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:dbms_upg5                *'
log '*                                            *'
log '**********************************************'


  #########################################################
  # attributs accessed:
  #########################################################

dbowner   = node[:ebs_dbuser]
dbgroup   = node[:ebs_dbgroup]
dbbin     = node[:ebs][:db][:bin]
dbhome    = node[:ebs][:db][:usr][:homedir]
dbenv     = node[:ebs][:db][:env_11204]
ora_home  = node[:ebs][:db][:orahome4]
sid       = node[:ebs][:db][:sid]
hname     = node[:hostname]


  #####################################################################
  # Doc_id: 1623879.1 Section 2                                       #
  #    Update application tier context file with new                  #
  #    database listener port number (conditional)                    #
  #####################################################################

template "#{dbbin}/fix_initora.sh" do
  source "fix_initora.sh.erb"
  owner dbowner
  group dbgroup
  mode '0755'
end

cookbook_file "#{dbbin}/initparms.sql" do
  owner dbowner
  group dbgroup
  mode '0755'
end

  #####################################################################
  # Doc_id: 1623879.1 Section 14                                      #
  #    Modify initialization parameters                               #
  #####################################################################

# modify directory locations within init.ora file
execute "Update_initora_with_new_dir_path.sh" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  cwd           "#{ora_home}/dbs"
  command "#{dbbin}/fix_initora.sh > #{node[:ebs][:db][:outdir]}/out.initora 2>&1"
end

