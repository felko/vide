{ stdenv
, lib
, writeShellScript
, makeWrapper

, config
, programs
, components
}:

stdenv.mkDerivation rec {
  pname = "vide";
  version = "0.1.0";

  src = writeShellScript "vide" ''
    export KAKOUNE_CONFIG_DIR="${config.kakoune}"
    export LG_CONFIG_FILE="${config.lazygit}/config.yml"
    export YAZI_CONFIG_HOME="${config.yazi}"
    session_name=`${components.sessionNameGenerator}`
    export KKS_SESSION="$session_name"
    export KKS_CLIENT="main"
    export EDITOR="${components.editorOpen}"
    case `${programs.zellij} list-sessions --no-formatting --short` in
        *"$session_name"*)
            session_args="attach $session_name";;
        *)
            session_args="--session $session_name";;
    esac
    cmd="${programs.zellij} --config-dir ${config.zellij} $session_args; ${programs.zellij} kill-session $session_name; ${programs.kak} -clear"
    title="vide [$session_name]"
    if [ -t 0 ]; then
        eval "$cmd"
        if [ -n "$ALACRITTY_WINDOW_ID" ]; then
            ${programs.alacritty} msg config --window-id $ALACRITTY_WINDOW_ID window.title="$title"
        fi
    else
        ${programs.alacritty} --title "$title" --working-dir /home/joseph/code/vide --command $SHELL -c "$cmd"
    fi
  '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase =
    lib.optionalString stdenv.isDarwin ''
      install -Dm755 "$src" "$out/bin/${pname}"

      install -Dm644 ${../Info.plist} $out/Applications/${pname}.app/Contents/Info.plist
      install -Dm755 $src $out/Applications/${pname}.app/Contents/MacOS/vide
      install -Dm644 ${../icon/icon.icns} $out/Applications/${pname}.app/Contents/Resources/vide.icns
    '';      

  meta = with lib; {
    description = "A IDE made out of UNIX programs";
    homepage = "https://github.com/felko/vide";
    mainProgram = "vide";
    platforms = platforms.unix;
  };
}

