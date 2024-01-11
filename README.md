vide
====

A nix-powered IDE assembled from individual components, namely:
- [kakoune](https://kakoune.org/)
- [fzf](https://github.com/junegunn/fzf)
- [broot](https://dystroy.org/broot/)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [zellij](https://zellij.dev/)

## Motivation

Thanks to Nix flakes, one can directly invoke `nix run github:felko/vide` from any computer with Nix installed with flake and nix-command experimental features.
The IDE will run and leave no trace after garbage collection.
The configuration is completely standalone which means you will get the exact same interface regardless of any potential XDG configurations.

## Intended workflow

The IDE is very opinionated so feel free to fork and replace with your favorite tools.

## Installation

While the primary purpose is to be able to run the IDE by URL as shown above, it's also possible to

### NixOS/nix-darwin

```
{
  inputs = {
    ...

    vide.url = "github:felko/vide";
  };

  outputs = inputs @ { self, ... }: {
    # nixosConfigurations.myconfig = nixos.lib.nixosSystem rec {
    #   system = "aarch64-darwin";
    # or
    darwinConfigurations.myconfig = nix-darwin.lib.darwinSystem rec {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = {
        inherit inputs;
      };
    };
  };
}
```

```
{ pkgs, inputs, system, ... }:

{
  environment.systemPackages = [
    inputs.vide.packages.${system}.vide
  ];
}
```

### Home-manager


```
{
  inputs = {
    ...

    vide.url = "github:felko/vide";
  };

  outputs = { nixpkgs, ... } @ inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.joseph = home-manager.lib.homeManagerConfiguration {
        ...
        extraSpecialArgs = {
          inherit inputs system;
        };
      };
    };
}
```

```
{ pkgs, inputs, system, ... }:

{
  home.packages = [
    inputs.vide.packages.${system}.vide
  ];
}
```

### Profile installation

```nix
nix profile install github:felko/vide
```

