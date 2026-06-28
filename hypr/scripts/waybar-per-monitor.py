#!/usr/bin/env python3
"""Per-monitor Waybar control.

While the external monitor (HDMI-A-1) is connected, show Waybar ONLY on it
(laptop bar hidden). When it is disconnected, show Waybar on whatever is left
(the laptop).

Two triggers keep this correct:
  1. Hyprland monitor hotplug events (.socket2 stream)  -> plug/unplug.
  2. config.jsonc modification watch (mtime poll)        -> Waybar layout
     switches (Mod+Alt+Up/Down) regenerate config.jsonc with output ["*"],
     so we re-apply right after.

Only the "output" key is touched here; the ws-11 hide lives in the Waybar
*include* module files (hyprland-workspaces*.jsonc), which survive layout
switches on their own.
"""
import json
import os
import re
import socket
import subprocess
import sys
import threading
import time

CONFIG = os.path.expanduser("~/.config/waybar/config.jsonc")
LAPTOP = "eDP-1"
EXTERNAL = "HDMI-A-1"


def connected_monitors():
    try:
        out = subprocess.run(
            ["hyprctl", "monitors", "-j"], capture_output=True, text=True
        ).stdout
        return [m["name"] for m in json.loads(out)]
    except Exception as e:
        print(f"[waybar-per-monitor] monitor query failed: {e}", file=sys.stderr)
        return []


def desired_output():
    return [EXTERNAL] if EXTERNAL in connected_monitors() else ["*"]


def load_jsonc(text):
    """Parse JSON-with-comments: strip // and /* */ (respecting strings) and
    trailing commas. Some Waybar layouts ship config.jsonc with comments."""
    out = []
    i, n, in_str, esc = 0, len(text), False, False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            out.append(c)
            i += 1
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "/":
            while i < n and text[i] != "\n":
                i += 1
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "*":
            i += 2
            while i + 1 < n and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
            continue
        out.append(c)
        i += 1
    stripped = re.sub(r",(\s*[}\]])", r"\1", "".join(out))
    return json.loads(stripped)


def apply():
    value = desired_output()
    try:
        with open(CONFIG) as f:
            cfg = load_jsonc(f.read())
    except Exception as e:
        # genuinely unparseable -> bail without damaging the file
        print(f"[waybar-per-monitor] cannot parse config.jsonc: {e}", file=sys.stderr)
        return
    if cfg.get("output") == value:
        return  # already correct, no write / no reload
    cfg["output"] = value
    tmp = CONFIG + ".tmp"
    with open(tmp, "w") as f:
        json.dump(cfg, f, indent=4)
    os.replace(tmp, CONFIG)
    reload_waybar()
    print(f"[waybar-per-monitor] output -> {value}")


def reload_waybar():
    """Fully restart Waybar. A SIGUSR2 reload does NOT recreate bars on an
    output that was previously excluded, so an output change needs a restart.
    HyDE runs Waybar as transient unit hyde-<desktop>-bar.service."""
    desktop = os.environ.get("XDG_SESSION_DESKTOP", "unknown")
    unit = f"hyde-{desktop}-bar.service"
    r = subprocess.run(
        ["systemctl", "--user", "restart", unit],
        stderr=subprocess.DEVNULL,
    )
    if r.returncode != 0:
        # fallback if the unit name differs: hard restart the process
        subprocess.run(["killall", "waybar"], stderr=subprocess.DEVNULL)
        time.sleep(0.3)
        subprocess.Popen(
            ["waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )


def watch_config():
    """Re-apply when something else (HyDE layout switch) rewrites config.jsonc."""
    last = None
    while True:
        try:
            mtime = os.path.getmtime(CONFIG)
            if mtime != last:
                last = mtime
                time.sleep(0.2)  # let the writer finish
                apply()
        except FileNotFoundError:
            pass
        time.sleep(1)


def hypr_signature(rt):
    """Get Hyprland instance signature from env, or newest runtime dir."""
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if sig:
        return sig
    hypr_dir = os.path.join(rt, "hypr")
    dirs = [d for d in os.listdir(hypr_dir) if os.path.isdir(os.path.join(hypr_dir, d))]
    if not dirs:
        raise RuntimeError("no Hyprland instance found")
    return max(dirs, key=lambda d: os.path.getmtime(os.path.join(hypr_dir, d)))


def listen_monitors():
    rt = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    sig = hypr_signature(rt)
    path = f"{rt}/hypr/{sig}/.socket2.sock"
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(path)
    buf = ""
    while True:
        data = s.recv(4096).decode(errors="ignore")
        if not data:
            return  # socket closed; outer loop reconnects
        buf += data
        while "\n" in buf:
            line, buf = buf.split("\n", 1)
            event = line.split(">>", 1)[0]
            if event in (
                "monitoradded",
                "monitoraddedv2",
                "monitorremoved",
                "monitorremovedv2",
            ):
                time.sleep(0.3)  # let Hyprland settle
                apply()


def main():
    # line-buffer so log lines reach journald promptly (not a TTY under systemd)
    try:
        sys.stdout.reconfigure(line_buffering=True)
        sys.stderr.reconfigure(line_buffering=True)
    except Exception:
        pass
    apply()  # initial state
    threading.Thread(target=watch_config, daemon=True).start()
    while True:
        try:
            listen_monitors()
        except Exception as e:
            print(f"[waybar-per-monitor] listener error: {e}", file=sys.stderr)
        time.sleep(2)


if __name__ == "__main__":
    main()
