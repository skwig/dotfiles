# A quick little script to get 
import os
import json
from configparser import ConfigParser
from pathlib import Path

# Index the icons first
iconsLocations = ["/usr/share/icons/", "/usr/share/pixmaps", "/home/" + str(os.getenv("USER")) + "/.local/share/icons/"]
iconsDict = {}

paths = ["/usr/share/applications/", "/home/" + str(os.getenv("USER")) + "/.local/share/applications/"]

# Initialize the parser without interpolation
config = ConfigParser(interpolation=None)

# Instead of recurseIcons — much faster
for icons_path in iconsLocations:
    for root, dirs, files in os.walk(icons_path):
        for filename in files:
            full_path = os.path.join(root, filename)
            iconsDict[Path(full_path).stem] = full_path

# with open("./icons.json", "w", encoding='utf-8') as f:
#     json.dump(iconsDict, f)

# Instead of reusing a single ConfigParser — avoid state bleed
apps = {}
for path in paths:
    for file in os.listdir(path):
        if file.endswith(".desktop"):
            fullpath = os.path.join(path, file)

            config = ConfigParser(interpolation=None)  # fresh each time
            config.read(fullpath)

            if "Desktop Entry" in config:
                if not (config["Desktop Entry"].getboolean("NoDisplay")) and not (config["Desktop Entry"].getboolean("Hidden")):
                    name = str(config["Desktop Entry"].get("Name"))
                    icon = str(config["Desktop Entry"].get("Icon"))

                    if not os.path.exists(icon) or os.path.isdir(icon):
                        if icon in iconsDict:
                            icon = iconsDict[icon]
                        else:
                            icon = ""
                    apps[name] = {
                        "code": str(Path(fullpath).stem),
                        "icon": icon
                    }

# with open("./apps.json", "w", encoding='utf-8') as f:
#     json.dump(apps, f)

print(json.dumps(apps))