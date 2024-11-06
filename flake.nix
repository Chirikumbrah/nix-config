{
    description = "Dyrwin system flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        nix-darwin.url = "github:LnL7/nix-darwin";
        nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
        home-manager.url = "github:nix-community/home-manager/master";

        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = inputs@{ self, nix-darwin, nix-homebrew, nixpkgs, home-manager }:
        let
            configuration = { pkgs, config, ... }: {

                # List packages installed in system profile. To search by name, run:
                # $ nix-env -qaP | grep wget
                environment = {
                    pathsToLink = [ "/share/bash-completion" ];
                    shells = [ pkgs.bashInteractive ];
                    systemPackages = with pkgs; [
                        aerospace ansible ansible-language-server ansible-lint argocd
                        clipboard-jh ctags
                        fastfetch figlet
                        delta
                        gnutls
                        kubernetes-helm
                        helm-ls home-manager
                        jq
                        k9s kubectl
                        libmtp
                        mas marksman mdcat mkalias
                        ncdu neovim
                        prettierd pyright
                        reattach-to-user-namespace
                        rename
                        ripgrep
                        inetutils
                        tmux tree
                        watch wget
                        yaml-language-server yq
                        zoxide
                    ];
                };
                homebrew = {
                    enable = true;

                    brews = [
                        "bash-completion@2"
                    ];

                    casks = [
                        "alacritty"
                        "chatgpt"
                        "brave-browser"
                        "middleclick"
                        "notion"
                        "the-unarchiver"
                    ];
                    onActivation.cleanup = "zap";
                    masApps = {
                        "Bitwarden" = 1352778147;
                        "GarageBand" = 682658836;
                        "Metronome" = 1629209971;
                        "Microsoft Remote Desktop" = 1295203466;
                        "Simplenote" = 692867256;
                        "Telegram" = 747648890;
                        "Universal Tuner" = 1593998190;
                        "WireGuard" = 1451685025;
                    };
                };

                fonts.packages = [
                    (pkgs.nerdfonts.override { fonts = ["UbuntuMono"]; })
                ];

                system = {
                    activationScripts.applications.text = let
                        env = pkgs.buildEnv {
                            name = "system-applications";
                            paths = config.environment.systemPackages;
                            pathsToLink = "/Applications";
                        };
                    in
                        pkgs.lib.mkForce ''
                            # Set up applications.
                            echo "setting up /Applications..." >&2
                            rm -rf /Applications/Nix\ Apps
                            mkdir -p /Applications/Nix\ Apps
                            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
                            while read src; do
                            app_name=$(basename "$src")
                            echo "copying $src" >&2
                            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
                            done
                        '';

                    # Set Git commit hash for darwin-version.
                    configurationRevision = self.rev or self.dirtyRev or null;

                    # Used for backwards compatibility, please read the changelog before changing.
                    # $ darwin-rebuild changelog
                    stateVersion = 5;
                    keyboard = {
                        enableKeyMapping = true;
                    };
                    defaults = {
                        # minimal dock
                        dock = {
                            autohide = true;
                            autohide-delay = 0.2;
                            orientation = "left";
                            tilesize = 59;
                            largesize = 92;
                            show-process-indicators = false;
                            show-recents = false;
                            static-only = true;
                        };
                        # a finder that tells me what I want to know and lets me work
                        finder = {
                            AppleShowAllExtensions = true;
                            ShowPathbar = true;
                            FXPreferredViewStyle = "clmv";
                            FXEnableExtensionChangeWarning = false;
                            _FXShowPosixPathInTitle = true;

                        };
                        # Tab between form controls and F-row that behaves as F1-F12
                        NSGlobalDomain = {
                            KeyRepeat = 2;
                            InitialKeyRepeat = 15;
                            AppleShowAllExtensions = true;
                            AppleInterfaceStyle = "Dark";
                            "com.apple.trackpad.scaling" = 2.1;
                            "com.apple.keyboard.fnState" = false;
                        };
                    };
                };
                # Auto upgrade nix package and the daemon service.
                services.nix-daemon.enable = true;
                # nix.package = pkgs.nix;

                # Necessary for using flakes on this system.
                nix.settings.experimental-features = "nix-command flakes";

                # The platform the configuration will be used on.
                nixpkgs = {
                    config.allowUnfree = true;
                    hostPlatform = "aarch64-darwin";
                };
            };
        in
            {
            # Build darwin flake using:
            # $ darwin-rebuild build --flake .#yrMac
            darwinConfigurations."yrMac" = nix-darwin.lib.darwinSystem {
                modules = [
                    configuration
                    nix-homebrew.darwinModules.nix-homebrew
                    {
                        nix-homebrew = {
                            enable = true;
                            enableRosetta = true;
                            user = "yr";
                        };
                    }
                    home-manager.darwinModules.home-manager
                    {
                        home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.yr = import ./home.nix;
                    };
                    users.users.yr.home = "/Users/yr";
                    }
                ];
            };

            # Expose the package set, including overlays, for convenience.
            darwinPackages = self.darwinConfigurations."yrMac".pkgs;
        };
}
