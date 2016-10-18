log '
     *****************************************
     *                                       *
     *        EBS Recipe:fs_filsys           *
     *                                       *
     *****************************************
    '
volgrp=node[:ebs][:vg][:vgname]
opts=node[:ebs][:vg][:fsopts]
DISKS=node[:ebs][:vg][:drives][node[:hostname]].join(" ")


  ##################################################################
  # If the file system doesnt exist then create
  #
FSdb=node[:ebs][:vg][:db_fs_nam]
lvnam=node[:ebs][:vg][:lv01][:lvname]

unless system("lsfs #{FSdb} > /dev/null 2>&1")

    # striping typically is better performance. So make a striped log volume
    #
  gigsiz = node[:ebs][:vg][:db_fs_siz].to_i  * node[:ebs][:vg][:pp_per_gig].to_i
  execute "make_logvolume_#{lvnam}" do
    user 'root'
    group node[:root_group]
#    command "mklv -y#{lvnam} -tjfs2 #{volgrp} #{gigsiz}  #{DISKS}"
    command "mklv -y#{lvnam} -tjfs2 -S128K #{volgrp} #{gigsiz}  #{DISKS}"
    not_if "lsvg -l #{volgrp} | fgrep #{lvnam} > /dev/null 2>&1"
  end
  
    ##################################################################
    # This section creates the FS file system, using the stripped lv.
    #
  
  execute "make_FS_#{FSdb}" do
    user 'root'
    group node[:root_group]
    command "/usr/sbin/crfs -v jfs2 -d#{lvnam} -m#{FSdb}  #{opts}"
    not_if "lsfs | fgrep #{FSdb} > /dev/null 2>&1"
  end
  
  mount "#{FSdb}" do
    device "/dev/#{lvnam}"
    fstype 'jfs2'
    options 'rw'
    action [:mount, :enable]
  end
end


  ##################################################################
  # If the file system doesnt exist then create
  #
FSapp=node[:ebs][:vg][:app_fs_nam]
lvnam=node[:ebs][:vg][:lv02][:lvname]

unless system("lsfs #{FSapp} > /dev/null 2>&1")
  gigsiz = node[:ebs][:vg][:app_fs_siz].to_i * node[:ebs][:vg][:pp_per_gig].to_i
  execute "make_logvolume_#{lvnam}" do
    user 'root'
    group node[:root_group]
    #command "mklv -y#{lvnam} -tjfs2 #{volgrp} #{gigsiz}  #{DISKS}"
    command "mklv -y#{lvnam} -tjfs2 -S128K #{volgrp} #{gigsiz}  #{DISKS}"
    not_if "lsvg -l #{volgrp} | fgrep #{lvnam} > /dev/null 2>&1"
  end
  
  
    ##################################################################
    # This section creates the FS file system, using the stripped lv.
    #
  execute "make_FS_#{FSapp}" do
    user 'root'
    group node[:root_group]
    command "/usr/sbin/crfs -v jfs2 -d#{lvnam} -m#{FSapp}  #{opts}"
    not_if "lsfs | fgrep #{FSapp} > /dev/null 2>&1"
  end
  
  mount "#{FSapp}" do
    device "/dev/#{lvnam}"
    fstype 'jfs2'
    options 'rw'
    action [:mount, :enable]
  end
end  
