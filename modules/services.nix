# =========================================================================
# SYSTEM SERVICES & BACKGROUND DAEMONS MODULE
# =========================================================================
# This module orchestrates background daemons, audio architecture pipelines,
# hardware abstraction layers, automated maintenance routines, and remote
# management dashboards.

{ config, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Audio Architecture Ecosystem (PipeWire Implementation)
  # -------------------------------------------------------------------------
  
  # Disables the legacy PulseAudio daemon to clear the pathway for a unified server
  services.pulseaudio.enable = false;
  
  # Grants RealtimeKit system privileges (Crucial for low-latency audio processing)
  security.rtkit.enable = true;
  
  # Implements the modern PipeWire media server multiplexer
  services.pipewire = {
    enable = true;
    alsa.enable = true;         # Provisions the ALSA software layer translation wrapper
    alsa.support32Bit = true;   # Enforces 32-bit ALSA execution routing (Critical for Wine/Games)
    pulse.enable = true;        # Deploys the PulseAudio API virtualization compatibility server
    
 # Tunes PipeWire's core engine clock rates and quantum buffer boundaries 
 # to enforce low-latency bounds for pro-audio and gaming applications. (e.g., Wine/Proton games)
  extraConfig.pipewire."99-lowlatency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 2048;
    };
  };
    
  };
  
  
  # -------------------------------------------------------------------------
  # Hardware Abstraction Layers & Local Networking Telemetry
  # -------------------------------------------------------------------------
  
  # Deploys vnStat: A lightweight kernel-space network traffic logger daemon
  services.vnstat.enable = true;
  
  # Cloudflare WARP Client: An encrypted WireGuard-based network tunnel client 
  # that secures traffic by routing it through Cloudflare's edge network.
  
  # Enable the cloudflare warp-cli client system daemon
  services.cloudflare-warp.enable = true;
  # To connect type: warp-cli connect in terminal
  # To disconnect type: warp-cli disconnect in terminal

  # Recommended for NixOS to prevent strict firewall routing conflicts with WARP's interface
  networking.firewall.checkReversePath = "loose";

  # Force auto-connect on boot
  /* 
  
  systemd.services.warp-auto-connect = {
  description = "Force Cloudflare WARP to connect on boot";
  after = [ "cloudflare-warp.service" ];
  wants = [ "cloudflare-warp.service" ];
  wantedBy = [ "multi-user.target" ];
  
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    # Tells the system to run the connect command using the exact binary path
    ExecStart = "${pkgs.cloudflare-warp}/bin/warp-cli connect";
  };
  };

*/
  
  # Activates PAM-integrated fingerprint sensor abstraction layers
  services.fprintd.enable = true;

  # Provisions the Common Unix Printing System (CUPS) driver infrastructure
  services.printing.enable = true;

  # -------------------------------------------------------------------------
  # Automated System Optimization, Firmware Management & Telemetry
  # -------------------------------------------------------------------------
  services = {
    # Periodic Storage Optimization: Triggers weekly background ATA/NVMe SSD trim 
    # operations to prevent long-term flash block write performance degradation.
    fstrim.enable = true;
    
    # Deploys the Linux Vendor Firmware Service (LVFS) daemon for system BIOS updates
    fwupd.enable = true;
    
    # Provisions the Cockpit web-based dashboard for secure remote server orchestration
    cockpit.enable = true;
  };

  # -------------------------------------------------------------------------
  # Declarative Garbage Collection & Nix Store Maintenance
  # -------------------------------------------------------------------------
  # Automatically sanitizes the local Nix store weekly by purging orphaned profiles,
  # unreferenced derivations, and generation state logs older than 7 days.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
