log '
     **********************************************
     *                                            *
     *        EBS Recipe:vnc_session_user         *
     *                                            *
     **********************************************
    '


vnc_owner = 'root'
vnc_group = node[:root_group]
vnc_home  = '/'
vnc_env   = node[:ebs][:root][:env]
vnc_num   = node[:ebs][:rapidwiz][:vnc_num]

directory "#{vnc_home}/.vnc" do
  owner vnc_owner
  group vnc_group
  mode '0755'
  action :create
end

cookbook_file "#{vnc_home}/.vnc/xstartup" do
  owner vnc_owner
  group vnc_group
  mode '0755'
  source  'xstartup'
end

execute "create_vnc_passwd_file" do
  user  vnc_owner
  group vnc_group
  cwd   vnc_home
  environment ( vnc_env )
  command "ksh #{node[:ebs][:db][:bin]}/vnc_#{vnc_owner}.sh "\
              "> #{node[:ebs][:db][:outdir]}/out.vnc_#{vnc_owner} 2>&1"
  creates     "#{node[:ebs][:db][:outdir]}/out.vnc_#{vnc_owner}"
  not_if { File.file?( "#{vnc_home}/.vnc/passwd" ) }
end

execute "make_vnc_session_#{vnc_num}_for_#{vnc_owner}" do
  user  vnc_owner
  group vnc_group
  environment ( vnc_env )
  command "su - "#{vnc_owner} -c '/usr/bin/X11/vncserver :#{vnc_num}'"
  #MAYBE  command "ssh #{vnc_owner}@#{node[:hostname]} 'vncserver :#{vnc_num}'"
  not_if  "ps -aef | fgrep #{vnc_owner} | fgrep -v fgrep | fgrep 'Xvnc :#{vnc_num}'"
end

