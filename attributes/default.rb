#Sat Dec 19 22:34:58 PST 2015
     #***********************************************#
     #**                                          ***#
     #**          Root Owner Attributes           ***#
     #**                                          ***#
     #***********************************************#


#-------------------------------------------------------
# hdisk Attributes
#-------------------------------------------------------
#
default[:ebs][:vg][:hdisk][:queue_depth]  = 255
default[:ebs][:vg][:hdisk][:max_coalesce] = '0x40000'
default[:ebs][:vg][:hdisk][:max_transfer] = '0x100000'

#-------------------------------------------------------
# Volume Group Attributes - used to create file systems
#-------------------------------------------------------
#
default[:ebs][:vg][:ppsiz]        = 128
default[:ebs][:vg][:pp_per_gig]   = 1024/node[:ebs][:vg][:ppsiz]
default[:ebs][:vg][:vgname]       = 'ebsvg01'
default[:ebs][:vg][:db_fs_siz]             = '398' # in GIGS
default[:ebs][:vg][:app_fs_siz]            = '198' # in GIGS

#-------------------------------------------------------
# Logical Volumes
#-------------------------------------------------------
#
default[:ebs][:vg][:lv01][:lvname] = 'lvebs01'
default[:ebs][:vg][:lv02][:lvname] = 'lvebs02'

#-------------------------------------------------------
# File System Attributes
#-------------------------------------------------------
#
            # DBMS Owner #
default[:ebs][:vg][:db_fs_nam]             = '/d01'

            # APPWEB Owner #
default[:ebs][:vg][:app_fs_nam]            = '/applmgr'

            # tmp and opt sizes #
default[:ebs][:vg][:tmp_fs_siz]    = '10' # in GIGS
default[:ebs][:vg][:opt_fs_siz]    = '10' # in GIGS

default[:ebs][:vg][:fsopts] = "-Ayes -prw -a agblksize=4096 -a logsize=1024 -a isnapshot=no"
                               #options for the file system creation

#----------------------------
# Host system drives for use:
#----------------------------
# 
# SAS DRIVES OR SSD DRIVES: This will determine hdisk settings.
default[:ebs][:vg][:ssdhosts]             = [ 'p135n51' , 'p135n52', 'p135n53' ]
default[:ebs][:vg][:sashosts]             = [ 'p135n55' ]

#---------------------------------------------------------------
# Host system drives for use: 600 GIGS across the drives listed.
#---------------------------------------------------------------
#
default[:ebs][:vg][:drives]['p135n51']    = [ 'hdisk1', 'hdisk2', 'hdisk3' ]
default[:ebs][:vg][:drives]['p135n52']    = [ 'hdisk1', 'hdisk2', 'hdisk3' ]
default[:ebs][:vg][:drives]['p135n53']    = [ 'hdisk0', 'hdisk1', 'hdisk2' ]
default[:ebs][:vg][:drives]['p135n55']    = [ 'hdisk1', 'hdisk2' ]
  
#---------------------------------------------------
# Swap space requirements with ability to ignore.
# if :swapspace_ignore is set to true
#---------------------------------------------------
#
default[:ebs][:vg][:swapspace_ignore]  = false
default[:ebs][:vg][:swapspace]         = 16384      # in Megabytes


#----------------------------------------
# kernel attributes that will be changed
#----------------------------------------
#
default[:ebs][:ncargs]   = 1024
default[:ebs][:maxuproc] = 16384

#------------------------------------
# Kernel required filesets
#------------------------------------
#
default[:ebs][:chk_filesets] = [ 'bos.adt.base','bos.adt.lib', 'bos.adt.libm', 
                                 'bos.perf.libperfstat',    'bos.perf.perfstat',
                                 'bos.perf.proctools',      'rsct.basic.rte', 
                                 'rsct.compat.clients.rte', 'X11.motif.lib',
                                 'openssh.base.server' ]

#---------------------------------------------------
# Miscellaneous Attributes.
#---------------------------------------------------
#

default[:ebs][:ogrps][:grps]   = [ 'dba', 'staff' ]
default[:ebs][:ogrps]['dba'][:gid]       = 5000
default[:ebs][:ogrps]['staff'][:gid]       = 1
default[:ebs][:vncpw]   = 'vncpassword'

#------------------------------------
# Location of commands
#------------------------------------
#
default[:ebs][:cmd][:compiler]     = '/usr/vacpp/bin'
default[:ebs][:linux][:tools]      = [ 'unzip','vnc' ] 
default[:ebs][:cmd][:shell]        = '/bin/ksh'
default[:ebs][:cmd][:chpasswd]     = '/usr/bin/chpasswd'
default[:ebs][:cmd][:linkxlC]      = "#{node[:ebs][:cmd][:compiler]}/linkxlC"
default[:ebs][:chk_symlinks]       = [ '/usr/bin/ar',   '/usr/bin/ld', 
                                       '/usr/bin/make', '/usr/bin/linkxlC']

#---------------------------------
# AIX Version Fileset Min and Max
#---------------------------------
#
default[:ebs][:aix]['6.1'][:min_lvl] = '6100-07-04'
default[:ebs][:aix]['6.1'][:max_lvl] = '6100-09+'

default[:ebs][:aix]['7.1'][:min_lvl] = '7100-01-03'
default[:ebs][:aix]['7.1'][:max_lvl] = '7100-03+'

default[:ebs][:aix]['7.2'][:min_lvl] = '7200-00-00'
default[:ebs][:aix]['7.2'][:max_lvl] = '7200-03+'


default[:ebs][:root][:env] = {
    'HOME'     => '/',
    'LOGIN'    => 'root',
    'LOGNAME'  => 'root',
    'USER'     => 'root',
    'ENV'      => '/.kshrc',
    'LOCPATH'  => '/usr/lib/nls/loc:/usr/vacpp/bin',
    'NLSPATH'  => '/usr/lib/nls/msg/%L/%N:/usr/lib/nls/msg/%L/%N.cat:'\
                  '/usr/lib/nls/msg/%l.%c/%N:/usr/lib/nls/msg/%l.%c/%N.cat:'\
                  '/usr/vacpp/bin',
    'PATH'     => '/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:'\
                  '/usr/java5/jre/bin:/usr/java5/bin:/usr/vacpp/bin:'\
                  '/usr/lpp/ssp/bin:/usr/lib/instl/:/usr/sbin:/usr/bin:'\
                  '/usr/lpp/ssp/rcmd/bin:/var/sysman:/etc/auto:/usr/lpp/csd/bin:'\
                  '/usr/lpp/mmfs/bin:/opt/ibmll/LoadL/full/bin:/usr/sbin/rsct/bin:'\
                  '/usr/lpp/LoadL/full/bin:/usr/bin/lsf/bin:/usr/bin/lsf/etc:'\
                  '/opt/csm/bin:/usr/lpp/ssp/local/bin:/vol/local/sbin:'\
                  '/vol/local/etc:/vol/local/bin::/usr/opt/ifor/ls/os/aix/bin:'\
                  '/opt/LicenseUseManagement/bin',
    'SHELL'    => '/usr/bin/ksh',
    'DSH_PATH' => '/bin:/usr/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:'\
                  '/sbin:/usr/java5/jre/bin:/usr/java5/bin:/usr/vacppDSH_PATH=/bin:'\
                  '/usr/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:'\
                  '/usr/java5/jre/bin:/usr/java5/bin:/usr/vacpp/bin:'\
                  '/usr/lpp/ssp/bin:/usr/lib/instl/:/usr/sbin:/usr/bin:'\
                  '/usr/lpp/ssp/rcmd/bin:/var/sysman:/etc/auto:/usr/lpp/csd/bin:'\
                  '/usr/lpp/mmfs/bin:/opt/ibmll/LoadL/full/bin:/usr/sbin/rsct/bin:'\
                  '/usr/lpp/LoadL/full/bin:/usr/bin/lsf/bin:/usr/bin/lsf/etc:'\
                  '/opt/csm/bin:/usr/lpp/ssp/local/bin:/vol/local/sbin:'\
                  '/vol/local/etc:/vol/local/bin:',
    'LANG'     => 'en_US',
    'LANGUAGE' => 'en_US',
    'LC_ALL'   => 'en_US',
    'TERM'     => 'vt100'
    }



#------------------------------------
# The stage directory attributes
#------------------------------------
#
default[:ebs][:dbm_patchdir]               = "#{node[:ebs][:vg][:db_fs_nam]}/Patches"





default[:ebs][:stage][:nfsmount]           = '/ebstage'
default[:ebs][:stage][:dir]                = "#{node[:ebs][:stage][:nfsmount]}/stage"
default[:ebs][:stage][:rapiddir]           = "#{node[:ebs][:stage][:dir]}/startCD/Disk1/rapidwiz"
default[:ebs][:stage][:nfshost]            = 'p134n31'
#default[:ebs][:stage][:patches]            = "#{node[:ebs][:stage][:dir]}/Patches"
default[:ebs][:stage][:zips]               = "#{node[:ebs][:stage][:nfsmount]}/zips"
default[:ebs][:stage][:bin_11204]          = "#{node[:ebs][:stage][:nfsmount]}/DBMS/11.2.0.4_base"

#default[:ebs][:stage][:opatch_11204]       = "#{node[:ebs][:stage][:patches]}/"\
#                                             "opatch/p6880880_112000_AIX64-5L.zip"
#default[:ebs][:stage][:pat_11204]          = "#{node[:ebs][:stage][:dir]}/DBMS/patches"

#
#---------------------------------------------------------
# Required DB Patches from document:( Doc ID 1594274.1)  -
#---------------------------------------------------------
#
default[:ebs][:stage][:patches_11204]      = [ '12949905','16075609','18485835','18604144','18708921',
                                               '18828868','18966843','19835133','19949371','20488666',
                                               '20678391','21034704','21249127','21472186','22127738' ]
default[:ebs][:stage][:bundles_11204]      = [ '20523280' ]
default[:ebs][:stage][:post_patches_11204] = [ '18966843','21472186','22127738' ]

#order is important here.
default[:ebs][:stage][:post_bundles_11204] = [ '@?/rdbms/admin/catbundle.sql EBS apply',
                                               '@?/md/admin/catmgdidcode.sql']
#default[:ebs][:stage][:fmw][:patchd]       = "#{node[:ebs][:stage][:patches]}/fmw_web"
default[:ebs][:stage][:fmw][:opatchn]      = '6880880_111000'
default[:ebs][:stage][:fmw][:patches]      = [ '17526668','20493440' ]

#default[:ebs][:stage][:ocommon][:patchd]   = "#{node[:ebs][:stage][:patches]}/ocommon"
default[:ebs][:stage][:ocommon][:opatchn]  = '6880880_111000'
#default[:ebs][:stage][:ocommon][:opatch]   = "#{node[:ebs][:stage][:patches]}/ocommon"\
#                                            "/p6880880_111000_AIX64-5L.zip"
default[:ebs][:stage][:ocommon][:patches]  = [ '9905685/oui','14754223' ] 

default[:ebs_group]         = 'oinstall'
default[:ebs_groupid]       = 1000

     #***********************************************#
     #**                                          ***#
     #**          DBMS Owner Attributes           ***#
     #**                                          ***#
     #***********************************************#

default[:ebs_dbuser]                  = 'oraprod'
default[:ebs_dbgroup]                 = node[:ebs_group]
default[:ebs][:db][:usr][:name]       = node[:ebs_dbuser]
default[:ebs][:db][:usr][:passwd]     = 'oraprod'
default[:ebs][:db][:usr][:uid]        = 3000
default[:ebs][:db][:usr][:pgrp]       = node[:ebs_dbgroup]
default[:ebs][:db][:usr][:pgid]       = node[:ebs_groupid]
default[:ebs][:db][:usr][:homedir]    = "/home/#{node[:ebs][:db][:usr][:name]}"

default[:ebs][:db][:dbf_dir]          = "#{node[:ebs][:vg][:db_fs_nam]}/oradata"
default[:ebs][:db][:sid]              = 'VIS'
default[:ebs][:db][:orabase]          = "#{node[:ebs][:vg][:db_fs_nam]}/oracle"
default[:ebs][:db][:oraInv]           = "#{node[:ebs][:vg][:db_fs_nam]}/oraInventory"
default[:ebs][:db][:orahome3]         = "#{node[:ebs][:db][:orabase]}/VIS/11.2.0"
default[:ebs][:db][:orahome4]         = "#{node[:ebs][:db][:orabase]}/VIS/11.2.0.4"

default[:ebs][:db][:bin]              = "#{node[:ebs][:vg][:db_fs_nam]}/bin"
default[:ebs][:db][:outdir]           = "#{node[:ebs][:vg][:db_fs_nam]}/log"
default[:ebs][:db][:DBENVF]           = "#{node[:ebs][:db][:bin]}/1124.env"
default[:ebs][:syspw]                 = 'manager' #dbms SYSTEM/manager Oracle password
default[:ebs][:sid_hname]             =  "#{node[:ebs][:db][:sid]}_#{node[:hostname]}"


default[:ebs][:db][:env_11203] = {
            'ORACLE_BASE' => node[:ebs][:db][:orabase],
            'ORACLE_HOME' => node[:ebs][:db][:orahome3],
            'ORACLE_SID'  => node[:ebs][:db][:sid],
            'HOME'        => node[:ebs][:db][:usr][:homedir],
            'LOGIN'       => node[:ebs][:db][:usr][:name],
            'LOGNAME'     => node[:ebs][:db][:usr][:name],
            'USER'        => node[:ebs][:db][:usr][:name],
            'PATH'        => "/usr/bin:/etc:/usr/sbin:"\
                             "/usr/ucb:/usr/bin/X11:/sbin:/usr/local/bin:"\
                             "#{node[:ebs][:db][:orahome3]}/bin:"\
                             "#{node[:ebs][:db][:orahome3]}/perl/bin:"\
                             "#{node[:ebs][:db][:orahome3]}/OPatch:"\
                             "#{node[:ebs][:cmd][:compiler]}:"\
                             "#{node[:ebs][:db][:usr][:homedir]}/bin:.",
            'SHLIB_PATH' => "#{node[:ebs][:db][:orahome3]}/lib:"\
                            "#{node[:ebs][:db][:orahome3]}/ctx/lib",
            'LOCPATH'    => "/usr/lib/nls/loc:/usr/vacpp/bin",
            'NLSPATH'    => "/usr/lib/nls/msg/%L/%N:/usr/lib/nls/msg/%L/%N.cat:"\
                            "/usr/lib/nls/msg/%l.%c/%N:/usr/lib/nls/msg/%l.%c/%N.cat:"\
                            "/usr/vacpp/bin",
            'LIBPATH'    => "#{node[:ebs][:db][:orahome3]}/lib:/usr/dt/lib:"\
                            "/usr/openwin/lib:#{node[:ebs][:db][:orahome3]}/lib:"\
                            "#{node[:ebs][:db][:orahome3]}/ctx/lib:",
    'LD_LIBRARY_PATH'    => "#{node[:ebs][:db][:orahome3]}/lib:/usr/dt/lib:"\
                            "/usr/openwin/lib:#{node[:ebs][:db][:orahome3]}/lib:"\
                            "#{node[:ebs][:db][:orahome3]}/ctx/lib:",
            'PERL5LIB'   => "#{node[:ebs][:db][:orahome3]}/perl/lib:"\
                            "#{node[:ebs][:db][:orahome3]}/perl/lib/5.10.0:"\
                            "#{node[:ebs][:db][:orahome3]}/perl/lib/site_perl/5.10.0",
          'LANG'         => 'en_US',
          'LANGUAGE'     => 'en_US',
          'LC_ALL'       => 'en_US',
            'ORA_NLS10'  => "#{node[:ebs][:db][:orahome3]}/nls/data/9idata",
            'PERL5LIB'   => "#{node[:ebs][:db][:orahome3]}/perl/lib:"\
                            "#{node[:ebs][:db][:orahome3]}/perl/lib/5.10.0:"\
                            "#{node[:ebs][:db][:orahome3]}/perl/lib/site_perl/5.10.0",
            'TNS_ADMIN'  => "#{node[:ebs][:db][:orahome3]}/network/admin/"\
                            "#{node[:ebs][:db][:sid]}_#{node[:hostname]}",
          'SKIP_ROOTPRE' => 'TRUE',
           }

default[:ebs][:db][:env_11204] = {
            'ORACLE_BASE' => node[:ebs][:db][:orabase],
            'ORACLE_HOME' => node[:ebs][:db][:orahome4],
            'ORACLE_SID'  => node[:ebs][:db][:sid],
            'HOME'        => node[:ebs][:db][:usr][:homedir],
            'LOGIN'       => node[:ebs][:db][:usr][:name],
            'LOGNAME'     => node[:ebs][:db][:usr][:name],
            'USER'        => node[:ebs][:db][:usr][:name],
            'PATH'        => "/usr/bin:/etc:/usr/sbin:"\
                             "/usr/ucb:/usr/bin/X11:/sbin:/usr/local/bin:"\
                             "#{node[:ebs][:db][:orahome4]}/bin:"\
                             "#{node[:ebs][:db][:orahome4]}/perl/bin:"\
                             "#{node[:ebs][:db][:orahome4]}/OPatch:"\
                             "#{node[:ebs][:cmd][:compiler]}:"\
                             "#{node[:ebs][:db][:usr][:homedir]}/bin:.",
            'SHLIB_PATH' => "#{node[:ebs][:db][:orahome4]}/lib:"\
                            "#{node[:ebs][:db][:orahome4]}/ctx/lib",
            'LOCPATH'    => "/usr/lib/nls/loc:/usr/vacpp/bin",
            'NLSPATH'    => "/usr/lib/nls/msg/%L/%N:/usr/lib/nls/msg/%L/%N.cat:"\
                            "/usr/lib/nls/msg/%l.%c/%N:/usr/lib/nls/msg/%l.%c/%N.cat:"\
                            "/usr/vacpp/bin",
            'LIBPATH'    => "#{node[:ebs][:db][:orahome4]}/lib:/usr/dt/lib:"\
                            "/usr/openwin/lib:#{node[:ebs][:db][:orahome4]}/lib:"\
                            "#{node[:ebs][:db][:orahome4]}/ctx/lib:",
    'LD_LIBRARY_PATH'    => "#{node[:ebs][:db][:orahome4]}/lib:/usr/dt/lib:"\
                            "/usr/openwin/lib:#{node[:ebs][:db][:orahome4]}/lib:"\
                            "#{node[:ebs][:db][:orahome4]}/ctx/lib:",
            'PERL5LIB'   => "#{node[:ebs][:db][:orahome4]}/perl/lib:"\
                            "#{node[:ebs][:db][:orahome4]}/perl/lib/5.10.0:"\
                            "#{node[:ebs][:db][:orahome4]}/perl/lib/site_perl/5.10.0",
          'LANG'         => 'en_US',
          'LANGUAGE'     => 'en_US',
          'LC_ALL'       => 'en_US',
            'ORA_NLS10'  => "#{node[:ebs][:db][:orahome4]}/nls/data/9idata",
            'PERL5LIB'   => "#{node[:ebs][:db][:orahome4]}/perl/lib:"\
                            "#{node[:ebs][:db][:orahome4]}/perl/lib/5.10.0:"\
                            "#{node[:ebs][:db][:orahome4]}/perl/lib/site_perl/5.10.0",
            'TNS_ADMIN'  => "#{node[:ebs][:db][:orahome4]}/network/admin/"\
                            "#{node[:ebs][:db][:sid]}_#{node[:hostname]}",
          'SKIP_ROOTPRE' => 'TRUE',
           }

#--------------------------------------------------------------
# Latest OPatch for DBMS. Might be different than App server. -
#--------------------------------------------------------------
#
  #mulitple versions of opatch. so we need more info to identify the zip file
  #
default[:ebs][:db][:opatchn] = 'p6880880_112000'

#-------------------------------------------------------
# DB Patches requiring postinstall.sql to be executed  -
#-------------------------------------------------------
#

     #***********************************************#
     #**                                          ***#
     #**          APP/WEB Owner Attributes        ***#
     #**                                          ***#
     #***********************************************#


#------------------------------------
# Applmgr Attributes
#------------------------------------
#
default[:ebs_appuser]                  = 'applmgr'
default[:ebs_appgroup]                 = node[:ebs_group]
default[:ebs][:app][:usr][:name]       = node[:ebs_appuser]
default[:ebs][:app][:usr][:passwd]     = 'applmgr'
default[:ebs][:app][:usr][:uid]        = 2000
default[:ebs][:app][:usr][:pgrp]       = node[:ebs_appgroup]
default[:ebs][:app][:usr][:pgid]       = node[:ebs_groupid]
default[:ebs][:app][:usr][:homedir]    = "/home/#{node[:ebs][:app][:usr][:name]}"
default[:ebs][:app][:bin]              = "#{node[:ebs][:vg][:app_fs_nam]}/bin"
default[:ebs][:app][:outdir]           = "#{node[:ebs][:vg][:app_fs_nam]}/log"

default[:ebs][:appsuser] = 'APPS' # EBS apps user
default[:ebs][:appspw]   = 'apps'

default[:ebs][:wlsuser]  = 'weblogic' # weblogic user
default[:ebs][:wlspw]    = 'welcome1'

default[:ebs][:app][:env] = {
            'ORACLE_BASE' => node[:ebs][:db][:orabase],
            'ORACLE_HOME' => node[:ebs][:db][:orahome],
            'ORACLE_SID'  => node[:ebs][:db][:sid],
            'HOME'        => node[:ebs][:app][:usr][:homedir],
            'LOGIN'       => node[:ebs][:app][:usr][:name],
            'LOGNAME'     => node[:ebs][:app][:usr][:name],
            'USER'        => node[:ebs][:app][:usr][:name],
            'PATH'        => "#{node[:ebs][:app][:orahome]}/bin:"\
                             "/usr/ccs/bin:"\
                             "/usr/sbin:"\
                             "#{node[:ebs][:app][:orahome]}/appsutil/jre/bin:"\
                             "/usr/bin:"\
                             "/etc:"\
                             "/usr/lbin:"\
                             "/usr/bin/X11:"\
                             "/usr/local/bin:"\
                             "/usr/bin:"\
                             "/etc:"\
                             "/usr/sbin:"\
                             "/usr/ucb:"\
                             "/usr/bin/X11:"\
                             "/sbin:"\
                             "#{node[:ebs][:app][:orahome]}/OPatch"\
                             "#{node[:ebs][:app][:usr][:homedir]}/bin:"\
                             ".:",
            'SHLIB_PATH' => "#{node[:ebs][:app][:orahome]}/lib:"\
                            "#{node[:ebs][:app][:orahome]}/ctx/lib",
            'LOCPATH'    => "/usr/lib/nls/loc:/opt/IBM/xlC/13.1.0/bin",
            'NLSPATH'    => "/usr/lib/nls/msg/%L/%N:/usr/lib/nls/msg/%L/%N.cat:"\
                            "/usr/lib/nls/msg/%l.%c/%N:"\
                            "/usr/lib/nls/msg/%l.%c/%N.cat:"\
                            "/opt/IBM/xlC/13.1.0/bin",
            'LIBPATH'    => "#{node[:ebs][:app][:orahome]}/lib:/usr/dt/lib:"\
                            "/usr/openwin/lib:#{node[:ebs][:app][:orahome]}/ctx/lib:"\
                            "#{node[:ebs][:app][:orahome]}/lib32:"\
                            "#{node[:ebs][:app][:orahome]}/ctx/lib",
       'LD_LIBRARY_PATH' => "#{node[:ebs][:app][:orahome]}/lib:/usr/dt/lib:"\
                            "/usr/openwin/lib:#{node[:ebs][:app][:orahome]}/ctx/lib",
           }


     #***********************************************#
     #**                                          ***#
     #**       Staging Owner Attributes           ***#
     #**                                          ***#
     #***********************************************#


#------------------------------------
# rapidwiz command installation atts
#------------------------------------
#
default[:ebs][:rapidwiz][:conf]       = "#{node[:ebs][:vg][:db_fs_nam]}/conf_"\
                                        "#{node[:ebs][:db][:sid]}.txt"
default[:ebs][:rapidwiz][:vnc_num]    = "10"
default[:ebs][:rapidwiz][:display]    = "#{node[:hostname]}:#{node[:ebs][:rapidwiz][:vnc_num]}.0"
default[:ebs][:rapidwiz][:opts]       = "-silent -waitforreturn -config "\
					"#{node[:ebs][:rapidwiz][:conf]}"
default[:ebs][:rapidwiz][:cmd]        = "#{node[:ebs][:stage][:rapiddir]}/rapidwiz "\
					"#{node[:ebs][:rapidwiz][:opts]}"

#-------------------------------------------------------
# Application Environments
#-------------------------------------------------------
#
#      . /applmgr/fs1/EBSapps/appl/APPSVIS_p135n53.env
default[:ebs][:app][:runbase]   = "#{node[:ebs][:vg][:app_fs_nam]}/fs1/EBSapps"
default[:ebs][:app][:runhome]   = "#{node[:ebs][:app][:runbase]}/10.1.2"
default[:ebs][:app][:runenv]    = "#{node[:ebs][:app][:runbase]}/appl/APPS"\
                                  "#{node[:ebs][:db][:sid]}_#{node[:hostname]}.env"
default[:ebs][:app][:contxtfs1] = "#{node[:ebs][:vg][:app_fs_nam]}/fs1/inst/apps/"\
                                  "#{node[:ebs][:db][:sid]}_#{node[:hostname]}/"\
				  "appl/admin/#{node[:ebs][:db][:sid]}_#{node[:hostname]}.xml"

default[:ebs][:app][:FS1ENVF]   = "#{node[:ebs][:vg][:app_fs_nam]}/"\
                                  "fs1/EBSapps/appl/APPS#{node[:ebs][:sid_hname]}.env"
default[:ebs][:app][:FS2ENVF]   = "#{node[:ebs][:vg][:app_fs_nam]}/"\
                                  "fs2/EBSapps/appl/APPS#{node[:ebs][:sid_hname]}.env"

default[:ebs][:app][:patchbase] = "#{node[:ebs][:vg][:app_fs_nam]}/fs2/EBSapps"
default[:ebs][:app][:patchhome] = "#{node[:ebs][:app][:patchbase]}/10.1.2"
default[:ebs][:app][:contxtfs2] = "#{node[:ebs][:vg][:app_fs_nam]}/fs2/inst/apps/"\
                                  "#{node[:ebs][:db][:sid]}_#{node[:hostname]}/"\
				  "appl/admin/#{node[:ebs][:db][:sid]}_#{node[:hostname]}.xml"

default[:ebs][:app][:ne_base]   = "#{node[:ebs][:vg][:app_fs_nam]}/fs_ne/EBSapps"

default[:ebs][:app][:fmw][:home]      = "#{node[:ebs][:vg][:app_fs_nam]}/fs1/FMW_Home/webtier"
default[:ebs][:app][:ocommon][:home]  = "#{node[:ebs][:vg][:app_fs_nam]}/fs1/FMW_Home/oracle_common"

#-----------------------------------------
# EBS Technology Code Checker            -
# ( Doc ID 2008451.1)                    -
#-----------------------------------------
#
default[:ebs][:etcc][:patchn]       = '17537119'
default[:ebs][:etcc][:rundir]       = "#{node[:ebs][:dbm_patchdir]}/etcc"
default[:ebs][:etcc][:dbm_contextf] = "#{node[:ebs][:db][:orahome4]}/appsutil/"\
                                      "#{node[:ebs][:db][:sid]}_#{node[:hostname]}.xml"


#-----------------------------------------
# Consolidated Seed Table Upgrade Patch  -
# ( Doc ID 1594274.1)                    -
#-----------------------------------------
#
default[:ebs][:seedTable][:patchnum] = '17204589'
default[:ebs][:seedTable][:patchdir] = "#{node[:ebs][:app][:ne_base]}/patch"
default[:ebs][:seedTable][:adop_cmd] = "#{node[:ebs][:app][:ne_base]}/appl/ad/bin/adop"


#----------------------------------
#Forms and Repost Upgrade Patch   -
#      ( Doc ID 1594274.1)        -
#----------------------------------
#
default[:ebs][:forms][:opatchn]        = 'p6880880_101000'
#default[:ebs][:forms][:patchsrc]       = "#{node[:ebs][:stage][:patches]}/forms"
default[:ebs][:forms][:patches]        = [ '21103001' ]

#-----------------------------------------
# AD and TXK Patches                     -
# ( Doc ID 1594274.1)                    -
#-----------------------------------------
#
default[:ebs][:ad_patches][:patch1]  = '20745242'
default[:ebs][:ad_patches][:patch2]  = '22123818'
default[:ebs][:txk_patches][:patchlst] = [ '20784380','22363475' ]

# this is the newest adgrants.sql within the patch set of ad_patches
default[:ebs][:adgrants][:patchn]    = '22123818'

#-----------------------------------------
# 12.2.5 Upgrade Patch                   -
# ( Doc ID 1983050.1 Section 8)          -
#-----------------------------------------
#
default[:ebs][:patch1225] = '19676458'

#-----------------------------------------
# Post 12.2.5 Online Patch               -
# ( Doc ID 1983050.1 Section 9)          -
#-----------------------------------------
#
default[:ebs][:post1225][:patch1]  = '19676460'

#-----------------------------------------
# Additional Critical Patches            -
# ( Doc ID 1983050.1 Section 10)         -
#-----------------------------------------
#
default[:ebs][:critical][:patch1]  = '21483810'

