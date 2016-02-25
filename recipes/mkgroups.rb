log '*                                            *'
log '*        EBS Recipe:kernel_mkgroups          *'
log '*                                            *'
log '**********************************************'


mygrp = node[:ebs][:db][:usr][:pgrp] # Get db primary user group
group "Set_group_#{mygrp}_for_db_user" do
  action :create
  group_name mygrp
  gid  node[:ebs][:db][:usr][:pgid]
end

mygrp = node[:ebs][:app][:usr][:pgrp] # Get app primary user group
group "Set_group_#{mygrp}_for_appuser" do
  action :create
  group_name mygrp
  gid  node[:ebs][:app][:usr][:pgid]
end

node[:ebs][:ogrps][:grps].each do |ogroup|
  group "Set_group_#{ogroup}" do
    action :create
    group_name ogroup
    gid  node[:ebs][:ogrps]["#{ogroup}"][:gid]
  end
end

