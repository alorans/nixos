{
  description = "NixOS configuration with Niri compositor and Emacs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: 
    let
      settings = import ./settings.nix;
    in {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({ pkgs, ... }: {
            # Enable flakes explicitly
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            # Boot loader configuration
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;

            # Networking
            networking.hostName = settings.hostname;
            networking.networkmanager.enable = true;

            # Localization
            time.timeZone = settings.timezone;
            i18n.defaultLocale = settings.locale;
            console = {
              font = settings.consoleFont;
              keyMap = settings.consoleKeyMap;
            };

            # Touchpad support
            services.libinput.enable = true;

            # Enable Niri
            programs.niri.enable = true;

            # Essential system services for Wayland
            services.greetd = {
              enable = true;
              settings = {
                default_session = {
                  command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
                  user = "greeter";
                };
              };
            };

            # Enable sound
            security.rtkit.enable = true;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              pulse.enable = true;
            };

            # Graphics and hardware acceleration
            hardware.graphics.enable = true;

            # Essential packages for Niri desktop environment
            environment.systemPackages = with pkgs; [
              # Editor
              emacs

              # Development tools
              git
              tree
              curl
              vim
              htop
              ripgrep
              fd
              zip
              unzip

              # Terminal emulator
              foot
              
              # Application launcher
              fuzzel
              
              # Notifications
              mako
              
              # Status bar (alternative to waybar)
              waybar
              
              # Clipboard manager
              wl-clipboard
              
              # File manager
              xfce.thunar
              
              # Browser (recommended)
              firefox
              
              # Wayland utilities
              wlr-randr
              wayland-utils
              
              # Display configuration
              wdisplays
              
              # Screen sharing support
              xdg-desktop-portal
              xdg-desktop-portal-gtk
            ];

            # XDG portal configuration for screen sharing
            xdg.portal = {
              enable = true;
              wlr.enable = true;
              extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
            };

            # Enable dbus (required for many desktop applications)
            services.dbus.enable = true;

            # Fonts configuration
            fonts.packages = with pkgs; [
              noto-fonts
              noto-fonts-emoji
              liberation_ttf
              fira-code
              fira-code-symbols
            ];

            # User configuration
            users.users.${settings.username} = {
              isNormalUser = true;
              initialPassword = "changeme";
              extraGroups = [ "wheel" "video" "audio" ];
            };

            # Basic system configuration
            system.stateVersion = "25.11";
          })
        ];
      };
    };
}
