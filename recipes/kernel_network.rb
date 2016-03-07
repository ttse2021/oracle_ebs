log '
     **********************************************
     *                                            *
     *        EBS Recipe:kernel_network           *
     *                                            *
     **********************************************
    '

aix_no "changing no tunables" do
  tunables( :rfc1323 => 1,
            :sb_max  => 4194304,
            :tcp_ephemeral_high => 65500,
            :tcp_ephemeral_low  => 9000,
            :udp_ephemeral_high => 65500,
            :udp_ephemeral_low  => 9000,
            :tcp_recvspace => 262144,
            :tcp_sendspace => 262144,
            :udp_recvspace => 262144,
            :udp_sendspace => 262144,
            :tcp_timewait => 1
  )
  set_default
  action :update
end

