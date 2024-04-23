Content-Type: multipart/mixed; boundary="==Boundary=="
MIME-Version: 1.0

--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
set hostname hub-fgt
set admintimeout 15
set admin-sport ${gui_port}
end

config system interface
edit port1
set mode dhcp
set allowaccess https ping ssh fgfm
set mtu-override enable
set mtu 9001
set alias public
next
edit port2
set mode dhcp
set defaultgw disable
set dns-server-override disable
set allowaccess ping
set mtu-override enable
set mtu 9001
set alias private
next
end

config router static
edit 1
set device port2
set dst ${vpc_cidr}
set dynamic-gateway enable
next
end

config vpn certificate ca
    edit "example-ca"
        set ca "${ca_cert}"
    next
end

config vpn certificate local
    edit "hub-fgt"
        set private-key "${fgt_key}"
        set certificate "${fgt_cert}"
    next
end

config user peer
    edit "signed-by-example-ca"
        set ca "example-ca"
    next
end

config user local
    edit ${sv_user}
        set type password
        set passwd ${sv_passwd}
    next
end

config user group
    edit "spoke-fgts-ugroup"
        set member "spoke-fgt"
    next
end

config system sdn-connector
edit aws-instance-role
set status enable
set type aws
set use-metadata-iam enable
set alt-resource-ip enable
next
end

config firewall address
edit "spoke-fgt-tun-ip"
set type iprange
set start-ip ${sv_tunnel_ip}
set end-ip ${sv_tunnel_ip}
next
edit "10.0.0.0/8"
set subnet 10.0.0.0 255.0.0.0
next
edit "172.16.0.0/12"
set subnet 172.16.0.0 255.240.0.0
next
edit "192.168.0.0/16"
set subnet 192.168.0.0 255.255.0.0
next
end

config firewall addrgrp
edit "rfc-1918-subnets"
set member "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
next
edit "spoke-fgts-agroup"
set member "spoke-fgt-tun-ip"
end

config vpn ssl web portal
    edit "no-access"
    next
    edit "spoke-fgt-portal"
        set tunnel-mode enable
        set forticlient-download disable
        set ip-pools "spoke-fgt-tun-ip"
    next
end

config vpn ssl settings
    set servercert "hub-fgt"
    set tunnel-ip-pools "SSLVPN_TUNNEL_ADDR1"
    set tunnel-ipv6-pools "SSLVPN_TUNNEL_IPv6_ADDR1"
	set port ${sv_port}
    set source-interface "port1"
    set source-address "all"
    set source-address6 "all"
    set default-portal "no-access"
    config authentication-rule
        edit 1
            set groups "spoke-fgts-ugroup"
            set portal "spoke-fgt-portal"
            set client-cert enable
            set user-peer "signed-by-example-ca"
        next
    end
end

config firewall policy
    edit 1
        set name "inbound-spoke-fgts"
        set srcintf "ssl.root"
        set dstintf "port2"
        set action accept
        set srcaddr "spoke-fgts-agroup"
        set dstaddr "rfc-1918-subnets"
        set schedule "always"
        set service "ALL"
        set logtraffic all
        set groups "spoke-fgts-ugroup"
    next
    edit 2
        set name "outbound-spoke-fgts"
        set srcintf "port2"
        set dstintf "ssl.root"
        set action accept
        set srcaddr "rfc-1918-subnets"
        set dstaddr "spoke-fgts-agroup"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
end

config system link-monitor
    edit "fgt-spoke1"
        set srcintf "ssl.root"
        set server "10.212.134.210"
        set interval 100
        set probe-timeout 100
        set failtime 1
        set recoverytime 1
        set update-cascade-interface disable
        set update-static-route disable
    next
end

%{ if license_type == "byol" }
--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${file(license_file)}
%{ endif }
%{ if license_type == "flex" }
--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

LICENSE-TOKEN: ${license_token}
%{ endif }
--==Boundary==--