#terry..
import os
import sys
import time
import threading
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
import tty
import termios

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

TARGET_URL = "https://mw-mobileapp.iq.zain.com/api/otp/request"
REQUEST_TIMEOUT = 10

def clear():
    try:
        sys.stdout.write("\033[3J\033[H\033[2J")
        sys.stdout.flush()
    except Exception:
        pass
    os.system("cls" if os.name == "nt" else "clear")

def typing_print(text, color=DARK_RED, char_delay=0.06):
    sys.stdout.write(color)
    sys.stdout.flush()
    for ch in text:
        sys.stdout.write(ch)
        sys.stdout.flush()
        time.sleep(char_delay)
    sys.stdout.write(RESET + "\n")
    sys.stdout.flush()

def getch():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
    return ch

def smqa():
    while True:
        clear()
        time.sleep(1.9)
        print(MAGENTA + acsrt + RESET)
        print()
        print()
        time.sleep(0.12)
        typing_print(YELLOW + f"Sorry, This tool {DARK_RED}Not {YELLOW}Exists" + RESET)
        print()
        print()
        time.sleep(0.12)
        print(DARK_RED + "[ CTRL + C to Exit ]" + RESET)
        print()
        
        while True:
            key = getch()
            if key == "\x03":
                
                return

if __name__ == "__main__":
    smqa()
