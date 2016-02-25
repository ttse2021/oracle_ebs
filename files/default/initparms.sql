archive log list;
shutdown immediate
startup mount;
alter database noarchivelog;
alter database open;
archive log list;

ALTER SYSTEM SET audit_sys_operations=FALSE SCOPE=SPFILE;
ALTER SYSTEM SET sga_target=3G SCOPE=SPFILE;
ALTER SYSTEM SET shared_pool_reserved_size=60M SCOPE=SPFILE;
ALTER SYSTEM SET shared_pool_size=600M SCOPE=SPFILE;
ALTER SYSTEM SET processes=800 SCOPE=SPFILE;
ALTER SYSTEM SET sessions=1600 SCOPE=SPFILE;
ALTER SYSTEM SET pga_aggregate_target=4G  SCOPE=SPFILE;
shutdown immediate
startup
quit;
