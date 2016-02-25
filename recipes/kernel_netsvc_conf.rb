log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:kernel_netsvc            *'
log '*                                            *'
log '**********************************************'


cookbook_file '/etc/netsvc.conf' do
  mode '0664'
  source 'netsvc.conf'
end

