log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:etcc                     *'
log '*                                            *'
log '**********************************************'

appusr       = node[:ebs_appuser]
appgrp       = node[:ebs_appgroup]
appenv       = node[:ebs][:app][:env]

template "#{node[:ebs][:app][:bin]}/etcc_app.sh" do
  source 'etcc_app.sh.erb'
  owner appusr
  group appgrp
  mode '0775'
end

execute "run_etcc_check_on_app" do
  user  appusr
  group appgrp
  environment ( appenv )
  command "#{node[:ebs][:app][:bin]}/etcc_app.sh"
  creates "#{node[:ebs][:app][:outdir]}/out.etcc_app"
end


