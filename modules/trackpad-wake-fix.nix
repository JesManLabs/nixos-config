

# =========================================================================
# HARDWARE QUIRK MODULE: INPUT DEVICE WAKE RECOVERY
# =========================================================================
#
# Generic workaround for laptops whose touchpad or touchscreen fails to
# recover after suspend, hibernation or hybrid sleep.
#
# Strategy
# --------
# Before sleep:
#   • Unload only the input drivers that are currently active.
#
# After wake:
#   • Give firmware time to restore power.
#   • Reload all common laptop input drivers.
#   • Drivers not present or not needed simply fail silently.
#   • Retrigger udev so devices are rebound if necessary.
#
# Safe to reuse across different laptops.
#


{ config, pkgs, ... }:



{
  powerManagement = {
    powerDownCommands = ''
      # HID-over-I2C touchpads/touchscreens
      if ${pkgs.kmod}/bin/lsmod | ${pkgs.gnugrep}/bin/grep -qw i2c_hid_acpi; then
        ${pkgs.kmod}/bin/modprobe -r hid_multitouch i2c_hid_acpi || true
      fi

      # Generic HID-over-I2C transport
      if ${pkgs.kmod}/bin/lsmod | ${pkgs.gnugrep}/bin/grep -qw i2c_hid; then
        ${pkgs.kmod}/bin/modprobe -r i2c_hid || true
      fi

      # Legacy PS/2 touchpads
      if ${pkgs.kmod}/bin/lsmod | ${pkgs.gnugrep}/bin/grep -qw psmouse; then
        ${pkgs.kmod}/bin/modprobe -r psmouse || true
      fi
    '';

    resumeCommands = ''
    # Allow firmware and the embedded controller to restore devices
    ${pkgs.coreutils}/bin/sleep 2

    # Ensure common laptop input drivers are available individually without cascading failure
    for module in i2c_hid i2c_hid_acpi hid_multitouch psmouse; do
    ${pkgs.kmod}/bin/modprobe "$module" 2>/dev/null || true
    done

    # Allow device nodes to settle
    ${pkgs.coreutils}/bin/sleep 1

    # Notify userspace that input devices may have changed
    ${pkgs.systemd}/bin/udevadm trigger \
      --subsystem-match=input \
      --action=change || true

    ${pkgs.systemd}/bin/udevadm settle || true
    '';
   
  };
}
