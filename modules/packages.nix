# =========================================================================
# SYSTEM PACKAGES & APPLICATION PROVISIONING MODULE
# =========================================================================
# This module controls the unfree license compliance exceptions, provisions
# native system binaries, establishes the Flatpak container subsystem, and
# compiles custom font assets into the Nix store dynamically.

{ config, pkgs, ... }:

{
  # -------------------------------------------------------------------------
  # Package Licensing and Core Programs
  # -------------------------------------------------------------------------
  
  # Relaxes Nix execution constraints to allow proprietary/unfree bin payloads
  nixpkgs.config.allowUnfree = true;

  # Provisions Firefox via native system-wide wrapper configurations
  programs.firefox.enable = true;
  

  # -------------------------------------------------------------------------
  # Core System Packages (Global Binaries Ecosystem)
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # --- Hardware Diagnostic & Telemetry Infrastructure ---
    smartmontools               # Storage health evaluation (S.M.A.R.T. monitoring daemon)
    hardinfo2                   # Comprehensive graphical hardware profiling engine
    nvtopPackages.intel         # Real-time GPU execution, VRAM utilization, and clock tracker
    
    # --- Performance Monitoring & Task Administration ---
    # scx.full                    # Extensible eBPF CPU schedulers and live scx_top telemetry manager
    htop                        # Standard process execution manager
    btop                        # High-fidelity terminal resource visualizer
    bottom                      # Lightweight, highly responsive system monitoring utility
    
    # --- Virtualization & Core Productivity Systems ---
    gnome-boxes                 # QEMU/KVM-driven frontend for rapid virtual machine provisioning
    libreoffice-qt              # Complete open-source workspace productivity suite
    onlyoffice-desktopeditors   # High-fidelity enterprise office suite
    
    
    # --- Browser & Desktop Customization Ecosystem ---
    google-chrome               # Enterprise-grade web browser deployment
    gnome-tweaks                # Advanced internal configuration manager for GNOME desktops
    gnome-extension-manager     # Direct native repository wrapper for shell extension tracking
   
    
    # --- Multimedia and Audio Processing Layers ---
    haruna                      # Advanced open-source video playback client (mpv-driven backend)
    easyeffects                 # Real-time DSP audio effect processing engine for PipeWire
    
    # --- Core Terminal Utilities, Shell Extensions & Visualizers ---
    fastfetch                   # Ultra-fast declarative system information fetch tool
    warp-terminal               # Modern, GPU-accelerated workspace terminal client
    networkmanagerapplet        # System tray interface network manager overlay
    file                        # Filesystem payload architecture identifying tool
    tree                        # Hierarchical graphical text directory visualizer
    cmatrix                     # Classic digital screen saver simulation binary
    git                         # Distributed version control system
    
    # --- Workspace IDE & Developer Toolchains ---
    antigravity                 # Google Antigravity cross-platform code editing environment
    # antigravity-cli             # Command-line interface suite for Antigravity engine interactions
    kdePackages.kate            # Advanced multi-tab developer workspace text engine

    # --- Orchestration Tools & Container Compatibility ---
    docker-compose              # Standard multi-container system deployment tool
    podman-compose              # Rootless composition engine wrapper matching compose blueprints
    distrobox                   # Advanced container tool integrating foreign Linux distributions with host tools

    # --- Core Qt6 App Presentation Libraries ---
    qt6Packages.qtbase          # Foundational cross-platform application UI structures
    qt6Packages.qttools         # Developer layout tools matching Qt6 environments
    qt6Packages.qtwayland       # Native Wayland display server abstraction bindings for Qt6
    qadwaitadecorations-qt6     # GNOME-styled Adwaita window decorations for Qt6 applications
    
    # --- Graphical Theming Engines & GNOME Integration ---
    # Enforces aesthetic consistency, drop shadows, and client-side borders across Qt sessions
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct            # Scoped Qt5 Configuration Engine
    kdePackages.qt6ct           # Scoped Qt6 Configuration Engine
  ];

  # -------------------------------------------------------------------------
  # Flatpak Container Subsystem 
  # -------------------------------------------------------------------------
  services.flatpak.enable = true;
  xdg.portal.enable = true; 

  
  # -------------------------------------------------------------------------
  # Declarative Font Engine Packaging
  # -------------------------------------------------------------------------
  fonts.packages = [
    (pkgs.runCommand "win-fonts" {} ''
      mkdir -p $out/share/fonts/truetype
      cp -r ${../windows-fonts}/* $out/share/fonts/truetype/
    '')
  ];
}
