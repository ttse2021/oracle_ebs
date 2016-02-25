log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:dbms_upg2                *'
log '*                                            *'
log '**********************************************'


  # This script will isntall oracle binaries for 11.2.0.4 and the patches.
  #

  #########################################################
  # attributs accessed:
  #########################################################

binaries       =    node[:ebs][:stage][:bin_11204]
patches        =    node[:ebs][:stage][:pat_11204]
dbuser        =    node[:ebs_dbuser]
dbgroup        =    node[:ebs_dbgroup]
orahome4       =    node[:ebs][:db][:orahome4]
rootgroup      =    node[:root_group]
dbenv          =    node[:ebs][:db][:env_11204]
bindb          =    node[:ebs][:db][:bin]
resp_file      = "#{bindb}/ocm.rsp"

  #########################################################
  #Ok. lets make sure the directories exist:
  # Doc_id: 1623879.1 Section 3
  #    Prepare to create the 11.2.0.4 Oracle home
  #########################################################
directory orahome4 do
  owner dbuser
  group dbgroup
  mode '0775'
  action :create
end

group 'root_is_a_member_of_dba' do
    action :modify
    group_name 'dba'
    members  'root'
    append true
end

  #########################################################
  # Doc_id: 1623879.1 Section 4
  #    Install the 11.2.0.4 software
  # AIX has a root pre-install step, rootpre.sh
  #########################################################
execute 'on_aix_rootpre.sh_dbms' do
  user 'root'
  group rootgroup
  command "#{binaries}/rootpre.sh >#{node[:ebs][:db][:outdir]}/out.rootpre_sh 2>&1"
  creates                         "#{node[:ebs][:db][:outdir]}/out.rootpre_sh"
end

log '*******************************************'
log '*       Installing the 11204 binaries     *'
log '*           (30 minutes)                  *'
log '*******************************************'


  #########################################################
  # Doc_id: 1623879.1 Section 4
  #    Install the 11.2.0.4 software
  #########################################################
execute 'execute_the_install_of_the_dbms_binaries' do
  user  dbuser
  group dbgroup
  cwd   binaries
  environment (dbenv)
  command "export SKIP_ROOTPRE='TRUE'; ./runInstaller -showProgress -silent -waitforcompletion -ignoreSysPrereqs "\
            "-responseFile #{node[:ebs][:db][:bin]}/11204_template.rsp " \
            "-invPtrLoc /etc/oraInst.loc >    #{node[:ebs][:db][:outdir]}/out.runinstaller 2>&1 && "\
          "touch #{node[:ebs][:db][:outdir]}/t.runinstaller.good"
  creates       "#{node[:ebs][:db][:outdir]}/t.runinstaller.good"
  #  not_if "fgrep 'Successfully Setup Software' #{node[:ebs][:db][:outdir]}/out.runinstaller > /dev/null"
end

  #########################################################
  # Doc_id: 1623879.1 Section 4
  #    Install the 11.2.0.4 software
  #########################################################
execute "dbms_11204_post_script_root.sh" do
  user 'root'
  group node[:root_group]
  cwd   orahome4
  command "./root.sh >#{node[:ebs][:db][:outdir]}/out.root_sh_11204 2>&1"
  not_if { File.file?( "/opt/ORCLfmap/prot1_64/etc/filemap.ora" ) }
end

  #########################################################
  #    Make 1124.env active NOW
  #########################################################
template "#{bindb}/1124.env" do
  owner dbuser
  group dbgroup
  source '1124.env.erb'
  mode '0775'
end

profile="#{node[:ebs][:db][:usr][:homedir]}/.profile"
execute "Modify_the_dbuser_profile_to_1124.env" do
  user  dbuser
  group dbgroup
  command "perl -pi -e 's/1123.env/1124.env/' #{profile}"
  not_if "fgrep 1124.env #{profile} | fgrep DBMS_ENVFILE > /dev/null"
end

  #########################################################
  # Doc_id: 1623879.1 Section 5
  #    Setting up the ENVIRONMENT after install
  #########################################################

  #########################################################
  # Doc_id: 1623879.1 Section 6
  #    Apply additional 11.2.0.4 RDBMS patches
  #  Using Document 1594274.1
  #########################################################

     opatch="#{orahome4}/OPatch"
orig_opatch="#{orahome4}/OPatch.orig"
execute "save_original_opatch_to_11204" do
  user  dbuser
  group dbgroup
  cwd   orahome4
  command "mv #{opatch} #{orig_opatch}"
  not_if { File.directory?( orig_opatch ) }
end

target=orahome4
patchpat=node[:ebs][:db][:opatchn]
execute "unzip_#{patchpat}" do
  user    dbuser
  group   dbgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{bindb}/getpatch.sh -p #{patchpat} -t #{target}\n"
  not_if { File.directory?( "#{target}/OPatch" ) }
end

  ############################################################
  # single patches are handled one at a time
  #
node[:ebs][:stage][:patches_11204].each do |patchnum|

  target=node[:ebs][:dbm_patchdir]
  execute "unzip_#{patchnum}" do
    user    dbuser
    group   dbgroup
    cwd     node[:ebs][:stage][:zips]
    command "#{bindb}/getpatch.sh -p #{patchnum} -t #{target}\n"
    not_if { File.directory?( "#{target}/#{patchnum}" ) }
  end

  log  "${opatch} lsinventory | fgrep #{patchnum}"
  execute "opatch_#{patchnum}" do
    user  dbuser
    group dbgroup
    cwd   target
    command "#{orahome4}/OPatch/opatch napply "\
            "#{target} -id #{patchnum} -silent -ocmrf #{resp_file}"
    not_if "#{opatch} lsinventory | fgrep #{patchnum}"
  end

end


  ############################################################
  # bundled patches are handled one by napply
  #
node[:ebs][:stage][:bundles_11204].each do |patchnum|
  target=node[:ebs][:dbm_patchdir]
  execute "unzip_#{patchnum}" do
    user    dbuser
    group   dbgroup
    cwd     node[:ebs][:stage][:zips]
    command "#{bindb}/getpatch.sh -p #{patchnum} -t #{target}\n"
    not_if { File.directory?( "#{target}/#{patchnum}" ) }
  end

  execute "opatch_#{patchnum}" do
    user  dbuser
    group dbgroup
    # bundle must be done within itself with special options
    cwd   "#{target}/#{patchnum}"
    command "#{orahome4}/OPatch/opatch napply "\
            "-skip_subset -skip_duplicate -silent -ocmrf #{resp_file} "\
            " > #{node[:ebs][:db][:outdir]}/out.#{patchnum} 2>&1"
  creates      "#{node[:ebs][:db][:outdir]}/out.#{patchnum}"
    not_if "#{opatch} lsinventory | fgrep #{patchnum}"
  end
end

