log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:reboot                   *'
log '*                                            *'
log '**********************************************'

reboot_completed="#{node[:ebs][:db][:outdir]}/t.rebooted_#{node[:hostname]}" 

unless File.file?( "#{reboot_completed}" )
  log '*************************************************************************'
  log '*                                                                       *'
  log '*                 EBS Recipe:reboot                                     *'
  log '*                                                                       *'
  log '* We have made changes to the kernel, and therefore we have to reboot.  *'
  log '* So heres whats going to happen. We are executing a reboot of the      *'
  log '* target node and Chef is NOT GOING TO EXIT! In another telnet window,  *'
  log '* use ping to identify when the node is back up, then exit out of CHEF  *'
  log '* and restart the bootstrap to continue the installation.               *'
  log '*                                                                       *'
  log '*************************************************************************'
  
  execute "kernel_rebooting_#{node[:hostname]}" do
    user 'root'
    group node[:root_group]
    command "touch #{reboot_completed}"
    creates       "#{reboot_completed}"
  end
  
  reboot 'Node_#{node[:hostname]}_requires_reboot' do
    action :reboot_now
    reason "Kernel Changes require rebooting. \r\nChef will not come back.\n"\
      "YOU MUST EXIT CHEF(hit ctrl-c), as it WONT come back on its own.\n"\
      "Then WAIT for the NODE to be up, before you restart the Install."
  end
end

#execute "Wait until SSH is up" do
#   command "ssh -q userB@nodeB exit"
#   retries 10
#   retry_delay 60
#   timeout 10
#end
#
# 1/27/2016 nathan suggested this code for teh reboot. Will have to look
#require 'timeout'
#Timeout.timeout(60) do
#  <long running command>
#end
#rescue Timeout::Error
#  <do thing if it times out>
#end

