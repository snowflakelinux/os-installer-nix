{ lib ? <nixpkgs/lib>
, pkgs ? <nixpkgs>
, python3 ? pkgs.python3
, vte-gtk4
, os-installer-src
, os-installer-config ? null
}:

python3.pkgs.buildPythonApplication rec {

  pname = "os-installer";
  version = "git";
  format = "other";

  src = os-installer-src;

  nativeBuildInputs = with pkgs; [
    blueprint-compiler
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook4
  ];

  buildInputs = with pkgs; [
    appstream
    cryptsetup
    desktop-file-utils
    e2fsprogs
    epiphany
    glib
    gnome-desktop
    gnome.gnome-control-center
    gnome.gnome-disk-utility
    gtk4
    libadwaita
    libgweather
    libxml2
    udisks
    vte-gtk4
    os-installer-config
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
    pyyaml
  ];

  strictDeps = false;

  postPatch = ''
    substituteInPlace data/com.github.p3732.OS-Installer.desktop.in \
      --replace "Name=OS-Installer" "Name=Install SnowflakeOS"
    substituteInPlace data/com.github.p3732.OS-Installer.desktop.in \
      --replace "Comment=Install an Operating System" "Comment=Install the SnowflakeOS Operating System"
    substituteInPlace meson.build \
      --replace "meson.add_install_script('.build_files/postinstall.py')" ""
    substituteInPlace src/util/system_calls.py \
      --replace "    _exec(['localectl', '--no-ask-password', 'set-locale', 'LANG=en_US.UTF-8'])" ""
    substituteInPlace src/util/system_calls.py \
      --replace "    _exec(['timedatectl', '--no-ask-password', 'set-timezone', timezone])" ""
    substituteInPlace src/util/system_calls.py \
      --replace "    _exec(['timedatectl', '--no-ask-password', 'set-ntp', 'true'])" ""
  '' + lib.optionalString (os-installer-config != null) ''
    substituteInPlace src/config.py \
      --replace "/etc/os-installer/config.yaml" "${os-installer-config}/etc/os-installer/config.yaml"
    substituteInPlace src/util/installation_scripting.py \
      --replace "/etc/os-installer/scripts/" "${os-installer-config}/etc/os-installer/scripts/"
  '';

  postInstall = ''
    wrapProgram $out/bin/os-installer --prefix PATH : '${lib.makeBinPath [ pkgs.gptfdisk pkgs.pciutils ]}'
  '';
}
