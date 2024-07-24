Content-Type: multipart/mixed; boundary="==Boundary=="
MIME-Version: 1.0

--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
set hostname spoke-fgt
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
edit "hub-sslvpn-int"
set vdom "root"
set allowaccess ping
set type ssl
set role lan
set interface "port1"
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
    edit "spoke-fgt"
        set private-key "${fgt_key}"
        set certificate "${fgt_cert}"
    next
end

config user peer
    edit "hub-fgt-cert"
        set ca "example-ca"
		set cn "hub-fgt"
    next
end

config firewall address
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
end

config vpn ssl client
    edit "hub-sslvpn-client"
        set interface "hub-sslvpn-int"
        set user ${sv_user}
        set psk ${sv_passwd}
        set peer "hub-fgt-cert"
        set server ${sv_public_ip}
        set port ${sv_port}
        set certificate "spoke-fgt"
    next
end


config firewall vip
edit "fg1-icmp-vip"
set extip ${sv_tunnel_ip}
set mappedip "10.2.2.71"
set extintf "hub-sslvpn-int"
set portforward enable
set protocol icmp
next
edit "fg1-example-vip"
set extip ${sv_tunnel_ip}
set mappedip "10.2.2.71"
set extintf "hub-sslvpn-int"
set portforward enable
set extport 30000
set mappedport 30000
next
end
end

config firewall policy
    edit 1
        set name "outbound-hub-fgt"
        set srcintf "port2"
        set dstintf "hub-sslvpn-int"
        set action accept
        set srcaddr "rfc-1918-subnets"
        set dstaddr "rfc-1918-subnets"
        set schedule "always"
        set service "ALL"
        set logtraffic all
        set nat enable
    next
    edit 2
        set name "inbound-hub-fgt"
        set srcintf "hub-sslvpn-int"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "fg1-icmp-vip" "fg1-example-vip"
        set schedule "always"
        set service "ALL"
        set logtraffic all
        set nat enable
    next
end

config system link-monitor
    edit "fgt-hub"
        set srcintf "hub-sslvpn-int"
        set server "10.1.1.10"
        set interval 100
        set probe-timeout 100
        set failtime 1
        set recoverytime 1
        set update-cascade-interface disable
        set update-static-route disable
        set update-policy-route disable
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