log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:1225_upg3                *'
log '*                                            *'
log '**********************************************'

appuser     =  node[:ebs_appuser]
appgroup    =  node[:ebs_appgroup]
appenv      =  node[:ebs][:app][:env]
binapp      =  node[:ebs][:app][:bin]
outapp      =  node[:ebs][:app][:outdir]
patchtop    =  node[:ebs][:seedTable][:patchdir]
dbenv       = node[:ebs][:db][:env_11203]
bindb       = node[:ebs][:db][:bin]
dbmuser     = node[:ebs_dbuser]
dbmgroup    = node[:ebs_dbgroup]


  #####################################################################
  # Doc_id: 1983050.1 Section 9 Step1                                 #
  # Apply Oracle E-Business Suite Release 12.2.5 Online Help          #
  ##################################################################### 
  #    adop phase=apply apply_mode=downtime patches=19676460          #
  ##################################################################### 


patchn=node[:ebs][:critical][:patch1]
target=node[:ebs][:seedTable][:patchdir]
log "#{binapp}/getpatch.sh -p #{patchn} -t #{target}\n"
execute "unzip_#{patchn}" do
  user    appuser
  group   appgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{binapp}/getpatch.sh -p #{patchn} -t #{target}\n"
  not_if { File.directory?( "#{target}/#{patchn}" ) }
end

template "#{binapp}/critical_patch.sh" do
  source 'critical_patch.sh.erb'
  user  appuser
  group appgroup
  mode '0775'
end

  log '***************************************************'
  log '* Applying Additional Critical Patch (10mins)     *'
  log '***************************************************'

execute "post_critical_patch_#{patchn}" do
  user  'root'
  command "su - #{appuser} -c "\
          "'cd #{patchtop} && #{binapp}/critical_patch.sh > #{outapp}/out.critical 2>&1 && "\
          "touch #{outapp}/t.post_critical'"
  creates       "#{outapp}/t.post_critical"
end

execute "stop_the_wls_server_after_critialpatch" do
  user          appuser
  group         appgroup
  environment ( appenv  )
  command "#{binapp}/stopwls.sh"
end

execute "#{bindb}/stopdb.sh" do
  user  dbmuser
  group dbmgroup
  environment ( dbenv )
end
