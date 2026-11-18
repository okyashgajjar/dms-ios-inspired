#!/usr/bin/env bash
set -euo pipefail

# Install dms-ios-inspired config into the current user's ~/.config.
# Review before running. Creates timestamped backups of files it replaces.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d%H%M%S)"
HOME_DIR="${HOME}"

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" ]]; then
    cp -a "$target" "${target}.bak.${TS}"
    echo "Backed up: $target -> ${target}.bak.${TS}"
  fi
}

echo "==> Installing dms-ios-inspired from: $ROOT_DIR"

# Theme
mkdir -p "$HOME_DIR/.config/dms/themes"
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

# systemd user drop-in
mkdir -p "$HOME_DIR/.config/systemd/user/dms.service.d"
backup_if_exists "$HOME_DIR/.config/systemd/user/dms.service.d/light.conf"
cp "$ROOT_DIR/config/systemd/user/dms.service.d/light.conf" "$HOME_DIR/.config/systemd/user/dms.service.d/light.conf"
echo "Installed: ~/.config/systemd/user/dms.service.d/light.conf"

# Reload/restart DMS if available
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload || true
  if systemctl --user cat dms.service >/dev/null 2>&1; then
    echo "Restarting dms.service..."
    systemctl --user restart dms.service || echo "Warning: failed to restart dms.service (you may need to restart it manually)."
  else
    echo "Note: dms.service not found; skipped restart."
  fi
else
  echo "Note: systemctl not found; skipped daemon-reload/restart."
fi

echo "==> Done. Review ~/.config/dms/settings.json for any machine-specific tweaks (wallpaper, monitors, fonts)."
