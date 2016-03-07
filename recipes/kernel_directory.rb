log '
     **********************************************
     *                                            *
     *        EBS Recipe:kernel_directory         *
     *                                            *
     **********************************************
    '


directory "Create_the_database_directory_#{node[:ebs][:vg][:db_fs_nam]}" do
  path node[:ebs][:vg][:db_fs_nam]
  mode '0770'
  action :create
end

directory node[:ebs][:db][:bin] do
  mode '0777'
  action :create
end

directory node[:ebs][:app][:bin] do
  mode '0777'
  action :create
end

directory node[:ebs][:app][:outdir] do
  mode '0777'
  action :create
end

