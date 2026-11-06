# Fixed paths are supplied by the Nix wrapper, not the caller's environment.
selected="$NORMAL_CONFIG"
request="$DESKTOP_LOGIN_STATE_DIR/request"

if [[ -f "$request" ]]; then
  deadline=$(cat "$request" || true)
  # Consume before starting greetd, including malformed or expired requests.
  rm -f "$request"

  # Boot-relative time prevents wall-clock adjustments reviving old requests.
  if read -r uptime _ < "$DESKTOP_LOGIN_UPTIME_FILE"; then
    now="${uptime%%.*}"
    if [[ "$deadline" =~ ^[0-9]{1,10}$ && "$now" =~ ^[0-9]{1,10}$ ]] &&
       (( 10#$now < 10#$deadline && 10#$deadline <= 10#$now + 15 )); then
      rm -f "$DESKTOP_LOGIN_STATE_DIR/used"
      selected="$REMOTE_CONFIG"
    fi
  fi
fi

exec "$GREETD" --config "$selected"
