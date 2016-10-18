log '
   ************************************************************************* 
   *                                                                       * 
   *                 EBS Recipe:reboot                                     * 
   *                                                                       * 
   ************************************************************************* 
   '

reboot_completed="#{node[:ebs][:db][:outdir]}/t.rebooted_#{node[:hostname]}" 
log "FILE IS: #{node[:ebs][:db][:outdir]}/t.rebooted_#{node[:hostname]}"

unless File.file?( reboot_completed )
  log '
     ************************************************************************* 
     *                                                                       * 
     * We have made changes to the kernel, and therefore we have to reboot.  * 
     * So heres whats going to happen. We are executing a reboot of the      * 
     * target node and Chef is NOT GOING TO EXIT! In another telnet window,  * 
     * use ping to identify when the node is back up, then exit out of CHEF  * 
     * and restart the bootstrap to continue the installation.               * 
     *                                                                       * 
     ************************************************************************* 
  
  
              **********************************
              *    REBOOTING THE MACHINE       *
              *                                *
              *   Hit <CTRL-C> to EXIT CHEF.   *
              *  WAIT FOR MACHINE TO COME UP.  *
              *  THEN RESTART THE CHEF INSTALL *
              *                                *
              **********************************
  
  
      '
    
  execute "kernel_rebooting_#{node[:hostname]}" do
    user 'root'
    group node[:root_group]
    command "touch #{reboot_completed} && shutdown -Fr now && sleep 600"
    creates       "#{reboot_completed}"
  end
end
