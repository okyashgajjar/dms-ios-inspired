#!/usr/bin/env bash
set -euo pipefail

# Install dms-ios-inspired config into the current user's ~/.config.
# Reproduces the packaged DMS/Niri state with timestamped backups.
# Review before running, especially Niri/monitor sections.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d%H%M%S)"
HOME_DIR="${HOME}"

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    cp -a "$target" "${target}.bak.${TS}"
    echo "Backed up: $target -> ${target}.bak.${TS}"
  fi
}

echo "==> Installing dms-ios-inspired from: $ROOT_DIR"

# --- DMS config ---
mkdir -p "$HOME_DIR/.config/dms/themes"

# Theme
if [[ -d "$HOME_DIR/.config/dms/themes/detroit67" ]]; then
  cp -a "$HOME_DIR/.config/dms/themes/detroit67" "$HOME_DIR/.config/dms/themes/detroit67.bak.${TS}"
  echo "Backed up: $HOME_DIR/.config/dms/themes/detroit67 -> $HOME_DIR/.config/dms/themes/detroit67.bak.${TS}"
fi
cp -r "$ROOT_DIR/config/dms/themes/detroit67" "$HOME_DIR/.config/dms/themes/"
echo "Installed theme: ~/.config/dms/themes/detroit67"

# Plugins lockfile
backup_if_exists "$HOME_DIR/.config/dms/plugins.lock.json"
cp "$ROOT_DIR/config/dms/plugins.lock.json" "$HOME_DIR/.config/dms/plugins.lock.json"
echo "Installed: ~/.config/dms/plugins.lock.json"

# Optional firefox.css
if [[ -f "$ROOT_DIR/config/dms/firefox.css" ]]; then
  backup_if_exists "$HOME_DIR/.config/dms/firefox.css"
  cp "$ROOT_DIR/config/dms/firefox.css" "$HOME_DIR/.config/dms/firefox.css"
  echo "Installed: ~/.config/dms/firefox.css"
fi

# Settings (with path substitution)
backup_if_exists "$HOME_DIR/.config/dms/settings.json"
tmp_settings="$(mktemp)"
sed "s|__HOME__|$HOME_DIR|g" "$ROOT_DIR/config/dms/settings.json" > "$tmp_settings"
install -m 0644 "$tmp_settings" "$HOME_DIR/.config/dms/settings.json"
rm -f "$tmp_settings"
echo "Installed: ~/.config/dms/settings.json"

# --- systemd user drop-in ---
mkdir -p "$HOME_DIR/.config/systemd/user/dms.service.d"
backup_if_exists "$HOME_DIR/.config/systemd/user/dms.service.d/light.conf"
cp "$ROOT_DIR/config/systemd/user/dms.service.d/light.conf" "$HOME_DIR/.config/systemd/user/dms.service.d/light.conf"
echo "Installed: ~/.config/systemd/user/dms.service.d/light.conf"

# --- Niri integration ---
if [[ -d "$ROOT_DIR/config/niri" ]]; then
  mkdir -p "$HOME_DIR/.config/niri/dms"

  # Install DMS/Niri snapshot files (skip machine-specific outputs example)
  for f in "$ROOT_DIR"/config/niri/dms/*.kdl; do
    [[ -e "$f" ]] || continue
    base="$(basename "$f")"
    [[ "$base" == "outputs.kdl.example" ]] && continue
    backup_if_exists "$HOME_DIR/.config/niri/dms/$base"
    cp "$f" "$HOME_DIR/.config/niri/dms/$base"
    echo "Installed: ~/.config/niri/dms/$base"
  done
  # Keep outputs example for reference
  if [[ -f "$ROOT_DIR/config/niri/dms/outputs.kdl.example" ]]; then
    cp "$ROOT_DIR/config/niri/dms/outputs.kdl.example" "$HOME_DIR/.config/niri/dms/outputs.kdl.example"
    echo "Installed reference: ~/.config/niri/dms/outputs.kdl.example"
  fi

  # Main Niri config (backup existing)
  if [[ -f "$ROOT_DIR/config/niri/config.kdl" ]]; then
    backup_if_exists "$HOME_DIR/.config/niri/config.kdl"
    cp "$ROOT_DIR/config/niri/config.kdl" "$HOME_DIR/.config/niri/config.kdl"
    echo "Installed: ~/.config/niri/config.kdl"
  fi
fi

# --- Reload/restart services ---
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload || true
  if systemctl --user cat dms.service >/dev/null 2>&1; then
    echo "Restarting dms.service..."
    systemctl --user restart dms.service || echo "Warning: failed to restart dms.service (restart manually if needed)."
  else
    echo "Note: dms.service not found; skipped restart."
  fi
else
  echo "Note: systemctl not found; skipped daemon-reload/restart."
fi

echo "==> Done."
echo "    - Review ~/.config/niri/config.kdl and monitor/output settings for your hardware."
echo "    - DMS keybinds (Mod+Space launcher, Mod+A control center, Mod+W wallpaper selector, etc.) are in ~/.config/niri/dms/binds.kdl."
echo "    - DMS may regenerate files in ~/.config/niri/dms/; reapply from this repo if needed to restore this state."
