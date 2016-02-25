log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:DOC1983050_Section5      *'
log '*                                            *'
log '**********************************************'


  #########################################################
  # attributs accessed:
  #########################################################

dbuser       = node[:ebs_dbuser]
dbgroup      = node[:ebs_dbgroup]
dbenv        = node[:ebs][:db][:env_11204]
outapp       = node[:ebs][:app][:outdir]
appuser      = node[:ebs_appuser]
appgroup     = node[:ebs_appgroup]
appenv       = node[:ebs][:app][:env]
bindb        = node[:ebs][:db][:bin]
binapp       = node[:ebs][:app][:bin]


directory node[:ebs][:seedTable][:patchdir] do
  owner appuser
  group appgroup
  mode '0775'
  action :create
end

log '#-----------------------------------------#'
log '# Doc_ID_1983050.1_Section5 is Upgrading  #'
log '# Consolidated Seed Table                 #'
log '# Patches came from Doc_ID: 1594274.1     #'
log '#-----------------------------------------#'

execute "Section5_startdb" do
  user          dbuser
  group         dbgroup
  environment ( dbenv )
  command "#{bindb}/startdb.sh"
end
  
execute "#{binapp}/startwls.sh" do
  user          appuser
  group         appgroup
  environment ( appenv  )
end

log '***************************************************'
log '*                                                 *'
log '* Consolidated_SeedPatchTable_Upgrade Waiting...  *'
log '* (30-60 minutes)                                 *'
log '*                                                 *'
log '***************************************************'

#unpack the patch
patchn=node[:ebs][:seedTable][:patchnum]
target= node[:ebs][:seedTable][:patchdir]
log "#{binapp}/getpatch.sh -p #{patchn} -t #{target}\n"
execute "unzip_#{patchn}" do
  user    appuser
  group   appgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{binapp}/getpatch.sh -p #{patchn} -t #{target}\n"
  not_if { File.directory?( "#{target}/#{patchn}" ) }
end

  ############################################
  # Consolidated_SeedPatchTable_Upgrade Step
  #
log "su - #{appuser} -c #{appuser}@#{node[:hostname]} '#{binapp}/adopHpatch.sh -p #{patchn} -x'"
execute "adopHpatch_#{patchn}" do
   user  'root'
   command "su - #{appuser} -c "\
           "'#{binapp}/adopHpatch.sh -p #{patchn} -x && "\
          "touch #{outapp}/t.seedpatch'"
  creates       "#{outapp}/t.seedpatch"
end
  
execute "#{binapp}/stopwls.sh" do
  user  appuser
  group appgroup
  environment ( appenv )
end

execute "wait_90_seconds2" do
  command "sleep 90"
end
  
execute "Section5_stopdb" do
  user          dbuser
  group         dbgroup
  environment ( dbenv )
  command "#{bindb}/stopdb.sh"
end

