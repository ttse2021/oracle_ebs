log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:kernel_filesets          *'
log '*                                            *'
log '**********************************************'



  # TODO: Make this a cookbook. version of xlc and AIX
  # Check version of xlC
  # CHefk version of AIX
  # AIX 7 (7.1)	
  #
  #    xlC.aix61.rte:11.1.0.1 or later1
  #    xlC.rte:11.1.0.1 or later1



  # Check that all filesets are installed
  # TODO: Make this a cookbook. Filesets installed
  #
node[:ebs][:chk_filesets].each do |fset|
  execute "check_fileset_#{fset}" do
    user 'root'
    group node[:root_group]
    command "echo Fileset: #{fset} NOT FOUND ABORT; exit -1"
    not_if "lslpp -l #{fset}"
  end
end

  #lets make sure there linkxlC actually exists within oracle user
raise "#{node[:ebs][:cmd][:linkxlC]} not found." unless File.exist?( "#{node[:ebs][:cmd][:linkxlC]}" )


  # ok it exists, add to standard usr/bin driectory
link '/usr/bin/linkxlC' do            #foward pointer
  to node[:ebs][:cmd][:linkxlC]       #actual pointer
end

node[:ebs][:chk_symlinks].each do |fname|
  execute "utility_check_#{fname}" do
    user 'root'
    group node[:root_group]
    command "echo #{fname} NOT FOUND ABORT; exit -1"
    not_if { File.symlink?("#{fname}") }
  end
end

