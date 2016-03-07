log '
     ***************************************
     *                                     *
     *        EBS Recipe:fmw_web           *
     *                                     *
     ***************************************
    '

  ########################################################
  # attributs accessed:
  #########################################################

appuser      = node[:ebs_appuser]
appgroup     = node[:ebs_appgroup]
fs1base      = node[:ebs][:app][:runbase]
fs2base      = node[:ebs][:app][:patchhome]
ENVFS1       = node[:ebs][:app][:FS1ENVF]
ENVFS2       = node[:ebs][:app][:FS2ENVF]
ENVDB        = node[:ebs][:db][:DBENVF]
binapp       = node[:ebs][:app][:bin]
resp_file    = "#{binapp}/ocm.rsp"

fmwhome    =node[:ebs][:app][:fmw][:home]
     opatch="#{fmwhome}/OPatch"
orig_opatch="#{fmwhome}/OPatch.orig"
execute "save_fmw_opatch" do
  user  appuser
  group appgroup
  cwd   fmwhome
  command "mv #{opatch} #{orig_opatch}"
  not_if { File.directory?( orig_opatch ) }
end

  target=fmwhome
patchpat=node[:ebs][:stage][:fmw][:opatchn]
execute "unzip_#{patchpat}" do
  user    appuser
  group   appgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{binapp}/getpatch.sh -p #{patchpat} -t #{target}\n"
  not_if { File.directory?( "#{target}/OPatch" ) }
end

target= node[:ebs][:seedTable][:patchdir]
node[:ebs][:stage][:fmw][:patches].each do |patchn|
  execute "unzip_#{patchn}" do
    user    appuser
    group   appgroup
    cwd     node[:ebs][:stage][:zips]
    command "#{binapp}/getpatch.sh -p #{patchn} -t #{target}\n"
    not_if { File.directory?( "#{target}/#{patchn}" ) }
  end

  log "Patching #{patchn}"
  log "export ORACLE_HOME=#{fmwhome};#{fmwhome}/OPatch/opatch lsinventory|fgrep #{patchn}|fgrep applied"

  script "ksh_apply_patch_for_fmwweb_#{patchn}" do
    interpreter "ksh"
    user  appuser
    group appgroup
    cwd "#{target}/#{patchn}"
    code <<-EOH 
      export ORACLE_HOME=#{fmwhome};
      export PATH="#{fmwhome}/OPatch:$PATH";
      #{fmwhome}/OPatch/opatch apply -jre $ORACLE_HOME/jdk/jre \
            -silent -ocmrf #{resp_file}
    EOH
    not_if "export ORACLE_HOME=#{fmwhome}; "\
           "#{fmwhome}/OPatch/opatch lsinventory | "\
           "fgrep #{patchn} | fgrep applied",
           :user => appuser, :group => appgroup
  end
end

