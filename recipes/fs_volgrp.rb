log '
     *****************************************
     *                                       *
     *        EBS Recipe:fs_volgrp           *
     *                                       *
     *****************************************
    '

volgrp="#{node[:ebs][:vg][:vgname]}"

  ##################################################################
  # We need a volume group for the new file systems...
  #
  # Does it already exists? then bypass
unless system("lsvg #{volgrp} > /dev/null 2>&1")

    ##################################################################
    # Make sure that disk attributes exists for the host machine
    # Each machine should have their disks defined!
    #
  log "Disks: #{node[:ebs][:vg][:drives][node[:hostname]]}"
  raise "Disks not found for host" if node[:ebs][:vg][:drives][node[:hostname]].nil?
  
  
    ##################################################################
    # Each machine may have a different set of hdisk lists
    #
  DISKS=node[:ebs][:vg][:drives][node[:hostname]].join(" ")
  
  # We want to set performance for the drives prior to making the volume group
  #
  node[:ebs][:vg][:drives][node[:hostname]].each do |disk|
    # increase the diskperformance
    aix_chdev "#{disk}_queue_depth" do
      name disk
      attributes(:queue_depth => node[:ebs][:vg][:hdisk][:queue_depth] )
      need_reboot true
      action :update
      not_if "lspv #{disk}"
    end
    # For SSD disks, we have other tunables.
    #
    if node[:ebs][:vg][:ssdhosts].include? node[:hostname]
      aix_chdev "#{disk}_max_coalesce" do
        name disk
        attributes(:max_coalesce => node[:ebs][:vg][:hdisk][:max_coalesce] )
        need_reboot true
        action :update
      end
      aix_chdev "#{disk}_max_transfer" do
        name disk
        attributes(:max_transfer => node[:ebs][:vg][:hdisk][:max_transfer] )
        need_reboot true
        action :update
      end
    end
  end
  
  # We are going to make a volume group using the drives
  #
  execute "make_volume_group_#{volgrp}" do
    user 'root'
    group node[:root_group]
    command "/usr/sbin/mkvg -S -y#{volgrp} -s128 -f #{DISKS}"
    not_if "lsvg | fgrep #{volgrp} > /dev/null 2>&1"
  end
  
  ruby_block 'check_if_enough_space_in_vg' do
    block do

      # get total disk size requirements in MEGS
      # check that we have at least this much space in the file system
      #
      totfs_size=(node[:ebs][:vg][:db_fs_siz].to_i +
                   node[:ebs][:vg][:app_fs_siz].to_i)*1024
      curfree=0
      shell_out("lsvg #{volgrp}").stdout.each_line do | line |
        case line
        when /FREE PPs:.*\((\d+) megabytes/
          curfree=$1
          break
        end
      end
      if curfree.to_i < totfs_size.to_i
        raise "Not enough space in vg: Cur: #{curfree}  Tot: #{totfs_size}"
      end
    end
  end
end
