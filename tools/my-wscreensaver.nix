pkgs: pkgs.writeShellScriptBin "my-wscreensaver" ''
  JQ="${pkgs.jq}/bin/jq"
  MPV="${pkgs.mpv}/bin/mpv"
  PIDOF="${pkgs.procps}/bin/pidof"
  SWAYMSG="${pkgs.sway}/bin/swaymsg"
  SWAYLOCK="${pkgs.swaylock}/bin/swaylock"

  _HAS_MUSIC=$("$PIDOF" spotify)

  cd ~/Videos
  _PIDS=()
  function wallpaper() {
      local _TARGET="$1"
      [[ $_HAS_MUSIC ]] && _MEDIA='with-music.txt' \
          || _MEDIA="$2"
      [[ -z "$("$SWAYMSG" -t get_outputs | grep -Po \"$_TARGET\")" ]] && return
      echo "Showing for $_TARGET"
      "$MPV" --quiet --title="WScreenSaver@$_TARGET" --ao=none \
          --shuffle --loop-file=inf --scale=oversample \
          --playlist="$HOME/Videos/$_MEDIA" &
      _PIDS+=($!)
  }

  for _OUTPUT in $("$SWAYMSG" -t get_outputs -r | "$JQ" -r .[].name); do
    wallpaper "$_OUTPUT" 'horizontal.txt'
  done

  "$SWAYLOCK" -c 00000000
  kill "''${_PIDS[@]}"
''