//@ pragma UseQApplication

import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.Pam

// This is for outputing the cover image in the background of the media player column on the bar
// as a single composite layer to cut some corners (corner radius) and shit
// import Qt5Compat.GraphicalEffects

ShellRoot {
	id: root
	readonly property var themesFilePath: './themes.json'
	readonly property var configFilePath: './config.json'
	readonly property var kittyConfigPath: "/home/" + Quickshell.env("USER") + "/.config/kitty/kitty.conf"
	// readonly property var shrcPath: '/home/' + Quickshell.env("USER") + '/.zshrc'
	readonly property var fastfetchConfigPath: '/home/' + Quickshell.env("USER") + '/.config/fastfetch/config.jsonc'
	readonly property var makoConfigPath: '/home/' + Quickshell.env("USER") + '/.config/mako/config'

	property var themes: ({})
	FileView {
		id: themes_file
		path: Qt.resolvedUrl(themesFilePath)
		// blockLoading: true
		watchChanges: true
		// blockWrites: true

		onLoaded: {
			themes = JSON.parse(themes_file.text())
		}

		onFileChanged: this.reload()
	}

	FileView {
		id: config_file
		path: Qt.resolvedUrl(configFilePath)
		watchChanges: true
		blockWrites: true

		onFileChanged: reload()
		onAdapterUpdated: writeAdapter()

		JsonAdapter {
			id: configJson

			property int themeIndex: 0
			property var desktopEntries: ({})
		}
	}

	FileView {
		id: kitty_config_file
		path: Qt.resolvedUrl(kittyConfigPath)
		blockWrites: true
	}

	// onConfigJsonChanged: {
	// 	config_file.setText(JSON.stringify(configJson))
	// }

	// FileView {
	// 	id: shrc_file
	// 	path: Qt.resolvedUrl(shrcPath)
	// 	blockWrites: true
	// }

	FileView {
		id: fastfetch_config_file
		path: Qt.resolvedUrl(fastfetchConfigPath)
		blockWrites: true
	}

	FileView {
		id: mako_config_file
		path: Qt.resolvedUrl(makoConfigPath)
		blockWrites: true
	}

	// Colors
	readonly property var panelBackground:               themes[configJson.themeIndex]["panelBackground"]

	// > Top bar
	readonly property var archLogoColor:                 themes[configJson.themeIndex]["textBright1"]
	readonly property var batteryDefaultColor:           themes[configJson.themeIndex]["textBright1"]
	readonly property var batteryCriticalColor:          themes[configJson.themeIndex]["critical"]
	readonly property var batteryChargingColor:          themes[configJson.themeIndex]["accentHigh"]
	readonly property var workspaceButtonsColBackground: themes[configJson.themeIndex]["accentVeryLow"]
	readonly property var workspaceButtonBackground:     themes[configJson.themeIndex]["accentVeryHigh"]
	readonly property var workspaceButtonTextColor:      themes[configJson.themeIndex]["workspaceTextActivated"]
	readonly property var workspaceButtonDownColor:      themes[configJson.themeIndex]["workspaceTextDeactivated"]
	readonly property var workspaceButtonHoverBackground:themes[configJson.themeIndex]["accentLow"]

	// > Middle
	readonly property var activeWindowTitleColor:        themes[configJson.themeIndex]["textBright1"]

	// > Bottom bar
	readonly property var clockTextColor:                themes[configJson.themeIndex]["textBright1"]
	readonly property var trayButtonsColBackground:      themes[configJson.themeIndex]["sectionBackground"]
	readonly property var mediaButtonsDefaultBackground: themes[configJson.themeIndex]["accentVeryHigh"]
	readonly property var mediaButtonColor:              themes[configJson.themeIndex]["mediaButtonColor"]
	readonly property var mediaButtonEnabledOpacity:     themes[configJson.themeIndex]["mediaButtonEnabledOpacity"]
	readonly property var mediaButtonDisabledOpacity:    themes[configJson.themeIndex]["mediaButtonDisabledOpacity"]

	// > Popups
	readonly property var batteryPopupDetailsBackground: themes[configJson.themeIndex]["sectionBackground"]
	readonly property var clockGreyedOutTextColor:       themes[configJson.themeIndex]["textDimmed"]
	readonly property var clockTodayTextColor:           themes[configJson.themeIndex]["accentVeryHigh"]
	readonly property var volumeAndBrightnessTextColor:  themes[configJson.themeIndex]["textBright1"]
	readonly property var volumeAndBrightnessTextDown:   themes[configJson.themeIndex]["textDimmed"]
	readonly property var volumeAndBrightnessSection:    themes[configJson.themeIndex]["sectionBackground"]
	readonly property var volumeAndBrightnessIconColor:  themes[configJson.themeIndex]["textBright1"]
	readonly property var volumeAndBrightnessHighlighted:themes[configJson.themeIndex]["accent"]
	readonly property var volumeAndBrightnessSliderBg:   themes[configJson.themeIndex]["volumeAndBrightnessSliderBg"]
	readonly property var volumeAndBrightnessSliderKnob: themes[configJson.themeIndex]["accent"]
	readonly property var volumeAndBrightnessKnobDown:   themes[configJson.themeIndex]["accentHigh"]
	readonly property var volumeAndBrightnessDropdownBg: themes[configJson.themeIndex]["innerBackground"]
	readonly property var mediaSeekerBackground:         themes[configJson.themeIndex]["mediaSeekerBackground"]
	readonly property var mediaSeekerBackgroundOpacity:  themes[configJson.themeIndex]["mediaSeekerBackgroundOpacity"]
	readonly property var mediaSeekerHighlighted:        themes[configJson.themeIndex]["mediaSeekerHighlighted"]
	readonly property var mediaSeekerButton:             themes[configJson.themeIndex]["mediaSeekerButton"]
	readonly property var mediaSeekerButtonDown:         themes[configJson.themeIndex]["mediaSeekerButtonDown"]
	readonly property var statisticsTextColor:           themes[configJson.themeIndex]["textBright1"]
	readonly property var statisticsHighlightedTextColor:themes[configJson.themeIndex]["accentHigh"]
	readonly property var statisticsDimmedTextColor:     themes[configJson.themeIndex]["textDimmed"]
	readonly property var statisticsDetailsBackground:   themes[configJson.themeIndex]["sectionBackground"]
	readonly property var statisticsChartBackground:     themes[configJson.themeIndex]["innerBackground"]
	readonly property var statisticsChartHighlighted:    themes[configJson.themeIndex]["accent"]
	readonly property var statisticsChartHighlighted2:   themes[configJson.themeIndex]["contrast"]
	readonly property var statisticsChartCritical:       themes[configJson.themeIndex]["critical"]
	readonly property var statisticsLineChartBackground: themes[configJson.themeIndex]["innerBackground"]
	readonly property var statisticsChartLineWidth:      themes[configJson.themeIndex]["statisticsChartLineWidth"]
	readonly property var statisticsLineChartLineWidth:  themes[configJson.themeIndex]["statisticsLineChartLineWidth"]
	readonly property var statisticsLineChartPointRadius:themes[configJson.themeIndex]["statisticsLineChartPointRadius"]
	readonly property var statisticsNetPoints:           themes[configJson.themeIndex]["statisticsNetPoints"]
	readonly property var statisticsLineChartBgLineWidth:themes[configJson.themeIndex]["statisticsLineChartBgLineWidth"]
	readonly property var statisticsButtonBackground:    themes[configJson.themeIndex]["sectionBackground"]
	readonly property var statisticsButtonPressedDefBg:  themes[configJson.themeIndex]["accent"]
	readonly property var statisticsButtonHoldPower:     themes[configJson.themeIndex]["critical"]
	readonly property var statisticsButtonHoldReboot:    themes[configJson.themeIndex]["reboot"]
	readonly property var statisticsButtonHoldLogOut:    themes[configJson.themeIndex]["accent"]
	readonly property var statisticsButtonPressedFg:     themes[configJson.themeIndex]["statisticsButtonPressedFg"]
	readonly property int statisticsButtonHoldTime:      themes[configJson.themeIndex]["statisticsButtonHoldTime"]
	readonly property var statisticsScrollBarDown:       themes[configJson.themeIndex]["accentHigh"]
	readonly property var statisticsScrollBar:           themes[configJson.themeIndex]["accent"]
	readonly property var gallerySource:                 themes[configJson.themeIndex]["gallerySource"]
	readonly property var galleryLabel:                  themes[configJson.themeIndex]["galleryLabel"]
	readonly property var runPromptBackground:           themes[configJson.themeIndex]["panelBackground"]
	readonly property var runTextColor:                  themes[configJson.themeIndex]["textBright1"]
	readonly property var runSearchBox:                  themes[configJson.themeIndex]["sectionBackground"]
	readonly property var runSearchCursor:               themes[configJson.themeIndex]["accentHigh"]

	// > Theme selector
	readonly property var themeSelectorBackground:       themes[configJson.themeIndex]["panelBackground"]
	readonly property var themeSelectorHighlighted:      themes[configJson.themeIndex]["accent"]
	readonly property var themeSelectorTextColor:        themes[configJson.themeIndex]["textBright1"]

	// > Others
	readonly property var background: themes[configJson.themeIndex]["background"]
	readonly property var terminalBackground: themes[configJson.themeIndex]["innerBackground"]
	readonly property var terminalForeground: themes[configJson.themeIndex]["textBright1"]
	readonly property var terminalHighlight: themes[configJson.themeIndex]["accentHigh"]
	readonly property var notificationsBackground: themes[configJson.themeIndex]["panelBackground"]
	readonly property var notificationsForeground: themes[configJson.themeIndex]["textBright1"]

	// > Lock screen
	readonly property var lockscreenBackgroundColor: themes[configJson.themeIndex]["innerBackground"]
	readonly property var lockscreenCircleColor: themes[configJson.themeIndex]["accentVeryLow"]
	readonly property var lockscreenTimeColor: themes[configJson.themeIndex]["textBright1"]
	readonly property var lockscreenPanelColor: themes[configJson.themeIndex]["panelBackground"]
	readonly property var lockscreenTextColor: themes[configJson.themeIndex]["textBright1"]
	readonly property var lockscreenHighlightedTextColor: themes[configJson.themeIndex]["accentHigh"]
	readonly property var lockscreenDimmedTextColor: themes[configJson.themeIndex]["textDimmed"]
	readonly property var lockscreenInputColor: themes[configJson.themeIndex]["innerBackground"]
	readonly property var lockscreenWrongColor: themes[configJson.themeIndex]["critical"]

	Process {
		id: kitty_reloader
		running: false

		command: ["pkill", "-USR1", "kitty"]
	}

	Process {
		id: mako_reloader
		running: false

		command: ["makoctl", "reload"]
	}

	// This should work fine according to change order
	onTerminalForegroundChanged: {
		let update = "font_family JetBrains Mono\nfont_size 11.0\nbold_font auto\nitalic_font auto\nbold_italic_font auto\nbackground_opacity 0.875\nwindow_padding_width 15 18\ncursor_shape beam\nbackground " + terminalBackground + "\nforeground " + terminalForeground
		kitty_config_file.setText(update)

		kitty_reloader.running = true
	}

	onTerminalHighlightChanged: {
		// let update = 'HISTFILE=~/.zsh_history\nHISTSIZE=10000\nSAVEHIST=10000\nsetopt HIST_IGNORE_ALL_DUPS\nsetopt HIST_SAVE_NO_DUPS\nsetopt HIST_REDUCE_BLANKS\n\nbindkey "^[[H" beginning-of-line\nbindkey "^[[F" end-of-line\nbindkey "^[[3~" delete-char\n\nalias ls=\'ls --color=auto\'\nalias ll=\'ls --color=auto -la\'\nalias grep=\'grep --color=auto\'\nalias fgrep=\'fgrep --color=auto\'\nalias egrep=\'egrep --color=auto\'\n\nPROMPT="%B%F{' + terminalHighlight + '}%~%f%b %# \n\n# 1. Define the auto-reload function\nauto_reload_zshrc() {\n    # Set the flag so fastfetch is skipped during this source\n    ZSH_AUTO_RELOADING=1 \n    source ~/.zshrc\n    # Unset it immediately after so it doesn\'t leak\n    unset ZSH_AUTO_RELOADING \n}\n\n# 2. Register it to run before every prompt\nautoload -Uz add-zsh-hook\nadd-zsh-hook precmd auto_reload_zshrc\n\n# Only run fastfetch on a brand new terminal session\nif [[ -z "$ZSH_AUTO_RELOADING" ]]; then\n    fastfetch\nfi\n\nsource /etc/profile.d/flatpak.sh\nsource ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh\n'
		// shrc_file.setText(update)

		let fastfetchConfig = {"$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json", "logo": {"type": "kitty", "source": "/home/nautilus/Pictures/miku.jpg", "color": {"1": "", "2": "", "3": "", "4": "", "5": "", "6": "", "7": "", "8": "", "9": ""}, "width": 30, "height": 13, "padding": {"top": 0, "left": 1, "bottom": 2, "right": 4}, "printRemaining": true, "preserveAspectRatio": false, "recache": false, "position": "left", "chafa": {"fgOnly": false, "symbols": "block+border+space-wide-inverted"}}, "display": {"stat": false, "pipe": false, "showErrors": false, "disableLinewrap": true, "hideCursor": false, "separator": ": ", "color": {"keys": "#5fb7ff", "title": "#5fb7ff", "output": "", "separator": ""}, "brightColor": true, "duration": {"abbreviation": false, "spaceBeforeUnit": "default"}, "size": {"maxPrefix": "YB", "binaryPrefix": "iec", "ndigits": 2, "spaceBeforeUnit": "default"}, "temp": {"unit": "D", "ndigits": 1, "color": {"green": "32", "yellow": "93", "red": "91"}, "spaceBeforeUnit": "default"}, "percent": {"type": ["num", "num-color"], "ndigits": 0, "color": {"green": "32", "yellow": "93", "red": "91"}, "spaceBeforeUnit": "default", "width": 0}, "bar": {"char": {"elapsed": "\u25a0", "total": "-"}, "border": {"left": "[ ", "right": " ]", "leftElapsed": "", "rightElapsed": ""}, "color": {"elapsed": "auto", "total": "97", "border": "97"}, "width": 10}, "fraction": {"ndigits": 2, "trailingZeros": "default"}, "noBuffer": false, "key": {"width": 0, "type": "string", "paddingLeft": 0}, "freq": {"ndigits": 2, "spaceBeforeUnit": "default"}, "constants": []}, "general": {"thread": true, "processingTimeout": 5000, "detectVersion": true, "playerName": "", "dsForceDrm": false}, "modules": [{"type": "title", "key": " ", "keyIcon": "\uf015", "fqdn": false, "color": {"user": "", "at": "", "host": ""}}, {"type": "separator", "string": "\u2500", "outputColor": "", "times": 0}, {"type": "os", "key": "{icon} OS", "keyIcon": "\uf17c"}, {"type": "kernel", "key": "{icon} Kernel", "keyIcon": "\uf013"}, {"type": "uptime", "key": "{icon} Uptime", "keyIcon": "\ue641"}, {"type": "shell", "key": "{icon} Shell", "keyIcon": "\uf489"}, {"type": "terminal", "key": "{icon} Terminal", "keyIcon": "\ue795"}, {"type": "cpu", "key": "{icon} CPU", "keyIcon": "\uf4bc", "temp": false, "showPeCoreCount": false, "tempSensor": ""}, {"type": "gpu", "key": "{icon} GPU", "keyIcon": "\udb83\udfb2", "driverSpecific": false, "detectionMethod": "pci", "temp": false, "hideType": "none", "percent": {"green": 50, "yellow": 80, "type": 0}}, {"type": "memory", "key": "{icon} Memory", "keyIcon": "\uefc5", "percent": {"green": 50, "yellow": 80, "type": 0}}, {"type": "disk", "key": "{icon} Disk ({mountpoint})", "keyIcon": "\uf0a0", "showRegular": true, "showExternal": true, "showHidden": false, "showSubvolumes": false, "showReadOnly": true, "showUnknown": false, "folders": "", "hideFolders": "/efi:/boot:/boot/*", "hideFS": "", "useAvailable": false, "percent": {"green": 50, "yellow": 80, "type": 0}}, {"type": "separator", "string": "\u2500", "outputColor": "", "times": 0}, {"type": "colors", "key": " ", "keyIcon": "\uefcc", "symbol": "circle", "paddingLeft": 0, "brightness": "default"}, "break"]}
		fastfetchConfig["display"]["color"]["keys"] = terminalHighlight
		fastfetchConfig["display"]["color"]["title"] = terminalHighlight
		fastfetch_config_file.setText(JSON.stringify(fastfetchConfig))
	}

	onNotificationsForegroundChanged: {
		let update = "# --- Geometry and Layout ---\n# Limit the number of notifications on screen\nmax-history=20\n# Sort by time (newest first)\nsort=-time\n# Dimensions and spacing\nlayer=overlay\nwidth=350\nheight=200\nmargin=10\npadding=15\nborder-size=0\nborder-radius=5\n# Icons\nicons=1\nmax-icon-size=64\ndefault-timeout=5000\n\n# --- Global Styling ---\nfont=JetBrains Mono 10\nbackground-color=" + notificationsBackground + "\ntext-color=" + notificationsForeground + "\n# border-color=" + notificationsForeground + "\nprogress-color=over #1683ff\n\n# --- Conditional Styling ---\n# Mako allows you to change the look based on urgency level\n\n# Low urgency: Less intrusive color\n# [urgency=low]\n# border-color=#83a598\n\n# High urgency: Needs attention\n[urgency=high]\nborder-color=#1683ff\nborder-size=1\n# '0' means it stays on screen until you manually click/dismiss it\ndefault-timeout=0\n\n# --- Actions ---\n# Example: right click on notification runs a default action (e.g., dismiss)\non-button-right=dismiss\n"
		mako_config_file.setText(update)
		mako_reloader.running = true
	}

	// Configs
	readonly property var fontFamily: 'JetBrains Mono'

	// Stats
	property var batteryLevel: 0;
	property bool charging: false;
	property bool fullscreen: Hyprland.monitorFor(panel_window.screen)?.activeWorkspace?.hasFullscreen ?? false
	property bool hidden: false

	GlobalShortcut {
		name: "toggle"
		appid: "quickshell"

		onPressed: {
			hidden = !hidden
		}
	}

	GlobalShortcut {
		name: "lock"
		appid: "quickshell"

		onPressed: {
			locking = true
		}
	}

	GlobalShortcut {
		name: "changetheme"
		appid: "quickshell"

		onPressed: {
			themes_popup.shown = true
		}
	}

	GlobalShortcut {
		// id: leftButton
		name: "rightbutton"
		appid: "quickshell"

		onPressed: {
			themes_dis_area.rightButtonPressed()
		}
	}

	GlobalShortcut {
		// id: rightButton
		name: "leftbutton"
		appid: "quickshell"

		onPressed: {
			themes_dis_area.leftButtonPressed()
		}
	}

	GlobalShortcut {
		name: "run"
		appid: "quickshell"

		onPressed: {
			run_popup.shown = true
		}
	}

	GlobalShortcut {
		name: "esc"
		appid: "quickshell"

		onPressed: {
			if (run_popup.shown) run_popup.shown = false
			if (themes_popup.shown) themes_popup.shown = false
		}
	}

	// Pipewire
	PwObjectTracker {
		id: pwTracker
		objects: [Pipewire.defaultAudioSink]
	}

	// Background updater
	Process {
		id: bg_updater
		running: false

		command: [
			"awww", "img",
			background,
			"--transition-type", "grow", "--transition-pos", "bottom", "--transition-duration", "1", "--transition-fps", "120"
		]
	}

	readonly property PwNode sink: Pipewire.defaultAudioSink
	property int currentVolValue: Math.round(sink.audio.volume * 100)

	// Stats updater
	Process {
		id: battery_mon
		running: true;
		onRunningChanged: if (!running) running = true;

		command: ["sh", "-c", "
		acpi - b;
		sleep 1;
		"]

		stdout: SplitParser {
			onRead: data => {
				var out = data.split(", ");
				if (out[0].includes("Discharging")) charging = false;
				else charging = true;

				batteryLevel = parseInt(out[1]);
			}
		}
	}

	// Popups' individual codebase
	// Battery related statistics
	property var batteryID: ""
	Process {
		id: battery_id_parser
		running: true
		onRunningChanged: if (!running) running = true;

		command: ["sh", "-c", "
		ls /sys/class/power_supply/ | grep -E '^BAT|^BATT'
		sleep 5
		"]

		stdout: SplitParser {
			onRead: data => {
				var out = data.split("\n");
				batteryID = out[0]

				battery_information_parser.running = true // Kickstart it
			}
		}
	}

	property var batteryInfo: ({})
	Process {
		id: battery_information_parser
		running: false
		onRunningChanged: if (!running) running = true;

		command: ["sh", "-c", `
		upower -i /org/freedesktop/UPower/devices/battery_${batteryID}
		sleep 5
		`]

		stdout: SplitParser {
			onRead: data => {
				var out = data.split("\n");
				// console.log(battery_information_parser.command)
				var toBeBatteryInfo = {}
				var updated = Object.assign({}, batteryInfo);
				for (const line of out) {
					// console.log(line)
					var parts = line.trim().split(/\s+/);
					if (parts.length >= 2) {
						var key = parts[0].replace(/:$/, "");
						var value = parts.slice(1).join(" "); // rejoin everything after the key
						updated[key] = value;
					}
				}

				batteryInfo = updated
			}
		}
	}

	property int currentBrightnessPercent: 0 // %
	Process {
		id: brightness_information_parser
		running: true
		onRunningChanged: if (!running) running = true;

		command: ["sh", "-c", `
		brightnessctl -m
		sleep 0.08
		`]

		stdout: SplitParser {
			onRead: data => {
				// nvidia_0,backlight,100,100%,100
				var out = data.split(",")
				currentBrightnessPercent = parseInt(out[3])
				// console.log(out)
			}
		}
	}

	// A universal command runner
	Process {
		id: brightness_change_value
		running: false

		property var value: currentBrightnessPercent
		command: ["sh", "-c", `
		brightnessctl set ${value}%
		`]
	}

	property var username: Quickshell.env("USER")
	property var hostname: "host"
	Process {
		id: user_info_parser
		running: true

		command: ["sh", "-c", `
		hostname
		`]

		stdout: SplitParser {
			onRead: data => {
				var out = data.split("\n")
				hostname = out[0]
			}
		}
	}

	function formatBytes(bytes, decimals = 2) {
		if (bytes === 0) return '0 B';

		const k = 1024;
		const dm = decimals < 0 ? 0 : decimals;
		const sizes = ['B', 'KB', 'MB', 'GB'];

		// This calculates which index of the 'sizes' array to use
		const i = Math.floor(Math.log(bytes) / Math.log(k));

		// Ensure we don't exceed the 'GB' index in the array
		const index = Math.min(i, sizes.length - 1);

		if (index < 0) return "0 B";

		return parseFloat((bytes / Math.pow(k, index)).toFixed(dm)) + ' ' + sizes[index];
	}

	// System stats monitor
	property real cpuUsage: 0
	property real ramUsage: 0
	property var diskTotalBytesCount: 0
	property var diskUsedBytesCount: 0
	property var netUpBytes: 0
	property var netDownBytes: 0

	Process {
		id: cpu_mon
		running: false;
		onRunningChanged: if (!running && statistics_popup.shown) running = true;

		command: ["sh", "-c", "
		mpstat 1 1 | awk 'END{print 100-$NF}';
		sleep 1;
		"]

		stdout: SplitParser {
			onRead: data => cpuUsage = Math.round(parseFloat(data) * 10) / 10;
		}
	}

	Process {
		id: ram_mon
		running: false;
		onRunningChanged: if (!running && statistics_popup.shown) running = true;

		command: ["sh", "-c", "
		free | grep Mem | awk '{print $3/$2 * 100.0}'
		sleep 3;
		"]

		stdout: SplitParser {
			onRead: data => ramUsage = Math.round(parseFloat(data) * 100) / 100;
		}
	}

	Process {
		id: disk_mon
		running: false;
		onRunningChanged: if (!running && statistics_popup.shown) running = true;

		command: ["sh", "-c", `
		df -B1 / | awk 'NR==2 {print $2, $3}'
		sleep 10
		`]

		stdout: SplitParser {
			onRead: data => {
				var out = data.split(" ")

				diskTotalBytesCount = parseInt(out[0])
				diskUsedBytesCount = parseInt(out[1])

				// console.log(diskTotalBytesCount)
				// console.log(diskUsedBytesCount)
			}
		}
	}

	Process {
		id: net_mon
		running: true;
		onRunningChanged: if (!running) running = true;

		command: ["sh", "-c", "
		IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

		RX1=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
		TX1=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)

		sleep 1

		RX2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
		TX2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)

		RX_SPEED=$(($RX2 - $RX1))
		TX_SPEED=$(($TX2 - $TX1))

		echo \"$RX_SPEED|$TX_SPEED\"
		"]

		stdout: SplitParser {
			onRead: data => {
				let out = data.split("|");

				// RX: Recieve - Download
				netDownBytes = parseInt(out[0]);

				// TX: Transmit - Upload
				netUpBytes = parseInt(out[1]);
			}
		}
	}

	Process {
		id: power_off_proc
		running: false

		command: ["sh", "-c", `
		sleep 0.5;
		poweroff
		`]
	}

	Process {
		id: reboot_proc
		running: false

		command: ["sh", "-c", "
		sleep 0.5;
		reboot
		"]
	}

	Process {
		id: logout_proc
		running: false

		command: ["sh", "-c", "
		sleep 0.5;
		hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit
		"]
	}

	property var notificationsHistory: ({})
	property string _notifBuffer: ""

	Process {
		id: notif_mon
		running: true // Run first time when qs starts
		// onRunningChanged: if (!running && statistics_popup.shown) running = true;
		command: ["sh", "-c", `
			makoctl history -j
			`]
		stdout: SplitParser {
			onRead: data => {
				_notifBuffer += data + "\n"
			}
		}
		onExited: {
			if (_notifBuffer.trim() !== "") {
				notificationsHistory = JSON.parse(_notifBuffer.trim())
				// console.log(JSON.stringify(notificationsHistory))
				_notifBuffer = ""
			}
		}
	}

	Timer {
		running: true
		repeat: true
		interval: 1000
		triggeredOnStart: true

		onTriggered: {
			if (statistics_popup.shown) notif_mon.running = true
		}
	}

	Process {
		id: notif_clear_proc
		running: false

		command: ["systemctl", "restart", "--user", "mako"]
	}

	readonly property var applistReloaderPath: "/home/" + Quickshell.env("USER") + "/.config/quickshell/listapps.py"
	property string _applistBuffer: ""
	property var applist: ({})
	Process {
		id: applist_reloader
		running: false

		command: ["python", applistReloaderPath]

		// onRunningChanged: {
		// 	console.log("A")
		// }

		stdout: SplitParser {
			onRead: data => {
				// The data is only 1 line. But its fucking long
				// So we still need a buffer
				_applistBuffer += data + "\n"
				// console.log(data)
			}
		}
		onExited: {
			if (_applistBuffer.trim() !== "") {
				applist = JSON.parse(_applistBuffer.trim())

				// console.log(JSON.stringify(applist))
				_applistBuffer = ""
			}
		}
	}

	Process {
		id: app_launch
		running: false

		property var appName: ""

		command: ["sh", "-c", "gtk-launch \"" + appName + "\" > \"/tmp/" + appName + ".log\" 2>&1"]
		environment: ({
			"DISPLAY": Qt.environment("DISPLAY"),
			"WAYLAND_DISPLAY": Qt.environment("WAYLAND_DISPLAY"),
			"DBUS_SESSION_BUS_ADDRESS": Qt.environment("DBUS_SESSION_BUS_ADDRESS"),
			"XDG_RUNTIME_DIR": Qt.environment("XDG_RUNTIME_DIR"),
			"HOME": Qt.environment("HOME"),
		})
	}




	PanelWindow {
		id: panel_window
		// Side bar on the left
		anchors {
			left: true
			top: true
			bottom: true
		}

		color: "#00000000" // Invisible
		implicitWidth: hidden ? 0 : 50

		WlrLayershell.layer: WlrLayer.Overlay

		Rectangle {
			id: panel
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			width: parent.width
			color: panelBackground

			Behavior on color {
				ColorAnimation {
					duration: 200
				}
			}

			// Ermmm this kinda sucks actually
			// topRightRadius: 10
			// bottomRightRadius: 10

			x: (fullscreen || hidden) ? -width : 0

			opacity: 1.0

			Behavior on x {
				NumberAnimation {
					duration: 200
					easing.type: Easing.OutCubic
				}
			}

			// The top buttons
			Column {
				id: panel_top

				anchors.left: panel.left
				anchors.right: panel.right
				anchors.top: panel.top

				spacing: 20

				Text {
					// anchors.topMargin: 10
					topPadding: 10
					anchors.left: parent.left
					anchors.right: parent.right
					// anchors.top: parent.top
					// anchors.topMargin: 10

					id: arch_logo
					text: "󰣇 "

					font.pixelSize: 16

					color: archLogoColor
					horizontalAlignment: Text.AlignHCenter

					HoverHandler {
						onHoveredChanged: {
							statistics_popup.shown = hovered
						}
					}
				}

				Text {
					anchors.left: parent.left
					anchors.right: parent.right
					// anchors.top: arch_logo.bottom
					// anchors.topMargin: 10

					id: battery_icon

					font.pixelSize: 16
					text: {
						if (charging) {
							if (batteryLevel > 90) {
								return "󰂅"
							} else if (batteryLevel > 80) {
								return "󰂋"
							} else if (batteryLevel > 70) {
								return "󰂊"
							} else if (batteryLevel > 60) {
								return "󰢞"
							} else if (batteryLevel > 50) {
								return "󰂉"
							} else if (batteryLevel > 40) {
								return "󰢝"
							} else if (batteryLevel > 30) {
								return "󰂈"
							} else if (batteryLevel > 20) {
								return "󰂇"
							} else if (batteryLevel > 10) {
								return "󰂆"
							} else {
								return "󰢜"
							}
						} else {
							if (batteryLevel > 90) {
								return "󰁹"
							} else if (batteryLevel > 80) {
								return "󰂂"
							} else if (batteryLevel > 70) {
								return "󰂁"
							} else if (batteryLevel > 60) {
								return "󰂀"
							} else if (batteryLevel > 50) {
								return "󰁿"
							} else if (batteryLevel > 40) {
								return "󰁾"
							} else if (batteryLevel > 30) {
								return "󰁽"
							} else if (batteryLevel > 20) {
								return "󰁼"
							} else if (batteryLevel > 10) {
								return "󰁻"
							} else {
								return "󰁺"
							}
						}
					}

					color: charging ? batteryChargingColor : (
						batteryLevel > 20 ? batteryDefaultColor : batteryCriticalColor
					)
					horizontalAlignment: Text.AlignHCenter

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true

						onEntered: battery_popup.shown = true
						onExited: battery_popup.shown = false
					}
				}

				Rectangle {
					width: 25

					height: childrenRect.height
					anchors.horizontalCenter: parent.horizontalCenter

					color: workspaceButtonsColBackground

					radius: 5

					Behavior on height {
						NumberAnimation {
							duration: 200
							easing.type: Easing.OutCubic
						}
					}

					Column {
						id: workspaces_column
						spacing: 5

						anchors.top: parent.top
						anchors.left: parent.left
						anchors.right: parent.right

						// Handles the very first time the bar loads
						populate: Transition {
							NumberAnimation {
								properties: "scale,opacity";
								from: 0;
								duration: 200;
								easing.type: Easing.OutBack
							}
						}

						// Handles new workspaces being created
						add: Transition {
							NumberAnimation {
								properties: "scale,opacity";
								from: 0;
								duration: 200;
								easing.type: Easing.OutBack
							}
						}

						// CRITICAL: Handles existing workspaces sliding when others are removed
						move: Transition {
							NumberAnimation {
								properties: "x,y";
								duration: 200;
								easing.type: Easing.OutCubic
							}
						}

						Repeater {
							model: Hyprland.workspaces

							delegate: Rectangle {
								property string activeSpecial: ""
								Connections {
									target: Hyprland
									function onRawEvent(event) {
										// Triggered when a special workspace is toggled on
										if (event.name === "activespecial") {
											const name = event.data.split(',')[0];
											// Hyprland sends an empty string when the special workspace is dismissed
											if (name === "") {
												activeSpecial = "";
											} else {
												activeSpecial = name;
											}
										}
									}
								}

								required property var modelData
								property bool isChosen: activeSpecial === modelData.name || Hyprland.focusedWorkspace === modelData

								width: 25
								height: 25

								radius: 5

								// Initial state for the 'add' animation
								opacity: 1
								scale: 1

								color: workspaces_hover_handler.hovered ? workspaceButtonHoverBackground : workspaceButtonsColBackground

								Behavior on color {
									ColorAnimation {
										duration: 150
									}
								}

								Rectangle {
									anchors.fill: parent
									radius: 5

									scale: isChosen ? 1 : 0
									color: workspaceButtonBackground

									Behavior on scale {
										NumberAnimation {
											duration: 200
											easing.type: Easing.OutBack
										}
									}
								}

								Text {
									anchors.centerIn: parent

									text: modelData.name == "special:magic" ? "" : (modelData.name === "10" ? "0" : modelData.name)
									color: isChosen ? workspaceButtonTextColor : workspaceButtonDownColor

									font.pixelSize: 12
									font.family: fontFamily

									// font.bold: true
								}

								HoverHandler {
									id: workspaces_hover_handler;
									// anchors.fill: parent;
								}

								MouseArea {
									anchors.fill: parent
									onClicked: modelData.activate()
								}
							}
						}
					}
				}
			}

			// The middle status label
			Item {
				id: middle_area

				anchors.top: panel_top.bottom
				anchors.bottom: panel_bottom.top
				anchors.left: panel.left
				anchors.right: panel.right

				anchors.topMargin: 30
				anchors.bottomMargin: 30

				Text {
					visible: ToplevelManager.toplevels.values.length > 0 && ToplevelManager.activeToplevel !== null

					id: windowName
					color: activeWindowTitleColor
					rotation: 270

					text: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.title : "";
					font.pixelSize: 14
					font.family: fontFamily

					elide: Text.ElideRight;

					anchors.centerIn: parent

					// Cuz of the -90 degrees rotation
					width: Math.min(implicitWidth, parent.height)
					height: Math.min(implicitHeight, parent.width)
				}
			}

			// The bottom buttons
			Column {
				id: panel_bottom

				anchors.left: panel.left
				anchors.bottom: panel.bottom
				anchors.right: panel.right
				// anchors.bottomMargin: 10

				spacing: 20

				Item {
					id: media_rect_container

					anchors.left: parent.left
					anchors.right: parent.right
					height: childrenRect.height

					HoverHandler {
						onHoveredChanged: {
							media_popup.shown = hovered
						}
					}

					Rectangle {
						id: media_buttons_container
						width: 25

						height: Mpris.players.values.length > 0 ? 80 : 0
						opacity: Mpris.players.values.length > 0 ? 1 : 0

						visible: opacity != 0

						anchors.horizontalCenter: parent.horizontalCenter

						color: mediaButtonsDefaultBackground
						radius: 5

						clip: true

						// layer.enabled: true
						// layer.effect: OpacityMask {
						// 	maskSource: Rectangle {
						// 		width: media_buttons_container.width
						// 		height: media_buttons_container.height
						// 		radius: media_buttons_container.radius
						// 	}
						// }

						Behavior on height {
							NumberAnimation {
								duration: 200
								easing.type: Easing.OutCubic
							}
						}

						Behavior on opacity {
							NumberAnimation {
								duration: 200
							}
						}

						property int playerIndex: 0
						property int playerNumbers: Mpris.players.values.length
						property MprisPlayer player: Mpris.players.values[playerIndex]  // now reactive to int changes

						// Clamp playerIndex whenever playerNumbers changes
						onPlayerNumbersChanged: {
							if (playerNumbers === 0) {
								playerIndex = 0;
							} else if (playerIndex > playerNumbers - 1) {
								playerIndex = playerNumbers - 1;
							}
						}

						MouseArea {
							anchors.fill: parent
							onWheel: (wheel) => {
								if (wheel.angleDelta.y > 0) {
									parent.playerIndex = Math.min(parent.playerIndex + 1, parent.playerNumbers - 1);
								} else if (wheel.angleDelta.y < 0) {
									parent.playerIndex = Math.max(parent.playerIndex - 1, 0);
								}
							}
						}

						Image {
							id: media_dynamic_bg
							anchors.fill: parent
							cache: true

							source: media_buttons_container.player?.trackArtUrl ?? "";
							fillMode: Image.PreserveAspectCrop;

							visible: source != ""; // As long as the source exists.
							asynchronous: true;
						}

						// DYNAMIC BACKGROUND IMAGE: BLUR EFFECT
						MultiEffect {
							anchors.fill: media_dynamic_bg;
							source: media_dynamic_bg;

							autoPaddingEnabled: false;

							brightness: 0.5;
							saturation: 0;
							blurEnabled: true;
							blurMax: 64;
							blur: 0.5;
						}

						// More faith
						Text {
							id: media_prev_button
							// The previous button
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.top: parent.top
							anchors.topMargin: 3

							horizontalAlignment: Text.AlignHCenter
							text: "󰒮"
							font.pixelSize: 18

							color: mediaButtonColor

							opacity: media_buttons_container.player.canGoPrevious ? mediaButtonEnabledOpacity : mediaButtonDisabledOpacity

							scale: 1 // Initialize the thing yk
							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								anchors.fill: parent
								onClicked: {
									media_buttons_container.player?.previous()
								}

								onPressed: {
									parent.scale = 0.75
								}

								onReleased: {
									parent.scale = 1
								}
							}
						}

						// Alright the play pause button
						Text {
							id: media_play_button
							// The next button
							anchors.centerIn: parent

							// horizontalAlignment: Text.AlignHCenter
							text: media_buttons_container.player?.isPlaying ? "󰏤" : "󰐊"
							font.pixelSize: 18

							color: mediaButtonColor

							opacity: media_buttons_container.player.canTogglePlaying ? mediaButtonEnabledOpacity : mediaButtonDisabledOpacity

							scale: 1 // Initialize the thing yk
							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								anchors.fill: parent
								onClicked: {
									media_buttons_container.player?.togglePlaying()
								}

								onPressed: {
									parent.scale = 0.75
								}

								onReleased: {
									parent.scale = 1
								}
							}
						}

						// More faith
						Text {
							id: media_next_button
							// The next button
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.bottom: parent.bottom
							anchors.bottomMargin: 3

							horizontalAlignment: Text.AlignHCenter
							text: "󰒭"
							font.pixelSize: 18

							color: mediaButtonColor

							opacity: media_buttons_container.player.canGoNext ? mediaButtonEnabledOpacity : mediaButtonDisabledOpacity

							scale: 1 // Initialize the thing yk
							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								anchors.fill: parent
								onClicked: {
									media_buttons_container.player?.next()
								}

								onPressed: {
									parent.scale = 0.75
								}

								onReleased: {
									parent.scale = 1
								}
							}
						}
					}
				}

				Rectangle {
					width: 25

					height: childrenRect.height
					anchors.horizontalCenter: parent.horizontalCenter

					color: trayButtonsColBackground

					radius: 5

					Behavior on height {
						NumberAnimation {
							duration: 200
							easing.type: Easing.OutCubic
						}
					}

					Column {
						id: tray_buttons_column
						spacing: 10

						// anchors.bottom: parent.bottom
						anchors.left: parent.left
						anchors.right: parent.right

						Repeater {
							model: SystemTray.items

							delegate: Item {
								id: tray_item

								required property SystemTrayItem modelData

								width: 20
								height: 20

								anchors.horizontalCenter: parent.horizontalCenter

								Image {
									anchors.fill: parent
									source: tray_item.modelData.icon
									fillMode: Image.PreserveAspectFit
								}

								MouseArea {
									anchors.fill: parent
									acceptedButtons: Qt.LeftButton | Qt.RightButton

									onClicked: (event) => {
										if (event.button === Qt.RightButton && tray_item.modelData.hasMenu) {
											menu_anchor.open()
										} else if (!tray_item.modelData.onlyMenu) {
											tray_item.modelData.activate()
										} else if (tray_item.modelData.hasMenu) {
											menu_anchor.open()
										}
									}
								}

								QsMenuAnchor {
									id: menu_anchor
									menu: tray_item.modelData.menu
									// anchor.item: parent
									anchor.item: parent
								}
							}
						}
					}
				}

				SystemClock {
					id: clock;
					precision: SystemClock.Seconds;
				}

				Text {
					id: clock_text

					anchors.left: parent.left
					anchors.right: parent.right
					// anchors.bottom: parent.bottom
					// anchors.bottomMargin: 7

					// anchors.topMargin: 9

					horizontalAlignment: Text.AlignHCenter
					// verticalAlignment: Text.AlignVCenter

					text: Qt.formatDateTime(
						clock.date,
						"hh\nmm\nss"
					)
					font.family: fontFamily
					font.pixelSize: 14
					color: clockTextColor

					lineHeight: 1.4
					height: 75 // This is kinda alright

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true

						onEntered: calendar_popup.shown = true
						onExited: calendar_popup.shown = false
					}
				}

				Text {
					id: sound_and_brightness_button
					anchors.left: parent.left
					anchors.right: parent.right
					bottomPadding: 10

					horizontalAlignment: Text.AlignHCenter

					text: "󰘮"
					// font.family: fontFamily
					font.pixelSize: 16
					color: clockTextColor

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true

						onEntered: volume_and_brightness_popup.shownForced = true
						onExited: volume_and_brightness_popup.shownForced = false
					}
				}
			}
		}


		// Dedicated pop up for battery percentage and stuff
		PopupWindow {
			id: battery_popup

			property var shown: false
			property var popupWidth: 400
			property var popupHeight: 210

			anchor.item: battery_icon
			implicitWidth: popupWidth + 10 // +10 for animation
			implicitHeight: popupHeight // 10 on each side (up and down)

			// property var offsetX: (shown ? panel.width + 10 : 0)
			anchor.rect.x: panel.width
			anchor.rect.y: -10 // Shadows buffer zone

			// Behavior on offsetX {
			// 	NumberAnimation {
			// 		duration: 200
			// 	}
			// }

			visible: (battery_details_rect.opacity > 0)

			color: "transparent"

			Rectangle {
				id: battery_details_rect
				anchors.top: parent.top
				anchors.bottom: parent.bottom

				width: battery_popup.popupWidth
				x: (battery_popup.shown ? 10 : 0)

				opacity: (battery_popup.shown ? 1 : 0)

				Behavior on opacity {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				Behavior on x {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				color: panelBackground
				radius: 10

				Behavior on color {
					ColorAnimation {
						duration: 200
					}
				}

				Rectangle {
					id: battery_state_of_charge

					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.leftMargin: 15
					anchors.rightMargin: 15
					anchors.topMargin: 15

					height: childrenRect.height

					color: 'transparent'

					Text {
						anchors.left: parent.left

						text: (charging ? "AC Connected" : "Discharging")
						color: battery_icon.color

						font.family: fontFamily
					}

					Text {
						anchors.right: parent.right;

						text: batteryLevel + "%"
						color: battery_icon.color

						font.family: fontFamily
						font.bold: true
					}
				}

				Rectangle {
					anchors.top: battery_state_of_charge.bottom
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom

					anchors.topMargin: 15
					anchors.bottomMargin: 15
					anchors.leftMargin: 15
					anchors.rightMargin: 15

					color: batteryPopupDetailsBackground

					radius: 8

					opacity: parent.opacity

					Column {
						anchors.fill: parent;
						anchors.topMargin: 15
						anchors.bottomMargin: 15
						anchors.leftMargin: 15
						anchors.rightMargin: 15
						spacing: 10

						Rectangle {
							anchors.left: parent.left
							anchors.right: parent.right
							height: childrenRect.height

							color: "transparent"

							Text {
								anchors.left: parent.left

								text: batteryID
								color: batteryDefaultColor

								font.family: fontFamily
							}

							Text {
								anchors.right: parent.right

								text: batteryInfo["vendor"] + " " + batteryInfo["model"]
								color: batteryDefaultColor

								font.family: fontFamily
							}
						}

						Rectangle {
							anchors.left: parent.left
							anchors.right: parent.right
							height: childrenRect.height

							color: 'transparent'

							Text {
								anchors.left: parent.left

								text: "Capacity"
								color: batteryDefaultColor

								font.family: fontFamily
							}

							Text {
								anchors.right: parent.right

								text: batteryInfo["capacity"] + " (" + batteryInfo["energy-full"] + "/" + batteryInfo["energy-full-design"] + ")"
								color: batteryDefaultColor

								font.family: fontFamily
							}
						}

						Rectangle {
							anchors.left: parent.left
							anchors.right: parent.right
							height: childrenRect.height

							color: 'transparent'

							Text {
								anchors.left: parent.left

								text: "Charge Cycles"
								color: batteryDefaultColor

								font.family: fontFamily
							}

							Text {
								anchors.right: parent.right

								text: batteryInfo["charge-cycles"] ? batteryInfo["charge-cycles"] : "-"
								color: batteryDefaultColor

								font.family: fontFamily
							}
						}

						Rectangle {
							anchors.left: parent.left
							anchors.right: parent.right
							height: childrenRect.height

							color: 'transparent'

							Text {
								anchors.left: parent.left

								text: "Voltage"
								color: batteryDefaultColor

								font.family: fontFamily
							}

							Text {
								anchors.right: parent.right

								text: batteryInfo["voltage"] ? batteryInfo["voltage"] : "-"
								color: batteryDefaultColor

								font.family: fontFamily
							}
						}
					}
				}
			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true

				onEntered: battery_popup.shown = true
				onExited: battery_popup.shown = false
			}
		}



		// Dedicated pop up for time and calendar
		PopupWindow {
			id: calendar_popup

			property var shown: false
			property var popupWidth: 330 // Well this is kinda a half assed approach, but what can I do anyways?

			anchor.item: clock_text
			implicitWidth: popupWidth + 10 // +10 for animation
			implicitHeight: calendar_details_rect.height + 20 // 10 on each side (up and down)

			// property var offsetX: (shown ? panel.width + 10 : 0)
			anchor.rect.x: panel.width
			anchor.rect.y: -10 // Shadows buffer zone

			visible: (calendar_details_rect.opacity > 0)

			color: "transparent"

			Rectangle {
				id: calendar_details_rect
				anchors.top: parent.top
				// anchors.bottom: parent.bottom
				// height:childrenRect.height
				height: childrenRect.height + 30

				width: calendar_popup.popupWidth
				x: (calendar_popup.shown ? 10 : 0)

				opacity: (calendar_popup.shown ? 1 : 0)

				Behavior on opacity {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				Behavior on x {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				color: panelBackground
				radius: 10

				Behavior on color {
					ColorAnimation {
						duration: 200
					}
				}

				Column {
					id: calendar_col
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					// anchors.fill: parent
					anchors.margins: 15
					spacing: 10

					// Now its a bit better
					// First is the current time and date line
					Item {
						anchors.left: parent.left
						anchors.right: parent.right
						height: childrenRect.height

						Text {
							anchors.left: parent.left

							text: Qt.formatDateTime(
								clock.date,
								"hh:mm:ss"
							)
							color: clockTextColor
							font.family: fontFamily
							// font.pixelSize:
						}

						Text {
							anchors.right: parent.right

							text: Qt.formatDateTime(
								clock.date,
								"dd/MM/yyyy"
							)
							color: clockTextColor
							font.family: fontFamily
							// font.pixelSize:
						}
					}

					// Text {
					// 	id: calendar_weekday_labels
					// 	color: clockTextColor
					// 	font.family: fontFamily

					// 	text: "MON  TUE  WED  THU  FRI  SAT  SUN"
					// }
					Grid {
						id: calendar_weekday_labels
						anchors.left: parent.left
						anchors.right: parent.right
						columns: 7
						spacing: 5

						property var weekdays: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

						Repeater {
							model: calendar_weekday_labels.weekdays

							delegate: Rectangle {
								height: childrenRect.height
								width: 40

								color: "transparent"

								Text {
									// anchors.centerIn: parent
									text: modelData

									color: clockTextColor
									font.family: fontFamily
								}
							}
						}
					}

					// The actual calendar (minus the weekday labels)
					Item {
						id: calendar
						anchors.left: parent.left
						anchors.right: parent.right
						height: childrenRect.height

						property var dayDisplays: {
							let days = []
							const now = new Date();
							let firstDate = new Date(now.getFullYear(), now.getMonth(), 1)
							let firstWeekday = (firstDate.getDay() + 6) % 7
							// let firstWeekday = 3 // debug

							let lastDate = new Date(now.getFullYear(), now.getMonth() + 1, 0)
							let digitsAmount = (firstWeekday + lastDate.getDate())
							if (digitsAmount > 7 * 5) digitsAmount = 7 * 6
							else digitsAmount = 7 * 5
							// console.log(firstWeekday)
							// firstWeekday will have these values:
							// 0: MONDAY
							// 1: TUESDAY
							// 2: WEDNESDAY
							// 3: THURSDAY
							// 4: FRIDAY
							// 5: SATURDAY
							// 6: SUNDAY

							// Now we just append it all first

							// console.log(firstWeekday + " | " + digitsAmount)
							let lastMonthFinalDate = new Date(now.getFullYear(), now.getMonth(), 0).getDate()
							for (let i = 0; i < firstWeekday; i++) {
								let offset = firstWeekday - i

								days.push("_" + (lastMonthFinalDate - offset + 1))
							}

							// Now we just need to add the rest of the days
							for (let i = 1; i <= lastDate.getDate(); i++) {
								let value = "" + i

								if (value.length == 1) value = "0" + value
								days.push(value)
							}

							digitsAmount -= days.length
							for (let i = 1; i <= digitsAmount; i++) {
								let value = "" + i

								if (value.length == 1) value = "0" + value
								days.push("_"+value)
							}

							// console.log(days)

							return days
						}

						property var today: {
							let d = "" + new Date().getDate()
							return d.length === 1 ? "0" + d : d
							// console.log(today)
						}
						Grid {
							id: calendar_grid
							columns: 7
							spacing: 5

							Repeater {
								model: calendar.dayDisplays

								delegate: Rectangle {
									height: childrenRect.height
									width: 40

									// color: modelData === calendar.today ? "white" : "transparent"
									color: "transparent"

									Text {
										// anchors.centerIn: parent
										text: modelData[0] == '_' ? modelData.slice(1) : (modelData === calendar.today ? modelData + "*" : modelData)

										color: modelData[0] == '_' ? clockGreyedOutTextColor : (modelData === calendar.today ? clockTodayTextColor : clockTextColor)
										font.bold: modelData === calendar.today
										font.family: fontFamily
									}
								}
							}
						}
					}
				}
			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true

				onEntered: calendar_popup.shown = true
				onExited: calendar_popup.shown = false
			}
		}

		// Dedicated pop up for volume and brightness
		PopupWindow {
			id: volume_and_brightness_popup

			property var shownForced: false
			property int openCountdown: 0 // When the brightness was changed without using the track, it should hover on the screen for a while
			property var shown: shownForced || openCountdown > 0 || audio_device_selector.popup.visible
			property var popupWidth: 330

			anchor.item: sound_and_brightness_button
			implicitWidth: popupWidth + 10 // +10 for animation
			implicitHeight: volume_and_brightness_details_rect.height + 20 // 10 on each side (up and down)

			// property var offsetX: (shown ? panel.width + 10 : 0)
			anchor.rect.x: panel.width
			anchor.rect.y: -10 // Shadows buffer zone

			visible: (volume_and_brightness_details_rect.opacity > 0)

			color: "transparent"

			Timer {
				id: open_countdown_timer
				interval: 1000      // Trigger interval in milliseconds (1 second)
				repeat: true        // Keep running continuously
				running: true       // Start automatically

				onTriggered: {
					if (volume_and_brightness_popup.openCountdown > 0) {
						volume_and_brightness_popup.openCountdown--;
					}
				}
			}

			Rectangle {
				id: volume_and_brightness_details_rect
				anchors.top: parent.top
				// anchors.bottom: parent.bottom
				// height:childrenRect.height
				height: childrenRect.height + 30

				width: volume_and_brightness_popup.popupWidth
				x: (volume_and_brightness_popup.shown ? 10 : 0)

				opacity: (volume_and_brightness_popup.shown ? 1 : 0)

				Behavior on opacity {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				Behavior on x {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				color: panelBackground
				radius: 10

				Behavior on color {
					ColorAnimation {
						duration: 200
					}
				}

				Column {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					// anchors.fill: parent
					anchors.margins: 15
					spacing: 10

					// Text {
					// 	text: "placeholder: volume/brightness"
					// 	font.family: fontFamily
					// 	color: volumeAndBrightnessTextColor
					// }

					Rectangle {
						id: brightness_rect
						anchors.left: parent.left
						anchors.right: parent.right
						height: 40

						color: volumeAndBrightnessSection
						radius: 8

						Text {
							id: brightness_rect_icon
							anchors.top: parent.top
							anchors.left: parent.left
							anchors.bottom: parent.bottom
							anchors.leftMargin: 15
							text: ""

							color: volumeAndBrightnessIconColor
							verticalAlignment: Text.AlignVCenter
						}

						Text {
							id: brightness_rect_details
							anchors.top: parent.top
							anchors.right: parent.right
							anchors.bottom: parent.bottom
							anchors.rightMargin: 15
							text: currentBrightnessPercent + "%"
							width: 35
							horizontalAlignment: Text.AlignRight

							font.family: fontFamily
							color: volumeAndBrightnessTextColor
							verticalAlignment: Text.AlignVCenter
						}

						Slider {
							id: brightness_control

							from: 1
							value: currentBrightnessPercent
							to: 100

							onValueChanged: {
								volume_and_brightness_popup.openCountdown = 2
							}

							Behavior on value {
								enabled: !brightness_control.pressed
								NumberAnimation {
									id: brightness_slider_animation
									duration: 150
									easing.type: Easing.OutCubic
								}
							}

							anchors.top: parent.top
							anchors.bottom: parent.bottom
							anchors.left: brightness_rect_icon.right
							anchors.right: brightness_rect_details.left
							anchors.leftMargin: 15
							anchors.rightMargin: 15

							background: Rectangle {
								// This is gonna be the track?
								x: brightness_control.leftPadding
								y: brightness_control.topPadding + brightness_control.availableHeight / 2 - height / 2
								// implicitWidth: 100
								implicitHeight: 4

								radius: 5

								// Yeah doing all this just to make the width and height be correct
								width: brightness_control.availableWidth
								height: implicitHeight

								color: volumeAndBrightnessSliderBg

								Rectangle {
									// Subtract half the handle width on each side
									width: brightness_control.visualPosition * (parent.width - brightness_control.handle.width)
										+ brightness_control.handle.width / 2
									height: parent.height
									radius: 5
									color: volumeAndBrightnessHighlighted
								}
							}

							handle: Item {
								x: brightness_control.leftPadding
									+ brightness_control.visualPosition * (brightness_control.availableWidth - width)
								y: brightness_control.topPadding + brightness_control.availableHeight / 2 - height / 2
								implicitWidth: 15
								implicitHeight: 15

								Rectangle {
									anchors.centerIn: parent
									width: parent.width
									height: parent.height
									radius: 5
									color: brightness_control.pressed ? volumeAndBrightnessKnobDown : volumeAndBrightnessSliderKnob
									border.width: 0

									Behavior on scale {
										NumberAnimation {
											duration: 100
											easing.type: Easing.OutCubic
										}
									}
									scale: brightness_control.pressed ? 1.2 : 1.0
								}
							}

							onMoved: {
								brightness_change_value.value = value
								brightness_change_value.running = true
							}
						}
					}

					Rectangle {
						id: volume_rect
						anchors.left: parent.left
						anchors.right: parent.right
						height: 100

						color: volumeAndBrightnessSection
						radius: 8

						Item {
							id: audio_device_selector_container

							anchors.left: parent.left
							anchors.right: parent.right
							anchors.top: parent.top
							height: 60

							// This is the area for the device selector
							ComboBox {
								id: audio_device_selector
								anchors.fill: parent
								anchors.margins: 15

								property var sinkNodes: {
									let values = Pipewire.nodes.values
									if (!values) return []
									let _len = values.length  // track for reactivity
									return values.filter(n => n.isSink && !n.isStream)
								}

								model: sinkNodes.map(n => n.nickname || n.description || n.name)

								// Keep the displayed selection in sync with the actual default sink
								currentIndex: {
									let current = Pipewire.defaultSink
									if (!current) return 0
									return sinkNodes.findIndex(n => n.id === current.id)
								}

								onActivated: {
									if (currentIndex >= 0 && currentIndex < sinkNodes.length) {
										Pipewire.preferredDefaultAudioSink = sinkNodes[currentIndex]
										console.log(currentIndex)
									}
								}

								background: Rectangle {
									color: volumeAndBrightnessDropdownBg
									radius: 5
									border.width: 0
								}

								contentItem: Text {
									color: volumeAndBrightnessTextColor
									font.family: fontFamily
									text: audio_device_selector.displayText
									anchors.fill: parent

									verticalAlignment: Text.AlignVCenter
									anchors.margins: 10
								}

								indicator: Text {
									anchors.fill: parent
									anchors.margins: 10
									text: "󰅀"
									color: volumeAndBrightnessTextColor

									verticalAlignment: Text.AlignVCenter
									horizontalAlignment: Text.AlignRight
								}

								delegate: ItemDelegate {
									width: audio_device_selector.width
									contentItem: Text {
										text: modelData
										color: volumeAndBrightnessTextColor
										font.family: fontFamily
										verticalAlignment: Text.AlignVCenter
									}
									background: Rectangle {
										color: hovered ? volumeAndBrightnessHighlighted : volumeAndBrightnessDropdownBg
										radius: 5

										Behavior on color {
											ColorAnimation {
												duration: 150
												easing.type: Easing.OutQuad
											}
										}
									}
								}

								popup: Popup {
									y: audio_device_selector.height + 4
									width: audio_device_selector.width
									padding: 4

									background: Rectangle {
										color: volumeAndBrightnessDropdownBg
										radius: 8
									}

									contentItem: ListView {
										implicitHeight: contentHeight
										model: audio_device_selector.popup.visible ? audio_device_selector.delegateModel : null
										clip: true
									}

									// Entrance animation
									enter: Transition {
										ParallelAnimation {
											NumberAnimation {
												property: "opacity"
												from: 0.0
												to: 1.0
												duration: 200
											}
											NumberAnimation {
												property: "y"
												from: -30
												to: 0
												duration: 200
												easing.type: Easing.OutQuad
											}
										}
									}

									// Exit animation
									exit: Transition {
										ParallelAnimation {
											NumberAnimation {
												property: "opacity"
												from: 1.0
												to: 0.0
												duration: 150
											}
											NumberAnimation {
												property: "y"
												from: 0
												to: 30
												duration: 150
												easing.type: Easing.InQuad
											}
										}
									}
								}
							}
						}

						Item {
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.bottom: parent.bottom
							anchors.top: audio_device_selector_container.bottom

							Text {
								id: volume_rect_icon
								anchors.top: parent.top
								anchors.left: parent.left
								anchors.bottom: parent.bottom
								anchors.leftMargin: 15
								text: sink.audio.muted ? "󰝟" : "󰕾"

								onTextChanged: {
									volume_and_brightness_popup.openCountdown = 2
								}

								color: volumeAndBrightnessIconColor
								verticalAlignment: Text.AlignVCenter

								MouseArea {
									anchors.fill: parent

									onClicked: {
										sink.audio.muted = !sink.audio.muted
									}
								}
							}

							Text {
								id: volume_rect_details
								anchors.top: parent.top
								anchors.right: parent.right
								anchors.bottom: parent.bottom
								anchors.rightMargin: 15
								text: currentVolValue
								width: 35
								horizontalAlignment: Text.AlignRight

								font.family: fontFamily
								color: sink.audio.muted ? volumeAndBrightnessTextDown : volumeAndBrightnessTextColor
								verticalAlignment: Text.AlignVCenter
							}

							Slider {
								id: volume_control

								from: 1
								value: currentVolValue
								to: 100

								onValueChanged: {
									volume_and_brightness_popup.openCountdown = 2
								}

								Behavior on value {
									enabled: !volume_control.pressed
									NumberAnimation {
										id: volume_slider_animation
										duration: 150
										easing.type: Easing.OutCubic
									}
								}

								anchors.top: parent.top
								anchors.bottom: parent.bottom
								anchors.left: volume_rect_icon.right
								anchors.right: volume_rect_details.left
								anchors.leftMargin: 15
								anchors.rightMargin: 15

								background: Rectangle {
									// This is gonna be the track?
									x: volume_control.leftPadding
									y: volume_control.topPadding + volume_control.availableHeight / 2 - height / 2
									// implicitWidth: 100
									implicitHeight: 4

									radius: 5

									// Yeah doing all this just to make the width and height be correct
									width: volume_control.availableWidth
									height: implicitHeight

									color: volumeAndBrightnessSliderBg

									Rectangle {
										// Subtract half the handle width on each side
										width: volume_control.visualPosition * (parent.width - volume_control.handle.width)
											+ volume_control.handle.width / 2
										height: parent.height
										radius: 5
										color: volumeAndBrightnessHighlighted
									}
								}

								handle: Item {
									x: volume_control.leftPadding
										+ volume_control.visualPosition * (volume_control.availableWidth - width)
									y: volume_control.topPadding + volume_control.availableHeight / 2 - height / 2
									implicitWidth: 15
									implicitHeight: 15

									Rectangle {
										anchors.centerIn: parent
										width: parent.width
										height: parent.height
										radius: 5
										color: volume_control.pressed ? volumeAndBrightnessKnobDown : volumeAndBrightnessSliderKnob
										border.width: 0

										Behavior on scale {
											NumberAnimation {
												duration: 100
												easing.type: Easing.OutCubic
											}
										}
										scale: volume_control.pressed ? 1.2 : 1.0
									}
								}

								onMoved: {
									sink.audio.volume = value / 100
								}
							}
						}
					}
				}
			}

			HoverHandler {
				onHoveredChanged: {
					volume_and_brightness_popup.shownForced = hovered
					if (!hovered) {
						volume_and_brightness_popup.openCountdown = 0
					}
				}
			}
		}

		// Dedicated pop up for media
		PopupWindow {
			id: media_popup

			property var shown: false
			property var popupWidth: 400 // Well this is kinda a half assed approach, but what can I do anyways?

			anchor.item: media_rect_container
			implicitWidth: popupWidth + 10 // +10 for animation
			implicitHeight: media_details_rect.height + 20

			// property var offsetX: (shown ? panel.width + 10 : 0)
			anchor.rect.x: panel.width // I don't fucking know...
			anchor.rect.y: (media_rect_container.height / 2) - (height / 2) // Shadows buffer zone

			visible: (media_details_rect.opacity > 0)

			color: "transparent"

			Rectangle {
				id: media_details_rect
				anchors.top: parent.top
				// anchors.bottom: parent.bottom
				// height:childrenRect.height
				height: media_details_col.height + 30

				width: media_popup.popupWidth
				x: (media_popup.shown ? 10 : 0)

				opacity: (media_popup.shown ? 1 : 0)

				Behavior on opacity {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				Behavior on x {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				color: mediaButtonsDefaultBackground
				radius: 10

				Behavior on color {
					ColorAnimation {
						duration: 200
					}
				}

				// Player: media_buttons_container.player
				// layer.enabled: true
				// layer.effect: OpacityMask {
				// 	maskSource: Rectangle {
				// 		width: media_dynamic_bg_v2.width
				// 		height: media_dynamic_bg_v2.height
				// 		radius: media_details_rect.radius
				// 	}
				// }

				Image {
					id: media_dynamic_bg_v2
					visible: media_buttons_container.player != null
					anchors.fill: parent

					source: media_buttons_container.player ? media_buttons_container.player.trackArtUrl : ""
					fillMode: Image.PreserveAspectCrop;

					cache: true
					asynchronous: true
				}

				MultiEffect {
					anchors.fill: media_dynamic_bg_v2
					source: media_dynamic_bg_v2

					autoPaddingEnabled: false

					brightness: 0.4
					saturation: 0
					blurEnabled: true
					blurMax: 256
					blur: 0.5
				}

				Column {
					id: media_details_col

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.margins: 15

					spacing: 10
					// The column here is gonna house the metadata row and the controls row
					Item {
						// The metadata row
						anchors.left: parent.left
						anchors.right: parent.right
						height: childrenRect.height

						Rectangle {
							id: media_cover_art_container
							height: 80
							width: media_cover_art.visible ? 80 : 1
							anchors.left: parent.left
							anchors.top: parent.top

							opacity: media_details_rect.opacity
							radius: 8
							clip: true
							color: "transparent"

							// I fucking hate layers
							// layer.enabled: true
							// layer.effect: OpacityMask {
							// 	maskSource: Rectangle {
							// 		width: media_cover_art_container.width
							// 		height: media_cover_art_container.height
							// 		radius: 8
							// 	}
							// }

							Image {
								anchors.fill: parent
								opacity: parent.opacity

								// Ngl I kinda fw this
								smooth: true      // Enables bilinear filtering (enabled by default)
								mipmap: true      // Smooths downscaling by generating a mipmap chain
								antialiasing: true
								fillMode: Image.PreserveAspectCrop;

								id: media_cover_art
								source: media_buttons_container.player.trackArtUrl
								visible: source != null && source != ""
							}
						}

						Item {
							id: media_metadata_labels

							// anchors.fill: parent
							anchors.left: media_cover_art_container.right
							anchors.leftMargin: media_cover_art.visible ? 15 : 0
							anchors.right: parent.right
							anchors.top: parent.top
							height: 80

							anchors.verticalCenter: parent.verticalCenter
							Column {
								anchors.verticalCenter: parent.verticalCenter
								anchors.left: parent.left
								anchors.right: parent.right
								spacing: 2

								Text {
									id: media_metadata_title

									anchors.left: parent.left
									anchors.right: parent.right

									horizontalAlignment: Text.AlignLeft

									text: media_buttons_container.player.trackTitle ? media_buttons_container.player.trackTitle : "Unknown"
									// text: "I'm cringe, but that's based. I'll never be based and that's not cringe."
									color: mediaButtonColor
									font.family: fontFamily
									font.bold: true
									font.pixelSize: 22

									elide: Text.ElideRight
								}

								Text {
									id: media_metadata_artist

									anchors.left: parent.left
									anchors.right: parent.right
									// anchors.topMargin: 3

									text: media_buttons_container.player.trackArtist ? media_buttons_container.player.trackArtist : "Unknown"
									font.family: fontFamily
									font.pixelSize: 12

									elide: Text.ElideRight
								}

								Text {
									id: media_metadata_album

									anchors.left: parent.left
									anchors.right: parent.right

									text: media_buttons_container.player.trackAlbum ? media_buttons_container.player.trackAlbum : "Unknown"
									font.family: fontFamily
									font.pixelSize: 12
									font.italic: true

									elide: Text.ElideRight
								}
							}
						}
					}

					Item {
						id: media_controls
						// The controls row (?)
						anchors.left: parent.left
						anchors.right: parent.right

						height: childrenRect.height

						function convertSecondsToTime(totalSeconds) {
							// Ensure we deal with integers
							const totalSecs = Math.floor(totalSeconds);

							// Calculate minutes and remaining seconds
							const minutes = Math.floor(totalSecs / 60);
							const seconds = totalSecs % 60;

							// Pad both numbers to ensure they are always 2 digits
							const paddedMinutes = String(minutes).padStart(2, '0');
							const paddedSeconds = String(seconds).padStart(2, '0');

							return `${paddedMinutes}:${paddedSeconds}`;
						}

						// Refresh the position of the player
						// It's quite shit, and honestly, there should be better ways than this, but beggers cant be choosers
						Timer {
							// Optimization
							running: media_buttons_container.player.playbackState == MprisPlaybackState.Playing && media_popup.shown

							interval: 1000
							repeat: true

							// emit the positionChanged signal every second to update pos
							triggeredOnStart: true
							onTriggered: media_buttons_container.player.positionChanged()
						}

						// Seeker
						Text {
							id: media_current_time

							text: media_controls.convertSecondsToTime(media_buttons_container.player.position)
							font.family: fontFamily
							font.pixelSize: 12

							anchors.left: parent.left
						}

						Text {
							id: media_length

							text: media_controls.convertSecondsToTime(media_buttons_container.player.length)
							font.family: fontFamily
							font.pixelSize: 12

							anchors.right: parent.right
						}

						Slider {
							id: media_seek_control

							anchors.left: media_current_time.right
							anchors.right: media_length.left
							anchors.leftMargin: 10
							anchors.rightMargin: 10

							from: 0
							to: media_buttons_container.player.length
							value: media_buttons_container.player.position

							background: Rectangle {
								// This is gonna be the track?
								x: media_seek_control.leftPadding
								y: media_seek_control.topPadding + media_seek_control.availableHeight / 2 - height / 2
								// implicitWidth: 100
								implicitHeight: 4

								radius: 5

								// Yeah doing all this just to make the width and height be correct
								width: media_seek_control.availableWidth
								height: implicitHeight

								color: Qt.rgba(
									parseInt(mediaSeekerBackground.slice(1,3), 16) / 255,
									parseInt(mediaSeekerBackground.slice(3,5), 16) / 255,
									parseInt(mediaSeekerBackground.slice(5,7), 16) / 255,
									mediaSeekerBackgroundOpacity
								)
								// opacity: mediaSeekerBackgroundOpacity

								border.width: 0

								Rectangle {
									// Subtract half the handle width on each side
									width: media_seek_control.visualPosition * (parent.width - media_seek_control.handle.width)
										+ media_seek_control.handle.width / 2
									height: parent.height
									radius: 5
									color: mediaSeekerHighlighted
									opacity: 1
								}
							}

							handle: Item {
								x: media_seek_control.leftPadding
									+ media_seek_control.visualPosition * (media_seek_control.availableWidth - width)
								y: media_seek_control.topPadding + media_seek_control.availableHeight / 2 - height / 2
								implicitWidth: 15
								implicitHeight: 15

								Rectangle {
									anchors.centerIn: parent
									width: parent.width
									height: parent.height
									radius: 5
									color: media_seek_control.pressed ? mediaSeekerButtonDown : mediaSeekerButton
									border.width: 0

									Behavior on scale {
										NumberAnimation {
											duration: 100
											easing.type: Easing.OutCubic
										}
									}
									scale: media_seek_control.pressed ? 1.2 : 1.0
								}
							}

							// Track the last valid value internally
							onPressedChanged: {
								if (!pressed && media_buttons_container.player.canSeek) {
									media_buttons_container.player.position = value
								}
							}
						}
					}

					Row {
						// anchors.top: media_seek_control.bottom
						height: childrenRect.height

						spacing: 15

						anchors.horizontalCenter: parent.horizontalCenter

						Text {
							text: {
								if (media_buttons_container.player.loopState == MprisLoopState.Playlist) return "󰑖"
								else if (media_buttons_container.player.loopState == MprisLoopState.Track) return "󰑘"
								else return "󰑗"
							} // 󰑖 / 󰑗 / 󰑘
							font.pixelSize: 24
							width: 30
							horizontalAlignment: Text.AlignHCenter

							opacity: media_buttons_container.player.loopSupported ? mediaButtonEnabledOpacity : mediaButtonDisabledOpacity

							scale: 1
							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								anchors.fill: parent

								onClicked: {
									// media_buttons_container.player.loopState = MprisLoopState
									if (media_buttons_container.player.loopState == MprisLoopState.None) {
										// Alright
										media_buttons_container.player.loopState = MprisLoopState.Playlist
									} else if (media_buttons_container.player.loopState == MprisLoopState.Playlist) {
										media_buttons_container.player.loopState = MprisLoopState.Track
									} else {
										media_buttons_container.player.loopState = MprisLoopState.None
									}
								}

								onPressed: {
									parent.scale = 0.75
								}

								onReleased: {
									parent.scale = 1
								}
							}
						}

						Text {
							text: "󰒮"
							font.pixelSize: 24
							width: 30
							horizontalAlignment: Text.AlignHCenter

							opacity: media_buttons_container.player.canGoPrevious ? mediaButtonEnabledOpacity : mediaButtonDisabledOpacity

							scale: 1
							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								anchors.fill: parent

								onClicked: {
									media_buttons_container.player.previous()
								}

								onPressed: {
									parent.scale = 0.75
								}

								onReleased: {
									parent.scale = 1
								}
							}
						}

						Text {
							text: media_buttons_container.player.isPlaying ? "󰏤" : "󰐊"
							font.pixelSize: 24
							width: 30
							horizontalAlignment: Text.AlignHCenter

							opacity: media_buttons_container.player.canTogglePlaying ? mediaButtonEnabledOpacity : mediaButtonDisabledOpacity

							scale: 1
							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								anchors.fill: parent

								onClicked: {
									media_buttons_container.player.togglePlaying()
								}

								onPressed: {
									parent.scale = 0.75
								}

								onReleased: {
									parent.scale = 1
								}
							}
						}

						Text {
							text: "󰒭"
							font.pixelSize: 24
							width: 30
							horizontalAlignment: Text.AlignHCenter

							opacity: media_buttons_container.player.canGoNext ? mediaButtonEnabledOpacity : mediaButtonDisabledOpacity

							scale: 1
							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								anchors.fill: parent

								onClicked: {
									media_buttons_container.player.next()
								}

								onPressed: {
									parent.scale = 0.75
								}

								onReleased: {
									parent.scale = 1
								}
							}
						}

						Text {
							text: media_buttons_container.player.shuffle ? "󰒝" : "󰒞"
							font.pixelSize: 24
							width: 30
							horizontalAlignment: Text.AlignHCenter

							opacity: media_buttons_container.player.shuffleSupported ? mediaButtonEnabledOpacity : mediaButtonDisabledOpacity

							scale: 1
							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								anchors.fill: parent

								onClicked: {
									media_buttons_container.player.shuffle = !media_buttons_container.player.shuffle
								}

								onPressed: {
									parent.scale = 0.75
								}

								onReleased: {
									parent.scale = 1
								}
							}
						}
					}
				}
			}

			HoverHandler {
				onHoveredChanged: {
					media_popup.shown = hovered
				}
			}
		}

		PopupWindow {
			id: statistics_popup

			property var shown: false
			property var popupWidth: 500 // Well this is kinda a half assed approach, but what can I do anyways?

			// OPTIMIZATION
			onShownChanged: {
				if (shown) {
					cpu_mon.running = true
					ram_mon.running = true
					disk_mon.running = true
					notif_mon.running = true
				} else {
					power_off_button.confirming = false
					reboot_button.confirming = false
					logout_button.confirming = false
				}
			}

			anchor.item: arch_logo
			implicitWidth: popupWidth + 10 // +10 for animation
			implicitHeight: statistics_details_rect.height + 20 // 10 on each side (up and down)

			// property var offsetX: (shown ? panel.width + 10 : 0)
			anchor.rect.x: panel.width
			anchor.rect.y: 10 // Shadows buffer zone

			visible: (statistics_details_rect.opacity > 0)

			color: "transparent"

			Rectangle {
				id: statistics_details_rect
				anchors.top: parent.top
				// anchors.bottom: parent.bottom
				// height:childrenRect.height
				height: childrenRect.height + 40 // margins 15, top and bottom

				width: statistics_popup.popupWidth
				x: (statistics_popup.shown ? 10 : 0)

				opacity: (statistics_popup.shown ? 1 : 0)

				Behavior on opacity {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				Behavior on x {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutCubic
					}
				}

				color: panelBackground
				radius: 10

				Behavior on color {
					ColorAnimation {
						duration: 200
					}
				}

				// Yeah for freedom's sake I'm not using column or row this time around for the BIG CONTAINER
				// Yes the BIG ASS CONTAINER
				// FREEDOM
				//
				Item {
					opacity: parent.opacity

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.margins: 15

					height: childrenRect.height

					Row {
						opacity: parent.opacity
						id: statistics_names
						anchors.top: parent.top
						anchors.left: parent.left

						Text {
							opacity: parent.opacity
							text: username
							font.family: fontFamily
							// font.bold: true
							font.weight: 750
							color: statisticsHighlightedTextColor

							font.pixelSize: 14
						}

						Text {
							opacity: parent.opacity
							text: "@"
							font.family: fontFamily
							color: statisticsDimmedTextColor

							font.pixelSize: 14
						}

						Text {
							opacity: parent.opacity
							text: hostname
							font.family: fontFamily
							color: statisticsTextColor

							font.pixelSize: 14
						}
					}

					Text {
						opacity: parent.opacity
						id: statistics_names_right_side
						anchors.top: parent.top
						anchors.right: parent.right

						property var quotes: [
							"I use arch btw",
							"I love you <3",
							"AUR FUCKING SUCKS",
							"Quickshell is wonderful",
							"sudo pacman -S arch_btw",
							"fastfetch!! QUICK!!",
							"R.I.P neofetch",
							"Wrote from the ground up hehe",
						]

						function getRandomQuote() {
							// Math.random() gives a number between 0 (inclusive) and 1 (exclusive)
							var randomIndex = Math.floor(Math.random() * quotes.length);
							return quotes[randomIndex];
						}

						text: getRandomQuote()
						font.family: fontFamily
						color: statisticsDimmedTextColor
					}

					Rectangle {
						opacity: parent.opacity
						id: cpu_mon_container

						anchors.top: statistics_names.bottom
						anchors.left: parent.left
						anchors.topMargin: 15
						anchors.leftMargin: 10

						width: 250
						height: 250

						color: statisticsDetailsBackground
						radius: 10

						Canvas {
							opacity: parent.opacity
							id: cpu_mon_drawn
							anchors.fill: parent
							anchors.margins: 15

							property real cpuUsageUsable: cpuUsage / 100

							Behavior on cpuUsageUsable {
								NumberAnimation {
									duration: 200
									easing.type: Easing.OutCubic
								}
							}

							onCpuUsageUsableChanged: requestPaint()

							onPaint: {
								var ctx = getContext("2d");
								ctx.reset();

								var centerX = width / 2;
								var centerY = height / 2;
								var radius = Math.min(width, height) / 2 - 10;
								var lineWidth = statisticsChartLineWidth;

								var startAngle = -Math.PI / 2; // 12 o'clock
								var fullCircle = 2 * Math.PI;

								// Background track
								ctx.beginPath();
								ctx.arc(centerX, centerY, radius, 0, fullCircle);
								ctx.lineWidth = lineWidth;
								ctx.lineCap = "round";
								ctx.strokeStyle = statisticsChartBackground;
								ctx.stroke();

								// Usage arc
								ctx.beginPath();
								ctx.arc(centerX, centerY, radius, startAngle, startAngle + fullCircle * cpuUsageUsable);
								ctx.lineWidth = lineWidth;
								ctx.lineCap = "round";
								ctx.strokeStyle = cpuUsageUsable > 0.8 ? statisticsChartCritical : statisticsChartHighlighted;
								ctx.stroke();
							}

							Column {
								anchors.centerIn: parent
								width: 200
								height: childrenRect.height

								Text {
									anchors.left: parent.left
									anchors.right: parent.right

									color: statisticsTextColor
									font.bold: true
									font.pixelSize: 24

									text: cpuUsage + "%"
									font.family: fontFamily

									horizontalAlignment: Text.AlignHCenter
								}

								Text {
									anchors.left: parent.left
									anchors.right: parent.right

									color: statisticsTextColor
									// font.bold: true
									font.pixelSize: 16

									text: " CPU"
									font.family: fontFamily

									horizontalAlignment: Text.AlignHCenter
								}
							}
						}
					}

					Rectangle {
						opacity: parent.opacity
						id: ram_mon_container

						anchors.top: statistics_names.bottom
						anchors.left: cpu_mon_container.right
						anchors.right: parent.right
						anchors.topMargin: 15
						anchors.leftMargin: 10
						anchors.rightMargin: 10

						height: width
						color: statisticsDetailsBackground
						radius: 10

						Canvas {
							opacity: parent.opacity
							id: ram_mon_drawn
							anchors.fill: parent
							anchors.margins: 15

							// height: width

							property real ramUsageUsable: ramUsage / 100

							Behavior on ramUsageUsable {
								NumberAnimation {
									duration: 200
									easing.type: Easing.OutCubic
								}
							}

							onRamUsageUsableChanged: requestPaint()

							onPaint: {
								var ctx = getContext("2d");
								ctx.reset();

								var centerX = width / 2;
								var centerY = height / 2;
								var radius = Math.min(width, height) / 2 - 10;
								var lineWidth = statisticsChartLineWidth;

								var startAngle = -Math.PI / 2; // 12 o'clock
								var fullCircle = 2 * Math.PI;

								// Background track
								ctx.beginPath();
								ctx.arc(centerX, centerY, radius, 0, fullCircle);
								ctx.lineWidth = lineWidth;
								ctx.lineCap = "round";
								ctx.strokeStyle = statisticsChartBackground;
								ctx.stroke();

								// Usage arc
								ctx.beginPath();
								ctx.arc(centerX, centerY, radius, startAngle, startAngle + fullCircle * ramUsageUsable);
								ctx.lineWidth = lineWidth;
								ctx.lineCap = "round";
								ctx.strokeStyle = ramUsageUsable > 0.8 ? statisticsChartCritical : statisticsChartHighlighted;
								ctx.stroke();
							}

							Column {
								anchors.centerIn: parent
								width: 100
								height: childrenRect.height

								Text {
									anchors.left: parent.left
									anchors.right: parent.right

									color: statisticsTextColor
									font.bold: true
									font.pixelSize: 18

									text: ramUsage + "%"
									font.family: fontFamily

									horizontalAlignment: Text.AlignHCenter
								}

								Text {
									anchors.left: parent.left
									anchors.right: parent.right

									color: statisticsTextColor
									// font.bold: true
									font.pixelSize: 14

									text: " MEM"
									font.family: fontFamily

									horizontalAlignment: Text.AlignHCenter
								}
							}
						}
					}

					Rectangle {
						opacity: parent.opacity
						id: disk_mon_container

						anchors.top: ram_mon_container.bottom
						anchors.left: cpu_mon_container.right
						anchors.bottom: cpu_mon_container.bottom
						anchors.right: parent.right
						anchors.topMargin: 10
						anchors.leftMargin: 10
						anchors.rightMargin: 10

						color: statisticsDetailsBackground

						radius: 10

						Rectangle {
							opacity: parent.opacity
							id: disk_mon_bg
							anchors.fill: parent
							anchors.margins: 15

							radius: 5

							color: statisticsChartBackground
						}

						Rectangle {
							opacity: parent.opacity
							id: disk_mon_highlight
							anchors.left: parent.left
							anchors.top: parent.top
							anchors.bottom: parent.bottom

							anchors.margins: 15

							// THIS THING DOESNT NEED AN ANIMATION
							// NO IT DONT NEED THAT KIND OF SHIT
							width: (diskUsedBytesCount / diskTotalBytesCount) * disk_mon_bg.width
							radius: 5

							color: statisticsChartHighlighted
						}

						Text {
							opacity: parent.opacity
							id: disk_mon_icon
							anchors.left: parent.left
							anchors.top: parent.top
							anchors.bottom: parent.bottom
							anchors.leftMargin: 20

							verticalAlignment: Text.AlignVCenter

							text: "/: " + formatBytes(diskUsedBytesCount, 1) + "/" + formatBytes(diskTotalBytesCount, 1)
							font.family: fontFamily
							font.pixelSize: 11
							color: statisticsTextColor
						}
					}

					Rectangle {
						opacity: parent.opacity
						id: net_mon_container

						anchors.top: cpu_mon_container.bottom
						anchors.left: parent.left
						anchors.right: parent.right

						anchors.margins: 10

						// height: 100
						height: net_graph.height + net_info_label.height + 15 + 15 + 15

						color: statisticsDetailsBackground
						radius: 10

						Canvas {
							opacity: parent.opacity
							id: net_graph
							// width: 200  // set as needed
							// height: 60  // set as needed, treated as fixed
							// anchors.fill: parent
							anchors.top: parent.top
							anchors.left: parent.left
							anchors.right: parent.right
							height: 100
							anchors.topMargin: 15
							anchors.leftMargin: 15
							anchors.rightMargin: 15

							// Bind to your data source
							property real downBytes: netDownBytes
							property real upBytes: netUpBytes

							property color downColor: statisticsChartHighlighted
							property color upColor:   statisticsChartHighlighted2

							readonly property int pointCount: statisticsNetPoints
							property var downHistory: new Array(statisticsNetPoints).fill(0)
							property var upHistory:   new Array(statisticsNetPoints).fill(0)

							// ADD THIS TIMER instead:
							Timer {
								interval: 1000 // Update once per second (or match your backend source)
								running: true
								repeat: true
								onTriggered: {
									// Process Down data safely
									let validDown = (!isNaN(net_graph.downBytes) && net_graph.downBytes !== undefined) ? net_graph.downBytes : 0;
									net_graph.downHistory = net_graph.downHistory.slice(1).concat([validDown]);

									// Process Up data safely right alongside it
									let validUp = (!isNaN(net_graph.upBytes) && net_graph.upBytes !== undefined) ? net_graph.upBytes : 0;
									net_graph.upHistory = net_graph.upHistory.slice(1).concat([validUp]);

									// Force a single clean redraw of both lines simultaneously
									net_graph.requestPaint();
								}
							}

							onPaint: {
								var ctx = getContext("2d")
								ctx.clearRect(0, 0, width, height)

								var maxVal = 1
								for (var i = 0; i < pointCount; i++) {
									if (downHistory[i] > maxVal) maxVal = downHistory[i]
									if (upHistory[i] > maxVal) maxVal = upHistory[i]
								}

								var stepX = width / (pointCount - 1)
								// ctx.lineWidth = statisticsLineChartLineWidth
								ctx.lineJoin = "round"
								ctx.lineCap = "round"

								function drawBackground(color) {
									ctx.strokeStyle = color
									for (var j = 0; j < pointCount; j++) {
										var x = j * stepX

										ctx.beginPath()
										ctx.lineWidth = statisticsLineChartBgLineWidth
										ctx.moveTo(x, 0)
										ctx.lineTo(x, height)

										ctx.stroke()
									}
								}

								function drawLine(history, color) {
									ctx.beginPath()
									ctx.strokeStyle = color
									ctx.lineWidth = statisticsLineChartLineWidth
									for (var j = 0; j < pointCount; j++) {
										var x = j * stepX
										var y = height - (((Number.isNaN(history[j]) || history[j] === undefined) ? 0 : history[j]) / maxVal) * height

										if (j === 0) ctx.moveTo(x, y)
										else ctx.lineTo(x, y)
									}
									ctx.stroke()

									// Draw the circles on top yeah?
									ctx.fillStyle = color
									for (var j = 0; j < pointCount; j++) {
										var x = j * stepX
										var y = height - (((Number.isNaN(history[j]) || history[j] === undefined) ? 0 : history[j]) / maxVal) * height

										ctx.beginPath()
										// Draw a circle to mark the point
										var radius = statisticsLineChartPointRadius // pixels
										ctx.arc(x, y, radius, 0, 2 * Math.PI)
										ctx.fill()
									}
									// ctx.stroke()
								}

								drawBackground(statisticsLineChartBackground)
								drawLine(upHistory, upColor)
								drawLine(downHistory, downColor)
							}
						}

						Text {
							opacity: parent.opacity
							id: net_info_label
							anchors.top: net_graph.bottom
							anchors.left: net_mon_container.left
							anchors.right: net_mon_container.right
							anchors.leftMargin: 15
							anchors.rightMargin: 15
							anchors.topMargin: 15

							text: " " + formatBytes(netUpBytes) + "/s    " + formatBytes(netDownBytes) + "/s"
							font.family: fontFamily
							color: statisticsTextColor
						}
					}

					// Power buttons row
					Row {
						id: power_buttons_row

						opacity: parent.opacity
						anchors.top: net_mon_container.bottom
						anchors.left: parent.left

						anchors.margins: 10

						height: childrenRect.height
						width: childrenRect.width

						spacing: 10

						Rectangle {
							opacity: parent.opacity
							id: power_off_button

							property bool confirming: false

							onConfirmingChanged: {
								if (confirming) power_off_confirming_timer.running = true
							}

							Timer {
								id: power_off_confirming_timer
								running: false
								interval: statisticsButtonHoldTime * 1000
								triggeredOnStart: false
								repeat: false

								onTriggered: {
									power_off_button.confirming = false
								}
							}

							width: 50
							height: 50

							color: confirming ? statisticsButtonHoldPower : (power_button_area.pressed ? statisticsButtonPressedDefBg : statisticsButtonBackground)
							radius: 10
							scale: power_button_area.pressed ? 0.75 : 1

							Text {
								id: power_off_icon
								anchors.centerIn: parent
								color: statisticsTextColor
								// font.family: fontFamily

								text: "󰐥"
								font.bold: true
								font.pixelSize: 18
							}

							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							Behavior on color {
								ColorAnimation {
									duration: 100
								}
							}

							Behavior on width {
								NumberAnimation {
									duration: 200
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								id: power_button_area
								anchors.fill: parent

								onClicked: {
									if (!power_off_button.confirming) {
										power_off_button.confirming = true
									} else {
										// Run command
										power_off_button.color = statisticsButtonBackground
										power_off_icon.text = ""
										power_off_proc.running = true
									}
								}
							}
						}

						Rectangle {
							opacity: parent.opacity
							id: reboot_button

							property bool confirming: false

							onConfirmingChanged: {
								if (confirming) reboot_confirming_timer.running = true
							}

							Timer {
								id: reboot_confirming_timer
								running: false
								interval: statisticsButtonHoldTime * 1000
								triggeredOnStart: false
								repeat: false

								onTriggered: {
									reboot_button.confirming = false
								}
							}

							width: 50
							height: 50

							color: confirming ? statisticsButtonHoldReboot : (reboot_button_area.pressed ? statisticsButtonPressedDefBg : statisticsButtonBackground)
							radius: 10
							scale: reboot_button_area.pressed ? 0.75 : 1

							Text {
								id: reboot_icon
								anchors.centerIn: parent
								color: statisticsTextColor
								// font.family: fontFamily

								text: "󰜉"
								font.bold: true
								font.pixelSize: 18
							}

							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							Behavior on color {
								ColorAnimation {
									duration: 100
								}
							}

							Behavior on width {
								NumberAnimation {
									duration: 200
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								id: reboot_button_area
								anchors.fill: parent

								onClicked: {
									if (!reboot_button.confirming) {
										reboot_button.confirming = true
									} else {
										// Run command
										reboot_button.color = statisticsButtonBackground
										reboot_icon.text = ""
										reboot_proc.running = true
									}
								}
							}
						}

						Rectangle {
							opacity: parent.opacity
							id: logout_button

							property bool confirming: false

							onConfirmingChanged: {
								if (confirming) logout_confirming_timer.running = true
							}

							Timer {
								id: logout_confirming_timer
								running: false
								interval: statisticsButtonHoldTime * 1000
								triggeredOnStart: false
								repeat: false

								onTriggered: {
									logout_button.confirming = false
								}
							}

							width: 50
							height: 50

							color: confirming ? statisticsButtonHoldLogOut : (logout_button_area.pressed ? statisticsButtonPressedDefBg : statisticsButtonBackground)
							radius: 10
							scale: logout_button_area.pressed ? 0.75 : 1

							Text {
								id: logout_icon
								anchors.centerIn: parent
								color: statisticsTextColor
								// font.family: fontFamily

								text: "󰗽"
								font.bold: true
								font.pixelSize: 18
							}

							Behavior on scale {
								NumberAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							Behavior on color {
								ColorAnimation {
									duration: 100
								}
							}

							Behavior on width {
								NumberAnimation {
									duration: 200
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								id: logout_button_area
								anchors.fill: parent

								onClicked: {
									if (!logout_button.confirming) {
										logout_button.confirming = true
									} else {
										// Run command
										logout_button.color = statisticsButtonBackground
										logout_icon.text = "󰆢"
										logout_proc.running = true
									}
								}
							}
						}
					}

					// Notifications area
					Rectangle {
						id: notifications_area

						anchors.top: net_mon_container.bottom
						anchors.left: power_buttons_row.right
						anchors.right: parent.right

						anchors.margins: 10

						radius: 10
						color: statisticsDetailsBackground

						height: 300

						Text {
							id: notif_label
							text: "Notifications"
							font.pixelSize: 16
							font.family: fontFamily
							font.bold: true
							color: statisticsTextColor

							anchors.left: parent.left
							anchors.top: parent.top
							anchors.leftMargin: 15
							anchors.topMargin: 15
						}

						Text {
							id: clear_button
							text: "clear all"
							font.family: fontFamily
							color: clear_button_mousearea.containsMouse ? statisticsTextColor : statisticsDimmedTextColor
							font.pixelSize: 14

							anchors.right: parent.right
							anchors.top: parent.top
							anchors.rightMargin: 15
							anchors.topMargin: 15

							Behavior on color {
								ColorAnimation {
									duration: 100
									easing.type: Easing.OutCubic
								}
							}

							MouseArea {
								id: clear_button_mousearea
								anchors.fill: parent
								hoverEnabled: true

								onClicked: {
									notif_clear_proc.running = true
								}
							}
						}

						Column {
							anchors.top: clear_button.bottom
							anchors.topMargin: 20
							anchors.left: parent.left
							anchors.right: parent.right

							spacing: 20

							visible: notificationsHistory.length == 0

							Text {
								anchors.left: parent.left
								anchors.right: parent.right

								horizontalAlignment: Text.AlignHCenter

								text: "No notification history"
								color: statisticsDimmedTextColor
								font.family: fontFamily
								font.italic: true
								font.pixelSize: 14
							}

							Text {
								anchors.left: parent.left
								anchors.right: parent.right

								horizontalAlignment: Text.AlignHCenter

								text: "¯\\_(ツ)_/¯"
								color: statisticsDimmedTextColor
								font.family: fontFamily
								// font.italic: true
								font.pixelSize: 30
							}
						}

						ScrollView {
							id: notif_scrollview
							anchors.top: clear_button.bottom
							anchors.topMargin: 10
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.bottom: parent.bottom

							// contentHeight: myColumn.height
   							// contentWidth: width

							// Prevent ScrollView from also creating a horizontal bar
							ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

							ScrollBar.vertical: ScrollBar {
								id: vertical_scroll_bar
								policy: ScrollBar.AsNeeded   // or AlwaysOn / AlwaysOff
								anchors.top: notif_scrollview.top
								anchors.right: notif_scrollview.right
								anchors.bottom: notif_scrollview.bottom

								visible: notif_column.height > notif_scrollview.height
								// opacity: visible ? (vertical_scroll_bar.hovered ? 1 : 0.5) : 0

								// Behavior on opacity {
								// 	NumberAnimation { duration: 150 }
								// }

								contentItem: Rectangle {
									// The draggable handle
									implicitWidth: 6
									implicitHeight: 100
									radius: width / 2
									color: vertical_scroll_bar.pressed ? statisticsScrollBarDown : statisticsScrollBar
									opacity: (vertical_scroll_bar.hovered || vertical_scroll_bar.pressed) ? 1 : 0.5

									Behavior on color {
										ColorAnimation {
											duration: 150
										}
									}

									Behavior on opacity {
										NumberAnimation {
											duration: 150
										}
									}
								}

								background: Rectangle {
									// The track behind the handle
									implicitWidth: 6
									color: "transparent"
									radius: width / 2
								}
							}

							Column {
								id: notif_column
								width: parent.width
								height: childrenRect.height

								Behavior on height {
									NumberAnimation {
										duration: 300
										easing.type: Easing.OutCubic
									}
								}

								Repeater {
									model: notificationsHistory
									delegate: Rectangle {
										id: notif_rect

										width: parent.width  // match Column's width
										height: childrenRect.height + 20

										color: "transparent"

										Text {
											id: notif_app
											anchors.top: parent.top
											anchors.left: parent.left
											anchors.right: parent.right
											anchors.topMargin: 10
											anchors.leftMargin: 15
											anchors.rightMargin: 15

											text: modelData["app_name"]
											font.family: fontFamily
											font.pixelSize: 14
											color: statisticsDimmedTextColor
										}

										Image {
											anchors.top: notif_app.bottom
											anchors.right: parent.right
											anchors.rightMargin: 15
											anchors.topMargin: 8

											source: modelData["app_icon"] ? modelData["app_icon"] : ""
											smooth: true
											mipmap: true
											antialiasing: true

											width: source != "" && source ? parent.width / 4 : 0
											height:source != "" && source ? implicitHeight * (width / implicitWidth) : 0
										}

										Text {
											id: notif_summary
											anchors.top: notif_app.bottom
											anchors.left: parent.left
											anchors.right: parent.right
											anchors.topMargin: 5
											anchors.leftMargin: 15
											anchors.rightMargin: 15
											// The big ass title
											text: modelData["summary"]
											font.family: fontFamily
											font.pixelSize: 16
											font.bold: true

											color: statisticsTextColor

											elide: Text.ElideRight
										}

										Text {
											id: notif_body
											anchors.top: notif_summary.bottom
											anchors.left: parent.left
											anchors.right: parent.right
											anchors.topMargin: 5
											anchors.leftMargin: 15
											anchors.rightMargin: 15
											width: parent.width - 30  // required for wrapping to kick in
											text: modelData["body"]
											font.family: fontFamily
											font.pixelSize: 14
											wrapMode: Text.WordWrap  // uncomment this
											color: statisticsTextColor
										}
									}
								}
							}
						}
					}

					Rectangle {
						id: gallery
						anchors.left: parent.left
						anchors.top: power_buttons_row.bottom
						anchors.right: notifications_area.left
						anchors.bottom: notifications_area.bottom

						anchors.leftMargin: 10
						anchors.topMargin: 10
						anchors.rightMargin: 10

						color: statisticsDetailsBackground
						radius: 10

						// Component.onCompleted: {
						// 	console.log("WH: " + gallery.width + " " + gallery.height)
						// }

						// layer.enabled: true
						// layer.effect: OpacityMask {
						// 	maskSource: Rectangle {
						// 		width: gallery.width
						// 		height: gallery.height
						// 		radius: gallery.radius
						// 	}
						// }

						Image {
							anchors.fill: parent
							source: gallerySource
							fillMode: Image.PreserveAspectCrop
							smooth: true
							mipmap: true
							antialiasing: true
						}

						// Gradient overlay
						Rectangle {
							id: gradient_overlay
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.bottom: parent.bottom
							height: parent.height * 0.4 // Cover 40%

							gradient: Gradient {
								GradientStop { position: 0.0; color: "transparent" }
								GradientStop { position: 1.0; color: '#e1000000' }  // semi-transparent black
							}

							Text {
								anchors.left: parent.left
								anchors.top: parent.top
								anchors.bottom: parent.bottom
								anchors.right: parent.right

								anchors.leftMargin: 10
								anchors.bottomMargin: 10
								anchors.rightMargin: 10

								elide: Text.ElideRight

								text: galleryLabel

								verticalAlignment: Text.AlignBottom

								color: "#ffffff"
								font.pixelSize: 14
								font.family: fontFamily
							}
						}
					}
				}
			}

			HoverHandler {
				onHoveredChanged: {
					statistics_popup.shown = hovered
				}
			}
		}
	}

	PanelWindow {
		id: themes_popup

		// Parent for theme picker on the bottom of the screen yeah?
		anchors {
			left: true
			bottom: true
			right: true
		}

		// Invisible
		// implicitHeight: 0

		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.keyboardFocus: themes_popup.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
		// visible: themes_popup.shown || themes_sel_rect.opacity > 0
		WlrLayershell.exclusiveZone: -1

		property var shown: false
		// property var popupHeight: 250
		// property var popupWidth: 600

		// anchor.window: bottom_panel
		// implicitWidth: popupWidth
		implicitHeight: 270

		visible: themes_popup.shown || themes_sel_rect.opacity > 0

		// anchor.edges: Edges.Bottom
		// anchor.rect.y: 0
		// anchor.rect.x: (bottom_panel.width / 2) - (width / 2)

		color: "transparent"

		onShownChanged: {
			themes_popup_shown_timer.running = true
			themes_popup_shown_timer.restart()

			if (shown) {
				themes_sel_rect.forceActiveFocus()
			}
		}

		Timer {
			id: themes_popup_shown_timer
			interval: 2000 // 2 secs
			repeat: false
			running: false

			onTriggered: {
				themes_popup.shown = false
			}
		}

		Rectangle {
			id: themes_sel_rect

			// anchors.top: parent.top
			// anchors.left: parent.left
			// anchors.bottom: parent.bottom
			width: 600
			height: 250

			anchors.horizontalCenter: parent.horizontalCenter

			// height: themes_popup.popupHeight
			// width: themes_popup.shown ? themes_popup.popupWidth : themes_popup.popupWidth * 2 / 3
			// anchors.horizontalCenter: parent.horizontalCenter

			y: themes_popup.shown ? 0 : 20
			opacity: themes_popup.shown ? 1 : 0

			Behavior on opacity {
				NumberAnimation {
					duration: 250
					easing.type: Easing.OutCubic
				}
			}

			Behavior on y {
				NumberAnimation {
					duration: 250
					easing.type: Easing.OutCubic
				}
			}

			color: themeSelectorBackground
			radius: 10

			Behavior on color {
				ColorAnimation {
					duration: 200
				}
			}

			HoverHandler {
				onHoveredChanged: {
					themes_popup_shown_timer.running = false
					if (hovered) {
						// Good. It's fine
						// themes_popup.shown = true
					} else {
						// Nah goodbye son
						themes_popup.shown = false
					}
				}
			}

			Keys.onPressed: (event) => {
				console.log(event.key)
			}

			ScrollView {
				id: themes_scrollview

				anchors.fill: parent
				anchors.margins: 30
				ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
				ScrollBar.vertical.policy: ScrollBar.AlwaysOff

				opacity: parent.opacity

				Item {
					id: themes_dis_area
					width: Math.max(childrenRect.width, parent.width)  // expands or fills
					height: parent.height

					// opacity: parent.opacity

					function scrollToIndex(index) {
						var itemWidth = themes_row.height  // your items use height for width (width: height)
						var itemX = index * (itemWidth + themes_row.spacing)
						var targetX = itemX + itemWidth / 2 - themes_scrollview.width / 2
						targetX = Math.max(0, Math.min(targetX, themes_row.width - themes_scrollview.width))
						scrollAnim.to = targetX
						scrollAnim.restart()
					}

					NumberAnimation {
						id: scrollAnim
						target: themes_scrollview.contentItem
						property: "contentX"
						duration: 400
						easing.type: Easing.OutCubic
					}

					function refreshCanvas() {
						net_graph.requestPaint()
						ram_mon_drawn.requestPaint()
						cpu_mon_drawn.requestPaint()
					}

					function leftButtonPressed() {
						// console.log("left__")
						if (themes_popup.shown && configJson.themeIndex > 0) {
							configJson.themeIndex--;
							refreshCanvas()
							bg_updater.running = true
							scrollToIndex(configJson.themeIndex)
						}
						if (themes_popup_shown_timer.running) themes_popup_shown_timer.restart()
					}

					function rightButtonPressed() {
						if (themes_popup.shown && configJson.themeIndex < themes.length - 1) {
							configJson.themeIndex++;
							refreshCanvas()
							bg_updater.running = true
							scrollToIndex(configJson.themeIndex)
						}
						if (themes_popup_shown_timer.running) themes_popup_shown_timer.restart()
					}

					Row {
						id: themes_row

						anchors.centerIn: parent  // centers when not overflowing
						height: parent.height

						spacing: 50

						Repeater {
							model: themes

							delegate: Item {
								id: theme_dis
								height: parent.height
								width: height

								Rectangle {
									anchors.fill: parent
									border.width: 2
									radius: 14
									border.color: index == configJson.themeIndex ? themeSelectorHighlighted : "transparent"

									Behavior on border.color {
										ColorAnimation {
											duration: 200
											easing.type: Easing.OutCubic
										}
									}

									color: "transparent"

									Rectangle {
										id: theme_dis_desktop
										anchors.left: parent.left
										anchors.right: parent.right
										anchors.top: parent.top
										anchors.bottom: theme_dis_label.top
										anchors.bottomMargin: 10
										anchors.leftMargin: 5
										anchors.topMargin: 5
										anchors.rightMargin: 5

										color: "transparent"

										radius: 10

									// layer.enabled: true
									// layer.effect: OpacityMask {
									// 	maskSource: Rectangle {
									// 		width: theme_dis_desktop.width
									// 		height: theme_dis_desktop.height
									// 		radius: theme_dis_desktop.radius
									// 	}
									// }

										Image {
											id: theme_dis_bg
											anchors.fill: parent

											source: modelData["background"]
											fillMode: Image.PreserveAspectCrop
											smooth: true
											antialiasing: true
											mipmap: true
										}

										Rectangle {
											id: theme_dis_panel

											anchors.left: parent.left
											anchors.top: parent.top
											anchors.bottom: parent.bottom
											width: 20

											color: modelData["panelBackground"]

											Column {
												// Color pallete display
												anchors.fill: parent
												Rectangle {
													anchors.left: parent.left
													anchors.right: parent.right
													height: width

													color: modelData["accentVeryHigh"]
												}

												Rectangle {
													anchors.left: parent.left
													anchors.right: parent.right
													height: width

													color: modelData["accentHigh"]
												}

												Rectangle {
													anchors.left: parent.left
													anchors.right: parent.right
													height: width

													color: modelData["accent"]
												}

												Rectangle {
													anchors.left: parent.left
													anchors.right: parent.right
													height: width

													color: modelData["accentLow"]
												}

												Rectangle {
													anchors.left: parent.left
													anchors.right: parent.right
													height: width

													color: modelData["accentVeryLow"]
												}
											}
										}
									}

									Text {
										id: theme_dis_label

										anchors.left: parent.left
										anchors.right: parent.right
										anchors.bottom: parent.bottom
										anchors.bottomMargin: 10

										text: modelData["name"]
										font.family: fontFamily
										color: themeSelectorTextColor

										horizontalAlignment: Text.AlignHCenter
										font.bold: true
									}
								}
							}
						}
					}
				}
			}
		}
	}

	PanelWindow {
		id: run_popup
		property bool shown: false

		onShownChanged: {
			if (shown) {
				Qt.callLater(run_input.forceActiveFocus)
				run_input.text = ""

				applist_reloader.running = true
				// console.log(applist_reloader.running)
			}
		}

		anchors {
			left: true
			top: true
			right: true
		}

		// focusable: true

		implicitHeight: 350 // Just enough for 5
		// Also I'm not gonna change height dynamicaly cuz its gonna suck, REALLY suck, like the lag is gonna be unbearable at that point rlly
		// implicitWidth: 500
		WlrLayershell.layer: WlrLayer.Top
    	WlrLayershell.exclusiveZone: -1
		WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

		visible: shown || run_popup_rect.opacity > 0

		color: "transparent"

		onVisibleChanged: {
			if (!visible) {
				run_input.result = {}
			}
		}

		Rectangle {
			id: run_popup_rect
			// anchors.left: parent
			// anchors.right: parent
			anchors.top: parent
			width: 600
			height: run_input.height + result_dis_column.height + 45 // Plus margins

			Behavior on height {
				NumberAnimation {
					duration: 200
					easing.type: Easing.OutCubic
				}
			}

			clip: true

			anchors.horizontalCenter: parent.horizontalCenter

			color: runPromptBackground
			radius: 10

			opacity: run_popup.shown ? 1 : 0
			y: run_popup.shown ? 20 : 0 // float down

			Behavior on opacity {
				NumberAnimation {
					duration: 250
					easing.type: Easing.OutCubic
				}
			}

			Behavior on y {
				NumberAnimation {
					duration: 250
					easing.type: Easing.OutCubic
				}
			}

			// opacity: parent.opacity

			TextField {
				id: run_input
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.right: parent.right

				anchors.margins: 15
				// anchors.bottom: parent.bottom

				placeholderText: "Search an app..."
				echoMode: TextInput.Normal

				padding: 12

				font.family: fontFamily
				color: runTextColor
				opacity: parent.opacity

				cursorDelegate: Rectangle {
					visible: false
				}

				Rectangle {
					id: run_cursor

					width: 2
					height: run_input.height - (run_input.padding * 2)
					anchors.verticalCenter: parent.verticalCenter
					// x: -(width / 2) + x // Offset a bit so that it is kinda (?) centered
					radius: 5
					visible: run_input.cursorVisible
					x: run_input.cursorRectangle.x
        			y: run_input.cursorRectangle.y

					Connections {
						target: run_input
						function onTextChanged() {
							run_cursor_blinking_anim.restart()
						}
					}

					Behavior on x {
						NumberAnimation {
							duration: 200
							easing.type: Easing.OutCubic
						}
					}

					SequentialAnimation {
						id: run_cursor_blinking_anim

						running: run_input.cursorVisible
						loops: Animation.Infinite

						NumberAnimation {
							target: run_cursor
							property: "opacity"
							from: 1.0
							to: 0.0
							duration: 600
						}

						NumberAnimation {
							target: run_cursor
							property: "opacity"
							from: 0.0
							to: 1.0
							duration: 600
						}
					}
				}

				property var result: ({})
				property int selectedIndex: -1

				Keys.onUpPressed: {
					if (selectedIndex > 0) selectedIndex--
				}

				Keys.onDownPressed: {
					if (selectedIndex < result.length - 1) selectedIndex++;
				}

				Keys.onReturnPressed: {
					// console.log("Enter")
					// If result.length = 0 then result.length - 1 = -1
					// Therefore selectedIndex <= -1
					// BUT selectedIndex >= 0
					// So it is impossible
					if (selectedIndex >= 0 && selectedIndex <= result.length - 1) {
						// console.log(applist[result[selectedIndex]]["code"])
						run_popup.shown = false
						app_launch.appName = applist[result[selectedIndex]]["code"]
						app_launch.running = true

						console.log(app_launch.command.join(" "))

						let desktopEntriesUpdated = configJson.desktopEntries
						if (desktopEntriesUpdated.hasOwnProperty(result[selectedIndex])) desktopEntriesUpdated[result[selectedIndex]]++
						else desktopEntriesUpdated[result[selectedIndex]] = 1

						configJson.desktopEntries = desktopEntriesUpdated

						config_file.writeAdapter()
					}
				}

				onTextChanged: {
					// run_cursor_blinking_anim.restart()

					if (text !== "") {
						const query = text.toLowerCase().trim();

						if (!query) {
							result = [];
							return;
						}

						let scored = [];

						Object.keys(applist).forEach(key => {
							const keyLower = key.toLowerCase();
							let score = 0;

							// Exact match
							if (keyLower === query) {
								score = 1000;
							}
							// Starts with query
							else if (keyLower.startsWith(query)) {
								score = 500;
							}
							// Word boundary match (e.g. "fire" matches "firefox")
							else if (keyLower.split(/[\s.\-_]/).some(word => word.startsWith(query))) {
								score = 300;
							}
							// Contains query as substring
							else if (keyLower.includes(query)) {
								score = 100;
							}
							// Fuzzy: all characters of query appear in order
							else {
								let qi = 0;
								for (let i = 0; i < keyLower.length && qi < query.length; i++) {
									if (keyLower[i] === query[qi]) qi++;
								}
								if (qi === query.length) {
									// Penalize by how spread out the characters are
									score = Math.max(1, 50 - (keyLower.length - query.length));
								}
							}

							if (score > 0) {
								const pop = configJson.desktopEntries.hasOwnProperty(key)
									? configJson.desktopEntries[key]
									: 0;
								scored.push({ key, score, pop });
							}
						});

						scored.sort((a, b) => {
							// 1. Match quality
							if (b.score !== a.score) return b.score - a.score;
							// 2. Popularity
							if (b.pop !== a.pop) return b.pop - a.pop;
							// 3. Alphabetical
							if (a.key < b.key) return -1;
							if (a.key > b.key) return 1;
							return 0;
						});

						result = scored.slice(0, 5).map(item => item.key);

						if (selectedIndex > result.length - 1) selectedIndex = result.length - 1;
						else if (selectedIndex < 0) selectedIndex = 0;
					} else {
						result = {}
					}
				}

				background: Rectangle {
					opacity: parent.opacity
					anchors.fill: parent
					color: runSearchBox
					radius: 10
				}
			}

			Column {
				id: result_dis_column

				anchors.top: run_input.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.topMargin: 15
				anchors.bottomMargin: 15
				anchors.leftMargin: 20
				anchors.rightMargin: 20

				height: childrenRect.height

				spacing: 10

				Repeater {
					model: run_input.result

					delegate: Rectangle {
						anchors.left: parent.left
						anchors.right: parent.right
						height: 40

						color: "transparent"

						Text {
							id: result_entry_sel_icon

							anchors.left: parent.left
							anchors.top: parent.top
							anchors.bottom: parent.bottom

							text: " > "
							width: run_input.selectedIndex == index ? 30 : 0
							opacity: run_input.selectedIndex == index ? 1 : 0

							Behavior on width {
								NumberAnimation {
									duration: 200
									easing.type: Easing.OutCubic
								}
							}

							Behavior on opacity {
								NumberAnimation {
									duration: 100
								}
							}

							color: runTextColor
							font.family: fontFamily
							font.bold: true

							verticalAlignment: Text.AlignVCenter
						}

						Image {
							id: result_entry_img

							anchors.top: parent.top
							anchors.bottom: parent.bottom
							anchors.left: result_entry_sel_icon.right
							anchors.margins: 5

							width: height
							source: applist[modelData]["icon"]

							smooth: true
							mipmap: true
							antialiasing: true
						}

						Text {
							anchors.top: parent.top
							anchors.bottom: parent.bottom
							anchors.left: result_entry_img.right
							anchors.right: parent.right
							anchors.leftMargin: 15

							verticalAlignment: Text.AlignVCenter

							text: modelData

							color: runTextColor
							font.family: fontFamily
							font.bold: run_input.selectedIndex == index
						}
					}
				}
			}
		}
	}

	property bool locking: false

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: preemptive_lockscreen

			required property var modelData
        	screen: modelData

			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.exclusiveZone: -1

			anchors {
				left: true
				top: true
				right: true
				bottom: true
			}

			visible: false

			color: "transparent"

			Connections {
                target: root
                function onLockingChanged() {
                    if (root.locking) {
                        preemptive_lockscreen_hide_anim.stop()
                        preemptive_lockscreen_show_anim.start()
                    } else {
                        preemptive_lockscreen_show_anim.stop()
                        preemptive_lockscreen_hide_anim.start()
                    }
                }
            }

			Rectangle {
				id: preemptive_lockscreen_surface
				anchors.fill: parent
				// scale: 0.85

				color: lockscreenBackgroundColor

				SequentialAnimation {
					id: preemptive_lockscreen_show_anim

					ScriptAction {
						script: preemptive_lockscreen.visible = true
					}

					ParallelAnimation {
						NumberAnimation {
							target: preemptive_lockscreen_surface
							property: "scale"
							from: 0.85
							to: 1
							duration: 400
							easing.type: Easing.OutQuart
						}

						NumberAnimation {
							target: preemptive_lockscreen_surface
							property: "opacity"
							from: 0
							to: 1
							duration: 200
						}
					}

					ScriptAction {
						script: lock.locked = true
					}
				}

				SequentialAnimation {
					id: preemptive_lockscreen_hide_anim

					ScriptAction {
						script: preemptive_lockscreen.visible = true
					}

					ScriptAction {
						script: lock.locked = false
					}

					ParallelAnimation {
						NumberAnimation {
							target: preemptive_lockscreen_surface
							property: "scale"
							from: 1
							to: 0.85
							duration: 400
							easing.type: Easing.OutQuart
						}

						NumberAnimation {
							target: preemptive_lockscreen_surface
							property: "opacity"
							from: 1
							to: 0
							duration: 200
						}
					}

					ScriptAction {
						script: preemptive_lockscreen.visible = false
					}
				}
			}
		}
	}

	WlSessionLock {
		id: lock

		onLockedChanged: {
			inputting = false
		}

		property bool inputting: false

		WlSessionLockSurface {
			color: "transparent"
			// opacity: 0.5

			Rectangle {
				id: lockscreen

				anchors.fill: parent

				// Fallback for when image doesn't load
				color: lockscreenBackgroundColor

				focus: !lock.inputting

				Keys.onReturnPressed: {
					lock.inputting = true
				}

				Keys.onEnterPressed: {
					lock.inputting = true
				}

				Item {
					id: lockscreen_elements
					anchors.fill: parent
					opacity: 0

					NumberAnimation {
						id: lockscreen_init_anim
						target: lockscreen_elements
						property: "opacity"
						from: 0
						to: 1
						duration: 400
					}

					Component.onCompleted: {
						lockscreen_init_anim.start()
					}

					// Behavior on opacity {
					// 	NumberAnimation {
					// 		duration: 300
					// 	}
					// }

					// A circle
					Rectangle {
						anchors.centerIn: parent
						width: lock.inputting ? 900 : 600
						height: lock.inputting ? 900 : 600
						border.color: lockscreenCircleColor
						border.width: 4
						color: "transparent"

						radius: width / 2 // Perfect circle

						Behavior on width {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutCubic
							}
						}

						Behavior on height {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutCubic
							}
						}

						NumberAnimation on rotation {
							from: 0
							to: 360
							duration: lock.inputting ? 20000 : 10000
							loops: Animation.Infinite
							running: true
						}

						Rectangle {
							// Ah yea...
							anchors.top: parent.top
							width: 150
							height: 150

							color: lockscreenBackgroundColor // Making a cut in the circ yeah?

							anchors.horizontalCenter: parent.horizontalCenter
						}
					}

					// Another one
					Rectangle {
						anchors.centerIn: parent
						width: lock.inputting ? 1300 : 900
						height: lock.inputting ? 1300 : 900
						border.color: lockscreenCircleColor
						border.width: 3
						color: "transparent"

						radius: width / 2 // Perfect circle

						Behavior on width {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutCubic
							}
						}

						Behavior on height {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutCubic
							}
						}

						NumberAnimation on rotation {
							from: 0
							to: -360
							duration: lock.inputting ? 30000 : 25000
							loops: Animation.Infinite
							running: true
						}

						Rectangle {
							// Ah yea...
							anchors.top: parent.top
							width: 150
							height: 150

							color: lockscreenBackgroundColor // Making a cut in the circ yeah?

							anchors.horizontalCenter: parent.horizontalCenter
						}
					}

					// Another one too
					Rectangle {
						anchors.centerIn: parent
						width: lock.inputting ? 1700 : 1400
						height: lock.inputting ? 1700 : 1400
						border.color: lockscreenCircleColor
						border.width: 2
						color: "transparent"

						radius: width / 2 // Perfect circle

						Behavior on width {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutCubic
							}
						}

						Behavior on height {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutCubic
							}
						}

						NumberAnimation on rotation {
							from: 0
							to: 360
							duration: lock.inputting ? 50000 : 40000
							loops: Animation.Infinite
							running: true
						}

						Rectangle {
							// Ah yea...
							anchors.top: parent.top
							width: 150
							height: 150

							color: lockscreenBackgroundColor // Making a cut in the circ yeah?

							anchors.horizontalCenter: parent.horizontalCenter
						}
					}

					// Another one too x2
					Rectangle {
						anchors.centerIn: parent
						width: lock.inputting ? 2100 : 2000
						height: lock.inputting ? 2100 : 2000
						border.color: lockscreenCircleColor
						border.width: 1
						color: "transparent"

						radius: width / 2 // Perfect circle

						Behavior on width {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutCubic
							}
						}

						Behavior on height {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutCubic
							}
						}

						NumberAnimation on rotation {
							from: 0
							to: -360
							duration: lock.inputting ? 30000 : 15000
							loops: Animation.Infinite
							running: true
						}

						Rectangle {
							// Ah yea...
							anchors.top: parent.top
							width: 250
							height: 250

							color: lockscreenBackgroundColor // Making a cut in the circ yeah?

							anchors.horizontalCenter: parent.horizontalCenter
						}
					}

					Row {
						anchors.left: parent.left
						anchors.bottom: parent.bottom
						anchors.margins: 30
						spacing: 10

						height: 30

						Text {
							// anchors.top: arch_logo.bottom
							// anchors.topMargin: 10

							id: lockscreen_battery_icon

							function getBatteryIcon() {
								if (charging) {
									if (batteryLevel > 90) {
										return "󰂅"
									} else if (batteryLevel > 80) {
										return "󰂋"
									} else if (batteryLevel > 70) {
										return "󰂊"
									} else if (batteryLevel > 60) {
										return "󰢞"
									} else if (batteryLevel > 50) {
										return "󰂉"
									} else if (batteryLevel > 40) {
										return "󰢝"
									} else if (batteryLevel > 30) {
										return "󰂈"
									} else if (batteryLevel > 20) {
										return "󰂇"
									} else if (batteryLevel > 10) {
										return "󰂆"
									} else {
										return "󰢜"
									}
								} else {
									if (batteryLevel > 90) {
										return "󰁹"
									} else if (batteryLevel > 80) {
										return "󰂂"
									} else if (batteryLevel > 70) {
										return "󰂁"
									} else if (batteryLevel > 60) {
										return "󰂀"
									} else if (batteryLevel > 50) {
										return "󰁿"
									} else if (batteryLevel > 40) {
										return "󰁾"
									} else if (batteryLevel > 30) {
										return "󰁽"
									} else if (batteryLevel > 20) {
										return "󰁼"
									} else if (batteryLevel > 10) {
										return "󰁻"
									} else {
										return "󰁺"
									}
								}
							}

							font.pixelSize: 20
							text: getBatteryIcon()
							// font.family: fontFamily
							// padding: 20

							color: charging ? batteryChargingColor : (
								batteryLevel > 20 ? batteryDefaultColor : batteryCriticalColor
							)
							// horizontalAlignment: Text.AlignHCenter

							anchors.top: parent.top
							anchors.bottom: parent.bottom
							verticalAlignment: Text.AlignVCenter
						}

						Text {
							font.family: fontFamily
							color: charging ? batteryChargingColor : (
								batteryLevel > 20 ? batteryDefaultColor : batteryCriticalColor
							)
							font.pixelSize: 16
							text: batteryLevel + "%"

							anchors.top: parent.top
							anchors.bottom: parent.bottom
							verticalAlignment: Text.AlignVCenter
						}
					}

					Column {
						id: lockscreen_clock
						anchors.centerIn: parent
						width: childrenRect.width
						height: childrenRect.height

						spacing: 30

						visible: opacity > 0
						opacity: lock.inputting ? 0 : 1

						Behavior on opacity {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutCubic
							}
						}

						Text {
							// anchors.centerIn: parent
							color: lockscreenTimeColor
							font.family: fontFamily
							font.pixelSize: 50
							anchors.left: parent.left
							anchors.right: parent.right
							horizontalAlignment: Text.AlignHCenter
							// width: 40
							height: 50

							text: Qt.formatDateTime(
								clock.date,
								"hh mm ss"
							)

							font.bold: true
						}

						Column {
							id: lockscreen_calendar_col
							width: 290
							height: 160
							// anchors.verticalCenter: parent.verticalCenter
							// anchors.fill: parent
							spacing: 10

							Grid {
								id: lockscreen_calendar_weekday_labels
								anchors.left: parent.left
								anchors.right: parent.right
								columns: 7
								spacing: 5

								property var weekdays: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

								Repeater {
									model: lockscreen_calendar_weekday_labels.weekdays

									delegate: Rectangle {
										height: childrenRect.height
										width: 40

										color: "transparent"

										Text {
											// anchors.centerIn: parent
											text: modelData

											color: clockTextColor
											font.family: fontFamily
										}
									}
								}
							}

							// The actual calendar (minus the weekday labels)
							Item {
								id: lockscreen_calendar
								anchors.left: parent.left
								anchors.right: parent.right
								height: childrenRect.height

								property var dayDisplays: {
									let days = []
									const now = new Date();
									let firstDate = new Date(now.getFullYear(), now.getMonth(), 1)
									let firstWeekday = (firstDate.getDay() + 6) % 7
									// let firstWeekday = 3 // debug

									let lastDate = new Date(now.getFullYear(), now.getMonth() + 1, 0)
									let digitsAmount = (firstWeekday + lastDate.getDate())
									if (digitsAmount > 7 * 5) digitsAmount = 7 * 6
									else digitsAmount = 7 * 5
									// console.log(firstWeekday)
									// firstWeekday will have these values:
									// 0: MONDAY
									// 1: TUESDAY
									// 2: WEDNESDAY
									// 3: THURSDAY
									// 4: FRIDAY
									// 5: SATURDAY
									// 6: SUNDAY

									// Now we just append it all first

									// console.log(firstWeekday + " | " + digitsAmount)
									let lastMonthFinalDate = new Date(now.getFullYear(), now.getMonth(), 0).getDate()
									for (let i = 0; i < firstWeekday; i++) {
										let offset = firstWeekday - i

										days.push("_" + (lastMonthFinalDate - offset + 1))
									}

									// Now we just need to add the rest of the days
									for (let i = 1; i <= lastDate.getDate(); i++) {
										let value = "" + i

										if (value.length == 1) value = "0" + value
										days.push(value)
									}

									digitsAmount -= days.length
									for (let i = 1; i <= digitsAmount; i++) {
										let value = "" + i

										if (value.length == 1) value = "0" + value
										days.push("_"+value)
									}

									// console.log(days)

									return days
								}

								property var today: {
									let d = "" + new Date().getDate()
									return d.length === 1 ? "0" + d : d
									// console.log(today)
								}
								Grid {
									id: lockscreen_calendar_grid
									columns: 7
									spacing: 5

									Repeater {
										model: calendar.dayDisplays

										delegate: Rectangle {
											height: childrenRect.height
											width: 40

											// color: modelData === calendar.today ? "white" : "transparent"
											color: "transparent"

											Text {
												// anchors.centerIn: parent
												text: modelData[0] == '_' ? modelData.slice(1) : (modelData === lockscreen_calendar.today ? modelData + "*" : modelData)

												color: modelData[0] == '_' ? clockGreyedOutTextColor : (modelData === lockscreen_calendar.today ? clockTodayTextColor : clockTextColor)
												font.bold: modelData === calendar.today
												font.family: fontFamily
											}
										}
									}
								}
							}
						}
					}

					Rectangle {
						id: lockscreen_passwd_panel
						width: lock.inputting ? 500 : 213
						height: 300

						color: lockscreenPanelColor

						anchors.centerIn: parent
						radius: 10

						scale: lock.inputting ? 1 : 0.85
						opacity: lock.inputting ? 1 : 0


						Behavior on scale {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutQuart
							}
						}

						Behavior on width {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutQuart
							}
						}

						Behavior on opacity {
							NumberAnimation {
								duration: 400
								easing.type: Easing.OutQuart
							}
						}

						Column {
							// The part that house the username and password input box yea?
							// anchors.top: parent.top
							anchors.right: parent.right
							// anchors.bottom: parent.bottom
							anchors.left: lockscreen_gallery.right
							anchors.margins: 30
							anchors.verticalCenter: parent.verticalCenter

							spacing: 20

							Item {
								anchors.left: parent.left
								anchors.right: parent.right
								height: childrenRect.height

								Row {
									height: childrenRect.height
									opacity: parent.opacity
									id: lockscreen_names
									// anchors.top: parent.top
									// anchors.left: parent.left
									anchors.horizontalCenter: parent.horizontalCenter

									Text {
										opacity: parent.opacity
										text: username
										font.family: fontFamily
										// font.bold: true
										font.weight: 750
										color: lockscreenHighlightedTextColor

										font.pixelSize: 16
									}

									Text {
										opacity: parent.opacity
										text: "@"
										font.family: fontFamily
										color: lockscreenDimmedTextColor

										font.pixelSize: 16
									}

									Text {
										opacity: parent.opacity
										text: hostname
										font.family: fontFamily
										color: lockscreenTextColor

										font.pixelSize: 16
									}
								}
							}

							TextField {
								id: lockscreen_passwd_field

								anchors.horizontalCenter: parent.horizontalCenter
								// anchors.left: parent.left
								// anchors.right: parent.right
								width: lockscreen_names.width + 50
								padding: 15
								background: Rectangle {
									color: lockscreenInputColor
									radius: 8
									// padding: 30
									border.width: 2
									border.color: "transparent"

									Behavior on border.color {
										ColorAnimation {
											duration: 300
										}
									}
								}

								focus: lock.inputting

								Keys.onEscapePressed: {
									lock.inputting = false
								}

								Keys.onReturnPressed: {
									pam.start()
								}

								Keys.onEnterPressed: {
									pam.start()
								}

								PamContext {
									id: pam
									onCompleted: (result) => {
										lockscreen_passwd_field.readOnly = false
										if (result === PamResult.Success) {
											root.locking = false
										} else {
											lockscreen_passwd_field.background.border.color = lockscreenWrongColor
										}
									}

									onPamMessage: {
										// fires when PAM wants a response (e.g. asking for the password)
										if (this.responseRequired) {
											this.respond(lockscreen_passwd_field.text)
											lockscreen_passwd_field.readOnly = true
										}
									}
								}

								font.family: fontFamily
								color: readOnly ? lockscreenDimmedTextColor : lockscreenTextColor

								Behavior on color {
									ColorAnimation {
										duration: 200
									}
								}

								echoMode: TextInput.Password
								passwordCharacter: "*"
								horizontalAlignment: TextInput.AlignHCenter

								cursorDelegate: Rectangle {
									visible: false
								}

								onTextChanged: {
									lockscreen_passwd_field.background.border.color = "transparent"
								}

								Rectangle {
									id: lockscreen_passwd_cursor

									width: 2
									height: lockscreen_passwd_field.height - (lockscreen_passwd_field.padding * 2)
									anchors.verticalCenter: parent.verticalCenter
									// x: -(width / 2) + x // Offset a bit so that it is kinda (?) centered
									radius: 5
									visible: lockscreen_passwd_field.cursorVisible
									x: lockscreen_passwd_field.cursorRectangle.x
									y: lockscreen_passwd_field.cursorRectangle.y

									Connections {
										target: lockscreen_passwd_field
										function onTextChanged() {
											run_cursor_blinking_anim.restart()
										}
									}

									Behavior on x {
										NumberAnimation {
											duration: 200
											easing.type: Easing.OutCubic
										}
									}

									SequentialAnimation {
										id: run_cursor_blinking_anim

										running: lockscreen_passwd_field.cursorVisible
										loops: Animation.Infinite

										NumberAnimation {
											target: lockscreen_passwd_cursor
											property: "opacity"
											from: 1.0
											to: 0.0
											duration: 600
										}

										NumberAnimation {
											target: lockscreen_passwd_cursor
											property: "opacity"
											from: 0.0
											to: 1.0
											duration: 600
										}
									}
								}
							}
						}

						Rectangle {
							id: lockscreen_gallery

							anchors.left: parent.left
							anchors.top: parent.top
							anchors.bottom: parent.bottom

							anchors.margins: 30

							radius: 10

							color: "transparent"

							width: (height * 17 / 24)

							// layer.enabled: true
							// layer.effect: OpacityMask {
							// 	maskSource: Rectangle {
							// 		width: gallery.width
							// 		height: gallery.height
							// 		radius: gallery.radius
							// 	}
							// }

							Image {
								anchors.fill: parent
								source: gallerySource
								fillMode: Image.PreserveAspectCrop
								smooth: true
								mipmap: true
								antialiasing: true
							}

							// Gradient overlay
							Rectangle {
								// id: gradient_overlay
								anchors.left: parent.left
								anchors.right: parent.right
								anchors.bottom: parent.bottom
								height: parent.height * 0.4 // Cover 40%

								gradient: Gradient {
									GradientStop { position: 0.0; color: "transparent" }
									GradientStop { position: 1.0; color: '#e1000000' }  // semi-transparent black
								}

								Text {
									anchors.left: parent.left
									anchors.top: parent.top
									anchors.bottom: parent.bottom
									anchors.right: parent.right

									anchors.leftMargin: 10
									anchors.bottomMargin: 10
									anchors.rightMargin: 10

									elide: Text.ElideRight

									text: galleryLabel

									verticalAlignment: Text.AlignBottom

									color: "#ffffff"
									font.pixelSize: 14
									font.family: fontFamily
								}
							}
						}
					}
				}

				// Button {
				// 	// Backup cuz dealing with WlSessionLock is a pain in the ass
				// 	text: "unlock me"
				// 	onClicked: {
				// 		root.locking = false
				// 	}
				// }
			}
		}
	}
}
