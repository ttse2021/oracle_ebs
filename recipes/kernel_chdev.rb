log '
     *****************************************
     *                                       *
     *        EBS Recipe:kerne_chdev         *
     *                                       *
     *****************************************
    '


  # Typically the number of processes per user limit is small, lets increase for EBS
  #
aix_chdev "sys0" do
  attributes(:maxuproc => node[:ebs][:maxuproc], :ncargs => node[:ebs][:ncargs])
  need_reboot true
  action :update
end

  # This is needed for the DBMS install
  #
aix_chdev "iocp0" do
  attributes(:autoconfig => "available")
  need_reboot true
  action :update
end

