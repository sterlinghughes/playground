{ config, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_6_19;

  networking = {
    hostName = "playground-vm";
    firewall.allowedTCPPorts = [ 2375 ];
  };

  virtualisation.docker = {
    enable = true;
    listenOptions = [ "/run/docker.sock" "0.0.0.0:2375" ];
  };

  users.users.dev = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    kubectl
    kind
    git
    curl
  ];

  system.stateVersion = "24.11";
}
