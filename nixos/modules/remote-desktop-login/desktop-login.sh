# Fixed paths are supplied by the Nix wrapper, not the caller's environment.
if (( $# != 0 )); then
  echo "Usage: sudo desktop-login" >&2
  exit 1
fi

if [[ $(id -u) != 0 ]]; then
  echo "Run this using sudo." >&2
  exit 1
fi

umask 077
install -d -m 0700 "$DESKTOP_LOGIN_STATE_DIR"
exec 9>"$DESKTOP_LOGIN_STATE_DIR/lock"
if ! flock -n 9; then
  echo "Another desktop-login request is running." >&2
  exit 1
fi

if ! sessions=$(loginctl list-sessions --no-legend --no-pager); then
  echo "Cannot enumerate sessions; refusing to restart greetd." >&2
  exit 1
fi

while read -r session _; do
  [[ -n "$session" ]] || continue
  if ! session_type=$(loginctl show-session "$session" --property=Type --value); then
    echo "Cannot inspect session $session; refusing to restart greetd." >&2
    exit 1
  fi
  case "$session_type" in
    wayland|x11)
      echo "A graphical session already exists; refusing to restart greetd." >&2
      exit 1
      ;;
    tty|unspecified) ;;
    *)
      echo "Unknown type for session $session; refusing to restart greetd." >&2
      exit 1
      ;;
  esac
done <<< "$sessions"

read -r uptime _ < "$DESKTOP_LOGIN_UPTIME_FILE"
now="${uptime%%.*}"
if [[ ! "$now" =~ ^[0-9]{1,10}$ ]]; then
  echo "Cannot determine request expiry." >&2
  exit 1
fi

request="$DESKTOP_LOGIN_STATE_DIR/request"
trap 'rm -f "$DESKTOP_LOGIN_STATE_DIR/request.tmp"' EXIT
trap 'rm -f "$request"; exit 1' HUP INT TERM

# Publish atomically so a concurrent greetd start never reads a partial request.
printf '%s\n' "$(( 10#$now + 15 ))" > "$DESKTOP_LOGIN_STATE_DIR/request.tmp"
mv -f "$DESKTOP_LOGIN_STATE_DIR/request.tmp" "$request"

if ! systemctl restart greetd.service; then
  rm -f "$request"
  echo "Failed to restart greetd." >&2
  exit 1
fi

echo "Login requested. Check greetd/Sunshine if streaming is unavailable."
