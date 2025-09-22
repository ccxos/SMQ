#Thx!
set -e

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python3 not found. Please install python3 and try again."
  exit 1
fi

INSTALL_DIR="$PWD"
cd "$INSTALL_DIR" || exit 1

echo "Checking required python modules..."
python3 -c 'import importlib,subprocess,sys
pkgs=["requests"]
for p in pkgs:
    try:
        importlib.import_module(p)
    except ImportError:
        subprocess.check_call([sys.executable,"-m","pip","install",p])
' || { echo "Failed installing python packages (you can manually run : python3 -m pip install requests)"; }

PYFILE=""

PYFILE=$(mktemp /tmp/SMQ.XXXXXX.py 2>/dev/null) || :

if [ -z "$PYFILE" ] && [ -n "$TMPDIR" ]; then
  PYFILE=$(mktemp "$TMPDIR/SMQ.XXXXXX.py" 2>/dev/null) || :
fi

if [ -z "$PYFILE" ] && [ -n "$HOME" ]; then
  PYFILE=$(mktemp "$HOME/SMQ.XXXXXX.py" 2>/dev/null) || :
fi

if [ -z "$PYFILE" ]; then
  PYFILE=$(mktemp "$INSTALL_DIR/SMQ.XXXXXX.py" 2>/dev/null) || :
fi

if [ -z "$PYFILE" ] && command -v python3 >/dev/null 2>&1; then
  PYFILE=$(python3 - <<'PY'
import tempfile, sys
try:
    f = tempfile.NamedTemporaryFile(suffix=".py", delete=False)
    print(f.name)
    f.close()
except Exception:
    sys.exit(1)
PY
) || PYFILE=""
fi

if [ -z "$PYFILE" ]; then
  PYFILE="$INSTALL_DIR/SMQ_embedded.py"
fi

tdir=$(dirname "$PYFILE")
if [ ! -d "$tdir" ]; then
  mkdir -p "$tdir" 2>/dev/null || true
fi
if [ ! -w "$tdir" ]; then
  echo "Warning: cannot write to $tdir — trying current directory"
  PYFILE="./SMQ_embedded.py"
fi

trap 'rm -f "$PYFILE"' EXIT

cat > "$PYFILE" <<'PYCODE'

import requests
import time
import sys
import SMQ_Z
import SMQ_A

CYAN = "\033[1;36m"
GREEN = "\033[1;32m"
DARK_RED = "\033[0;31m"
MAGENTA = "\033[1;35m"
YELLOW = "\033[1;33m"
RED = "\033[1;31m"
MAUVE = "\033[38;5;141m"
RESET = "\033[0m"

def typing_print(text, color=DARK_RED, char_delay=0.06):
    sys.stdout.write(color)
    sys.stdout.flush()
    for ch in text:
        sys.stdout.write(ch)
        sys.stdout.flush()
        time.sleep(char_delay)
    sys.stdout.write(RESET + "\n")
    sys.stdout.flush()

def sema():
    time.sleep(1.9)
    typing_print(CYAN + "--- Choose an option ---" + RESET)
    print()
    while True:
        print(MAUVE + "[1] ~ Zain Iraq" + RESET)
        print()
        print(RED + "[2] ~ Asiacell" + RESET)
        print()
        choice = input(CYAN + ": " + RESET).strip()
        print()

        if choice == "1":
            SMQ_Z.smqz()
            break
        elif choice == "2":
            SMQ_A.smqa()
            break
        else:
            print(DARK_RED + "Invalid Choice !" + RESET)
            print()
            time.sleep(1.5)
            continue

if __name__ == "__main__":
    sema()

PYCODE

PYTHONPATH="$INSTALL_DIR:$PYTHONPATH"
python3 "$PYFILE" "$@"
EXIT_CODE=$?

rm -f "$PYFILE"

exit $EXIT_CODE