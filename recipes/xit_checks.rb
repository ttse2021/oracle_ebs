log "***************************************"
log "*                                     *"
log "*     EBS Recipe:xit_checks           *"
log "*                                     *"
log "***************************************"

log "----------------------------------------------"
log "|********************************************|"
log "|****                                    ****|"
log "|****    EBS INSTALLTION COMPLETE        ****|"
log "|****                                    ****|"
log "|********************************************|"
log "----------------------------------------------"

log "*******************************************************"
log "* Here are some things you should check:              *"
log "*                                                     *"
log "*  a) sqlplus apps/apps                               *"
log "*     select release_name from fnd_product_groups;    *"
log "*     The version should be 12.2.5                    *"
log "*                                                     *"
log "*  b) Login onto the application:                     *"
log "*      Bring up a browser and type URL:               *"
log "*     <hostname>:8000/OA_HTML/AppsLogin               *"
log "*      UserName: SYSADMIN Password: sysadmin          *"
log "*           goto:                                     *"
log "*     'System Administration' ->                      *"
log "*        'Applications System status'                 *"
log "*    Check out the host machine and Software Updates  *"
log "*    Tab for accuracy                                 *"
log "*                                                     *"
log "*  c) Login onto the web server:                      *"
log "*      Bring up a browser and type URL:               *"
log "*     <hostname>:7001/console/                        *"
log "*      UserName: weblogic Password: welcome1          *"
log "*           goto: Servers                             *"
log "*                                                     *"
log "*  d) Practice using startapp, startwls, startdb,     *"
log "*     stopapp, stopwls,  and stopdb  scripts          *"
log "*                                                     *"
log "*  e) Take a backup of the system                     *"
log "*                                                     *"
log "*******************************************************"

log "----------------------------------------------"
log "|********************************************|"
log "|****                                    ****|"
log "|****    EBS INSTALLTION COMPLETE        ****|"
log "|****                                    ****|"
log "|********************************************|"
log "----------------------------------------------"
