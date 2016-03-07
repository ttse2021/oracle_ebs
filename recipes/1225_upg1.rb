
log '
     **********************************************
     *                                            *
     *        EBS Recipe:1225_upg1                *
     *                                            *
     **********************************************
   '

appuser     =  node[:ebs_appuser]
appgroup    =  node[:ebs_appgroup]
appenv      =  node[:ebs][:app][:env]
binapp      =  node[:ebs][:app][:bin]
outapp      =  node[:ebs][:app][:outdir]
patchtop    =  node[:ebs][:seedTable][:patchdir]


  #####################################################################
  # Doc_id: 1983050.1 Section 7                                       #
  #    Perform 12.2.5 Pre-Update Steps (Conditional)                  #
  ##################################################################### 
  # Perform the following pre-update steps only if you have           #
  # licensed this product:                                            #
  #     Supply Chain Management tasks:                                #
  ##################################################################### 
  #     N/A - does not apply to us.                                   #
  ##################################################################### 


  #####################################################################
  # Doc_id: 1983050.1 Section 8.1                                     #
  # New Installation upgrading to EBS 12.2.5 Release Update Pack      #
  ##################################################################### 
  # . <INSTALL_BASE>/EBSapps.env run
  # stopwls
  # adop phase=apply apply_mode=downtime patches=19676458 
  # 
  # 
  ##################################################################### 
  #     N/A - does not apply to us.                                   #
  ##################################################################### 



  #-----------------------------------------#
  # Doc_ID_1983050.1_Section8.1 step2       #
  # Shutdown wls                            #
  #-----------------------------------------#

execute "1983050.1_Section8.1_stopwls" do
  user          appuser
  group         appgroup
  environment ( appenv  )
  command "#{binapp}/stopwls.sh"
end


template "#{binapp}/1225_patch.sh" do
  source '1225_patch.sh.erb'
  user  appuser
  group appgroup
  mode '0775'
end

  # unpack the 12.2.5 patch
  #
patchn=node[:ebs][:patch1225]
execute "unzip_#{patchn}" do
  user    appuser
  group   appgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{binapp}/getpatch.sh -p #{patchn} -t #{patchtop}\n"
  not_if { File.directory?( "#{patchtop}/#{patchn}" ) }
end

log '
     ***************************************************
     * Applying 12.2.5 patch   Takes over 4-12 hours   *
     ***************************************************
    '

execute "apply_1225_patch_now" do
  user  'root'
  timeout 86400 #24 hours
  command "su - #{appuser} -c "\
          "'#{binapp}/1225_patch.sh > #{outapp}/out.1225_patch 2>&1 && "\
          "touch #{outapp}/t.1225_patch'"
  creates       "#{outapp}/t.1225_patch"
end

  #####################################################################
  # Doc_id: 1983050.1 Section 8.1 Step4                               #
  # start up the app server                                           #
  ##################################################################### 

execute "start_the_app_server_after_1225patch" do
  user          appuser
  group         appgroup
  environment ( appenv  )
  command "#{binapp}/startapp.sh"
end

log '
     ***************************************************
     * Applying 12.2.5 cleanup takes 10 minutes        *
     ***************************************************
    '

template "#{binapp}/1225_cleanup.sh" do
  source '1225_cleanup.sh.erb'
  user  appuser
  group appgroup
  mode '0775'
end

execute "apply_1225_cleanup" do
  user  'root'
  command "su - #{appuser} -c "\
          "'cd #{patchtop} && #{binapp}/1225_cleanup.sh > #{outapp}/out.1225_cleanup 2>&1 "\
          "&& touch #{outapp}/t.1225_cleanup'"
  creates          "#{outapp}/t.1225_cleanup"
end

execute "stop_the_app_server_before_clone_step" do
  user          appuser
  group         appgroup
  environment ( appenv  )
  command "#{binapp}/stopapp.sh"
end

template "#{binapp}/1225_clone.sh" do
  source '1225_clone.sh.erb'
  user  appuser
  group appgroup
  mode '0775'
end

log '
     ***************************************************
     * Applying 12.2.5 clone   takes 90 minutes        *
     ***************************************************
    '

execute "apply_1225_clone" do
  user  'root'
  command "su - #{appuser} -c "\
          "'cd #{patchtop} && #{binapp}/1225_clone.sh > #{outapp}/out.1225_clone 2>&1 "\
          "&& touch #{outapp}/t.1225_clone'"
  creates          "#{outapp}/t.1225_clone"
  timeout 18000
end

