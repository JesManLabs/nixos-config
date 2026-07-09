# =========================================================================
# BATTERY MANAGEMENT & LID POLICY MODULE (COMMUNITY EDITION)
# =========================================================================
# Laptop-exclusive power lifecycle policies: lid switch handling, battery
# failsafe infrastructure, and optimized suspend behaviors.
#
# LAPTOP ONLY: Do NOT import on desktop systems.
#
# NOTE: This public version utilizes standard Suspend-to-RAM. The advanced
# Suspend-then-Hibernate pipeline requires a dedicated swap topology, which
# is exclusively pre-configured in our Pro Edition.
#
# Get the full edition with performance & power stack here: https://selar.com/g54221314e

{ config, pkgs, ... }:

{
  # Enables the dconf backend registry service needed to pass runtime preferences down to user desktops
  programs.dconf.enable = true;

  # -------------------------------------------------------------------------------------
  # Power Orchestration: Automated Suspend Pipeline & Input Recovery
  # -------------------------------------------------------------------------------------
  services.logind = {
    settings = {
      Login = {
        # Overrides apps like Chrome that try to inhibit suspend states
        InhibitDelayMaxSec = 5;

        # Standard safe suspend policies that require zero swap allocations
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend"; 
        HandleLidSwitchDocked = "ignore";         
        IdleAction = "suspend";
        IdleActionSec = "20min";                  
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
  # a clean system shutdown when thresholds are reached to protect data.
  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 20;       # Level at which the OS warns the user of low battery
    percentageCritical = 15;  # Level at which aggressive power-saving protocols begin
    percentageAction = 5;     # Level at which the final safety action is invoked
    
    # SAFE FOR PUBLIC USE: Hybrid/Standard Power Off cleanly unmounts drives
    # and shuts down services safely without needing a swapfile backdrop.
    criticalPowerAction = "PowerOff"; 
  };
}
