log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:linux_tools              *'
log '*                                            *'
log '**********************************************'


  #install missing linux tools that chef may need
  #
node[:ebs][:linux][:tools].each do |pack|
  aix_toolboxpackage pack do
    action :install
  end
end

