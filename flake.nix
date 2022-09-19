{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    vte-src = {
      url = "git+https://gitlab.gnome.org/gnome/vte?ref=master";
      flake = false;
    };
    os-installer-src = {
      url = "git+https://gitlab.gnome.org/p3732/os-installer";
      flake = false;
    };
    os-installer-snowflake-config.url = "path:/home/victor/Documents/snowflake/os-installer-snowflake-config";
  };

  outputs = { self, nixpkgs, utils, vte-src, os-installer-src, os-installer-snowflake-config }@inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        libadwaita-git = pkgs.libadwaita.overrideAttrs (oldAttrs: rec {
          version = "1.2.rc";
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner = "GNOME";
            repo = "libadwaita";
            rev = version;
            hash = "sha256-p7nsaAqrzQKeUiu7aGlgoKu0AH9KV/sMsVcLLpgl4Lo=";
          };
        });
        vte-gtk4 = pkgs.callPackage ./vte-gtk4.nix {
          inherit (inputs) vte-src;
        };
        os-installer-snowflake-config-pkg = pkgs.callPackage os-installer-snowflake-config {
          inherit (inputs);
        };
        name = "os-installer";
      in
      rec
      {

        

        packages.${name} = pkgs.callPackage ./default.nix {
         inherit (inputs) os-installer-src;
         vte-gtk4 = vte-gtk4;
         os-installer-snowflake-config = os-installer-snowflake-config-pkg;
        };

        # `nix build`
        defaultPackage = packages.${name};

        # `nix run`
        #apps.${name} = utils.lib.mkApp {
        #  inherit name;
        #  drv = packages.${name};
        #};
        #defaultApp = packages.${name};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            python310Packages.pyaml
            python310Packages.pygobject3
            gnome-desktop
            libxml2
            vte-gtk4
            desktop-file-utils
            cairo
            gdk-pixbuf
            gobject-introspection
            graphene
            gtk4
            gtksourceview5
            libadwaita-git
            meson
            ninja
            openssl
            pandoc
            pango
            pkgconfig
            polkit
            libgweather
            wrapGAppsHook4
          ];
        };
      });
}
