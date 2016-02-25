log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:kernel_etehosts          *'
log '*                                            *'
log '**********************************************'


cookbook_file '/etc/hosts' do
  mode '0664'
  source 'hosts'
end

