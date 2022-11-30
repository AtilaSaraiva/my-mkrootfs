{ writeShellScriptBin, jq, mpv, procps, sway, swaylock, spotify-unwrapped, swaynotificationcenter }:
# In sway, this is my "screensaver", it's transparent swaylock, with mpv running GIFs behind it.
# A different MPV is launched per-display.
writeShellScriptBin "my-wscreensaver" ''
  JQ="${jq}/bin/jq"
  MPV="${mpv}/bin/mpv"
  PIDOF="${procps}/bin/pidof"
  SWAYMSG="${sway}/bin/swaymsg"
  SWAYLOCK="${swaylock}/bin/swaylock"
  SWAYNC="${swaynotificationcenter}/bin/swaync-client"

  _HAS_MUSIC=$("$PIDOF" ${spotify-unwrapped}/share/spotify/.spotify-wrapped)

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

  _DND_MINE=""
  [[ "$("$SWAYNC" -D)" == "false" ]] && "$SWAYNC" -dn && _DND_MINE=1
  for _OUTPUT in $("$SWAYMSG" -t get_outputs -r | "$JQ" -r .[].name); do
    wallpaper "$_OUTPUT" 'horizontal.txt'
  done

  "$SWAYLOCK" -c 00000000
  kill "''${_PIDS[@]}"
  if [[ "x$_DND_MINE" != "x" ]] || [[ "x$1" == "x--first-run" ]]; then
    "$SWAYNC" -df
  fi
''
