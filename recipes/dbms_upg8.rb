log '
     **********************************************
     *                                            *
     *        EBS Recipe:dbms_upg8                *
     *                                            *
     **********************************************
    '


  #########################################################
  # attributs accessed:
  #########################################################

dbowner   = node[:ebs_dbuser]
dbgroup   = node[:ebs_dbgroup]
dbhome    = node[:ebs][:db][:usr][:homedir]
dbenv        = node[:ebs][:db][:env_11204]
ora_home4    = node[:ebs][:db][:orahome4]
sid          = node[:ebs][:db][:sid]
hname        = node[:hostname]
bindb        = node[:ebs][:db][:bin]
tmpstage     = node[:ebs][:stage][:dir]
app_home     = node[:ebs][:app][:runbase]
userAPPS     = node[:ebs][:appsuser]
mysid        = node[:ebs][:db][:sid]
apppw        = node[:ebs][:appspw]
syspw        = node[:ebs][:syspw]
appuser      = node[:ebs_appuser]
appgroup     = node[:ebs_appgroup]
appenv       = node[:ebs][:app][:env]
fs1base      = node[:ebs][:app][:runbase]
fs2base      = node[:ebs][:app][:patchbase]
contxtfs1    = node[:ebs][:app][:contxtfs1]
contxtfs2    = node[:ebs][:app][:contxtfs2]
outdb        = node[:ebs][:db][:outdir]
outapp       = node[:ebs][:app][:outdir]
ENVFS1       = node[:ebs][:app][:FS1ENVF]
ENVFS2       = node[:ebs][:app][:FS2ENVF]
ENVDB        = node[:ebs][:db][:DBENVF]
display      = node[:ebs][:rapidwiz][:display]
contxtdb     = "#{node[:ebs][:db][:orahome4]}/appsutil/#{node[:ebs][:sid_hname]}.xml"

template "#{bindb}/adbldxml.exp" do
  source "adbldxml.exp.erb"
  owner dbowner
  group dbgroup
  mode '0755'
end

  ################################
  # save the original. we may need
  #
log "mv #{contxtdb} #{contxtdb}.orig"
execute "Save_original_xml_context_file" do
  user  dbowner
  group dbgroup
  environment ( dbenv )
  command "mv #{contxtdb} #{contxtdb}.orig"
  not_if { File.file?( "#{contxtdb}.orig" ) }
end

execf='adbldxml.exp'
cmd="#{bindb}/#{execf}"
outfile="#{outdb}/out.db.#{execf}"
execute "generate_new_#{sid}_#{hname}.xml" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  command <<-EOF
echo "Running adbldxml.exp on DBMS"
.    #{ENVDB} 
 echo ${CHEF_ENV?} | fgrep "11204" > /dev/null 2>&1
 if  [ $? != 0 ] ; then echo "Cannot source $ENVDB. Aborting..."; exit 255; fi
 #{cmd} #{apppw} #{mysid} '#{display}' > #{outfile}
EOF
end

  #####################################################################
  # Doc_id: 1623879.1 Section 25                                      #
  #    Implement and run AutoConfig                                   #
  #####################################################################
  # Implement and run AutoConfig in the new Oracle home on the        #
  # database server node. You must also run AutoConfig on each        #
  # application tier server node on both the Patch and Run            #
  # APPL_TOP to update the system with the listener.                  #
  #####################################################################

shellf='adconfig.sh'
cmd="#{ora_home4}/appsutil/bin/#{shellf}"
outfile="#{outdb}/out.db.#{shellf}"
contxt=contxtdb

  # Ok run autoconfig for DBMS
  #
execute "run_#{shellf}_script_for_dbms" do
  user          dbowner
  group         dbgroup
  environment ( dbenv )
  command <<-EOF
    echo "Running adconfig on DBMS"
    echo ENVDB       #{ENVDB};      echo cmd        #{cmd};       
    echo contxt  #{contxt}; echo outfile    #{outfile};   
    echo apppw      #{apppw}

    .    #{ENVDB}
    echo ${CHEF_ENV?} | fgrep "11204" > /dev/null 2>&1
    if  [ $? != 0 ] ; then echo "Cannot source $CHEF_ENV. Aborting..."; exit 255; fi
    #{cmd} contextfile=#{contxtdb} > #{outfile} 2>&1 <<-EOC
#{apppw}
EOC
  fgrep "AutoConfig completed successfully" #{outfile} > /dev/null 2>&1
  EOF
end


shellf='adconfig.sh'
cmd="#{fs1base}/appl/ad/12.0.0/bin/#{shellf}"
outfile="#{outapp}/out.fs1.#{shellf}"
fs="fs1"

  # Ok run autoconfig for APP FS1 (run path)
  #
execute "run_#{shellf}_script_for_#{fs}" do
  user          appuser
  group         appgroup
  environment ( appenv )
  command <<-EOF
    echo "Running adconfig on ${fs}"
    echo ENVFS1       #{ENVFS1};      echo cmd        #{cmd};       
    echo contxtfs1  #{contxtfs1}; echo outfile    #{outfile};   
    echo apppw      #{apppw}

    .    #{ENVFS1}
    echo ${AD_TOP?} | fgrep "#{fs}" > /dev/null 2>&1
    if  [ $? != 0 ] ; then echo "Cannot source $ENVFS1. Aborting..."; exit 255; fi
    #{cmd} contextfile=#{contxtfs1} > #{outfile} 2>&1 <<-EOC
#{apppw}
EOC
  fgrep "AutoConfig completed successfully" #{outfile} > /dev/null 2>&1
  EOF
end

shellf='adconfig.sh'
cmd="#{fs2base}/appl/ad/12.0.0/bin/#{shellf}"
outfile="#{outapp}/out.fs2.#{shellf}"
fs="fs2"

  # Ok run autoconfig for APP FS2 (run path)
  #
execute "run_#{shellf}_script_for_#{fs}" do
  user          appuser
  group         appgroup
  environment ( appenv )
  command <<-EOF
    echo "Running adconfig on ${fs}"
    echo ENVFS2       #{ENVFS2};      echo cmd        #{cmd};       
    echo contxtfs2  #{contxtfs2}; echo outfile    #{outfile};   
    echo apppw      #{apppw}

    .    #{ENVFS2}
    echo ${AD_TOP?} | fgrep "#{fs}" > /dev/null 2>&1
    if  [ $? != 0 ] ; then echo "Cannot source $ENVFS2. Aborting..."; exit 255; fi
    #{cmd} contextfile=#{contxtfs2} > #{outfile} 2>&1 <<-EOC
#{apppw}
EOC
  # docId says to ignore all errors. so should be errors.
  fgrep "AutoConfig completed with errors" #{outfile} > /dev/null 2>&1
  EOF
end

