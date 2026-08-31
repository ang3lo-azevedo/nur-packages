import os

def fix_angr():
    with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/pkgs/angr-management/default.nix', 'r') as f:
        content = f.read()
    
    content = content.replace('src,', '')
    content = content.replace('${src}', '${sources.angr-management-src.src}')
    
    with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/pkgs/angr-management/default.nix', 'w') as f:
        f.write(content)

def fix_autodesk():
    with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/pkgs/autodesk-fusion/default.nix', 'r') as f:
        content = f.read()
    
    content = content.replace('src,', 'pkgs,')
    content = content.replace('deps = [', 'sources = pkgs.callPackage ../_sources/generated.nix {};\n  deps = [')
    content = content.replace('inherit src;', 'src = sources.autodesk-fusion.src;')
    
    with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/pkgs/autodesk-fusion/default.nix', 'w') as f:
        f.write(content)

def fix_ist():
    with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/pkgs/ist-fenix-auto-enroller/default.nix', 'r') as f:
        content = f.read()
    
    content = content.replace('src,', 'pkgs,')
    content = content.replace('let\n  pythonEnv', 'let\n  sources = pkgs.callPackage ../_sources/generated.nix {};\n  pythonEnv')
    content = content.replace('inherit src;', 'src = sources.ist-fenix-auto-enroller.src;')
    content = content.replace('version = "1.0.0";', 'version = sources.ist-fenix-auto-enroller.version;')
    
    with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/pkgs/ist-fenix-auto-enroller/default.nix', 'w') as f:
        f.write(content)

fix_angr()
fix_autodesk()
fix_ist()
