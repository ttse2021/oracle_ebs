log '************************************'
log '*                                  *'
log '*  EBS Recipe:rapidwiz_install     *'
log '*                                  *'
log '************************************'

  #########################################################
  # attributs accessed:
  #########################################################

orahome3       = node[:ebs][:db][:orahome3]
dbenv          = node[:ebs][:db][:env_11203]
outdb          = node[:ebs][:db][:outdir]
bindb          = node[:ebs][:db][:bin]
dbmuser        = node[:ebs_dbuser]
dbmgroup       = node[:ebs_dbgroup]
appuser        = node[:ebs_appuser]
appgroup       = node[:ebs_appgroup]
appenv         = node[:ebs][:app][:env]
binapp         = node[:ebs][:app][:bin]


  #-------------------------------------#
  #only run once, and only if successful#
  #-------------------------------------#

unless File.file?( "#{outdb}/t.rapidwiz_installed" )
  

  # lets see if we can catch problems before we run the install
  #
  execute "chk_prereqs" do
    user  dbmuser
    group dbmgroup
    command "ksh #{bindb}/chk_prereqs.sh"
  end
  
  
  log '***************************************************'
  log '*                                                 *'
  log '* rapidwiz_install hours to complets: (5-12 hours *'
  log '*                                                 *'
  log '***************************************************'

  # Rapidwiz can take a very long time to finish!
  #
  execute "rapidwiz_install" do
    user  'root'
    group node[:root_group]
    timeout 50400
    command "ksh #{bindb}/rapidstart.sh > #{outdb}/out.rapidstart 2>&1"
  end
  
 # Check the log files for success
 #
 execute "chk_passed" do
   user  'root'
   group node[:root_group]
   command "#{bindb}/chk_passed.pl && "\
                  "touch #{outdb}/t.rapidwiz_installed"
     creates            "#{outdb}/t.rapidwiz_installed"
 end

  execute "kill_vnc_session10_for_root" do
    user  'root'
    group node[:root_group]
    command "/usr/bin/X11/vncserver -kill :10"
    only_if  "ps -aef | fgrep #{node[:ebs_dbuser]} | fgrep -v fgrep | fgrep 'Xvnc :10'"
  end

  # we shouldnt need to do this but we check anyway.
  execute "dbms_installation_post_script_root.sh" do
    user 'root'
    group node[:root_group]
    command "#{orahome3}/root.sh"
    # on AIX this is the hardcoded path for testing if root.sh was executed
    not_if { File.file?( "/opt/ORCLfmap/prot1_64/etc/filemap.ora" ) }
  end

end

template  "#{bindb}/1123.env" do
  owner  dbmuser
  group  dbmgroup
  source '1123.env.erb'
  mode '0775'
end

  # Make sure everything is down!
execute "stop_the_app_server_1" do
  user          appuser
  group         appgroup
  environment ( appenv  )
  command "#{binapp}/stopapp.sh"
end

execute "#{bindb}/stopdb.sh" do
  user  dbmuser
  group dbmgroup
  environment ( dbenv )
end


