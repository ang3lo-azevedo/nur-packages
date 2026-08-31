with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/pkgs/ist-fenix-auto-enroller/default.nix', 'r') as f:
    content = f.read()

content = content.replace('nativeBuildInputs = [makeWrapper];', 'nativeBuildInputs = [makeWrapper pkgs.copyDesktopItems];\n\n    desktopItems = [\n      (pkgs.makeDesktopItem {\n        name = "ist-fenix-auto-enroller";\n        exec = "ist-fenix-auto-enroller";\n        desktopName = "IST Fenix Auto-Enroller";\n        comment = "Automatically enroll in IST Fenix shifts";\n        categories = ["Utility"];\n      })\n    ];')

with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/pkgs/ist-fenix-auto-enroller/default.nix', 'w') as f:
    f.write(content)
