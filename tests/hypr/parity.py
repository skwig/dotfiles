"""Behavioral comparisons to the original files, not a second hand-written config."""
import copy
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
LEGACY = ROOT / "tests/hypr/fixtures/legacy"


def value(text):
    if text in ("true", "on", "yes"):
        return True
    if text in ("false", "off", "no"):
        return False
    try:
        return float(text)
    except ValueError:
        return text


def binding_key(key):
    parts = key.replace("+", " ").split()
    return tuple(sorted(parts[:-1])), parts[-1]


def old_binding(line, main_mod, submap):
    flags, payload = line.split("=", 1)
    mods, key, action, *rest = [part.strip() for part in payload.split(",", 3)]
    argument = rest[0] if rest else ""
    options = {name: True for flag, name in (("e", "repeating"), ("l", "locked"), ("m", "mouse")) if flag in flags}
    names = {"exec": "exec_cmd", "killactive": "window.close", "togglefloating": "window.float",
             "fullscreen": "window.fullscreen", "movefocus": "focus", "movewindow": "window.move",
             "workspace": "focus", "movetoworkspacesilent": "window.move", "movetoworkspace": "window.move",
             "togglespecialworkspace": "workspace.toggle_special", "submap": "submap", "resizewindow": "window.resize"}
    name, args = names[action], None
    if action == "exec":
        args = argument
        if "hyprctl dispatch togglefloating" in args:
            return {"key": " ".join((mods.replace("$mainMod", main_mod), key)).strip(),
                    "submap": submap, "options": options, "calls": [
                        {"name": "window.float", "args": {"action": "toggle"}},
                        {"name": "window.pin", "args": {"action": "toggle"}}]}
    elif action == "togglefloating":
        args = {"action": "toggle"}
    elif action in ("movefocus", "movewindow"):
        if options.get("mouse"):
            name = "window.drag"
        else:
            args = {"direction": dict(l="left", r="right", u="up", d="down")[argument]}
    elif action == "workspace":
        args = {"workspace": int(argument)}
    elif action == "movetoworkspacesilent":
        args = {"workspace": int(argument), "follow": False}
    elif action == "movetoworkspace":
        args = {"workspace": argument}
    elif action in ("togglespecialworkspace", "submap"):
        args = argument
    call = {"name": name}
    if args is not None:
        call["args"] = args
    return {"key": " ".join((mods.replace("$mainMod", main_mod), key)).strip(),
            "submap": submap, "options": options, "calls": [call]}


def legacy_bindings():
    result = []
    for filename, mod in (("hyprland.keybindings.conf", ""), ("hyprland.keybindings.mainMod.conf", "SUPER ALT"), ("hyprland.keybindings.mainMod.conf", "SUPER")):
        submap = ""
        for raw in (LEGACY / filename).read_text().splitlines():
            line = raw.strip()
            if line.startswith("submap ="):
                submap = line.split("=", 1)[1].strip()
                if submap == "reset":
                    submap = ""
            if re.match(r"bind(?:el|l|m)?\s*=", line):
                result.append(old_binding(line, mod, submap))
    return result


def flatten(data, prefix=""):
    result = {}
    for key, item in data.items():
        name = prefix + key
        if isinstance(item, dict) and key != "active_border":
            result.update(flatten(item, name + "."))
        else:
            result[name] = item
    return result


def legacy_settings():
    settings, animations, curves, stack = {}, [], {}, []
    for raw in (LEGACY / "hyprland.conf").read_text().splitlines():
        line = raw.split("#", 1)[0].strip()
        if line.endswith("{"):
            stack.append(line[:-1].strip())
        elif line == "}":
            stack.pop()
        elif stack and "=" in line:
            key, text = map(str.strip, line.split("=", 1))
            if key == "bezier":
                name, *points = text.split(",")
                curves[name] = {"type": "bezier", "points": [list(map(float, points[:2])), list(map(float, points[2:]))]}
            elif key == "animation":
                leaf, enabled, speed, bezier, *style = map(str.strip, text.split(","))
                animation = dict(leaf=leaf, enabled=bool(int(enabled)), speed=float(speed), bezier=bezier)
                if style:
                    animation["style"] = style[0]
                animations.append(animation)
            elif stack[0] != "device":
                settings[".".join(stack + [key])] = value(text)
    return settings, animations, curves


def parse_rule(text):
    rule = {"match": {}}
    for field in text.split(","):
        key, text = field.strip().split(" ", 1)
        target = rule["match"] if key.startswith("match:") else rule
        key = key.removeprefix("match:")
        target[key] = value(text.strip())
        if key == "workspace":
            target[key] = text.strip()
        if target is rule["match"] and key in ("xwayland", "float", "fullscreen", "pin"):
            target[key] = bool(int(text))
    return rule


def legacy_rules():
    todo = {"name": "todo-workspace", "match": {"workspace": "special:todo"}, "float": True, "size": "1850 1000", "center": True}
    windows = [copy.deepcopy(todo), copy.deepcopy(todo)]
    for raw in (LEGACY / "hyprland.conf").read_text().splitlines():
        if raw.startswith("windowrule ="):
            windows.append(parse_rule(raw.split("=", 1)[1]))
    layers = []
    for raw in (LEGACY / "hyprland.apps.conf").read_text().splitlines():
        if raw.startswith("windowrule ="):
            windows.append(parse_rule(raw.split("=", 1)[1]))
        elif raw.startswith("layerrule ="):
            layers.append(parse_rule(raw.split("=", 1)[1]))
    return windows, layers


def legacy_monitors(host):
    variables, monitors = {}, []
    for part in ("globals", "monitors"):
        for raw in (LEGACY / f"hyprland.{part}.{host}.conf").read_text().splitlines():
            line = raw.split("#", 1)[0].strip()
            if "=" not in line:
                continue
            key, text = map(str.strip, line.split("=", 1))
            text = re.sub(r"\$(\w+)", lambda match: variables[match[1]], text)
            if key.startswith("$"):
                variables[key[1:]] = text
            elif key == "monitor":
                output, mode, position, scale = map(str.strip, text.split(","))
                monitors.append(dict(output=output, mode=mode, position=position, scale=float(scale)))
    return monitors


def legacy_devices_and_gestures():
    devices, gestures, device = [], [], None
    for raw in (LEGACY / "hyprland.conf").read_text().splitlines():
        line = raw.split("#", 1)[0].strip()
        if line == "device {":
            device = {}
        elif device is not None:
            if line == "}":
                devices.append(device)
                device = None
            elif "=" in line:
                key, text = map(str.strip, line.split("=", 1))
                device[key] = value(text)
        elif line.startswith("gesture ="):
            fingers, direction, action = map(str.strip, line.split("=", 1)[1].split(","))
            gestures.append(dict(fingers=int(fingers), direction=direction, action=action))
    return devices, gestures


def capture(host, main_monitor=None, scale=None, role_edits=None):
    with tempfile.TemporaryDirectory(prefix="hypr-parity-", dir="/tmp/opencode") as directory:
        fixture = Path(directory)
        shutil.copytree(ROOT / "hypr", fixture / "hypr")
        custom = fixture / "hypr-custom"
        custom.mkdir()
        for name, filename in (("hyprland.monitors.lua", f"hyprland.monitors.{host}.lua"),):
            path = fixture / "hypr" / filename
            if path.exists():
                text = path.read_text()
                if main_monitor and ".monitors." in filename:
                    text = re.sub(r'mainMonitor\s*=\s*"[^"]+"', f'mainMonitor = "{main_monitor}"', text, count=1)
                if scale and ".monitors." in filename:
                    text = re.sub(r'scale\s*=\s*[\d.]+', f'scale = {scale}', text, count=1)
                if role_edits and ".monitors." in filename:
                    for role, output in role_edits.items():
                        text = re.sub(role + r'\s*=\s*"[^"]+"', f'{role} = "{output}"', text, count=1)
                path.write_text(text)
                (custom / name).symlink_to(path)
        return json.loads(subprocess.check_output(["lua", str(ROOT / "tests/hypr/capture.lua"), host, directory],
                         env={**os.environ, "XDG_CONFIG_HOME": directory}, text=True))


class Parity(unittest.TestCase):
    def test_shared_monitor_and_scale_edits_propagate(self):
        for host in ("blackbox", "smallbox"):
            with self.subTest(host=host):
                data = capture(host, main_monitor="TEST-OUTPUT", scale=1.75)["first"]
                self.assertEqual(data["monitors"][0]["output"], "TEST-OUTPUT")
                self.assertTrue(all(m["scale"] == 1.75 for m in data["monitors"]))
                self.assertEqual(float(data["env"]["GDK_SCALE"]), 1.75)
                workspaces = [w for w in data["workspaces"] if w["workspace"] != "special:todo"]
                self.assertTrue(all(w["monitor"] == "TEST-OUTPUT" for w in workspaces[:5]))
                if host == "smallbox":
                    self.assertTrue(all(w["monitor"] == "TEST-OUTPUT" for w in workspaces))
        data = capture("blackbox", role_edits={"leftMonitor": "TEST-LEFT", "rightMonitor": "TEST-RIGHT"})["first"]
        self.assertEqual(data["monitors"][1]["output"], "TEST-LEFT")
        self.assertEqual(data["monitors"][2]["output"], "TEST-RIGHT")
        numbered = [w for w in data["workspaces"] if w["workspace"] != "special:todo"]
        self.assertEqual([w["monitor"] for w in numbered[5:]], ["TEST-LEFT", "TEST-LEFT", "TEST-RIGHT", "TEST-RIGHT"])

    def test_original_settings_bindings_rules_order_and_reload(self):
        expected_settings, animations, curves = legacy_settings()
        # UWSM now runs start-hyprland; do not hide a missing-watchdog warning.
        expected_settings.pop("misc.disable_watchdog_warning")
        windows, layers = legacy_rules()
        # Shared todo rule moves once to apps.lua, after the two base rules.
        windows = windows[2:4] + windows[:1] + windows[4:]
        expected_binds = legacy_bindings()
        for host in ("blackbox", "smallbox"):
            with self.subTest(host=host):
                captured = capture(host)
                first, reloaded = captured["first"], captured["reloaded"]
                self.assertFalse(reloaded["commands"])
                for key in ("settings", "env", "monitors", "devices", "gestures", "curves", "animations", "workspaces", "binds", "windows", "layers", "sources", "event_results"):
                    self.assertEqual(first[key], reloaded[key], key)
                settings = flatten(first["settings"])
                gradient = settings["general.col.active_border"]
                settings["general.col.active_border"] = " ".join(gradient["colors"]) + f' {gradient["angle"]}deg'
                # Do not introduce unrelated bell or floating-policy overrides.
                self.assertNotIn("misc.bell_sound", settings)
                self.assertNotIn("misc.new_float_force_onscreen", settings)
                compatibility = {"quirks.skip_non_kms_dmabuf_formats": False}
                for key, expected in compatibility.items():
                    self.assertEqual(settings.pop(key, None), expected, key)
                self.assertEqual(settings, expected_settings)
                self.assertEqual(first["animations"], animations)
                self.assertEqual(first["curves"], curves)
                self.assertEqual(first["monitors"], legacy_monitors(host))
                devices, gestures = legacy_devices_and_gestures()
                self.assertEqual(first["devices"], devices)
                self.assertEqual(first["gestures"], gestures)
                self.assertEqual(first["windows"], windows)
                self.assertEqual(first["layers"], layers)
                self.assertEqual(len(first["binds"]), 138)
                for old, new in zip(expected_binds, first["binds"]):
                    self.assertEqual(binding_key(old.pop("key")), binding_key(new.pop("key")))
                    self.assertEqual(old, new)
                expected_binds = legacy_bindings()
                self.assertEqual(first["sources"], ["hyprland.monitors.lua", "hyprland.keybindings.lua",
                                                   "hyprland.keybindings.mainMod.lua", "hyprland.keybindings.mainMod.lua", "hyprland.apps.lua", "hyprland.events.lua"])
                self.assertLess(first["order"].index("setting:input.follow_mouse"), first["order"].index("binds"))
                numbered = [w for w in first["workspaces"] if w["workspace"] != "special:todo"]
                self.assertEqual(len(numbered), 9)
                for i, rule in enumerate(numbered, 1):
                    self.assertEqual(rule.get("persistent"), True if i <= 5 else None)
                todo = [w for w in first["workspaces"] if w["workspace"] == "special:todo"]
                self.assertEqual(todo, [])
                self.assertTrue(all("on_created_empty" not in w for w in first["workspaces"]))
                self.assertEqual(first["event_names"], ["hyprland.start", "window.active", "workspace.created"])

    def test_verifier_version_and_deprecation_policy(self):
        with tempfile.TemporaryDirectory(prefix="hypr-version-test-", dir="/tmp/opencode") as directory:
            binary = Path(directory) / "Hyprland"
            binary.write_text('#!/usr/bin/env python3\nimport os,sys\nif "--version" in sys.argv:\n print("Hyprland " + os.environ["TEST_VERSION"] + " built from test")\nelse:\n print("config ok")\n print(os.environ.get("TEST_DEPRECATION", ""))\n')
            binary.chmod(0o755)
            for version, accepted in (("0.57.0", True), ("0.57.2", True), ("0.58.0", True), ("1.0.0", True), ("0.56.2", False), ("invalid", False)):
                result = subprocess.run(["bash", str(ROOT / "tests/hypr/verify.sh"), str(binary)], capture_output=True,
                                        env={**os.environ, "TEST_VERSION":version, "TEST_DEPRECATION":""})
                self.assertEqual(result.returncode == 0, accepted, (version, result.stdout, result.stderr))
            for warning in ("deprecated setting", "on_created_empty workspace rule: Rather than on_created_empty, use a Lua handler"):
                result = subprocess.run(["bash", str(ROOT / "tests/hypr/verify.sh"), str(binary)], capture_output=True,
                                        env={**os.environ, "TEST_VERSION":"0.57.2", "TEST_DEPRECATION":warning})
                self.assertNotEqual(result.returncode, 0, warning)

    def test_native_todo_and_vm_callbacks(self):
        for host in ("blackbox", "smallbox"):
            with self.subTest(host=host):
                for stage in capture(host).values():
                    events = stage["event_results"]
                    self.assertEqual(events["todo_empty"]["commands"], [{
                        "command": 'dots-browser --app="https://todo.skwig.party"',
                        "rules": {"workspace": "special:todo"}}])
                    for name in ("todo_nonempty", "other_empty", "named_todo"):
                        self.assertFalse(events[name]["commands"], name)
                    for name in ("qemu_focus", "vmware_focus"):
                        self.assertEqual(events[name]["calls"], [{"name": "submap", "args": "vm"}], name)
                    for name in ("ordinary_focus", "empty_focus", "close_nil", "close_vm", "close_qemu"):
                        self.assertEqual(events[name]["calls"], [{"name": "submap", "args": "reset"}], name)
                    # Reload must not undo a manually selected/escaped submap.
                    for name in ("reload_vm", "reload_unmapped", "reload_ordinary", "reload_empty"):
                        self.assertFalse(events[name]["calls"], name)

    def test_startup_commands_do_not_inherit_initial_workspace_token(self):
        expected = ["wl-paste --watch cliphist store &", "systemctl --user start hyprpolkitagent",
                    "synology-drive &", "sleep 3 && librepods --start-minimized &"]
        # Replace only the external shell boundary; assert command argv and environment.
        for entry, command in zip(capture("blackbox")["first"]["commands"], expected):
            self.assertTrue(entry["command"].startswith("env -u HL_INITIAL_WORKSPACE_TOKEN sh -c "), "startup still uses ordinary tracked execution")
            with tempfile.TemporaryDirectory(prefix="hypr-startup-", dir="/tmp/opencode") as directory:
                shell = Path(directory) / "sh"
                shell.write_text('#!/usr/bin/env python3\nimport os,sys,json\nprint(json.dumps([sys.argv[1:],os.getenv("HL_INITIAL_WORKSPACE_TOKEN")]))\n')
                shell.chmod(0o755)
                result = subprocess.check_output(["/bin/sh", "-c", entry["command"]], text=True,
                    env={**os.environ, "PATH": directory + ":" + os.environ["PATH"], "HL_INITIAL_WORKSPACE_TOKEN": "sentinel"})
                self.assertEqual(json.loads(result), [["-c", command], None])
        self.assertEqual(len(capture("blackbox")["first"]["commands"]), 4)


if __name__ == "__main__":
    unittest.main()
