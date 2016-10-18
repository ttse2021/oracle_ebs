log '
     **********************************************
     *                                            *
     *        EBS Recipe:kernel_mount             *
     *                                            *
     **********************************************
    '

# Check that the staging directory is mounted by looking for a directory
#
stagedir=node[:ebs][:stage][:fsmount]
log "STAGEDIR: #{stagedir}/stage"
execute "check_if_stage_directory_is_there" do
  user 'root'
  group node[:root_group]
  command 'echo "Staging #{stagedir}/stage directory not found" ; exit -1; '
  not_if { File.directory?( "#{stagedir}/stage" ) }
end


# Ok its mounted, but is rapidwiz directory there?
#
log "#{node[:ebs][:stage][:rapiddir]}"
execute "check_if_rapidwiz_dir_is_there" do
  user 'root'
  group node[:root_group]
  command 'echo "Staging rapiddir directory not found" ; exit -1; '
  not_if { File.directory?( "#{node[:ebs][:stage][:rapiddir]}" ) }
end

# work around for broken code
#
execute "lsfs_to see if file is nfs mounted" do
  user 'root'
  group node[:root_group]
  command 'echo "#stagedir is nfs mounted. Aborting..."; exit -1;'
  only_if "lsfs #{stagedir} | fgrep #{stagedir} | awk '{print $4}' |fgrep nfs"
end


# Code below breaks due to how chef handles mount info:
###################################################
## Turns out that the rapdwiz installation writes to
## the /ebstage..rapidwiz directory # Well we dont
## want # the nfs image to be spoiled. So make sure
## its a local copy
##
#found=false
#ruby_block "dont_let_ebstage_be_nfs_mounted" do
#  block do
#     puts "\n This is a puts inside a ruby block in recipes/default.rb"
#    node['filesystem'].each do |dev,properties|
#      fsnam=properties['mount']
#      if ( stagedir == fsnam )
#        Chef::Log.warn("FSNAM: #{fsnam} #{properties['fs_type']} ")
#        found=true
#        if ( properties['fs_type'].include? "nfs" )
#          raise "File System: #{stagedir} is nfs mounted. "\
#                "Do Not use an NFS file system. Aborting..."
#        end
#      end
#    end
#    if ( found != true )
#      raise "Filesystem: #{stagedir} is NOT FOUND in ohai"
#    end
#
#  end
#end

