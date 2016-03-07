log '
     *************************************
     *                                   *
     *        EBS Recipe:oratab          *
     *                                   *
     *************************************
    '

myowner        = node[:ebs_dbuser]
mygroup        = node[:ebs_dbgroup]

template '/etc/oratab' do
  source 'oratab.erb'
  owner   myowner
  group   mygroup
  mode '0755'
  action :create_if_missing
end


