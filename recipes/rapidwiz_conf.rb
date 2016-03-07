log '
     ********************************************
     *                                          *
     *        EBS Recipe:rapidwiz_conf          *
     *                                          *
     ********************************************
    '


  ## we need to modify the conf file for the all in one, such that
  ## it is configured for this hostname, domain.
  ##
template "#{node[:ebs][:vg][:db_fs_nam]}/conf_#{node[:ebs][:db][:sid]}.txt" do
  owner 'root'
  group node[:root_group]
  mode '0770'
  source 'txt.conf.erb'
end

directory "/.vnc" do
  owner 'root'
  group node[:root_group]
  mode '0770'
  action :create
end

cookbook_file "/.vnc/xstartup" do
  owner 'root'
  group node[:root_group]
  mode '0775'
  source  'xstartup'
end

template "#{node[:ebs][:db][:bin]}/chk_passed.pl" do
  source 'chk_passed.pl.erb'
  owner 'root'
  group node[:root_group]
  mode '0775'
end

template "#{node[:ebs][:db][:bin]}/vnc_root.sh" do
  source 'vnc_root.sh.erb'
  owner 'root'
  group node[:root_group]
  mode '0700'
end

execute "create_vnc_passwd_file_root" do
  user 'root'
  group node[:root_group]
  command "ksh #{node[:ebs][:db][:bin]}/vnc_root.sh > #{node[:ebs][:db][:outdir]}/out.vnc_root 2>&1"
  creates                                             "#{node[:ebs][:db][:outdir]}/out.vnc_root"
end

userr='root'
execute "make_vnc_session10_for_root" do
  user userr
  group node[:root_group]
  command "su - #{userr} -c '/usr/bin/X11/vncserver :10'"
  #command "env > /tmp/env.chef; /usr/bin/X11/vncserver :10"
  #MAYBE  command "ssh "#{node[:ebs_dbuser]}@#{node[:hostname]} 'vncserver :10'"
  not_if  "ps -aef | fgrep #{userr} | fgrep -v fgrep | fgrep 'Xvnc :10'"
end

execute "wait_3_seconds" do
  command "sleep 3"
end

  # just before starting. lets cleanup with slibclean
  #
execute "time_to_slibclean_prior_rapidwiz" do
  user 'root'
  group node[:root_group]
  command "/usr/sbin/slibclean"
end

  # this list is tested by rapidwiz install. Todo, have these tested before rapidwiz...
  #
  #Available Physical Memory: Expected Value:50MB (51200.0KB) Actual Value:55.4098GB (5.8101428E7KB)
  #Expected Value:Patch IZ87564 Actual Value:Patch IZ87564:bos.adt.libmIZ87564:bos.adt.prof
  #Free Space: p135n51:/tmp: Expected Value:1GB Actual Value:9.7134GB
  #Hard Limit: maximum open file descriptors: Expected Value:65536 Actual Value:65536
  #Hard Limit: maximum user processes: Expected Value:16384 Actual Value:16384
  #OS Kernel Parameter: maxuproc: Expected Value:2048 Actual Value:16384
  #OS Kernel Parameter: ncargs: Expected Value:128 Actual Value:1024
  #OS Kernel Parameter: tcp_ephemeral_high: Expected Value:65500 Actual Value:65500
  #OS Kernel Parameter: tcp_ephemeral_low: Expected Value:9000 Actual Value:9000
  #OS Kernel Parameter: udp_ephemeral_high: Expected Value:65500 Actual Value:65500
  #OS Kernel Parameter: udp_ephemeral_low: Expected Value:9000 Actual Value:9000
  #OS Kernel Version: Expected Value:7.1-7100.00.01.1037 Actual Value:7.1-7100.03.05.1524
  #OS Patch:IZ87216: Expected Value:Patch IZ87216 Actual Value:Patch IZ87216:devices.common.IBM.mpio.rte OS Patch:IZ87564:
  #OS Patch:IZ89165: Expected Value:Patch IZ89165 Actual Value:Patch IZ89165:bos.rte.bind_cmds
  #OS Patch:IZ97035: Expected Value:Patch IZ97035 Actual Value:Patch IZ97035:devices.vdevice.IBM.l-lan.rte
  #Package: bos.adt.base-...: Expected Value:bos.adt.base-...  Actual Value:bos.adt.base-7.1.3.45-0
  #Package: bos.adt.lib-...: Expected Value:bos.adt.lib-...  Actual Value:bos.adt.lib-7.1.2.15-0
  #Package: bos.adt.libm-...: Expected Value:bos.adt.libm-...  Actual Value:bos.adt.libm-7.1.3.45-0
  #Package: bos.perf.libperfstat-...: Expected Value:bos.perf.libperfstat-...  Actual Value:bos.perf.libperfstat-7.1.3.45-0
  #Package: bos.perf.perfstat-...: Expected Value:bos.perf.perfstat-...  Actual Value:bos.perf.perfstat-7.1.3.45-0
  #Package: bos.perf.proctools-...: Expected Value:bos.perf.proctools-...  Actual Value:bos.perf.proctools-7.1.3.45-0
  #Package: xlC.aix61.rte-10.1.0.0: Expected Value:xlC.aix61.rte-10.1.0.0 Actual Value:xlC.aix61.rte-12.1.0.4-0
  #Package: xlC.rte-10.1.0.0: Expected Value:xlC.rte-10.1.0.0 Actual Value:xlC.rte-12.1.0.4-0
  #Physical Memory: Expected Value:1GB (1048576.0KB) INFO: Actual Value:60GB (6.291456E7KB)
  #Soft Limit: maximum open file descriptors: Expected Value:1024 Actual Value:65536
  #Soft Limit: maximum user processes: Expected Value:2047 Actual Value:16384
  #Swap Size: Expected Value:16GB (1.6777216E7KB) Actual Value:16GB (1.6777216E7KB)

