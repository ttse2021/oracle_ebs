log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:dbms_upg3                *'
log '*                                            *'
log '**********************************************'


  # This script will isntall oracle binaries for 11.2.0.4 and the patches.
  #

  #########################################################
  # attributs accessed:
  #########################################################

orahome4       =    node[:ebs][:db][:orahome4]
orahome3       =    node[:ebs][:db][:orahome3]
dbowner        =    node[:ebs_dbuser]
dbgroup        =    node[:ebs_dbgroup]
rootgroup      =    node[:root_group]
dbenv          =    node[:ebs][:db][:env_11204]
sid            =   node[:ebs][:db][:sid]
hname          =   node[:hostname]

  #########################################################
  # Doc_id: 1623879.1 Section 7
  #    Create nls/data/9idata directory
  #########################################################

execute "Create_nls/data/9idata" do
  user  dbowner
  group dbgroup
  environment ( dbenv )
  command "perl #{orahome4}/nls/data/old/cr9idata.pl > #{node[:ebs][:db][:outdir]}/out.9idata 2>&1"
  creates                                             "#{node[:ebs][:db][:outdir]}/out.9idata"
end

  # cr9idata.pl. doesnt return error codes. so below is a weak test to see if it passed.
  #
execute "Check output of #{node[:ebs][:db][:outdir]}/out.9idata" do
  user  dbowner
  group dbgroup
  command "echo 'Return error if we run this command'; exit 16"
  not_if "fgrep 'Please reset environment' #{node[:ebs][:db][:outdir]}/out.9idata > /dev/null 2>&1"
end

  #########################################################
  # Doc_id: 1623879.1 Section 12
  #    Prepare to upgrade
  #########################################################

pattern = "#{sid}:#{orahome4}"
execute "Add_#{orahome4}_dbms_to_oratab" do
  user  dbowner
  group dbgroup
  cwd   "/etc"
  command "echo '#{pattern}:N' >> /etc/oratab"
  not_if  "fgrep #{pattern}       /etc/oratab"
end

  #########################################################
  # Steps provided by ATS consultant
  #########################################################

tnsdir3        = "#{orahome3}/network/admin"
tnsdir4        = "#{orahome4}/network/admin"
execute "copy_over_network_listener_directory" do
  user  dbowner
  group dbgroup
  cwd   tnsdir3
  command "tar cfp - ./#{sid}_#{hname} | (cd #{tnsdir4} ; tar xpf - )"
  not_if  { File.directory?( "#{tnsdir4}/#{sid}_#{hname}" ) }
end

# Stop the 11203 dbms.
#
execute "Stop_the_DBMS_before_upgrade" do
  user  dbowner
  group dbgroup
  environment ( node[:ebs][:db][:env_11203] )
  command "ksh #{node[:ebs][:db][:bin]}/stopdb.sh"
end

Dir.glob("#{tnsdir4}/#{sid}_#{hname}/*.ora") do |item|
  fn=File.basename("#{item}") 
  execute "change_path_from_11203_to_11204_#{fn}" do
    user  dbowner
    group dbgroup
    cwd   tnsdir3
    command "perl -p -i -n -e 'if ( m:#{orahome3}: )"\
            " { s:$1:#{orahome4}:g; }' #{item} && "\
          "touch #{node[:ebs][:db][:outdir]}/t.to11204.#{fn}"
  creates       "#{node[:ebs][:db][:outdir]}/t.to11204.#{fn}"
  end
end

inidir3        = "#{orahome3}/dbs"
inidir4        = "#{orahome4}/dbs"
execute "copy_over_init.ora_to_11204" do
  user  dbowner
  group dbgroup
  cwd   inidir3
  command "cp init#{sid}.ora #{inidir4}"
  not_if  { File.file?( "#{inidir4}/init#{sid}.ora" ) }
end

  ######################################################
  # we want appsutil cloned over.
execute "tar_over_the_appsutil_directory_to_11204" do
  user        dbowner
  group       dbgroup
  cwd         orahome3
  command    "tar cfp - ./appsutil | (cd #{orahome4}; tar xpf - )"
  not_if     { File.directory?( "#{orahome4}/appsutil" ) }
end

