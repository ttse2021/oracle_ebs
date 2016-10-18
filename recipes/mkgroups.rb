log '
     ***************************************
     *                                     *
     *        EBS Recipe:mkgroups          *
     *                                     *
     ***************************************
    '


dbgrp = node[:ebs][:db][:usr][:pgrp] # Get db primary user group
group "Set_group_#{dbgrp}_for_db_user" do
  action :create
  group_name dbgrp
  gid  node[:ebs][:db][:usr][:pgid]
end

appgrp = node[:ebs][:app][:usr][:pgrp] # Get app primary user group
group "Set_group_#{appgrp}_for_appuser" do
  action :create
  group_name appgrp
  gid  node[:ebs][:app][:usr][:pgid]
end

node[:ebs][:ogrps][:grps].each do |ogroup|
  group "Set_group_#{ogroup}" do
    action :create
    group_name ogroup
    gid  node[:ebs][:ogrps]["#{ogroup}"][:gid]
  end
end

