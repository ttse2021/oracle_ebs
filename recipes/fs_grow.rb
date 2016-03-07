log '
     *************************************
     *                                   *
     *        EBS Recipe:fs_grow         *
     *                                   *
     *************************************
    '


  # Expand /tmp to Gigs in size
  #
gigs=node[:ebs][:vg][:tmp_fs_siz]
execute "expand_/tmp_#{gigs}G" do
  user 'root'
  group node[:root_group]
  command "/usr/sbin/chfs -a size=#{gigs}G /tmp"
  only_if "lsfs | fgrep /tmp | "\
          "perl -an -e '$GG=$F[4]/(1024*1024*2); exit ($GG >= #{gigs})'"
end

  # Expand /opt to Gigs in size
  #
gigs=node[:ebs][:vg][:opt_fs_siz]
execute "expand_/opt_to_#{gigs}G" do
  user 'root'
  group node[:root_group]
  command "/usr/sbin/chfs -a size=#{gigs}G /opt"
  only_if "lsfs | fgrep /opt | "\
          "perl -an -e '$GG=$F[4]/(1024*1024*2); exit ($GG >= #{gigs})'"
end
