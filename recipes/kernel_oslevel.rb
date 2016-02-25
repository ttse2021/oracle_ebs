log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:kernel_oslevel           *'
log '*                                            *'
log '**********************************************'


cookbook_file "#{node[:ebs][:db][:bin]}/kernel_oslevel.pl" do
  user 'root'
  group node[:root_group]
  mode '0775'
  source 'kernel_oslevel.pl'
end

execute "kernel_oslevel_check" do
  user 'root'
  group node[:root_group]
  command "#{node[:ebs][:db][:bin]}/kernel_oslevel.pl "\
            "-6 #{node[:ebs][:aix]['6.1'][:min_lvl]} "\
            "-7 #{node[:ebs][:aix]['7.1'][:min_lvl]} "
end

