{
  config,
  pkgs,
  inputs,
  myvars,
  ...
}:
let
  # quickshell = inputs.quickshell;
  iiPython = pkgs.python312.withPackages (
    ps: with ps; [
      build
      certifi
      cffi
      charset-normalizer
      click
      cryptography
      dbus-python
      google-auth
      idna
      kde-material-you-colors
      libsass
      loguru
      material-color-utilities
      materialyoucolor
      numpy
      opencv4
      packaging
      pillow
      psutil
      pyasn1
      pyasn1-modules
      pycairo
      pycparser
      pygobject3
      pyproject-hooks
      pywayland
      requests
      setproctitle
      setuptools
      setuptools-scm
      tqdm
      urllib3
      wheel
    ]
  );
  activate = pkgs.writeText "illogical-impulse-venv-activate" ''
    export ILLOGICAL_IMPULSE_VIRTUAL_ENV="''${ILLOGICAL_IMPULSE_VIRTUAL_ENV:-$HOME/.local/state/quickshell/.venv}"
    export VIRTUAL_ENV="$ILLOGICAL_IMPULSE_VIRTUAL_ENV"


    case ":$PATH:" in
    *":$VIRTUAL_ENV/bin:"*) ;;
    *) export PATH="$VIRTUAL_ENV/bin:$PATH" ;;
    esac

    export PYTHONNOUSERSITE=1
    export PYTHONDONTWRITEBYTECODE=1
  '';

  pythonWrapper = pkgs.writeShellScript "ii-python-wrapper" ''
    exec ${iiPython}/bin/python "$@"
  '';
  python3Wrapper = pkgs.writeShellScript "ii-python3-wrapper" ''
    exec ${iiPython}/bin/python3 "$@"
  '';
  venvCompat = pkgs.runCommandNoCC "illogical-impulse-venv-compat" { } ''
    mkdir -p "$out/bin"

    # expose all console scripts from the Nix Python env
    for f in ${iiPython}/bin/*; do
      ln -s "$f" "$out/bin/$(basename "$f")"
    done

    # override python/python3 with wrappers
    ln -sf ${pythonWrapper} "$out/bin/python"
    ln -sf ${python3Wrapper} "$out/bin/python3"

    ln -sf ${activate} "$out/bin/activate"
  '';
in
{
  home.file.".local/state/quickshell/.venv".source = venvCompat;

  home.packages = [
    # iiPython

    (pkgs.writeShellScriptBin "ii-python" ''
      exec ${iiPython}/bin/python "$@"
    '')
  ];
}
