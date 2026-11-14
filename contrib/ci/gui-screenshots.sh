#!/usr/bin/env bash
# Takes screenshots of the LiteDoge GUI wallet on a virtual display (used by
# CI, so GUI changes can be checked without a desktop).
#
# Usage: contrib/ci/gui-screenshots.sh <path to litedoge-qt> <output directory> [width]x[height]
# Needs: Xvfb, xdotool, ImageMagick (import)
#
# Uses a throwaway data directory with networking off, so no real wallet or
# chain data is involved.
set -u

BIN="$(readlink -f "$1")"
mkdir -p "$2"
OUT="$(cd "$2" && pwd)"
SIZE="${3:-1280x900}"
DATA="$(mktemp -d)"
cat > "$DATA/litedoge.conf" <<EOF
listen=0
dnsseed=0
connect=0
upnp=0
EOF
rm -f "$HOME/.config/LiteDoge/LiteDoge-Qt.conf"

Xvfb :99 -screen 0 "${SIZE}x24" >/dev/null 2>&1 &
XVFB=$!
export DISPLAY=:99
sleep 2

"$BIN" -datadir="$DATA" -splash=0 -choosedatadir=0 > "$OUT/litedoge-qt.log" 2>&1 &
APP=$!

cleanup() {
    kill "$APP" 2>/dev/null; sleep 5; kill -9 "$APP" 2>/dev/null
    kill "$XVFB" 2>/dev/null
}

WID=""
for _ in $(seq 1 90); do
    WID="$(xdotool search --onlyvisible --name 'LiteDoge' 2>/dev/null | head -n1)"
    [ -n "$WID" ] && break
    if ! kill -0 "$APP" 2>/dev/null; then echo "The wallet exited"; break; fi
    sleep 2
done
if [ -z "$WID" ]; then
    echo "The wallet window did not appear"
    import -window root "$OUT/00-screen.png"
    cat "$OUT/litedoge-qt.log"; tail -n 50 "$DATA/debug.log" 2>/dev/null
    cleanup
    exit 1
fi
sleep 8
echo "Window: $(xdotool getwindowname "$WID") $(xdotool getwindowgeometry "$WID" | tr '\n' ' ')"

focus() { xdotool windowfocus --sync "$WID" 2>/dev/null || true; }
shot()  { sleep 2; import -window "$1" "$OUT/$2.png" && echo "saved $2.png"; }

names=(overview receive send transactions addressbook chat)
for n in 1 2 3 4 5 6; do
    focus
    xdotool key "alt+$n"
    shot "$WID" "$(printf '%02d' "$n")-${names[$((n-1))]}"
done

dialog() {
    local title="$1" file="$2"; shift 2
    focus
    for k in "$@"; do xdotool key "$k"; sleep 0.7; done
    sleep 2
    local d
    d="$(xdotool search --onlyvisible --name "$title" 2>/dev/null | head -n1)"
    if [ -n "$d" ]; then
        shot "$d" "$file"
    else
        echo "Window '$title' not found"
        import -window root "$OUT/$file-screen.png"
    fi
    xdotool key Escape
    sleep 1
}
dialog '^Options'        10-options alt+s o
dialog 'Debug window'    12-debug   alt+h d
dialog '^About LiteDoge' 13-about   alt+h a

# Whole screen once more, then the window shrunk to its minimum size
import -window root "$OUT/20-screen.png"
xdotool windowsize "$WID" 400 300; sleep 3
shot "$WID" "21-small-window"

cleanup
echo "--- debug.log (last lines) ---"; tail -n 30 "$DATA/debug.log" 2>/dev/null

if [ "${PRINT_SCREENSHOTS_BASE64:-0}" = 1 ]; then
    for f in "$OUT"/*.png; do
        echo "=== BEGIN SCREENSHOT $(basename "$f") ==="
        base64 -w 1000 "$f"
        echo "=== END SCREENSHOT ==="
    done
fi
exit 0
