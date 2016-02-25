log '**********************************************'
log '*                                            *'
log '*        EBS Recipe:1225_upg2                *'
log '*                                            *'
log '**********************************************'

appuser     =  node[:ebs_appuser]
appgroup    =  node[:ebs_appgroup]
appenv      =  node[:ebs][:app][:env]
binapp      =  node[:ebs][:app][:bin]
outapp      =  node[:ebs][:app][:outdir]
patchtop    =  node[:ebs][:seedTable][:patchdir]


  #####################################################################
  # Doc_id: 1983050.1 Section 9 Step1                                 #
  # Apply Oracle E-Business Suite Release 12.2.5 Online Help          #
  ##################################################################### 
  #    adop phase=apply apply_mode=downtime patches=19676460          #
  ##################################################################### 


patchn=node[:ebs][:post1225][:patch1]
target= node[:ebs][:seedTable][:patchdir]
log "#{binapp}/getpatch.sh -p #{patchn} -t #{target}\n"
execute "unzip_#{patchn}" do
  user    appuser
  group   appgroup
  cwd     node[:ebs][:stage][:zips]
  command "#{binapp}/getpatch.sh -p #{patchn} -t #{target}\n"
  not_if { File.directory?( "#{target}/#{patchn}" ) }
end

template "#{binapp}/post_1225_hpatch.sh" do
  source 'post_1225_hpatch.sh.erb'
  user  appuser
  group appgroup
  mode '0775'
end

  log '***************************************************'
  log '* Applying 12.2.5 patch   takes 15 minutes        *'
  log '***************************************************'

patch=node[:ebs][:post1225][:patch1]
execute "post_1225_patch_#{patch}" do
  user 'root'
  command "su - #{appuser} -c "\
          "'cd #{patchtop} && #{binapp}/post_1225_hpatch.sh > #{outapp}/out.1225_post_hpatch 2>&1 && "\
          "touch #{outapp}/t.1225_post_hpatch'"
  creates       "#{outapp}/t.1225_post_hpatch"
end

  #####################################################################
  # Doc_id: 1983050.1 Section 9 Step 2                                #
  # Grant flexfield value set access to specific users (required)     #
  ##################################################################### 
  #   N/A. Not for new users. only for prev to 12.0 version           # 
  ##################################################################### 


  #####################################################################
  # Doc_id: 1983050.1 Section 9 Step 3                                #
  # Register new products (conditional)                               #
  #   Product Short Name        Product Name                          #
  #   yms                       Oracle Yard Management                #
  #   cmi                       Oracle In-memory Cost Management      #
  ##################################################################### 
  #   N/A. Not applicable, as we arent using this products            #
  ##################################################################### 

  #####################################################################
  # Doc_id: 1983050.1 Section 9 Step 4                                #
  # Perform Product-Specific Steps (conditional on these products)    #
  #   Application Technology tasks:                                   #
  #     Oracle Application Framework                                  #
  #     Oracle E-Business Suite Integrated SOA Gateway:               #
  #     Oracle Report Manager:                                        #
  #     Oracle Workflow:                                              #
  #   Customer Relationship Management tasks:                         #
  #     Oracle Advanced Scheduler and Field Service:                  #
  #     Oracle Incentive Compensation customers:                      #
  #     Oracle Mobile Field Service customers:                        #
  #     Oracle Price Protection customers:                            #
  #     Oracle Spares Management customers:                           #
  #   Financials tasks:                                               #
  #     Oracle Subledger Accounting:                                  #
  #   Human Resources tasks:                                          #
  #     Human Resources Legislative customers only:                   #
  #     Single Latest Balance Table Upgrade (Payroll only):           #
  #     Submit Update Action Type of Assignment Action (Payroll only):#
  #   Procurement tasks:                                              #
  #     Oracle Purchasing with Oracle Transportation Management:      #
  #   Supply Chain Management tasks:                                  #
  #     Oracle Complex Maintenance Repair and Overhaul:               #
  #     Oracle Flow Manufacturing:                                    #
  #     Oracle In-Memory Cost Management for Discrete Industries:     #
  #     Oracle In-Memory Cost Management for Process Industries:      #
  #     Oracle Manufacturing Operations Center:                       #
  #     Oracle Mobile Application Server:                             #
  #     Oracle Shipping Execution:                                    #
  #     Oracle Shipping Execution with Oracle Transportation Mgmt:    #
  #     Oracle Warehouse Management with Oracle Transportation Mgmt:  #
  #     Oracle Yard Management:                                       #
  #   Value Chain Planning tasks:                                     #
  #     Oracle Value Chain Planning:                                  #
  #####################################################################
  #   N/A. Not part of goal.                                          #
  ##################################################################### 

  #####################################################################
  # Doc_id: 1983050.1 Section 9 Step 5                                #
  # Perform NLS-related Step (conditional)                            #
  #  For languanges other than American English installed on your     #
  #  Release 12.2.0 system.                                           #
  ##################################################################### 
  #   N/A. Not applicable, as we arent installing other languages     #
  ##################################################################### 

  #####################################################################
  # Doc_id: 1983050.1 Section 9 Step 6                                #
  #   Patch Wizard Utility [Video] (Doc ID 976188.1)                  #
  ##################################################################### 
  #   N/A. This is GUI based and not part of scope.                   #
  ##################################################################### 


