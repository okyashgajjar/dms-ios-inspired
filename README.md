# dms-ios-inspired

An iOS-inspired setup for [Dank Material Shell (DMS)](https://github.com/Dux-Labs/danklinux) / Quickshell, tuned for a clean island-style bar, control center layout, and low-memory runtime options.

This repo packages the **user configuration** (settings, theme, and service tuning) so others can try, adapt, and maintain it.

## What's included

- `config/dms/settings.json` — DMS UI/layout/settings (iOS-inspired island bar, control center widgets, compact layout, blur enabled, etc.)
- `config/dms/themes/detroit67/` — custom `detroit67` theme
- `config/dms/plugins.lock.json` — plugin lockfile
- `config/dms/firefox.css` — optional Firefox styling (if you use it)
- `config/systemd/user/dms.service.d/light.conf` — user service drop-in with conservative memory limits and low-overhead env flags
- `install.sh` — installer that backs up existing files and applies this setup

> **Note:** This does **not** vendor/modify DMS shell source code. It uses your installed DMS/Quickshell shell with this configuration applied.

## Requirements

- Linux with Wayland (tested in a Niri session; should adapt to other compositors supported by DMS)
- [`dms`](https://github.com/Dux-Labs/danklinux) and [Quickshell](https://quickshell.org/) installed
- `systemd --user` session
- Fonts used by this config (optional but recommended for the intended look): **SF Compact Text** (falls back if unavailable)

## Download

### Git clone (recommended)
```bash
git clone https://github.com/<your-user>/dms-ios-inspired.git
cd dms-ios-inspired
```

### One-command install (after you host this repo)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/<your-user>/dms-ios-inspired/main/install.sh)
```

Replace `<your-user>` with your GitHub username/repo path.

## Install

From the repo directory:

```bash
chmod +x install.sh
./install.sh
```

The installer will:
1. Back up existing DMS config files (timestamped `.bak.*` copies)
2. Copy theme, settings, and systemd drop-in into `~/.config/...`
3. Set local paths in `settings.json` (e.g. theme path)
4. Run `systemctl --user daemon-reload` and restart `dms.service` if it exists

## Notes

- **Personal/machine-specific values removed:** `lockScreenWallpaperPath` is cleared and monitor-specific config is not shipped. Set your wallpaper/monitors in DMS settings after install.
- **Memory cap:** `light.conf` sets `MemoryHigh=650M` and `MemoryMax=700M` to keep DMS within budget (may restart DMS if the cap is hit under heavy load).
- **Design preserved:** blur/transparency-related design settings in this config are kept as-is; the drop-in only adds non-visual runtime limits.
- Review files before installing, especially if you have an existing customized DMS setup.

## Uninstall / revert

Restore from the `.bak.*` files created by the installer in:
- `~/.config/dms/`
- `~/.config/systemd/user/dms.service.d/`

Then run:
```bash
systemctl --user daemon-reload && systemctl --user restart dms.service
```

## License

[MIT](LICENSE)
