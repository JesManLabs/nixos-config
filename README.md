# ❄️ NixOS Core Starter Kit (Community Edition)

A performance-focused, modular NixOS foundation designed for everyday productivity, container virtualization, carrier-hardened networking, and sleek hardware optimization.

This repository ships as a drop-in starter kit that can be imported directly into your existing configuration without altering machine-specific file systems or hardware mounts.

---

## ⚡ Key Highlights & Baked-In Features

Unlike generic configurations, this public starter kit is meticulously tuned to solve real-world system and carrier pain points:

* **Carrier-Hardened Networking:** Built-in mitigation for restrictive Grade NATs by dynamically clamping TCP Maximum Segment Size (MSS) via `nftables` and optimizing MTU values to 1400 across all wireless and wired interfaces on discovery.
* **ISP Throttling Bypass:** Enforced system-wide policies for Chromium engines that disable the problematic QUIC protocol over HTTP/3 and route traffic through optimized Cloudflare (`1.1.1.1`) and Google (`8.8.8.8`) DNS servers using `systemd-resolved`.
* **Out-of-the-Box GPU Acceleration:** Deep hardware rasterization overlays patching upstream Google Chrome and Chromium to bypass software blacklists and map directly to your system's GPU via native Wayland pipes.
* **Universal OpenGL/Vulkan Pass-through:** Flatpak integration configured via system tmpfile overlays to seamlessly expose your host graphics drivers inside container filesystems.
* **Low-Latency Audio Topology:** A customized PipeWire implementation configured with 32-bit ALSA support and PulseAudio compatibility wrappers for smooth audio execution.
* **Input Device Wake Recovery:** Generic udev and modprobe lifecycle hooks that reload touchpads and touchscreens (`i2c_hid`, `psmouse`) after waking from sleep.
* **Containerization & Virtualization:** Full support for QEMU/KVM (`libvirtd`), rootless Podman (with Docker socket compatibility), and Android runtime via Waydroid.

---

## 📂 System Architecture & Module Tree

This configuration ships **without** a host-specific `hardware-configuration.nix` file. You can drop these files straight into `/etc/nixos/` without altering your machine’s unique drive mounts or filesystem UUIDs.

```text
/etc/nixos/
├── flake.nix                                 # Declarative Flake pinning nixos-26.05 & antigravity-cli
├── flake.lock                                # Flake dependency lockfile
├── configuration.nix                         # Your host entrypoint (imports ./modules/workstation-core.nix)
├── windows-fonts/                            # Local font repository dynamically built into Nix store
└── modules/
    ├── workstation-core.nix                  # Core kit entrypoint, networking, browser overlays, DE choices
    ├── packages.nix                          # Global binary ecosystems, dev tools, and unfree overlays
    ├── services.nix                          # Background daemons, PipeWire audio, Cloudflare WARP, & weekly GC
    ├── virtualization.nix                    # Hypervisors (QEMU/KVM), Waydroid, and rootless Podman
    ├── battery-management-and-lid-policy.nix # [LAPTOP ONLY] Lid handling & 12GB swap hibernation policy
    ├── desktop-hibernation-and-idle-policy.nix # [DESKTOP ONLY] Power key & idle timeout hibernation policy
    └── trackpad-wake-fix.nix                 # Touchpad/touchscreen hardware wake recovery hooks
```

---

## 🧩 Module Breakdown

| Module File | Role / Scope | Core Features |
| :--- | :--- | :--- |
| **`flake.nix`** | Flake Entrypoint | Pins `nixos-26.05`, embeds `antigravity-cli` input (`JesManLabs/antigravity-cli-nix`). |
| **`workstation-core.nix`** | Core Engine | Quiet boot, systemd-resolved, nftables MSS clamping, udev MTU rules, Chromium GPU overlays, DE selector. |
| **`packages.nix`** | System Binaries | Diagnostics (`btop`, `nvtop`), IDEs (`Kate`, `Warp`), office suites, Flatpak bridge, custom font derivation. |
| **`services.nix`** | Daemons | PipeWire (32-bit ALSA/PulseAudio), Cloudflare WARP tunnel, Cockpit dashboard, weekly `nix.gc` (>7 days). |
| **`virtualization.nix`** | Virtualization | QEMU/KVM (`virt-manager`), Podman (`dockerCompat`), Waydroid Android container framework. |
| **`battery-management-and-lid-policy.nix`** | Laptop Only | 12GB `/swapfile`, `suspend-then-hibernate` on lid close, UPower emergency battery hibernate at 10%. |
| **`desktop-hibernation-and-idle-policy.nix`** | Desktop Only | 16GB `/swapfile`, maps physical power button to hibernate, 30-minute idle sleep trigger. |
| **`trackpad-wake-fix.nix`** | Laptop Hardware | Safe module unloading (`i2c_hid`, `psmouse`) prior to sleep and auto-reloading/udev settling on resume. |

---

## 🚀 Unlock Elite Performance: NixOS Pro Edition

Looking to push your hardware to its absolute limit? While this Community Edition provides an incredibly solid desktop experience, the **Pro Edition** contains the ultimate low-latency optimization framework.

### Exclusive Pro Edition Modules:
* **Advanced Low-Latency Kernels:** Complete `linuxPackages_zen` implementations optimized for buttery-smooth visual fidelity.
* **Extensible eBPF Task Schedulers:** Pre-configured environments running cutting-edge schedulers like `scx_rusty` and `scx_lavd` via `sched_ext` for unparalleled frame consistency and touch-response speeds.
* **ZRAM/ZSTD Memory Compression:** A hyper-optimized topology (50% ZRAM pool with priority weighting) to squeeze peak performance out of system RAM.
* **Adaptive CPU Governor Tuning:** Autonomous clock scaling and smart turbo controls managed seamlessly via `auto-cpufreq`.
* **ALSA Audio Power-Transition Fix:** Dedicated hardware buffer-muting scripts to eliminate buzzing/looping bugs on system wake-up.

👉 **[Get the Full Pro Edition with Performance & Power Stack on Selar](https://selar.com/g54221314e)**

---

## 💻 Desktop Environment Selection

No graphical desktop is enabled by default. Open `modules/workstation-core.nix` and uncomment **one** preferred desktop environment block (ensure only one display manager is active):

* **GNOME 50:**
  ```nix
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  ```
* **COSMIC Desktop:**
  ```nix
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  ```
* **KDE Plasma 6:**
  ```nix
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  ```
* **LXQt (with PAM lock fix):**
  ```nix
  services.displayManager.sddm.enable = true;
  services.desktopManager.lxqt.enable = true;
  security.pam.services.lxlock.text = "auth include login";
  security.pam.services.i3lock.text = "auth include login";
  ```

---

## 🛠️ Step-by-Step Installation

### 1. Prepare Your Environment
Back up your current system setup to protect your existing configurations:
```bash
sudo cp -r /etc/nixos /etc/nixos.bak
```

### 2. Fetch and Deploy the Core Kit
Clone this repository directly into your system configuration directory:
```bash
git clone [https://github.com/JesManLabs/nixos-config.git](https://github.com/JesManLabs/nixos-config.git) /etc/nixos
```

### 3. Import the Kit in `configuration.nix`
Open your existing `/etc/nixos/configuration.nix` and add `./modules/workstation-core.nix` to your `imports` list:

```nix
imports = [
  ./hardware-configuration.nix
  ./modules/workstation-core.nix  # <--- Single import line
];
```

### 4. Select Your Power Policy Profile
Edit `/etc/nixos/modules/workstation-core.nix` to choose the correct power policy for your machine:
* **For Laptops:** Keep `./battery-management-and-lid-policy.nix` imported.
* **For Desktops:** Comment out `./battery-management-and-lid-policy.nix` and uncomment `./desktop-hibernation-and-idle-policy.nix`.

> **Warning:** Do not import both power policy modules simultaneously as they will conflict on `services.logind` and `systemd.sleep` settings.

### 5. Rebuild System via Flake
Review `/etc/nixos/modules/workstation-core.nix` to uncomment your preferred desktop environment, then rebuild your system using the `--flake` flag:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

---

## 🤝 Contact & Custom Implementations

I specialize in Linux & Cloud Systems Engineering | NixOS declarative setups, IaC, containerized workflows, and automated backend infrastructure..

For enterprise optimizations, hardware-fleet revitalizations, or custom cloud or personal setups, reach out via:
* **Email:** jemmanofficial@gmail.com
* **Telegram:** [t.me/JesManLabs](https://t.me/JesManLabs)

* **License:** MIT. Feel free to fork, tweak, and deploy!
