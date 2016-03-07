log '
     **********************************************
     *                                            *
     *        EBS Recipe:kernel_etchosts          *
     *                                            *
     **********************************************
    '

# get the machine host, ipaddress and fully qualified domain name fqdn
myaddr=node['ipaddress']
myhost=node['hostname']
mydomain=`namerslv -s -n | awk '{ print $2 }'`
mydomain.chomp!

myfqdn="#{myhost}.#{mydomain}"
hostline="#{myaddr}     #{myfqdn} #{myhost}"

log "hostline: #{hostline}"

execute "is_addr_blank" do
  command "exit -1"
  only_if { ( "#{myaddr}" == '' ) }
end

execute "is_fqdn_blank" do
  command "exit -1"
  only_if { ( "#{myfqdn}" == '' ) }
end

execute "is_host_blank" do
  command "exit -1"
  only_if { ( "#{myhost}" == '' ) }
end

# make sure that all three are on the same line. How?
# by getting the line from the /etc/hosts using each field
#
getline1=`fgrep #{myaddr} /etc/hosts`
getline2=`fgrep #{myfqdn} /etc/hosts`
getline3=`fgrep #{myhost} /etc/hosts`

# if we're getting multiple lines for this one line. we have issues. Flag.
#
raise "Multiple Hostlines for this machine in /etc/hosts. Please fix" if ( getline1!=getline2)
raise "Multiple Hostlines for this machine in /etc/hosts. Please fix" if ( getline1!=getline3)

#Ok Is it in the /etc/hosts file? if not, add it.
#
execute "make_sure_etchosts_file_has_machine_entry" do
  user 'root'
  command "echo '#{hostline}' >> /etc/hosts"
  only_if { ( "#{getline1}" == '') }
end#
