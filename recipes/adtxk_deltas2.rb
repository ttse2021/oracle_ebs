log '
     ******************************************* 
     *                                         * 
     *        EBS Recipe:adtxk_deltas2         * 
     *                                         * 
     ******************************************* 
    '


appuser        =    node[:ebs_appuser]
appgroup       =    node[:ebs_appgroup]
appenv         =    node[:ebs][:app][:env]
dbmuser        =    node[:ebs_dbuser]
dbmgroup       =    node[:ebs_dbgroup]
dbmenv         =    node[:ebs][:db][:env_11204]
binapp         =    node[:ebs][:app][:bin]
bindb          =    node[:ebs][:db][:bin]
outdbm         =    node[:ebs][:db][:outdir]
outapp         =    node[:ebs][:app][:outdir]
rootgroup      =    node[:root_group]
oraInventory   =    node[:ebs][:db][:oraInv]
ora_base       =    node[:ebs][:db][:orabase]
db_fs          =    node[:ebs][:vg][:db_fs_nam]
app_fs         =    node[:ebs][:vg][:app_fs_nam]
target         =    node[:ebs][:seedTable][:patchdir]

  #-----------------------------------------#
  # Doc_ID_1617461.1_Section3.1.2 Step4     #
  #   Reading R12.AD.C.Delta.7 Patch Notes  #
  # Patch 22123818 : Run admsi.pl follow    #
  # instructions. This done in              #
  # cp_adgrants.sh                          #
  #-----------------------------------------#

  #######################################################
  # Patch 22123818 says to create this DBMS directory
  #
directory "#{node[:ebs][:db][:orahome4]}/appsutil/admin" do
  owner dbmuser
  group dbmgroup
  mode '0775'
  action :create
end

  #---------------------------------------------------#
  # Doc_ID_1617461.1_Section3.1.2 step4               #
  #    Unzip AD patch1 as its adgrants needs grabbing #
  #---------------------------------------------------#
patch1=node[:ebs][:ad_patches][:patch1]
execute "unzip_#{patch1}" do
  user    appuser
  group   appgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{binapp}/getpatch.sh -p #{patch1} -t #{target}\n"
  not_if { File.directory?( "#{target}/#{patch1}" ) }
end

  #-----------------------------------------#
  # Doc_ID_1617461.1_Section3.1.2 step4     #
  #    Unzip AD patches                     #
  #-----------------------------------------#
patch2=node[:ebs][:ad_patches][:patch2]
execute "unzip_#{patch2}" do
  user    appuser
  group   appgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{binapp}/getpatch.sh -p #{patch2} -t #{target}\n"
  not_if { File.directory?( "#{target}/#{patch2}" ) }
end

#patch2 needed for this script
template "#{binapp}/cp_adgrant.sh" do
  source 'cp_adgrant.sh.erb'
  owner appuser
  group appgroup
  mode '0775'
end

execute "run_the_copy_of_adgrant.sql" do
  user   appuser
  group  appgroup
  environment ( appenv  )
  command "#{binapp}/cp_adgrant.sh"
  creates "#{node[:ebs][:db][:orahome4]}/appsutil/admin/adgrants.sql"
end

execute "chowner_of_adgrants_to_dbms_user" do
  user   'root'
  group  node[:root_group]
  command "chown #{dbmuser}:#{dbmgroup} #{node[:ebs][:db][:orahome4]}/appsutil/admin/adgrants.sql"
end

log '
     ***************************************************
     * Running latest adgrants.sql. takes 10 minutes   *
     ***************************************************
    '

execute "apply_adgrants_for_ad_txk" do
  user          dbmuser
  group         dbmgroup
  environment ( dbmenv ) 
  command "sqlplus /nolog  @#{node[:ebs][:db][:orahome4]}/appsutil/admin/adgrants.sql APPS"\
          " > #{outdbm}/out.applygrants 2>&1"
end

log '
     ***************************************************
     * Applying First AD patch.  Takes 10 minutes      *
     ***************************************************
    '

log "su - #{appuser} -c  #{appuser}@#{node[:hostname]} '#{binapp}/adopHpatch.sh -p #{patch1} -x'"
execute "adopHpatch_#{patch1}" do
   user  'root'
   command "su - #{appuser} -c "\
           "'#{binapp}/adopHpatch.sh -p #{patch1} -x && "\
          "touch #{outapp}/t.ad1patch'"
  creates       "#{outapp}/t.ad1patch"
end
  
log '
     ***************************************************
     * Applying Second AD patch.  Takes 10 minutes     *
     ***************************************************
    '

     # no -x option for this one.
log "su - #{appuser} -c  #{appuser}@#{node[:hostname]} '#{binapp}/adopHpatch.sh -p #{patch2}'"
execute "adopHpatch_#{patch2}" do
   user  'root'
   command "su - #{appuser} -c "\
           "'#{binapp}/adopHpatch.sh -p #{patch2} && "\
          "touch #{outapp}/t.ad2patch'"
  creates       "#{outapp}/t.ad2patch"
end
  
template "#{node[:ebs][:app][:bin]}/hpatch_txk.sh" do
  source 'hpatch_txk.sh.erb'
  owner appuser
  group appgroup
  mode '0775'
end

  #-----------------------------------------#
  # Doc_ID_1617461.1_Section3.1.2 step4     #
  #    Unzip TXK patches                    #
  #-----------------------------------------#
node[:ebs][:txk_patches][:patchlst].each do |tmppatch|
  log "#{binapp}/getpatch.sh -p #{tmppatch} -t #{target}\n"
  execute "unzip_#{tmppatch}" do
    user    appuser
    group   appgroup
    cwd     node[:ebs][:stage][:zips]
    command "#{binapp}/getpatch.sh -p #{tmppatch} -t #{target}\n"
    not_if { File.directory?( "#{target}/#{tmppatch}" ) }
  end
end

log '
     ***************************************************
     * Applying latest TSK patches   takes 10 minutes  *
     ***************************************************
    '

pat3=node[:ebs][:txk_patches][:patchlst][1]
log "#{node[:ebs][:app][:bin]}/hpatch_txk.sh > #{outapp}/out.txkpatches 2>&1"

execute "apply_txk_patches_next" do
  user  'root'
   command "su - #{appuser} -c "\
          "'#{node[:ebs][:app][:bin]}/hpatch_txk.sh > #{outapp}/out.hpatch_txk 2>&1 && "\
          "touch #{outapp}/t.hpatch_txk'"
  creates       "#{outapp}/t.hpatch_txk"
end

