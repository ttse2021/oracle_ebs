log '**********************************************
     *                                            *
     *        EBS Recipe:kernel_etchosts          *
     *                                            *
     **********************************************
    '

# get the machine host, ipaddress and fully qualified domain name fqdn

bindb          =    node[:ebs][:db][:bin]
outdb          =    node[:ebs][:db][:outdir]

cookbook_file "#{bindb}/chk_hosts.pl" do
  owner node[:ebs_dbuser]
  group node[:ebs_dbgroup]
  mode '0755'
  source 'chk_hosts.pl'
end

execute "Check_that_etc_hosts_is_valid" do
  user  'root'
  group node[:root_group]
  command "perl #{bindb}/chk_hosts.pl > #{outdb}/out.chk_hosts 2>&1 && "\
                "touch #{outdb}/t.chk_hosts"
   creates            "#{outdb}/t.chk_hosts"
end

