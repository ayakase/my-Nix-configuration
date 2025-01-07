# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  # Basic system configuration
  imports = [ ./hardware-configuration.nix ];

  # Define system attributes
  system.stateVersion = "23.05"; # Adjust to your installed NixOS version
  boot.loader.grub.device = "/dev/sda"; # Replace with your disk

  # Enable networking
  networking.hostName = "my-nixos-system";
  networking.useDHCP = true;

  # Enable basic services
  services.openssh.enable = true; # SSH for remote access

  # Install system packages
  environment.systemPackages = with pkgs; [
    nodejs-20_x  # Node.js 20
    microsoft-edge-stable # Microsoft Edge
    redis          # Redis CLI
    postgresql     # PostgreSQL CLI tools
  ];

  # PostgreSQL configuration
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15; # Adjust version as needed
    authentication = pkgs.lib.mkOverride 10 ''
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            md5
      host    all             all             ::1/128                 md5
    '';
    initialScript = ''
      CREATE USER myuser WITH PASSWORD 'mypassword';
      CREATE DATABASE mydb OWNER myuser;
    '';
  };

  # Redis configuration
  services.redis = {
    enable = true;
    bind = "127.0.0.1"; # Bind to localhost for security
    port = 6379;        # Default Redis port
  };

  # Enable Flatpak for Edge if necessary (optional)
  programs.flatpak.enable = true;

  # Security and firewall settings
  networking.firewall.allowedTCPPorts = [ 5432 6379 ]; # PostgreSQL and Redis ports
  networking.firewall.enable = true;

  # Enable Microsoft Edge via Flatpak
  environment.systemPackages = with pkgs; [
    microsoft-edge-stable
  ];

  # Optional: Enable Nix daemon for multi-user setups
  services.nix-daemon.enable = true;
}
