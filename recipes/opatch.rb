log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:opatch                   *'
log '*                                            *'
log '**********************************************'

thishome       =  node[:ebs][:app][:fmw][:home]
prev_opatch    =  "#{thishome}/OPatch.orig"
 cur_opatch    =  "#{thishome}/OPatch"

execute "Move Opatch_to_Opatch.orig" do
  user  appuser
  group appgroup
  cwd   thishome
  command "mv #{cur_opatch} #{prev_opatch}"
  not_if ( File.directory?( prev_opatch ) )
end

execute "update_opatch_for_FMWWEB" do
  user  node[:ebs][:app][:usr][:name]
  group node[:ebs][:app][:usr][:pgrp]
  cwd   thishome
  command "unzip node[:ebs][:stage][:fmw][:opatch]"
  not_if ( File.directory?( cur_opatch ) )
end

