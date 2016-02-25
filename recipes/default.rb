log '*****************************************'
log '*                                       *'
log '*        EBS Recipe:default             *'
log '*                                       *'
log '*****************************************'

  ######################
  #Machine Preparation #
  ######################

  #-----------------------------------------------------------
  # volume groups, lvm, file system creation. FS expansion   -
  #-----------------------------------------------------------
include_recipe 'oracle_ebs::fs_creation'


  #-----------------------------------------------------------
  # Create the oracle groups and users                       -
  #-----------------------------------------------------------
include_recipe 'oracle_ebs::mkgroups'
include_recipe 'oracle_ebs::mkusers'

  #-------------------------------------------------------------
  # Kernel and OS changes. Look within it, many files included -
  #-------------------------------------------------------------
include_recipe 'oracle_ebs::kernel'


  #-----------------------------------------------------------
  # Now lets reboot the box.                                 -
  #-----------------------------------------------------------
include_recipe 'oracle_ebs::reboot'

  ######################
  #EBS  INSTALL        #
  ######################

  #-----------------------------------------------------------
  # Linux utilties that may be used by CHEF recipes          -
  #-----------------------------------------------------------
include_recipe 'oracle_ebs::linux_tools'

  #-----------------------------------------------------------
  # We create directories to support the installation
  #-----------------------------------------------------------
include_recipe 'oracle_ebs::directory_creation'

  #-----------------------------------------------------------
  # The rapidwiz requires some special handling for xterm    = 
  #-----------------------------------------------------------
include_recipe 'oracle_ebs::rapidwiz_conf'

  #-----------------------------------------------------------
  # The big tomato. Run the base installation
  #-----------------------------------------------------------

include_recipe 'oracle_ebs::rapidwiz_install'

include_recipe 'oracle_ebs::oratab'
include_recipe 'oracle_ebs::dbms_upg_prep'
include_recipe 'oracle_ebs::dbms_upg1'   # prep 11203 for 11204
include_recipe 'oracle_ebs::vnc_session_user'

include_recipe 'oracle_ebs::dbms_upg2'  # Install 11204 binaries, patches
include_recipe 'oracle_ebs::dbms_upg3'  # Post 11204 misc.
include_recipe 'oracle_ebs::dbms_upg4'  # Run dbms upgrade assistant
include_recipe 'oracle_ebs::dbms_upg5'  # Update contxt file, init.or
include_recipe 'oracle_ebs::dbms_upg6'  # Dbms brought up. post_install.sql

include_recipe 'oracle_ebs::dbms_upg7'  # grants, etc stuff done
include_recipe 'oracle_ebs::dbms_upg8'  # run autoconfig on app
include_recipe 'oracle_ebs::dbms_upg9'  # update stats on dbms

include_recipe 'oracle_ebs::dbms_upg10' # DBMS ETCC checking
  ######################################################################
  # Doc_ID_1983050.1_Section4 : Upgrading the database with Opatches.  #
  # Patch numbers came from Doc_ID: 1594274.1                          #
  ######################################################################
  #
include_recipe 'oracle_ebs::DOC1983050_Section4'


  ######################################################################
  # Doc_ID_1594274.1_Section4 : Upgrading the Forms and Reports        #
  #  with Opatches.                                                    #
  # Patch numbers came from Doc_ID: 1594274.1                          #
  ######################################################################
  #
include_recipe 'oracle_ebs::forms_patch'
include_recipe 'oracle_ebs::fmw_web'
include_recipe 'oracle_ebs::ocommon'
include_recipe 'oracle_ebs::etcc'

  #########################################################################
  # Doc_ID_1983050.1_Section5 Apply Consolidated Seed Table Upgrade Patch #
  #########################################################################
  #
include_recipe 'oracle_ebs::DOC1983050_Section5'

  #########################################################################
  # Doc_ID_1983050.1_Section6 -> Doc_ID_1617461.1                         #
  #   'Applying the Latest AD and TXK Release Update Packs'               #
  #########################################################################
  #

include_recipe 'oracle_ebs::adtxk_deltas1'
include_recipe 'oracle_ebs::adtxk_deltas2'
include_recipe 'oracle_ebs::1225_upg1'
include_recipe 'oracle_ebs::1225_upg2'
include_recipe 'oracle_ebs::1225_upg3'

  #########################################################################
  # We are done. xit_checks tell you how to test                          #
  #########################################################################
  #
include_recipe 'oracle_ebs::xit_checks'

