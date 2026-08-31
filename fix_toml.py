with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/nvfetcher.toml', 'r') as f:
    content = f.read()

content = content.replace('src.gitea = "cryinkfly/Autodesk-Fusion-360-on-Linux"\nsrc.host = "codeberg.org"', 'src.git = "https://codeberg.org/cryinkfly/Autodesk-Fusion-360-on-Linux.git"')
content = content.replace('fetch.gitea = "cryinkfly/Autodesk-Fusion-360-on-Linux"\nfetch.host = "codeberg.org"', 'fetch.git = "https://codeberg.org/cryinkfly/Autodesk-Fusion-360-on-Linux.git"')

with open('/home/ang3lo/nix-config/pkgs/ang3lo-nur/nvfetcher.toml', 'w') as f:
    f.write(content)
