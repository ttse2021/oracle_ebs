log '
     **********************************************
     *                                            *
     *        EBS Recipe:directory_creation       *
     *                                            *
     **********************************************
    '


appuser        =    node[:ebs_appuser]
appgroup       =    node[:ebs_appgroup]
binapp         =    node[:ebs][:app][:bin]
outapp         =    node[:ebs][:app][:outdir]
dbuser         =    node[:ebs_dbuser]
dbgroup        =    node[:ebs_dbgroup]
bindb          =    node[:ebs][:db][:bin]
outdb          =    node[:ebs][:db][:outdir]
rootgroup      =    node[:root_group]
oraInventory   =    node[:ebs][:db][:oraInv]
ora_base       =    node[:ebs][:db][:orabase]
db_fs          =    node[:ebs][:vg][:db_fs_nam]
app_fs         =    node[:ebs][:vg][:app_fs_nam]


  # Curious whether chef remodifes the next three directories
  # they were already created but owned by root. Lets change that.
  #
directory "Change_ownership_of_#{db_fs}" do
  path  db_fs
  owner dbuser
  group dbgroup
  mode '0775'
  action :create
end

directory "Change_ownership_of_#{outapp}" do
  path outapp
  owner appuser
  group appgroup
  mode '0755'
  action :create
end

directory "Change_ownership_of_#{outdb}" do
  path outdb
  owner dbuser
  group dbgroup
  mode '0755'
  action :create
end


  # the rest are needed by EBS.


template "#{binapp}/funs" do
  source 'funs.erb'
  owner appuser
  group appgroup
  mode '770'
end

template "#{bindb}/funs" do
  source 'funs.erb'
  owner dbuser
  group dbgroup
  mode '770'
end

template "#{bindb}/chk_prereqs.sh" do
  source 'chk_prereqs.sh.erb'
  owner 'root'
  group rootgroup
  mode '770'
end

template "#{binapp}/startapp.sh" do
  source 'startapp.sh.erb'
  owner appuser
  group appgroup
  mode '770'
end

template "#{binapp}/stopapp.sh" do
  source 'stopapp.sh.erb'
  owner appuser
  group appgroup
  mode '770'
end

template "#{bindb}/rapidstart.sh" do
  source 'rapidstart.sh.erb'
  owner 'root'
  group rootgroup
  mode '770'
end

cookbook_file "#{bindb}/stopdb.sh" do
  owner dbuser
  group dbgroup
  mode '0755'
end

cookbook_file "#{bindb}/startdb.sh" do
  owner dbuser
  group dbgroup
  mode '0755'
end

#template "#{bindb}/startdb.sh" do
#  source 'startdb.sh.erb'
#  owner dbuser
#  group dbgroup
#  mode '770'
#end
#
#template "#{bindb}/stopdb.sh" do
#  source 'stopdb.sh.erb'
#  owner dbuser
#  group dbgroup
#  mode '770'
#end

template "#{binapp}/startwls.sh" do
  source 'startwls.sh.erb'
  owner appuser
  group appgroup
  mode '0755'
end

template "#{binapp}/stopwls.sh" do
  source 'stopwls.sh.erb'
  owner appuser
  group appgroup
  mode '770'
end

file "/etc/oraInst.loc" do
  owner dbuser
  group dbgroup
  content "inst_group=#{dbgroup}\ninventory_loc=#{db_fs}/oraInventory\n"
end

directory oraInventory do
  owner dbuser
  group dbgroup
  mode '0770'
  recursive true
  action :create
end

directory db_fs do
  owner dbuser
  group dbgroup
  mode '0770'
  recursive true
  action :create
end

directory app_fs do
  owner appuser
  group appgroup
  mode '0770'
  recursive true
  action :create
end

directory ora_base do
  owner dbuser
  group dbgroup
  mode '0770'
  recursive true
  action :create
end

