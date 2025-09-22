#Thx!

set -e

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python3 not found. Please install python3 and try again."
  exit 1
fi

INSTALL_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

cd "$INSTALL_DIR" || exit 1

echo "Checking required python modules..."
python3 -c 'import importlib,subprocess,sys
pkgs=["requests"]
for p in pkgs:
    try:
        importlib.import_module(p)
    except ImportError:
        subprocess.check_call([sys.executable,"-m","pip","install","--user",p])
' || { echo "Failed installing python packages (you can manually run : python3 -m pip install requests)"; }


mkdir -p "$HOME/tmp" >/dev/null 2>&1 || true


PYFILE=""
PYFILE=$(mktemp "$HOME/tmp/SMQ.XXXXXX.py" 2>/dev/null) || PYFILE=""

if [ -z "$PYFILE" ]; then
  
  PYFILE=$(python3 - <<'PY'
import tempfile,sys
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

trap 'rm -f "$PYFILE" 2>/dev/null || true' EXIT

echo "Using temporary python file: $PYFILE"

cat > "$PYFILE" <<'PYCODE'
# -*- coding: utf-8 -*-
#Thx!
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

def clear():
    try:
        sys.stdout.write("\033[3J\033[H\033[2J")
        sys.stdout.flush()
    except Exception:
        pass
    os.system("cls" if os.name == "nt" else "clear")

def sema():
    clear()
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


PYTHONPATH="$INSTALL_DIR:${PYTHONPATH:-}" python3 "$PYFILE" "$@"
EXIT_CODE=$?

exit $EXIT_CODE
