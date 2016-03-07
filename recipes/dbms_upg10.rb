log '
     **********************************************
     *                                            *
     *        EBS Recipe:dbms_upg10               *
     *                                            *
     **********************************************
    '

  #########################################################
  # attributs accessed:
  #########################################################

dbuser   = node[:ebs_dbuser]
dbgroup  = node[:ebs_dbgroup]
dbenv    = node[:ebs][:db][:env_11204]
bindb    = node[:ebs][:db][:bin]
outdb    = node[:ebs][:db][:outdir]

  #####################################################################
  # Doc_id: 1594274.1 Section 2                                       #
  #    EBS Technology Codelevel Checker                               #
  ##################################################################### 
  #this step actually occurs many places. we apply the check here     #
  #after we believe the dbms is fully installed.                      #
  ##################################################################### 


patchnum=node[:ebs][:etcc][:patchn]
  target=node[:ebs][:etcc][:rundir]
execute "unzip_#{patchnum}" do
  user    dbuser
  group   dbgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{bindb}/getpatch.sh -p #{patchnum} -t #{target}\n"
  not_if { File.directory?( "#{target}/#{patchnum}" ) }
end

template "#{bindb}/etcc_db.sh" do
  source 'etcc_db.sh.erb'
  owner dbuser
  group dbgroup
  mode '0775'
end

execute "run_etcc_check_on_dbms" do
  user  node[:ebs_dbuser]
  group node[:ebs_dbgroup]
  environment (dbenv)
  command "#{bindb}/etcc_db.sh"
  creates "#{outdb}/out.etcc_db"
end

