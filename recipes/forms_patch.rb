log '
     **********************************************
     *                                            *
     *        EBS Recipe:forms_patch              *
     *                                            *
     **********************************************
    '


  #########################################################
  # attributs accessed:
  #########################################################

app_home     = node[:ebs][:app][:runbase]
appuser      = node[:ebs_appuser]
appgroup     = node[:ebs_appgroup]
fs1base      = node[:ebs][:app][:runbase]
fs2base      = node[:ebs][:app][:patchhome]
ENVFS1       = node[:ebs][:app][:FS1ENVF]
formshome    = node[:ebs][:app][:runhome]
formstage    = node[:ebs][:forms][:patchsrc]
binapp       = node[:ebs][:app][:bin]
outapp       = node[:ebs][:app][:outdir]
resp_file    = "#{binapp}/ocm.rsp"


     opatch="#{formshome}/OPatch"
orig_opatch="#{formshome}/OPatch.orig"
execute "save_forms_opatch" do
  user  appuser
  group appgroup
  cwd   formshome
  command "mv #{opatch} #{orig_opatch}"
  not_if { File.directory?( orig_opatch ) }
end

  target=formshome
patchpat=node[:ebs][:forms][:opatchn]
execute "unzip_#{patchpat}" do
  user    appuser
  group   appgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{binapp}/getpatch.sh -p #{patchpat} -t #{target}\n"
  not_if { File.directory?( "#{target}/OPatch" ) }
end

target=node[:ebs][:seedTable][:patchdir]
node[:ebs][:forms][:patches].each do |patchnum|
  execute "unzip_#{patchnum}" do
    user    appuser
    group   appgroup
    cwd     node[:ebs][:stage][:zips]
    command "#{binapp}/getpatch.sh -p #{patchnum} -t #{target}\n"
    not_if { File.directory?( "#{target}/#{patchnum}" ) }
  end

  script "ksh_apply_patch_for_forms_#{patchnum}" do
    interpreter "ksh"
    user  appuser
    group appgroup
    cwd   target
    code <<-EOH 
      . "#{ENVFS1}"
      #{formshome}/OPatch/opatch napply #{target} -id #{patchnum} \
            -silent -ocmrf #{resp_file}
    EOH
    not_if ". #{ENVFS1}; "\
           "#{formshome}/OPatch/opatch lsinventory | "\
           "fgrep #{patchnum} | fgrep applied",
           :user => appuser, :group => appgroup
  end
end

