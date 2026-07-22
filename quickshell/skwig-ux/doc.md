# Design
1. shell.qml should read as a config file - example of config file is `wayle/runtime.toml` in this repo
2. every bar module is its own file

# Inspiration
- https://github.com/AvengeMedia/DankMaterialShell - greeter, lockscreen, launcher, music player, calendar
- https://github.com/end-4/dots-hyprland - high quality, nice ?material? design,
- https://github.com/caelestia-dots/shell - high quality, nicely integrated together
- https://github.com/octagonemusic/octashell - clipboard viewer with image preview
- https://github.com/tripathiji1312/quickshell/ - structured config, pywal integration, gnome-esque 1 panel s wifi, bt, brightness, notif etc, ai slop though
- https://github.com/Nautilus4K/Hyprland-Configs
- https://github.com/weldros/dotfiles

# Scope
1. time, onclick calendar
2. sound indicator, onclick picker + mixer
3. network indicator, ?hide if not wifi?
4. bluetooth indicator, onclick manager
5. hyprland keymap, hide if default
6. battery indicator, hide if not available
7. collapsible systray
9. sound OSD
0. ?mic osd?
10. notification OSD
x. multimonitor
x. systray on the right?
x. systray better icon?
x. systray counter?
x. split up into modules / components / services
x. launcher nixos icon
--- design round ---
11. launcher
12. clipboard manager
13. music player
14. lockscreen
15. greeter
16. low battery alert
