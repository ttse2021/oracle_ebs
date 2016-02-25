log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:ocommon                  *'
log '*                                            *'
log '**********************************************'

  #########################################################
  # attributs accessed:
  #########################################################

appuser      = node[:ebs_appuser]
appgroup     = node[:ebs_appgroup]
appenv       = node[:ebs][:app][:env]
binapp       = node[:ebs][:app][:bin]
outapp       = node[:ebs][:app][:outdir]
ocommonstage = "#{node[:ebs][:stage][:ocommon][:opatch]}"
ocommonhome  = node[:ebs][:app][:ocommon][:home]
prev_opatch  = "#{ocommonhome}/OPatch.orig"
cur_opatch   = "#{ocommonhome}/OPatch"
resp_file    = "#{binapp}/ocm.rsp"


     opatch="#{ocommonhome}/OPatch"
orig_opatch="#{ocommonhome}/OPatch.orig"
execute "save_ocommon_opatch" do
  user  appuser
  group appgroup
  cwd   ocommonhome
  command "mv #{opatch} #{orig_opatch}"
  not_if { File.directory?( orig_opatch ) }
end

  target=ocommonhome
patchpat=node[:ebs][:stage][:ocommon][:opatchn]
execute "unzip_#{patchpat}" do
  user    appuser
  group   appgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{binapp}/getpatch.sh -p #{patchpat} -t #{target}\n"
  not_if { File.directory?( "#{target}/OPatch" ) }
end

target= node[:ebs][:seedTable][:patchdir]
node[:ebs][:stage][:ocommon][:patches].each do |patchn|

  patchnum=patchn.sub('/oui','');
  execute "unzip_#{patchnum}" do
    user    appuser
    group   appgroup
    cwd     node[:ebs][:stage][:zips]
    command "#{binapp}/getpatch.sh -p #{patchnum} -t #{target}\n"
    not_if { File.directory?( "#{target}/#{patchnum}" ) }
  end

  log "Patching #{patchnum}"
  script "ksh_apply_patch_for_ocommon_#{patchnum}" do
    interpreter "ksh"
    user  appuser
    group appgroup
    cwd "#{target}/#{patchn}"
    code <<-EOH 
      export ORACLE_HOME=#{ocommonhome};
      export PATH="#{ocommonhome}/OPatch:$PATH";
      cd "#{target}/#{patchn}"
      #{ocommonhome}/OPatch/opatch apply \
         -silent -ocmrf #{resp_file} > #{outapp}/t.#{patchnum} 2>&1
    EOH
    not_if "export ORACLE_HOME=#{ocommonhome}; "\
           "#{ocommonhome}/OPatch/opatch lsinventory | "\
           "fgrep #{patchnum} | fgrep applied",
           :user => appuser, :group => appgroup
  end
end

