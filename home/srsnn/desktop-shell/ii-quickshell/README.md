# ii-quickshell

based on: [illogical-flake](github.com/soymou/illogical-flake)

## usage

import this in home.nix and enable illogical-impulse
```nix
  programs.illogical-impulse = {
    enable = true;
    # Customize shell tools (all enabled by default)
    dotfiles = {
      fish.enable = true; # Fish shell with custom config
      kitty.enable = false; # Kitty terminal emulator
      starship.enable = true; # Starship prompt
    };
  };
```