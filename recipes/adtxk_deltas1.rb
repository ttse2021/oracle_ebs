log '
     *******************************************
     *                                         *
     *        EBS Recipe:adtxk_deltas1         *
     *                                         *
     *******************************************
    '


appuser        =    node[:ebs_appuser]
appgroup       =    node[:ebs_appgroup]
appenv         =    node[:ebs][:app][:env]
dbmuser        =    node[:ebs_dbuser]
dbmgroup       =    node[:ebs_dbgroup]
dbenv          =    node[:ebs][:db][:env_11204]
binapp         =    node[:ebs][:app][:bin]
bindb          =    node[:ebs][:db][:bin]
outdb          =    node[:ebs][:db][:outdir]
outapp         =    node[:ebs][:app][:outdir]
rootgroup      =    node[:root_group]
oraInventory   =    node[:ebs][:db][:oraInv]
ora_base       =    node[:ebs][:db][:orabase]
db_fs          =    node[:ebs][:vg][:db_fs_nam]
app_fs         =    node[:ebs][:vg][:app_fs_nam]



  #-----------------------------------------#
  # Doc_ID_1617461.1_Section3.1.2 step3     #
  # Start up wls and dbms only              #
  #-----------------------------------------#

execute "Doc_ID_1617461_3132_stopapp" do
  user          appuser
  group         appgroup
  environment ( appenv  )
  command "#{binapp}/stopapp.sh"
end

execute "Doc_ID_1617461_3132_stopwls" do
  user          appuser
  group         appgroup
  environment ( appenv  )
  command "#{binapp}/stopwls.sh"
end

  # if dbms is not running it should be
  #
execute "Doc_ID_1617461_3132_startdb" do
  user          dbmuser
  group         dbmgroup
  environment ( dbenv )
  command      "#{bindb}/startdb.sh"
end

execute "Doc_ID_1617461_3132_startwls" do
  user          appuser
  group         appgroup
  environment ( appenv  )
  command "#{binapp}/startwls.sh"
end

