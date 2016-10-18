log '
     ***************************************
     *                                     *
     *        EBS Recipe:mkusers           *
     *                                     *
     ***************************************
    '
# local vars
#
logdb   = node[:ebs][:db][:outdir]

directory logdb do
  mode '0777'
  action :create
end

  # create db user if doesnt exist
  #

tuser  = node[:ebs][:db][:usr][:name] 
tmp_pw = node[:ebs][:db][:usr][:passwd] 
myhome = node[:ebs][:db][:usr][:homedir]

user tuser  do
  uid         node[:ebs][:db][:usr][:uid]
  gid         node[:ebs][:db][:usr][:pgid] 
  shell       node[:ebs][:cmd][:shell]
  home        myhome
  manage_home true
end

execute "change_passw_for_#{tuser}" do
  user 'root'
  group node[:root_group]
  command "echo #{tuser}:#{tmp_pw} | #{node[:ebs][:cmd][:chpasswd]} && "\
               "touch #{node[:ebs][:db][:outdir]}/t.setpw_#{tuser}"
  creates            "#{node[:ebs][:db][:outdir]}/t.setpw_#{tuser}"
end

execute "change_ulimit_for_#{tuser}" do
  user 'root'
  group node[:root_group]
  command "chuser fsize=-1 data=-1 stack=-1 rss=-1 core=-1 cpu=-1 nofiles=65536 #{tuser} && "\
               "touch #{node[:ebs][:db][:outdir]}/t.ulimit_#{tuser}"
  creates            "#{node[:ebs][:db][:outdir]}/t.ulimit_#{tuser}"
end

execute "change_hard_ulimit_for_#{tuser}" do
  user 'root'
  group node[:root_group]
  command "chuser fsize_hard=-1 data_hard=-1 stack_hard=-1 rss_hard=-1 "\
                  "core_hard=-1 cpu_hard=-1 nofiles_hard=65536 #{tuser} && "\
               "touch #{node[:ebs][:db][:outdir]}/t.ulimit_hard_#{tuser}"
  creates            "#{node[:ebs][:db][:outdir]}/t.ulimit_hard_#{tuser}"
end

execute "change_pwadm_NOCHECK_for_#{tuser}" do
  user 'root'
  group node[:root_group]
  command "pwdadm -f NOCHECK #{tuser} && "\
               "touch #{node[:ebs][:db][:outdir]}/t.pwadm_#{tuser}"
  creates            "#{node[:ebs][:db][:outdir]}/t.pwadm_#{tuser}"
end

execute "mv_the_orig_as_backup_for_#{tuser}" do
  user   tuser
  group  node[:ebs][:db][:usr][:pgrp]
  command "mv #{myhome}/.profile #{myhome}/.profile.orig"
  not_if { File.file?( "#{myhome}/.profile.orig" ) }
end

  # see if theres a .profile file. should be.
  # We use 'if missing, so that mods can be made if wanted.
template "#{myhome}/.profile" do
  action :create_if_missing
  source "dbuser_profile.erb"
  owner  tuser
  group  node[:ebs][:db][:usr][:pgrp]
end


  # create app user if doesnt exist
  #
tuser  = node[:ebs][:app][:usr][:name] 
tmp_pw = node[:ebs][:app][:usr][:passwd] 
myhome = node[:ebs][:app][:usr][:homedir]

user tuser  do
  uid         node[:ebs][:app][:usr][:uid]
  gid         node[:ebs][:app][:usr][:pgid] 
  shell       node[:ebs][:cmd][:shell]
  home        myhome
  manage_home true
end

  #Lets do this one time only. So use output files to identify if successful
  #
execute "change_passw_for_#{tuser}" do
  user 'root'
  group node[:root_group]
  command "echo #{tuser}:#{tmp_pw} | #{node[:ebs][:cmd][:chpasswd]} > "\
               "#{node[:ebs][:db][:outdir]}/setpw_#{tuser}"
  creates      "#{node[:ebs][:db][:outdir]}/setpw_#{tuser}"
end

execute "change_ulimit_for_#{tuser}" do
  user 'root'
  group node[:root_group]
  command "chuser fsize=-1 data=-1 stack=-1 rss=-1 core=-1 cpu=-1 nofiles=65536 #{tuser} > "\
               "#{node[:ebs][:db][:outdir]}/ulimit_#{tuser}"
  creates      "#{node[:ebs][:db][:outdir]}/ulimit_#{tuser}"
end

execute "change_hard_ulimit_for_#{tuser}" do
  user 'root'
  group node[:root_group]
  command "chuser fsize_hard=-1 data_hard=-1 stack_hard=-1 rss_hard=-1 "\
                  "core_hard=-1 cpu_hard=-1 nofiles_hard=65536 #{tuser} > "\
               "#{node[:ebs][:db][:outdir]}/ulimit__hard_#{tuser}"
  creates      "#{node[:ebs][:db][:outdir]}/ulimit__hard_#{tuser}"
end

execute "change_pwadm_NOCHECK_for_#{tuser}" do
  user 'root'
  group node[:root_group]
  command "pwdadm -f NOCHECK #{tuser} > "\
               "#{node[:ebs][:db][:outdir]}/pwadm_#{tuser}"
  creates      "#{node[:ebs][:db][:outdir]}/pwadm_#{tuser}"
end

execute "mv_the_orig_as_backup_for_#{tuser}" do
  user   tuser
  group  node[:ebs][:db][:usr][:pgrp]
  command "mv #{myhome}/.profile #{myhome}/.profile.orig"
  not_if { File.file?( "#{myhome}/.profile.orig") }
end

  # see if theres a .profile file. should be.
  #
template "#{myhome}/.profile" do
  action :create_if_missing
  source "appuser_profile.erb"
  owner  tuser
  group  node[:ebs][:app][:usr][:pgrp]
end


  # Add user to each group he should belong in
  # (add members to dba and staff)
node[:ebs][:ogrps][:grps].each do |tgrp|
  group tgrp do
    action :modify
    group_name tgrp
    members  [  node[:ebs][:db][:usr][:name],node[:ebs][:app][:usr][:name] ] 
    append true
  end
end

  # Add root to oinstall. required for dbms install
group 'add_root_to_dbms_group' do
    action :modify
    group_name node[:ebs_dbgroup]
    members  'root'
    append true
end

group 'add_root_to_dba' do
    action :modify
    group_name 'dba'
    members  'root'
    append true
end
