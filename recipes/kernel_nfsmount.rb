log '
     **********************************************
     *                                            *
     *        EBS Recipe:kernel_nfsmount          *
     *                                            *
     **********************************************
    '




if node[:ebs][:stage][:is_nfsmount]
  directory node[:ebs][:stage][:nfsmount] do
   owner 'root'
   group node[:root_group]
  end
  
    # chef mount doesnt allow adding to filesystem, so do it manually
  execute "mknfsmnt_for_#{node[:ebs][:stage][:nfsmount]}" do
    user 'root'
    group node[:root_group]
    command "/usr/sbin/mknfsmnt -f #{node[:ebs][:stage][:nfsmount]} "\
              "-d #{node[:ebs][:stage][:nfsmount]} "\
              "-h #{node[:ebs][:stage][:nfshost]} "\
              "-M sys -B -A -t rw -w fg -b 32768 -c 32768 "\
              "-o 600 -K 3 -k tcp -H -e -j -q -g"
    not_if "fgrep #{node[:ebs][:stage][:nfsmount]} /etc/filesystems > /dev/null 2>&1"
  end
end  

log "#{node[:ebs][:stage][:rapiddir]}"
execute "chef_if_stage_directory_is_there" do
  user 'root'
  group node[:root_group]
  command 'echo "Staging dir not found" ; exit -1; '
  not_if { File.directory?( "#{node[:ebs][:stage][:rapiddir]}" ) }
end

