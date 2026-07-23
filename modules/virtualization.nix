# =========================================================================
# VIRTUALIZATION & CONTAINER ENGINE SUBSYSTEMS MODULE
# =========================================================================
# This module coordinates kernel-level hypervisor parameters, provisions
# high-performance container engines, establishes internal software-defined
# network bridges, and maps workspace virtualization environments.

{ config, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Stage 1 Boot (Initrd) & Low-Level Hypervisor Parameters
  # -------------------------------------------------------------------------
  boot.initrd.systemd.enable = true;

  # QEMU/KVM Hardware Accelerated Virtualization Subsystem
  virtualisation.libvirtd.enable = true;  
  programs.virt-manager.enable = true;    

  # -------------------------------------------------------------------------
  # Podman Containerization Ecosystem (Docker Interoperability Specification)
  # -------------------------------------------------------------------------
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;                      
    dockerSocket.enable = true;               
    defaultNetwork.settings.dns_enabled = true; 
  };

  # -------------------------------------------------------------------------
  # Waydroid LXC Containerization Infrastructure (Android Runtime Environment)
  # -------------------------------------------------------------------------
  virtualisation.waydroid.enable = true;
  boot.kernelModules = [ "tun" "bridge" ];
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
}
