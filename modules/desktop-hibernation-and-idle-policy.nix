# =========================================================================
# DESKTOP HIBERNATION & IDLE POLICY MODULE
# =========================================================================
# Desktop-specific hibernation and idle lifecycle policies. Desktops have
# no lid, no battery, and no lid switch events to handle — hibernation is
# instead triggered exclusively via idle timeout and manual user action.
#
# DESKTOP ONLY: Import this module only Desktop Pc. 
#
# 

{ config, pkgs, ... }:

{


# Physical Disk Swap Storage Mapping (Provisioned primarily to back system hibernation states)
  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024; # Establishes a static 16GB swap area | >= Ram Size
      priority = 5;     # Kept at a secondary execution rank to preserve SSD wear life
    }
  ];

  # -------------------------------------------------------------------------------------
  # Systemd Sleep State Management: Desktop Delays
  # -------------------------------------------------------------------------------------
  systemd.sleep.settings = {
    Sleep = {
      # Time spent in suspend before writing RAM snapshot to disk and shutting down
      HibernateDelaySec = "30min"; 
    };
  };

  # -------------------------------------------------------------------------------------
  # Logind Idle & Power Button Mapping (No Lid — Desktop Policy)
  # -------------------------------------------------------------------------------------
  services.logind = {
    settings = {
      Login = {
        # Overrides desktop apps (Chrome, media players) inhibiting the idle timeout
        InhibitDelayMaxSec = 0;

        # No lid on desktop — explicitly suppressed to avoid logind polling errors
        HandleLidSwitch = "ignore";         
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";

        # Physical infrastructure mappings
        HandlePowerKey = "hibernate";       # Physical power button triggers a clean hibernation snapshot
        HandleSuspendKey = "suspend-then-hibernate"; # Remaps a keyboard sleep key to the safer hybrid path
        
        # Idle automation pipeline
        IdleAction = "suspend-then-hibernate";
        IdleActionSec = "30min";            # Longer idle window than laptop for background compile/unattended tasks
      };
    };
  };
}
