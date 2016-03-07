log '
     **********************************************
     *                                            *
     *        EBS Recipe:dbms_upg1                *
     *                                            *
     **********************************************
    '

  #########################################################
  # attributs accessed:
  #########################################################

template_file  = "#{node[:ebs][:db][:bin]}/11204_template.rsp"
install_dir    =    node[:ebs][:db][:orahome4]
binaries       =    node[:ebs][:stage][:bin_11204]
patches        =    node[:ebs][:stage][:pat_11204]
dbowner        =    node[:ebs_dbuser]
dbgroup        =    node[:ebs_dbgroup]
orahome        =    node[:ebs][:db][:orahome4]
rootgroup      =    node[:root_group]
sid            =    node[:ebs][:db][:sid]
hname          =    node[:hostname]
bindb          =    node[:ebs][:db][:bin]
appuser        =    node[:ebs_appuser]
appgroup       =    node[:ebs_appgroup]
binapp         =    node[:ebs][:app][:bin]
outapp         =    node[:ebs][:app][:outdir]


  #########################################################
  # Going to need a silent install template
  # lets grab the one from the manual install and use it.
  #########################################################

template "#{bindb}/getpatch.sh" do
  owner dbowner
  group dbgroup
  mode '0755'
end

template "#{binapp}/getpatch.sh" do
  owner appuser
  group appgroup
  mode '0755'
end

template "#{bindb}/11204_template.rsp" do
  owner dbowner
  group dbgroup
  source '11.2.0.4.rsp.erb'
  mode '0775'
end

template "#{bindb}/dbms_upgrade.sh" do
  source "dbms_upgrade.sh.erb"
  owner dbowner
  group dbgroup
  mode '0755'
end

template "#{bindb}/chk_upgrade.pl" do
  owner dbowner
  group dbgroup
  mode '0755'
end

template "#{bindb}/dbua.sh" do
  owner dbowner
  group dbgroup
  mode '0755'
end

cookbook_file "#{bindb}/dbua_chk.pl" do
  owner dbowner
  group dbgroup
  mode '0755'
end

cookbook_file "#{bindb}/ocm.rsp" do
  owner dbowner
  group dbgroup
  mode '0755'
end

cookbook_file "#{binapp}/ocm.rsp" do
  owner dbowner
  group dbgroup
  mode '0755'
end

directory "#{node[:ebs][:dbm_patchdir]}" do
  owner dbowner
  group dbgroup
  mode '0775'
  action :create
end

directory "#{node[:ebs][:etcc][:rundir]}" do
  owner dbowner
  group dbgroup
  mode '0775'
  action :create
end

directory "#{install_dir}/admin/#{sid}_#{hname}" do
  owner dbowner
  group dbgroup
  mode '0775'
  action :create
  recursive true
end

template "#{binapp}/adopHpatch.sh" do
  source 'adopHpatch.sh.erb'
  owner appuser
  group appgroup
  mode '770'
end

