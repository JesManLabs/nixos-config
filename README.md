# ❄️ NixOS Core Starter Kit (Community Edition)

A performance-focused, modular NixOS foundation designed for everyday productivity, container virtualization, and sleek hardware optimization. 

This repository houses a highly refined configuration engineered to eliminate network latency bottlenecks, optimize hardware power usage, and enforce seamless GPU acceleration across desktop application engines without forcing you to worry about importing breaking hardware definitions.

---

## ⚡ Key Highlights & Baked-In Features

Unlike generic configurations, this public starter kit is meticulously tuned to solve real-world system and carrier pain points:

* **Carrier-Hardened Networking:** Built-in mitigation for restrictive Grade NATs by dynamically clamping TCP Maximum Segment Size (MSS) via `nftables` and optimizing MTU values to 1400 across all wireless and wired interfaces on discovery.
* **ISP Throttling Bypass:** Enforced system-wide policies for Chromium engines that disable the problematic QUIC protocol over HTTP/3 and route traffic through optimized Cloudflare DNS servers using `systemd-resolved`.
* **Out-of-the-Box GPU Acceleration:** Deep hardware rasterization overlays patching upstream Google Chrome and Chromium to bypass software blacklists and map directly to your system's GPU via native Wayland pipes.
* **Universal OpenGL/Vulkan Pass-through:** Flatpak integration configured via system tmpfile overlays to seamlessly expose your host graphics drivers inside container filesystems.
* **Low-Latency Audio Topology:** A customized PipeWire implementation that tunes core engine clock rates and quantum buffer boundaries to enforce tight latency bounds for pro-audio and gaming applications.

---

## 📂 System Topology

This configuration ships **without** a host-specific `hardware-configuration.nix` file. This means you can drop these files straight into your existing setup without altering your machine’s unique drive mount structures or filesystem UUIDs.

```text
.
├── configuration.nix                         # Core system initialization, networking primitives, and DE configurations
└── modules/                                  # Feature-specific architectural extensions
    ├── packages.nix                          # Global binary ecosystems, dev tools, and unfree overlays
    ├── services.nix                          # Background daemons, automated GC, low-latency PipeWire tuning, and Cloudflare WARP
    └── virtualization.nix                    # Hypervisors (QEMU/KVM), Waydroid, and rootless Podman environments
    └── battery-management-and-lid-policy.nix # Laptop-exclusive power lifecycle policies
```

---

## 🚀 Unlock Elite Performance: NixOS Pro Edition

Looking to push your hardware to its absolute limit? While this version provides an incredibly solid desktop experience, the **Pro Edition** contains the ultimate low-latency optimization framework.

### Exclusive Pro Edition Modules:
* **Advanced Low-Latency Kernels:** Complete implementations optimized for buttery-smooth visual fidelity.
* **Extensible eBPF Task Schedulers:** Pre-configured environments for cutting-edge schedulers like `scx_rustland` and `scx_lavd`, giving you unparalleled frame consistency and touch-response speeds.
* **ZRAM/ZSTD Memory Compression:** A hyper-optimized topology to squeeze peak performance out of system RAM.
* **Advanced Hybrid Sleep Pipelines:** High-performance Suspend-then-Hibernate configurations with pre-mapped virtual swap alignments.

👉 **[Get the Full Pro Edition with Performance & Power Stack on Selar](https://selar.com/g54221314e)**

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
git clone [https://github.com/jesam-emmanuel/nixos-config.git](https://github.com/jesam-emmanuel/nixos-config.git) /etc/nixos
```

### 3. Generate Your Hardware Profile
Because this repository deliberately keeps the host file empty to safeguard your system layout, generate a fresh hardware configuration for your exact machine:
```bash
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
```

### 4. Review and Build
Open `/etc/nixos/configuration.nix` to uncomment your preferred desktop environment options (GNOME, COSMIC, KDE, or LXQt) if you want to switch from the default layout, then test the build ecosystem:
```bash
sudo nixos-rebuild test
```

If the evaluation passes smoothly, permanently commit and apply the build layer:
```bash
sudo nixos-rebuild switch
```

---

## 🤝 Contact & Custom Implementations

I specialize in automating backend infrastructure, containerizing complex developer workflows, and breathing new life into local hardware arrays using lightweight, immutable Linux distributions. 

For enterprise optimizations, hardware-fleet revitalizations, or custom cloud setups, reach out via my Email: jemmanofficial@gmail.com or Telegram: @JesMan1

* **License:** MIT. Feel free to fork, tweak, and deploy!
