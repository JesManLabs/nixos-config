
# =========================================================================
# WORKSTATION CORE SUBSYSTEM ENGINE (workstation-core.nix)
# =========================================================================
# System-level hardware acceleration, carrier-hardened network routing,
# DNS resolution layers, boot initialization policies, and browser rendering
# pipeline overrides.
# =========================================================================



{ config, pkgs, ... }:

{

  # -------------------------------------------------------------------------
  # Core System Dependencies & Module Imports
  # -------------------------------------------------------------------------
  imports = [
    ./packages.nix
    ./battery-management-and-lid-policy.nix # Comment this out or delete this line if on desktop Pc
    ./services.nix
    ./virtualization.nix
    ./trackpad-wake-fix.nix
    # ./modules/desktop-hibernation-and-idle-policy.nix # Uncomment this line if on desktop Pc 
    
    # ./power-and-performance-tuning.nix
    
  # =========================================================================
  # PREMIUM PERFORMANCE & POWER TUNING MODULE
  # =========================================================================
  # The advanced low-latency kernel, ZRAM/ZSTD memory compression topology, 
  # and sched_ext (scx_rusty) task prioritization features are exclusive to 
  # the Pro Edition.
  # 
  # Get the full module here: https://selar.com/g54221314e
  # =========================================================================
  
  ];


 
  # Boot Animation (Plymouth) and Verbose Logging Suppression
  # Optimizes boot speed and hides systemd/udev TTY noise during initialization
  boot.plymouth.enable = true;
  boot.kernelParams = [ 
    "quiet" 
    "splash" 
    "boot.shell_on_fail" 
    "loglevel=3" 
    "rd.systemd.show_status=false" 
    "rd.udev.log_level=3" 
    "udev.log_priority=3" 
  ];
  boot.consoleLogLevel = 0;
  
  # Enable Nix Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
   
   
  # Network Stability Optimization:
  # Disables IPv6 routing globally to bypass issues with regional internet service 
  # providers advertising broken or high-latency IPv6 paths.
  networking.enableIPv6 = false;

  # Modern DNS Management Layer (systemd-resolved)
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNS = [ "1.1.1.1" "1.0.0.1" ];
        FallbackDNS = [ "8.8.8.8" "8.8.4.4" ];
        DNSSEC = "false";
      };
    };
  };
  
  
  # -------------------------------------------------------------------------
  # Carrier-Hardened Network Routing & Firewall Policies
  # -------------------------------------------------------------------------
  
  # Packet Fragmentation Prevention via nftables:
  # Clamps the TCP Maximum Segment Size (MSS) to 1360 bytes over the network forwarding
  # path. Prevents packet drop/stalls caused by aggressive carrier Grade NATs.
  networking.nftables = {
    enable = true;
    tables.clamp-mtu = {
      family = "inet";
      content = ''
        chain forward {
          type filter hook forward priority mangle; policy accept;
          tcp flags syn tcp option maxseg size set 1360
        }
        chain postrouting {
          type filter hook postrouting priority mangle; policy accept;
          tcp flags syn tcp option maxseg size set 1360
        }
      '';
    };
  };

  # Local Network Discovery and Device Sharing Firewalls
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ]; # LocalSend File Transfer Engine (TCP)
    allowedUDPPorts = [ 53317 ]; # LocalSend File Transfer Engine (UDP)
  };

  # System-wide Interface MTU Mitigation Rules (udev):
  # Normalizes Maximum Transmission Unit limits to 1400 on all physical, virtual,
  # wireless, and wired network interfaces on discovery/state-change.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="wlp*", RUN+="${pkgs.iproute2}/bin/ip link set dev %k mtu 1400"
    ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iproute2}/bin/ip link set dev %k mtu 1400"
    ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="enp*", RUN+="${pkgs.iproute2}/bin/ip link set dev %k mtu 1400"
    ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="eth*", RUN+="${pkgs.iproute2}/bin/ip link set dev %k mtu 1400"
  '';
  
  
  
  # -------------------------------------------------------------------------
  # Chromium Engine Enterprise & Architectural Policies
  # -------------------------------------------------------------------------
  programs.chromium = {
    enable = true;
    extraOpts = {
      "QuicAllowed" = false; # Disables QUIC protocol over HTTP/3 to avoid regional ISP throttling
      "CommandLineFlagSecurityWarningsEnabled" = false; # Suppresses developer flag banners on startup
    };
  };
  
  # Advanced Overlay: System-Wide Hardware Accelerated Browser Engine Overrides
  # Patches upstream Google Chrome & Chromium to bypass software blacklists, 
  # enforce GPU-driven text/ui rasterization, and lock into native Wayland pipes.
  nixpkgs.overlays = [
    (final: prev: {
      google-chrome = prev.google-chrome.override {
        commandLineArgs = [
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
          "--enable-gpu-rasterization"
          "--enable-oop-rasterization"
          "--canvas-oop-rasterization"
          "--enable-features=CanvasOopRasterization,DefaultANGLEVulkan,Vulkan,VulkanFromANGLE"
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
        ];
      };
      chromium = prev.chromium.override {
        commandLineArgs = [
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
          "--enable-gpu-rasterization"
          "--enable-oop-rasterization"
          "--canvas-oop-rasterization"
          "--enable-features=CanvasOopRasterization,DefaultANGLEVulkan,Vulkan,VulkanFromANGLE"
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
        ];
      };
    })
  ];
  
  
  
  # -------------------------------------------------------------------------
  # Hardware Graphics Acceleration & Core Pipelines
  # -------------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Necessary for 32-bit execution layers (Wine, Steam, retro runners)
    extraPackages = with pkgs; [
      intel-media-driver   # Hardware VA-API encoding/decoding for Intel Iris/UHD graphics
      vulkan-loader        # Native system-wide Vulkan interface layer
      vulkan-validation-layers
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader        # 32-bit Vulkan mapping (Critical infrastructure for Bottles/DXVK compatibility)
    ];
  };

  # Flatpak Graphics Bridge Integration
  services.flatpak.enable = true;
  # Exposes the system host's NixOS OpenGL/Vulkan drivers inside the Flatpak sandbox filesystem
  systemd.tmpfiles.rules = [
    "L+ /usr/share/glvnd - - - - /run/opengl-driver/share/glvnd"
  ];
  
  gtk.iconCache.enable = true;
  
  
  
  #environment.variables = {
   #GSK_RENDERER = "gl";
  #};
  
  # Enforce System-wide Qt Theme Engine Integration
  # Enables unified configuration of Qt5 and Qt6 application appearances 
  # (fonts, icons, and widget styles) by routing them through the qt6ct 
  # platform theme engine.
  environment.sessionVariables = {
  QT_QPA_PLATFORMTHEME = "qt6ct";
  
  # Forces Qt6 apps to use GNOME's native window decorations and shadows
  QT_WAYLAND_DECORATION = "adwaita";
  };
  
  
  # -------------------------------------------------------------------------
  # GRAPHICAL WORKSPACE SELECTION ENGINE
  # -------------------------------------------------------------------------
  # Global instructions: Uncomment the preferred desktop and its display manager.
  # Ensure only ONE system-wide display manager remains uncommented at a time.
  # Multiple desktop managers can safely coexist under an active display manager.
  # -------------------------------------------------------------------------

  # Foundation layer for display managers and X11/Wayland sessions
  # services.xserver.enable = true;

  # --- OPTION 1: GNOME 50 (ACTIVE BY DEFAULT) ---
  # services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;
  # services.desktopManager.gnome.sessionPath = [ pkgs.gdm ];

  # --- OPTION 2: COSMIC DESKTOP (MODERN, RUST-BASED WAYLAND ENV) ---
  # services.displayManager.cosmic-greeter.enable = true;
  # services.desktopManager.cosmic.enable = true;
  # services.system76-scheduler.enable = true;

  # --- OPTION 3: KDE PLASMA 6 (MODERN, FULLY FEATURED GRAPHICAL DESKTOP) ---
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true; # Asserts native Wayland session parsing
  # services.desktopManager.plasma6.enable = true;

  # --- OPTION 4: LXQT (DEEPLY LIGHTWEIGHT, PERFORMANCE DRIVEN DE) ---
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.lxqt.enable = true;
  #
  # # PAM Permissions Security Patch: Fixes potential desktop locking freezes 
  # # by explicitly connecting the locker backends to the PAM auth stack.
  # security.pam.services.lxlock.text = "auth include login"; 
  # security.pam.services.i3lock.text = "auth include login";

  
  
  







}
