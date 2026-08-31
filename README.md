<div id="top"></div>

# ang3lo-nur

Current maintainer: [ang3lo-azevedo](https://github.com/ang3lo-azevedo)

The ang3lo-nur repository is a personal Nix User Repository for custom Nix packages.
It provides access to custom package descriptions (Nix expressions) and allows you to install packages by referencing them via attributes.
In contrast to [Nixpkgs](https://github.com/NixOS/nixpkgs/), packages are built
from source and **are not reviewed by any Nixpkgs member**.

## Installation

### Using flakes

Include ang3lo-nur in your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ang3lo-nur = {
      url = "github:ang3lo-azevedo/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
};
```

Then, either the overlay (`overlays.default`) or `packages.<system>` can be used.

### Using `packageOverrides`

To make ang3lo-nur accessible for your login user, add the following to `~/.config/nixpkgs/config.nix`:

```nix
{
  packageOverrides = pkgs: {
    ang3lo-nur = import (builtins.fetchTarball "github:ang3lo-azevedo/nur-packages/archive/main.tar.gz") {
      inherit pkgs;
    };
  };
}
```

For NixOS add the following to your `/etc/nixos/configuration.nix`:

```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    ang3lo-nur = import (builtins.fetchTarball "github:ang3lo-azevedo/nur-packages/archive/main.tar.gz") {
      inherit pkgs;
    };
  };
}
```

### Pinning

You can pin the version if you don't want to fetch the latest commit every time:

```nix
builtins.fetchTarball {
  url = "github:ang3lo-azevedo/nur-packages/archive/<COMMIT_HASH>.tar.gz";
  sha256 = "<SHA256_HASH>";
}
```

## How to use

Then packages can be used or installed from the ang3lo-nur namespace.

```console
$ nix-shell -p ang3lo-nur.packages.x86_64-linux.chainsaw-rules
```

or

```console
# configuration.nix
environment.systemPackages = with pkgs; [
  ang3lo-nur.packages.x86_64-linux.chainsaw-rules
];
```

***This repository does not check for malicious content on a regular basis
and it is recommended to check expressions before installing them.***

### Using a single package in a devshell

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ang3lo-nur = {
      url = "github:ang3lo-azevedo/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ang3lo-nur }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ang3lo-nur.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.chainsaw-rules ];
        };
      }
    );
}
```

### Using the flake in NixOS

Using overlays and modules from ang3lo-nur in your configuration is fairly straightforward.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ang3lo-nur = {
      url = "github:ang3lo-azevedo/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ang3lo-nur }: {
    nixosConfigurations.myConfig = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        # Adds the ang3lo-nur overlay
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ ang3lo-nur.overlays.default ];
          environment.systemPackages = [ pkgs.chainsaw-rules ];
        })
      ];
    };
  };
}
```

### Integrating with Home Manager

Integrating with [Home Manager](https://github.com/rycee/home-manager) can be done by adding your modules to the `imports` attribute.

```nix
# In your Home Manager configuration
{
  imports = [
    # Include modules from ang3lo-nur here
  ];
}
```

### Using the flake in a standalone Home Manager configuration

If you instead build your Home Manager configuration standalone, with
`home-manager.lib.homeManagerConfiguration`, add the ang3lo-nur overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ang3lo-nur = {
      url = "github:ang3lo-azevedo/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ang3lo-nur, ... }: {
    homeConfigurations.myUser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        # Adds the ang3lo-nur overlay to Home Manager's pkgs
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ ang3lo-nur.overlays.default ];
        })
      ];
    };
  };
}
```
