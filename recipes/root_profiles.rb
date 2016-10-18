log '
     ***************************************
     *                                     *
     *        EBS Recipe:root_user         *
     *                                     *
     ***************************************
    '

rhome=homedir=node[:etc][:passwd][:root][:dir]
profiles = [ 'profile' , 'profile.local', 'kshrc', 'kshrc.local' ]

touchf="#{rhome}/.chef_root"
log "TOUCHF: #{touchf}"

unless File.file?( touchf )

  profiles.each do |thisfile|
    fpfile="#{rhome}/.#{thisfile}"
    execute "save_current_to_dot_chef_#{thisfile}" do
      user 'root'
      group node[:root_group]
      # if profile file exists, we move it.
      command "mv #{fpfile}  #{fpfile}.b4_chef"
      only_if  { File.file?( "#{fpfile}" ) } 
    end
  
    cookbook_file "#{fpfile}" do
      user 'root'
      group node[:root_group]
      mode '0740'
      source  "root.#{thisfile}"
    end
  end
  
  ###############################################################
  # Ok. what did we do? We put down our own the .profile files. #
  # this means the scripts that take advantage of the .profile  #
  # can do so.                                                  #
  ###############################################################

  log '
  
              **********************************
              *    REBOOTING THE MACHINE       *
              *                                *
              *   Hit <CTRL-C> to EXIT CHEF.   *
              *  WAIT FOR MACHINE TO COME UP.  *
              *  THEN RESTART THE CHEF INSTALL *
              *                                *
              **********************************
  
      '
    
  execute "kernel_rebooting_#{node[:hostname]}_for_profiles" do
    user 'root'
    group node[:root_group]
    command "touch #{touchf} && shutdown -Fr now && sleep 600"
    creates       "#{touchf}"
  end
end
