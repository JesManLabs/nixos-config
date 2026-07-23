# =========================================================================
# BATTERY MANAGEMENT & LID POLICY MODULE
# =========================================================================
# Laptop-exclusive power lifecycle policies: lid switch handling, battery
# failsafe infrastructure, and suspend-then-hibernate chain binding.
#
# LAPTOP ONLY: Import this module only on Laptop Computers. But harmless anyway
#
#

{ config, pkgs, ... }:

{

  # Physical Disk Swap Storage Mapping (Provisioned primarily to back system hibernation states)
  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024; # Establishes a static 12GB swap area | swap size should be = or > Ram Size
      priority = 5;     # Kept at a secondary execution rank to preserve SSD wear life
    }
  ];

  # -------------------------------------------------------------------------------------
  # Systemd Configuration Management & Device Sleep-to-hibernation transition policy
  # -------------------------------------------------------------------------------------

  # Enables the dconf backend registry service needed to pass runtime preferences down to user desktops
  programs.dconf.enable = true;

  # Declarative Sleep Parameters
  systemd.sleep.settings = {
    Sleep = {
      HibernateDelaySec = "30min"; # Establishes duration limits before converting an idle sleep profile into deep hibernation
    };
  };
  
  # -------------------------------------------------------------------------------------
  # Desktop Environment Target Redirection (Fixes Manual Suspend with Open Lid)
  # -------------------------------------------------------------------------------------
  # When you click "Suspend" in a GUI menu, the desktop environment commands systemd to trigger 
  # systemd-suspend.service. This clean override forces that specific service to execute the 
  # suspend-then-hibernate binary instead, without any complex userspace-freezing scripts.
  systemd.services.systemd-suspend.serviceConfig.ExecStart = [
    "" # Clears the upstream default command safely
    "${pkgs.systemd}/lib/systemd/systemd-sleep suspend-then-hibernate"
  ];
  
  # -------------------------------------------------------------------------------------
  # Power Orchestration: Automated Suspend-to-Hibernate Pipeline & Input Recovery
  # -------------------------------------------------------------------------------------
  services.logind = {
    settings = {
      Login = {
        # Overrides apps like Chrome that try to inhibit hibernation/suspend
        InhibitDelayMaxSec = 5;

        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend"; 
        HandleLidSwitchDocked = "ignore";         
        IdleAction = "suspend-then-hibernate";
        IdleActionSec = "15min";                  
      };
    };
  };
  

  powerManagement = {
    enable = true;
  };
  
  # -------------------------------------------------------------------------
  # UPower Critical Battery Failsafe Infrastructure
  # -------------------------------------------------------------------------
  # Defines the low-power lifecycle tracking matrix. Automatically triggers
  # emergency system states as the battery drains to protect volatile data.
  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 20;       # Level at which the OS warns the user of low battery
    percentageCritical = 15;  # Level at which aggressive power-saving protocols begin
    percentageAction = 10;    # Level at which the final safety action is invoked
    criticalPowerAction = "Hibernate"; # Securely snapshots RAM allocations to disk before the machine completely dies
  };
}
