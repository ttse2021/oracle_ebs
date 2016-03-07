log '
     ***************************************
     *                                     *
     *        EBS Recipe:xit_checks        *
     *                                     *
     ***************************************
    '

log '
     ----------------------------------------------
     |********************************************|
     |****                                    ****|
     |****    EBS INSTALLTION COMPLETE        ****|
     |****                                    ****|
     |********************************************|
     ----------------------------------------------
    '

log '
     *******************************************************
     * Here are some things you should check:              *
     *                                                     *
     *  a) sqlplus apps/apps                               *
     *     select release_name from fnd_product_groups;    *
     *     The version should be 12.2.5                    *
     *                                                     *
     *  b) Login onto the application:                     *
     *      Bring up a browser and type URL:               *
     *     <hostname>:8000/OA_HTML/AppsLogin               *
     *      UserName: SYSADMIN Password: sysadmin          *
     *           goto:                                     *
     *     System Administration ->                        *
     *        Applications System status                   *
     *    Check out the host machine and Software Updates  *
     *    Tab for accuracy                                 *
     *                                                     *
     *  c) Login onto the web server:                      *
     *      Bring up a browser and type URL:               *
     *     <hostname>:7001/console/                        *
     *      UserName: weblogic Password: welcome1          *
     *           goto: Servers                             *
     *                                                     *
     *  d) Practice using startapp, startwls, startdb,     *
     *     stopapp, stopwls,  and stopdb  scripts          *
     *                                                     *
     *  e) Take a backup of the system                     *
     *                                                     *
     *******************************************************
    '

log '
     ----------------------------------------------
     |********************************************|
     |****                                    ****|
     |****    EBS INSTALLTION COMPLETE        ****|
     |****                                    ****|
     |********************************************|
     ----------------------------------------------
    '

