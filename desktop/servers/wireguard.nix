{ pkgs, ... }:
{
  networking = {
    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "wg0" ];
    };

    wireguard = {
      interfaces = {
        wg0 = {
          ips = [ "10.100.0.1/24" "fda4:4413:3bb1::1/64" ];
          listenPort = 51820;
          privateKeyFile = "/home/pedrohlc/Projects/com.pedrohlc/wireguard-keys/private";
          peers = [
            # Laptop
            {
              publicKey = "sS6SMVRPPvTGdjVBUScWkYqT8jjT8PIWy0kzMklwITM=";
              allowedIPs = [
                "10.100.0.2/32"
                "fda4:4413:3bb1::2/128"
                # Multicast
                "224.0.0.251/32"
                "ff02::fb/128"
              ];
            }
            # POCO X3
            {
              publicKey = "j6bZsZZoWfN4SaJuCxP2ndqWGc75A2JH3gxNwSbIDEM=";
              allowedIPs = [
                "10.100.0.3/32"
                "fda4:4413:3bb1::3/128"
                # Multicast
                "224.0.0.251/32"
                "ff02::fb/128"
              ];
            }
          ];
          postSetup = ''
            ip link set wg0 multicast on
          '';
        };
      };
    };
  };

  # ip forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}