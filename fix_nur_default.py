with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/default.nix', 'r') as f:
    content = f.read()

new_packages = """  angr-management = pkgs.callPackage ./pkgs/angr-management {};
  autodesk-fusion = pkgs.callPackage ./pkgs/autodesk-fusion {
    wine = pkgs.wineWow64Packages.full;
  };
  ist-fenix-auto-enroller = pkgs.callPackage ./pkgs/ist-fenix-auto-enroller {};
}
"""

# replace the last }
parts = content.rsplit('}', 1)
content = parts[0] + new_packages.strip() + '\n}'

with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/default.nix', 'w') as f:
    f.write(content)
